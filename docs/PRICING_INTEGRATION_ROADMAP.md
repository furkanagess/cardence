# Cardence Paketleri Uygulama Entegrasyon Roadmap'i

Bu dokuman Free, Premium ve Business paketlerinin mevcut Cardence kod tabanina nasil entegre edilecegini adim adim anlatir. Odak, mevcut Clean Architecture kurallarini bozmadan Flutter ve .NET backend tarafinda uygulanabilir bir yol haritasi cikarmaktir.

Ilgili dokumanlar:

- `docs/PRICING_PRODUCT_STRATEGY.md`
- `docs/PRICING_TECHNICAL_ARCHITECTURE.md`
- `backend/docs/dotnet-backend-api.md`
- `backend/docs/database-design.md`
- `docs/QR_CARD_WALLET_FLOW.md`

## 1. Mevcut Kod Haritasi

### 1.1 Flutter

Mevcut entegrasyon noktalarinin ozeti:

| Alan | Mevcut dosya/feature | Durum |
| --- | --- | --- |
| DI/init | `lib/core/init/app_init.dart` | Use case'ler elle baglaniyor. |
| Abonelik | `lib/features/subscriptions` | RevenueCat configure, identify, restore ve paywall mevcut. |
| Reklam | `lib/features/ads` | Post-add monetization akisi mevcut. |
| Saved cards | `lib/features/saved_cards` | Local + remote repository, wallet quota, paywall flow mevcut. |
| Event groups | `lib/features/event_groups` | Local + remote repository, create/link/delete akislari mevcut. |
| Business cards | `lib/features/business_cards` | Kart kaydetme/guncelleme backend'e bagli. |
| Profile stats | `lib/features/profile` | `GetProfileStats` use case mevcut. |
| UI shell | `lib/app.dart`, `features/shell` | Feature use case'leri App uzerinden sayfalara veriliyor. |

### 1.2 Backend

Mevcut endpointler:

| Alan | Endpoint | Not |
| --- | --- | --- |
| Business cards | `/BusinessCards`, `/BusinessCard`, `/SaveBusinessCard`, `/UpdateBusinessCard` | Kendi kartlari. |
| Public share | `/BusinessCardShare`, `/PublicBusinessCardShare` | QR/public payload. |
| Saved cards | `/SavedCards`, `/SaveSavedCard`, `/UpdateSavedCard`, `/DeleteSavedCard` | Cüzdan. |
| Wallet quota | `/WalletQuota`, `/UpgradeWalletPlan` | Temel entitlement. |
| Event groups | `/EventGroups`, `/SaveEventGroup`, `/LinkEventGroupCards`, `/EventGroupCards` | Bireysel gruplar. |
| Profile stats | `/ProfileStats` | Baslangic istatistik endpoint'i. |

Mevcut backend modeli, Premium icin baslangic seviyesinde yeterli; Business icin yeni organization domain'i gerekir.

## 2. Faz 1 - Plan Entitlement ve Limitleri Tek Kaynaga Alma

Hedef: Free/Premium ayrimini guvenilir hale getirmek, kart/event limitlerini client hard-code yerine backend policy'den almak.

### 2.1 Backend adimlari

1. `Cardence.Domain` altina plan enum veya constants ekle:

```text
Cardence.Domain/Plans/PlanTier.cs
Cardence.Domain/Plans/PlanFeature.cs
```

2. `WalletEntitlement` modelini genislet veya yeni `Subscription` modeli ekle:

```text
Cardence.Domain/Entities/Subscription.cs
Cardence.Infrastructure/Persistence/Configurations/SubscriptionConfiguration.cs
```

3. Application katmanina policy servisi ekle:

```text
Cardence.Application/Interfaces/IPlanPolicyService.cs
Cardence.Application/DTOs/Plans/PlanEntitlementsDto.cs
Cardence.Application/Services/PlanPolicyService.cs
```

4. API endpoint ekle:

```text
GET /PlanEntitlements
```

Response:

```json
{
  "tier": "free",
  "features": {
    "adsDisabled": false,
    "advancedDesigns": false,
    "profileStats": false,
    "csvExport": false,
    "networkGraph": false,
    "walletPass": false,
    "crmIntegration": false
  },
  "limits": {
    "maxBusinessCards": 2,
    "maxSavedCards": null,
    "maxEventGroups": 2,
    "maxTeamSeats": 1
  }
}
```

