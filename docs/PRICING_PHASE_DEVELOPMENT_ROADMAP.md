# Cardence Paketleri Faz Bazli Gelistirme Yol Haritasi

Bu dokuman, `PRICING_PRODUCT_STRATEGY.md`, `PRICING_TECHNICAL_ARCHITECTURE.md` ve `PRICING_INTEGRATION_ROADMAP.md` uzerinden uygulama sirasinda takip edilecek faz ilerleme planini tanimlar. Amac, Free/Premium gelir modelini guvenli sekilde MVP'ye tasimak, ardindan Business ve Enterprise katmanlarini kontrollu buyutmektir.

## Faz Durum Ozeti

| Faz | Odak | Durum | Cikis hedefi |
| --- | --- | --- | --- |
| Faz 0 | Karar ve hazirlik | Planlandi | Limitler, hata kodlari, migration ve test kapsami net |
| Faz 1 | Entitlement ve limit altyapisi | Planlandi | Backend authoritative plan policy ve Flutter plan feature calisir |
| Faz 2 | RevenueCat server-side dogrulama | Planlandi | Satin alma/restore backend entitlement'a yansir |
| Faz 3 | Premium MVP ozellikleri | Planlandi | Reklamsiz kullanim, premium tasarim kilidi, stats ve CSV export acilir |
| Faz 4 | Premium ileri deger katmani | Planlandi | Network graph ve wallet pass PoC tamamlanir |
| Faz 5 | Business MVP | Planlandi | Organization, team, event workspace ve lead export calisir |
| Faz 6 | Business genisleme | Planlandi | CRM, ekip analitigi ve branded template katmani eklenir |
| Faz 7 | Enterprise sertlestirme | Planlandi | SSO, audit, retention, SLA ve compliance hazir |

## Faz 0 - Urun Kararlari ve Teknik Hazirlik

Hedef: Gelistirmeye baslamadan once limit, paket, hata ve migration kararlarini netlestirmek.

### Adimlar

1. Free plan kendi kart limitini MVP icin `2` olarak kesinlestir.
2. Saved cards icin ilk MVP kararini netlestir: temel kayit acik, export ve gelismis aksiyonlar Premium.
3. Premium paket kapsamlarini MVP sirasina koy:
   - Reklamsiz kullanim.
   - Sinirsiz event group.
   - Premium card design kilidi.
   - Profile stats detail.
   - CSV export.
4. Business kapsamlarini MVP disina ayir, ancak veri modeli kararlarini simdiden koru:
   - Organization.
   - Membership.
   - Organization event.
   - Event lead.
5. Backend hata kodlarini standartlastir:
   - `PLAN_LIMIT_REACHED`
   - `FEATURE_NOT_INCLUDED`
   - `SUBSCRIPTION_REQUIRED`
   - `EXPORT_NOT_ALLOWED`
6. Mevcut kullanicilar icin grace policy kararini yaz:
   - Mevcut kartlar silinmez.
   - Limit asimi varsa yeni kart olusturma kapanir.
   - UI, mevcut kartlarin korundugunu ve yeni kart icin Premium gerektigini gosterir.

### Cikis Kosullari

- Free/Premium/Business paket dagilimi urun tarafindan onaylandi.
- `null` limitin sinirsiz, `0` limitin kapali anlamina geldigi kabul edildi.
- Backend ve Flutter hata/feature gate sozlesmesi belirlendi.

## Faz 1 - Plan Entitlement ve Limit Altyapisi

Hedef: Paket kararlarini client hard-code yerine backend policy uzerinden yonetmek.

### 1.1 Backend

1. Domain seviyesinde plan kavramlarini ekle:
   - `PlanTier`
   - `PlanFeature`
   - `Subscription`
2. Application katmaninda policy servisini ekle:
   - `IPlanPolicyService`
   - `PlanPolicyService`
   - `PlanEntitlementsDto`
3. API endpoint ekle:
   - `GET /PlanEntitlements`
4. `BusinessCardService` icinde kullanicinin kendi kart sayisi limitini backend'de uygula.
5. `EventGroupService` icinde event group limitini backend'de zorunlu hale getir.
6. `SavedCardService.GetWalletQuotaAsync` sonucunu yeni plan policy ile uyumlu hale getir.
7. Quota policy unit testlerini ekle:
   - Free kullanici 3. karti olusturamaz.
   - Free kullanici 3. event group'u olusturamaz.
   - Premium kullanici limit engeline takilmaz.

### 1.2 Flutter

1. `lib/features/plans/` feature'ini Clean Architecture yapisiyla ekle:
   - Domain entity: `PlanEntitlements`, `PlanTier`
   - Repository interface: `PlanRepository`
   - Use case: `GetPlanEntitlements`
   - Remote data source ve model
   - `PlanCubit` ve `PlanState`
2. `AppInit.init()` icinde repository/use case baglantilarini yap.
3. Kart olusturma akisini `maxBusinessCards` ile bagla.
4. Event group create akisini `maxEventGroups` ve `canAddEventGroup` ile bagla.
5. Feature gate hatasinda baglamli paywall veya limit sheet goster.
6. UI metinlerinde hard-coded limit yazma; backend entitlement limitini kullan.

### Kabul Kriterleri

- Free kullanici 3. kendi kartini olusturamaz ve paywall/limit mesaji gorur.
- Free kullanici 3. event group'u olusturamaz.
- Premium entitlement aktifse ayni islemler basarili olur.
- Client manipule edilse bile backend limitleri korur.

## Faz 2 - RevenueCat Server-Side Dogrulama

Hedef: Premium bilgisini sadece Flutter tarafinda degil, backend tarafinda authoritative hale getirmek.

### 2.1 Backend

1. `POST /RevenueCatWebhook` endpoint'ini ekle.
2. Webhook authorization veya signature dogrulamasini uygula.
3. `app_user_id` degerini backend `UserId` ile esle.
4. Aktif entitlement eventlerinde subscription veya wallet entitlement kaydini guncelle.
5. Cancel, expire ve refund eventlerinde tier bilgisini geri cek.
6. Idempotency icin `subscription_events` tablosunu ekle:
   - `provider`
   - `provider_event_id`
   - `user_id`
   - `event_type`
   - `payload_json`
   - `processed_at`
7. Webhook signature, duplicate event ve cancel/expire unit testlerini ekle.

### 2.2 Flutter

1. Mevcut RevenueCat akislarini koru:
   - `configure()`
   - `identifyUser(userId)`
   - `presentWalletPaywall()`
   - `restorePurchases()`
2. Purchase veya restore sonrasi `GetPlanEntitlements` refresh et.
3. UI'da kalici Premium state'i sadece RevenueCat sonucuyla acma; backend entitlement refresh sonucunu bekle.
4. Senkronizasyon sirasinda kisa "plan guncelleniyor" state'i goster.
5. Offline durumda son bilinen entitlement cache okunabilir, ancak kritik server islemleri backend tarafinda yine korunur.

### Kabul Kriterleri

- Satin alma sonrasi RevenueCat webhook backend tier bilgisini gunceller.
- Restore purchases sonrasi app backend entitlement'i yeniler.
- App silinip yuklendiginde Premium durumu backend'den geri gelir.
- RevenueCat client manipule edilse bile export ve limit kontrolleri backend'de korunur.

## Faz 3 - Premium MVP Ozellikleri

Hedef: Bireysel Premium'u satin alinabilir yapan ilk deger setini tamamlamak.

### 3.1 Reklamsiz Kullanim

Backend/Flutter ortak karar:

1. `adsDisabled` entitlement alani `PlanEntitlements` icinde doner.
2. `ShowPostAddCardMonetization`, reklam repository cagrisi oncesi entitlement state'i kontrol eder.
3. Premium kullaniciya post-add reklam gosterilmez.
4. Free kullanicida mevcut reklam frekansi kritik QR/save akisini bozmayacak sekilde korunur.

### 3.2 Premium Card Design Kilidi

1. `features/card_design` feature iskeletini ekle.
2. Backend'de template modelini hazirla:
   - `card_templates`
   - `requiredTier`
3. Kart editor UI'da Free ve Premium template'leri ayir.
4. Free kullanici Premium template onizleyebilir, kaydetmek istediginde paywall gorur.
5. Premium kullanici Premium template'i kaydedebilir.