5. `BusinessCardService` icinde kart sayisi kontrolu ekle.
6. `EventGroupService` icinde event group sayisi kontrolu zorunlu yap.
7. `SavedCardService.GetWalletQuotaAsync` sonucunu `PlanPolicyService` ile uyumlu hale getir.

Yeni hata kodlari:

| Kod | HTTP | Ne zaman |
| --- | --- | --- |
| `PLAN_LIMIT_REACHED` | 403 | Kart/event/seat limiti doldu. |
| `FEATURE_NOT_INCLUDED` | 403 | Export, graph, wallet pass gibi ozellik kapali. |
| `SUBSCRIPTION_REQUIRED` | 402 veya 403 | Premium/Business gerekir. |

### 2.2 Flutter adimlari

Yeni feature:

```text
lib/features/plans/
  domain/entities/plan_entitlements.dart
  domain/entities/plan_tier.dart
  domain/repositories/plan_repository.dart
  domain/usecases/get_plan_entitlements.dart
  data/models/plan_entitlements_model.dart
  data/datasources/plan_remote_datasource.dart
  data/repositories/plan_repository_impl.dart
  presentation/cubit/plan_cubit.dart
  presentation/cubit/plan_state.dart
```

DI:

- `AppInit.init()` icinde `PlanRepositoryImpl`, `GetPlanEntitlements`, `PlanCubit` veya ilgili use case baglanir.
- `App` constructor'ina sadece gereken use case gecilir; buyuk constructor daha da sisiyorsa ileride composition root refactor planlanabilir.

UI:

- Kart ekleme sayfasi `maxBusinessCards` kontrolu yapar.
- Event group create sheet `maxEventGroups` ve `canAddEventGroup` kontrolu yapar.
- Premium ozellik butonlari disabled degil, paywall tetikleyici olarak davranir.

### 2.3 Kabul kriterleri

- Free kullanici 3. event group'u olusturamaz ve paywall gorur.
- Free kullanici 3. kendi kartini olusturamaz.
- Premium entitlement aktif olunca ayni islem basarili olur.
- Backend testleri client bypass durumunda da limiti uygular.

## 3. Faz 2 - RevenueCat Server-Side Dogrulama

Hedef: Premium bilgisini sadece Flutter tarafinda degil, backend tarafinda da guvenilir yapmak.

### 3.1 Backend

Endpoint:

```text
POST /RevenueCatWebhook
```

Yapilacaklar:

1. RevenueCat webhook signature veya authorization header dogrulanir.
2. `app_user_id` backend `UserId` ile eslestirilir.
3. Entitlement aktifse `subscriptions` veya `wallet_entitlements` guncellenir.
4. Cancel/expire/refund eventlerinde tier geri cekilir.
5. Idempotency icin `provider_event_id` saklanir.

Tablo:

```text
subscription_events
  id
  provider
  provider_event_id
  user_id
  event_type
  payload_json
  processed_at
```

### 3.2 Flutter

Mevcut akislari koru:

- `RevenueCatSubscriptionDataSource.configure()`
- `identifyUser(userId)`
- `presentWalletPaywall()`
- `restorePurchases()`

Ek olarak:

1. Purchase veya restore sonrasi backend `PlanEntitlements` yenilenir.
2. UI sadece RevenueCat sonucuna gore kalici premium acmaz; backend sonucunu bekler veya "senkronize ediliyor" state'i gosterir.
3. Offline durumda son entitlement cache okunur, ama kritik server islemleri backend'de yine kontrol edilir.

### 3.3 Kabul kriterleri

- Kullanici satin alma yapinca RevenueCat webhook backend'e tier update eder.
- Restore purchases sonrasi backend entitlement yenilenir.
- App silinip yuklenince premium backend'den geri gelir.
- Client manipule edilse bile export/limit backend'de korunur.

## 4. Faz 3 - Premium Ozellikler

### 4.1 Reklamsiz kullanim

Mevcut `ShowPostAddCardMonetization` akisi su hale getirilmeli:

1. Plan entitlement yuklenir.
2. `adsDisabled = true` ise reklam repository cagrilmaz.
3. `adsDisabled = false` ise mevcut counter ve frekans kurallari uygulanir.