### 3.3 Profile Stats Detail

1. Backend'de `card_interactions` tablosunu ekle.
2. Public card view, QR scan, card save ve contact click noktalarinda event yaz.
3. `ProfileStatsDto` alanlarini genislet:
   - `totalViews`
   - `totalQrScans`
   - `totalSaves`
   - `topSources`
   - `recentSaves`
4. Gizlilik varsayimi olarak "kim kaydetti" bilgisini anonim/aggregate dondur.
5. Flutter `profile` feature entity/state/UI katmanini yeni alanlarla genislet.
6. Free kullaniciya stats preview ve Premium CTA goster.

### 3.4 CSV Export

1. Backend endpointlerini ekle:
   - `GET /ExportSavedCards?format=csv`
   - `GET /ExportEventGroupCards?id={eventGroupId}&format=csv`
2. Export authorization kurallarini uygula:
   - Free: kapali.
   - Premium: kendi wallet ve event group'lari.
3. Flutter `features/exports/` feature'ini ekle.
4. Saved cards ve event group detail ekranlarina export CTA ekle.
5. Free kullanicida paywall, Premium kullanicida dosya indirme/paylasma akisi calisir.

### Kabul Kriterleri

- Premium kullanici reklam gormez.
- Free kullanici Premium template'i kaydetmeye calisinca paywall gorur.
- QR scan ve public view olaylari profile stats aggregate'ine yansir.
- Premium kullanici CSV export alir.
- Free kullanici export endpointinden 403 alir ve UI paywall gosterir.

## Faz 4 - Premium Ileri Deger Katmani

Hedef: MVP sonrasinda Premium algisini guclendiren teknik olarak daha maliyetli ozellikleri kontrollu eklemek.

### 4.1 Personal Network Graph

**Referans:** `docs/PRICING_NETWORK_GRAPH_THEORY.md`

**Tamamlanan (Faz 4.1a–c temel):**

- `docs/PRICING_NETWORK_GRAPH_THEORY.md` — node/edge/path teorisi, metrikler, gizlilik, ER modeli
- Backend: `Cardence.Domain/Graph/*`, `CardInteraction` entity, `card_interactions` migration, NetworkGraph DTO'lari, `INetworkGraphService`
- Backend: `NetworkGraphService` personal/event graph query, BFS path, `GET /NetworkGraph`, `GET /NetworkGraphPath`
- Backend testleri: personal graph node/edge üretimi, event graph `met_at_event`/`same_company`, BFS path ve Free kullanıcı `FEATURE_NOT_INCLUDED`
- Event logging: cüzdana kaydedilen gerçek Cardence kartlari icin `card_saved`, QR payload kaynakliysa `qr_scanned`
- Event logging: public share açılışında `card_viewed`, contact aksiyonlarında `contact_clicked`
- Flutter: `lib/features/network_graph/domain/*`, data datasource/repository/model, usecase ve `NetworkGraphCubit`
- Flutter UI: Profil ekranindan Premium gated `NetworkGraphPage`, node/edge metrikleri, dereceye göre node listesi ve edge listesi

**Siradaki adimlar (Faz 4.1b–d):**

1. Flutter graph UI ikinci adim:
   - event scope selector
   - path sonucu vurgulama
   - force/radial graph canvas PoC
2. Organization graph icin `assigned_lead` ve `org_event_link` edge kaynaklarini Faz 6'ya bagla.

### 4.2 Wallet Pass PoC

1. Apple PassKit ve Google Wallet secret ihtiyaclarini belirle.
2. Backend pass uretim endpointlerini PoC seviyesinde ekle:
   - `POST /WalletPasses/Apple?cardId=`
   - `POST /WalletPasses/Google?cardId=`
   - `GET /WalletPasses/Status?cardId=`
3. Flutter `features/wallet_passes` feature'ini ekle.
4. Platforma gore Apple/Google akisini baslatan UI butonunu ekle.
5. Free kullanicida paywall, Premium kullanicida pass olusturma akisi calisir.

### Kabul Kriterleri

- Premium kullanici personal network graph ekranini gorebilir.
- Graph algoritmasi UI'da degil backend'de hesaplanir.
- Premium kullanici kendi karti icin wallet pass olusturabilir.
- Sertifika/private key bilgileri secret store disina cikmaz.

## Faz 5 - Business MVP

Hedef: Asil gelir kanali olan Business plan icin minimum organization ve event lead akisini calisir hale getirmek.

### 5.1 Organization ve Membership

1. Backend domain entity'lerini ekle:
   - `Organization`
   - `OrganizationMember`
   - `OrganizationInvitation`
   - `OrganizationRole`
2. Application servislerini ekle:
   - `IOrganizationService`
   - `IOrganizationMemberService`
   - `IOrganizationInvitationService`
   - `IOrganizationPlanService`
3. Endpointleri ekle:
   - Organization create/list/detail.
   - Member invite/accept/remove.
   - Role update.
4. Tum organization endpointlerinde membership ve role authorization uygula.
5. Flutter `features/organizations/` feature'ini ekle.
6. Organization list, create ve invite ekranlarini MVP seviyesinde tamamla.

### 5.2 Business Event Workspace ve Lead Listesi

1. Backend modellerini ekle:
   - `OrganizationEvent`
   - `EventLead`
   - `LeadTag`
   - `LeadNote`
2. Endpointleri ekle:
   - `GET /OrganizationEvents?organizationId=`
   - `POST /SaveOrganizationEvent`
   - `GET /OrganizationEventLeads?id=`
   - `POST /SaveOrganizationEventLead`
   - `POST /AssignLeadToMember`
3. Mevcut bireysel `event_groups` ile Business `organization_events` ayrimini koru.
4. Flutter `features/organization_events/` ve `features/leads/` feature'larini ekle.
5. Admin tum lead'leri, member sadece kendi lead'lerini gorecek sekilde state ve authorization kur.
6. Business export yetkisini role bazli uygula.

### Kabul Kriterleri

- Kullanici organization olusturur.
- Admin ekip uyesi davet eder, member daveti kabul eder.
- Admin organization event olusturur.
- Member event icinde lead toplar.
- Lead, kimin tarafindan toplandigi bilgisiyle kaydedilir.
- Admin tum lead'leri, member kendi lead'lerini gorur.
- Export sadece yetkili role'lerde acilir.

## Faz 6 - Business Genisleme

Hedef: Business planin satis degerini artiran CRM, ekip analitigi ve marka ozelliklerini eklemek.

### 6.1 CRM Entegrasyonu

1. Ilk provider olarak HubSpot'u sec.
2. Backend interface ve provider yapisini ekle:
   - `ICrmProvider`
   - `HubSpotCrmProvider`
   - `CrmConnectionService`
   - `CrmSyncService`
3. `crm_connections` ve `crm_sync_jobs` tablolarini ekle.
4. OAuth token'larini encrypted sakla.
5. Sync islemini async job olarak calistir.
6. Flutter `features/crm_integrations/` feature'ini ekle.
7. Admin CRM provider baglar, lead listesinden sync baslatir, job status izler.

### 6.2 Branded Templates

1. `branded_card_templates` modelini ekle.
2. Organization admin'in template olusturmasini sagla.
3. Member kart editor'unda organization template'lerini goster.
4. `is_locked` alanina gore logo/renk/font degisikliklerini kisitla.
5. Business template kullaniminda organization membership kontrolu yap.

### 6.3 Organization Analytics ve Business Graph

1. Backend servislerini ekle:
   - `OrganizationAnalyticsService`
   - `TeamPerformanceService`
   - `OrganizationNetworkGraphService`
2. Endpointleri ekle:
   - `GET /OrganizationAnalytics?id=`
   - `GET /OrganizationEventAnalytics?id=`
   - `GET /OrganizationEventTeamPerformance?id=`
   - `GET /OrganizationEventLeads?id=`
3. Flutter `features/organization_analytics/` feature'ini ekle.
4. Dashboard ekranlarini MVP seviyesinde tamamla:
   - Event lead count.
   - Member performance.
   - Lead source breakdown.
   - Organization network graph.

### Kabul Kriterleri

- Admin HubSpot baglayabilir ve lead sync baslatabilir.
- Yetkisiz member CRM baglayamaz.
- Sync tekrar calistirilabilir ve hata mesaji UI'da gorunur.
- Organization admin branded template olusturabilir.
- Member organization template'i kullanabilir.
- Admin event ve member bazli performansi gorebilir.