Kabul kriteri:

- Premium kullanici post-add reklam gormez.
- Free kullanici kritik akisi bozmayacak frekansta reklam gorur.

### 4.2 Gelismis kart tasarimlari

Implementasyon sirasi:

1. `features/card_design` domain entity'lerini olustur.
2. Backend'de `card_templates` ve gerekirse `branded_card_templates` tablolari ekle.
3. Free/Premium template ayrimini `requiredTier` ile modelle.
4. Kart editor UI'da premium template secimi paywall tetikler.
5. Business template secimi organization membership kontrolu ister.

Kabul kriteri:

- Free kullanici premium template onizleme yapabilir ama kaydetmek icin paywall gorur.
- Premium kullanici premium template'i kaydeder.
- Business member organization template'i gorebilir.

### 4.3 Profil istatistikleri

Backend:

1. `card_interactions` tablosu ekle.
2. Public kart goruntuleme ve QR scan noktalarinda event yaz.
3. Saved card kaydetme akisi `card_saved` event'i olustursun.
4. `ProfileStatsDto` aggregate alanlarini genislet:

```json
{
  "totalViews": 120,
  "totalQrScans": 32,
  "totalSaves": 14,
  "topSources": [
    { "source": "qr", "count": 32 }
  ],
  "recentSaves": [
    { "displayName": "Anonim kullanici", "savedAt": "2026-06-25T12:00:00Z" }
  ]
}
```

Flutter:

- `features/profile/domain/entities/profile_stats.dart` genisletilir.
- `ProfileCubit` veya mevcut state yapisi yeni alanlari render eder.
- Premium degilse stats karti preview + paywall CTA gosterir.

Kabul kriteri:

- QR scan sayisi backend'de artar.
- Profile stats endpoint'i sadece kart sahibine kendi kart aggregate'lerini dondurur.
- Free kullanici premium stats detayi gormez.

### 4.4 CSV/Excel export

Backend ilk faz:

```text
GET /ExportSavedCards?format=csv
GET /ExportEventGroupCards?id={eventGroupId}&format=csv
```

Flutter:

```text
lib/features/exports/
  domain/usecases/export_saved_cards.dart
  data/datasources/export_remote_datasource.dart
  presentation/cubit/export_cubit.dart
```

UI:

- Saved cards filtre sheet veya menu icine "CSV export" eklenir.
- Event group detail icine "Export" butonu eklenir.
- Free kullanici paywall gorur.

Kabul kriteri:

- Premium kullanici CSV indirir/paylasir.
- Free kullanici export endpointinde 403 alir ve UI paywall gosterir.

### 4.5 Graph ozelligi

Ilk faz:

1. Backend `NetworkGraphService` aggregate node/edge doner.
2. Flutter `features/network_graph` veriyi alir.
3. UI basit liste veya canvas benzeri graph component ile baslar.

Graph hesaplamalari:

- Degree: her node'un bag sayisi.
- Shortest path: iki kart/kullanici arasindaki en kisa bag.
- Common event: ayni eventte toplanan kisiler.
- Company cluster: ayni sirketten gelen kisiler.

Kabul kriteri:

- Premium kullanici kendi network graph'ini gorur.
- Business admin organization event graph'ini gorur.
- Free kullanici graph CTA + paywall gorur.

### 4.6 Wallet pass

Backend:

- Apple PassKit sertifikalari secret store'da tutulur.
- Google Wallet service account secret store'da tutulur.
- Kart guncellenince pass update mekanizmasi planlanir.

Flutter:

- `features/wallet_passes` eklenir.
- Platform kontrolu presentation'da kalabilir; pass olusturma backend use case ile yapilir.

Kabul kriteri:

- Premium kullanici kendi karti icin Apple veya Google Wallet pass olusturabilir.
- Free kullanici paywall gorur.

## 5. Faz 4 - Business / Event Organizer

### 5.1 Organization feature

Backend dosyalari:

```text
Cardence.Domain/Entities/Organization.cs
Cardence.Domain/Entities/OrganizationMember.cs
Cardence.Application/DTOs/Organizations/
Cardence.Application/Interfaces/IOrganizationService.cs
Cardence.Application/Services/OrganizationService.cs
Cardence.Api/Controllers/OrganizationsController.cs
```