## Faz 7 - Enterprise Sertlestirme

Hedef: Buyuk musteri ve kurumsal satis icin guvenlik, compliance ve operasyonel gereksinimleri tamamlamak.

### Adimlar

1. SSO/SAML veya OIDC destegini planla ve uygula.
2. Audit log'u export, CRM sync, role change, billing ve data access aksiyonlari icin zorunlu hale getir.
3. Data retention policy ve delete/export taleplerini destekle.
4. Role based access control kurallarini detaylandir.
5. Custom domain veya branded public page altyapisini ekle.
6. Monitoring, alerting ve SLA raporlama metriklerini tanimla.
7. Bulk import/export icin async job modelini genislet.

### Kabul Kriterleri

- Enterprise organization SSO ile giris yapabilir.
- Kritik admin aksiyonlari audit log'a yazilir.
- Data retention ve silme talepleri uygulanabilir.
- Monitoring ve operasyon metrikleri takip edilebilir.

## Uygulama Sirasi ve Bagimliliklar

1. Faz 0 tamamlanmadan Faz 1'e baslanmamalidir; limit ve hata kararlarinin degismesi backend sozlesmesini etkiler.
2. Faz 1 tamamlanmadan Premium UI kilitleri kalici hale getirilmemelidir; feature gate backend authoritative olmali.
3. Faz 2 tamamlanmadan Premium ozellikler gelir korumasi icin production'a acilmamalidir.
4. Faz 3 icindeki profile stats ve graph icin `card_interactions` temel veri kaynagi oldugundan once event logging kurulmalidir.
5. Faz 5 baslamadan Business domain'i bireysel `event_groups` icine sikistirilmamalidir; `organization_events` ayri kalmalidir.
6. Faz 6 CRM entegrasyonu baslamadan audit log ve role authorization en az MVP seviyesinde hazir olmalidir.
7. Faz 7, Business MVP dogrulanmadan erken eklenmemelidir; aksi halde core product hizini yavaslatir.

## Test ve Release Kontrol Listesi

Her faz sonunda asagidaki kontrol yapilmalidir:

1. Backend unit testleri:
   - Policy karar testleri.
   - Authorization testleri.
   - Webhook/idempotency testleri.
   - Export permission testleri.
2. Flutter testleri:
   - Feature gate unit testleri.
   - Cubit/BLoC state testleri.
   - Paywall trigger testleri.
   - Entitlement refresh/cache testleri.
3. Integration testleri:
   - Free -> limit -> paywall -> purchase -> entitlement refresh -> ozellik acilir.
   - Kart scan -> interaction event -> profile stats aggregation.
   - Business admin -> event yaratir -> member lead toplar -> admin export eder.
4. Dokuman guncellemeleri:
   - API endpointleri backend docs'a eklenir.
   - Yeni Flutter feature klasorleri mimari kurallarla uyumlu yazilir.
   - Plan/limit kararlari pricing dokumanlariyla tutarli kalir.

## Ilk MVP Teslim Tanimi

Ilk anlamli pricing MVP'si Faz 0, Faz 1, Faz 2 ve Faz 3'un temel kapsamindan olusur.

MVP kapsaminda mutlaka bulunmasi gerekenler:

1. Free kullanici:
   - En fazla 2 kendi karti.
   - En fazla 2 event group.
   - Temel saved cards akisi acik.
   - Reklam akisi acik.
2. Premium kullanici:
   - Reklamsiz kullanim.
   - Sinirsiz event group.
   - Premium tasarim kullanimi.
   - Profile stats detail.
   - CSV export.
3. Backend:
   - Server-side entitlement.
   - Plan policy.
   - Quota enforcement.
   - RevenueCat webhook.
4. Flutter:
   - `features/plans`.
   - Paywall trigger'lari.
   - Entitlement refresh.
   - Premium feature gate UI akislari.

Business icin ilk MVP'de sadece teknik temel dokuman ve organization domain kararlarinin korunmasi yeterlidir; tam Business urunu Faz 5 ve Faz 6'da gelistirilmelidir.