Flutter dosyalari:

```text
lib/features/organizations/
  domain/entities/organization.dart
  domain/entities/organization_member.dart
  domain/usecases/get_organizations.dart
  domain/usecases/create_organization.dart
  domain/usecases/invite_organization_member.dart
  data/models/
  data/datasources/organization_remote_datasource.dart
  data/repositories/organization_repository_impl.dart
  presentation/bloc/organization_bloc.dart
  presentation/pages/organizations_page.dart
```

Kabul kriteri:

- Kullanici organization olusturur.
- Admin ekip uyesi davet eder.
- Member daveti kabul eder.
- Role'a gore UI ve backend yetkileri farkli calisir.

### 5.2 Business event workspace

Backend:

```text
OrganizationEvent
EventLead
LeadTag
LeadNote
```

Endpointler:

```text
GET /OrganizationEvents?organizationId=
POST /SaveOrganizationEvent
GET /OrganizationEventLeads?id=
POST /SaveOrganizationEventLead
POST /AssignLeadToMember
```

Flutter:

```text
lib/features/organization_events/
lib/features/leads/
```

Akis:

1. Admin event olusturur.
2. Member event'i secer.
3. QR scan/manual/photo ile lead toplar.
4. Lead organization event'e baglanir.
5. Admin lead listesini gorur.

Kabul kriteri:

- Lead kimin tarafindan toplandigi ile kaydedilir.
- Admin tum lead'leri, member kendi lead'lerini gorur.
- Export sadece yetkili role'lerde acilir.

### 5.3 CRM entegrasyonu

Ilk provider olarak HubSpot onerilir.

Backend:

```text
Cardence.Application/Interfaces/ICrmProvider.cs
Cardence.Infrastructure/Crm/HubSpotCrmProvider.cs
Cardence.Application/Services/CrmConnectionService.cs
Cardence.Application/Services/CrmSyncService.cs
```

Flutter:

```text
lib/features/crm_integrations/
  presentation/pages/crm_connections_page.dart
  presentation/widgets/crm_provider_card.dart
```

Akis:

1. Admin CRM provider secip OAuth baslatir.
2. Backend token alir ve encrypted saklar.
3. Admin lead listesinden sync baslatir.
4. Job status UI'da gosterilir.

Kabul kriteri:

- Yetkisiz member CRM baglayamaz.
- Sync tekrarlanabilir ve hata durumunda mesaj gorunur.
- Export ve CRM sync audit log'a yazilir.

### 5.4 Business graph ve ekip analitigi

Backend:

- `OrganizationAnalyticsService`
- `TeamPerformanceService`
- `OrganizationNetworkGraphService`

Flutter:

```text
lib/features/organization_analytics/
```

Ekranlar:

- Organization dashboard.
- Event analytics.
- Team performance.
- Lead source breakdown.
- Network graph.

Kabul kriteri:

- Admin event bazli lead sayisini gorur.
- Admin member bazli performansi gorur.
- Graph, organization event scope'una gore filtrelenir.

## 6. Faz 5 - Enterprise Sertlestirme

Enterprise icin gerekli katmanlar:

1. SSO/SAML veya OIDC.
2. Audit log.
3. Data retention policy.
4. Role based access control detaylandirma.
5. Custom domain veya branded public page.
6. SLA ve monitoring.
7. Bulk import/export.

Bu faz Business MVP'den sonra yapilmalidir. Erken eklenirse core product hizini yavaslatir.

## 7. App Navigasyon ve UI Entegrasyonu

Onerilen UI yerlestirme:

| Ozellik | Ekran |
| --- | --- |
| Plan durumu | Settings -> Wallet & subscription |
| Premium paywall | Limit sheet, template lock, stats preview, export CTA |
| Advanced designs | Kart editor / card appearance section |
| Profile stats | Profile page |
| CSV export | Saved Cards ve Event Group detail |
| Graph | Profile veya ayri Network tab |
| Organization | Settings veya Shell'de Business workspace switch |
| Business leads | Organization event detail |
| CRM | Organization settings |

Paywall davranisi:

- Kullanici ozellige basinca baglamli aciklama gosterilmeli.
- "Premium'a gec" CTA'si RevenueCat paywall acmali.
- Satin alma sonrasi ilgili use case tekrar denenmeli veya ekran refresh edilmeli.

## 8. Migration ve Geriye Donus Uyumlulugu

Mevcut kullanicilar icin:

1. Her kullanici varsayilan `free` entitlement alir.
2. Mevcut `wallet_entitlements` kayıtları korunur.
3. RevenueCat identify ile mevcut premium kullanici backend'e eslenir.
4. Local saved cards ve event groups backend sync akisi korunur.
5. `freeMaxOwnBusinessCards` 50'den 2'ye inerse mevcut 2'den fazla karti olan kullanicilar icin grace policy gerekir.

Grace policy onerisi:

- Mevcut kartlar silinmez.
- Yeni kart olusturma kapatilir.
- UI "Mevcut kartlarin korunuyor, yeni kart icin Premium gerekli" mesajini gosterir.

## 9. Analitik Event Plani

Uygulama icinde izlenmesi gereken urun eventleri:

| Event | Parametreler |
| --- | --- |
| `paywall_viewed` | trigger, currentTier, feature |
| `paywall_purchased` | productId, feature |
| `plan_limit_hit` | limitType, currentCount, maxCount |
| `card_created` | tier, templateId |
| `card_shared_qr` | cardId, tier |
| `card_saved` | source, eventGroupId |
| `export_started` | format, scope |
| `organization_created` | planTier |
| `lead_collected` | eventId, source |
| `crm_sync_started` | provider, leadCount |

Bu eventler ilk basta backend `card_interactions` ve business analytics tablolarinda tutulabilir. Urun analitigi icin ileride Amplitude/Mixpanel/PostHog gibi araclara da aktarilabilir.

## 10. Onceliklendirilmis Yapilacaklar

### Kisa vade

1. `freeMaxOwnBusinessCards` urun kararina gore policy'den gelecek sekilde duzenle.
2. `PlanEntitlements` backend endpoint'i ekle.
3. Flutter `features/plans` feature'ini ekle.
4. RevenueCat purchase/restore sonrasi backend entitlement refresh yap.
5. Event group limit paywall akisini tamamla.

### Orta vade

1. Profil stats icin `card_interactions` event logging ekle.
2. CSV export endpointlerini ekle.
3. Premium card design template sistemini ekle.
4. Network graph endpoint ve Flutter feature iskeletini ekle.
5. Wallet pass proof-of-concept yap.

### Uzun vade

1. Organization ve team membership.
2. Business event workspace ve lead toplama.
3. CRM entegrasyonu.
4. Business analytics ve graph.
5. Enterprise security/audit/SSO.

## 11. Entegrasyon Sirasinda Dikkat Edilecek Kurallar

- Flutter domain katmanina Firebase, RevenueCat veya Dio import edilmemeli.
- Page/widget icinde use case dogrudan cagrilacaksa mevcut pattern'e uyulmali; is mantigi Cubit/BLoC'a tasinmali.
- Yeni UI renklerinde ham `Color(0x...)` veya `Colors.*` kullanilmamali; `AppColors` veya tema alanlari tercih edilmeli.
- Backend Application katmanina ASP.NET veya EF Core import edilmemeli.
- DTO alan adlari Flutter modelleriyle camelCase uyumlu olmali.
- Yeni endpointler Swagger ve `backend/docs/dotnet-backend-api.md` ile uyumlu belgelenmeli.
- Kritik plan/limit kontrolleri sadece Flutter'da degil backend servislerinde de uygulanmali.

## 12. Minimum MVP Tanimi

Bu paketleme stratejisinin ilk anlamli MVP'si su kapsami icermelidir:

1. Free: 2 kendi karti, 2 event group, temel saved cards acik, reklam acik.
2. Premium: reklamsiz, sinirsiz event group, premium tasarim kilidi, profil stats preview/detail, CSV export.
3. Backend: server-side entitlement, plan policy, quota enforcement.
4. Flutter: plan feature, paywall trigger'lari, entitlement refresh.
5. Business icin: sadece teknik temel dokuman ve organization domain iskeleti; tam business ozellikleri ikinci MVP.

Bu MVP, hem bireysel premium gelirini test eder hem de Business plan icin gereken veri altyapisini kurmaya baslar.
