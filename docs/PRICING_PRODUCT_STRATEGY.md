# Cardence Paketleme ve Urun Stratejisi

Bu dokuman Cardence icin uc ana gelir katmanini tanimlar: Ucretsiz Plan, Bireysel Premium ve Event Organizer / Business Plan. Amac, kullanici ag etkisini bozmadan bireysel kullaniciyi premium'a, asil gelir kanali olan etkinlik ve sirket hesaplarini ise business plana tasimaktir.

## 1. Stratejik Ozet

Cardence'in urun modeli iki farkli motivasyona dayanir:

1. Bireysel kullanici daha iyi dijital kart, daha iyi gorunurluk ve daha rahat networking ister.
2. Etkinlik sahibi veya sirket, kisileri toplamak, iliski agini analiz etmek, lead listesini export etmek ve CRM'e aktarmak ister.

Bu nedenle temel kart saklama ozelligi tamamen kapatilmamalidir. Kart saklama, uygulamanin ag etkisini olusturan cekirdek davranistir: Kullanici ne kadar cok kart kaydederse Cardence'e donme ihtimali ve baskalarina gostermesi o kadar artar. Para kazanma, kart saklamayi degil; limit, analitik, organizasyon, export, marka ve entegrasyon katmanlarini paketlemelidir.

## 2. Paketler

### 2.1 Ucretsiz Plan

Ucretsiz planin hedefi kullaniciyi uygulamaya sokmak, ilk kartini olusturmak, QR paylasimi yaptirmak ve baskalarindan kart kaydettirmektir. Bu plan network etkisinin baslangicidir.

Onerilen kapsam:

| Ozellik | Onerilen limit | Neden |
| --- | --- | --- |
| Kendi dijital karti | 1 veya 2 kart | Kullanicinin temel kimligini olusturmasi icin yeterli. Birden fazla rol icin kucuk esneklik verilebilir. |
| Kart saklama | Temel duzeyde acik | Ag etkisini korur; uygulamayi bos bir cüzdan olmaktan cikarir. |
| Event grubu | 2 grup | Mevcut kodda `freeMaxEventGroups = 2`; bu limit mantikli. |
| Gelismis tasarimlar | Sinirli | Premium tasarima gecis sebebi yaratir. |
| Profil istatistikleri | Sadece temel sayac veya kapali | Premium icin ana deger kaldiraci. |
| Export | Kapali | Bireysel Premium ve Business icin degerli ozellik. |
| Reklam | Acik | Mevcut `google_mobile_ads` entegrasyonu ile uyumlu. |
| Apple/Google Wallet | Kapali veya tek kart denemesi | Teknik maliyet ve premium algisi yuksek. |

Mevcut kod durumu:

- Flutter tarafinda `SavedCardsWalletLimits.freeMaxEventGroups = 2` bulunuyor.
- `freeMaxOwnBusinessCards` su an 50; urun kararina gore 1 veya 2'ye cekilmeli.
- `SavedCardsWalletQuota.hasUnlimitedWallet` su an her zaman `true`; urun stratejisine gore kart saklama temel duzeyde acik kalabilir, ama "sinirsiz" yerine is modeliyle uyumlu bir limit veya reklam destekli model netlestirilmeli.
- Reklam akisi `features/ads` altinda `ShowPostAddCardMonetization` ile baslamis durumda.

Ucretsiz plan icin tavsiye:

1. Kendi kart limiti: MVP'de 2.
2. Saved card limiti: Ilk fazda yuksek veya sinirsiz algisi korunabilir, fakat manual/photo ekleme gibi maliyetli yollar sinirlanabilir.
3. Event group limiti: 2.
4. Reklam: Kart ekleme sonrasi veya belirli oturumlarda kontrollu gosterilmeli; QR tarama basarisi gibi kritik akislari kesmemeli.

### 2.2 Bireysel Premium

Bireysel Premium, networking yapan profesyoneller icindir. Deger onerisi "daha iyi gorun, daha cok olc, daha kolay disa aktar" seklinde kurulmalidir.

Onerilen kapsam:

| Ozellik | Aciklama |
| --- | --- |
| Reklamsiz kullanim | `features/ads` icinde premium entitlement kontroluyle reklam gosterimi kapatilir. |
| Sinirsiz event grubu | Mevcut `hasUnlimitedEventGroups => isPremium` mantigi korunabilir. |
| Gelismis kart tasarimlari | Tema, layout, font, arka plan, alan yerlesimi ve premium template kilitleri. |
| Profil istatistikleri | Kartimi kim kaydetti, kac kez goruntulendi, QR kac kez tarandi. |
| CSV/Excel export | Kaydedilen kartlar, event gruplari ve etkilesimler disa aktarilir. |
| Graph/node ag gorunumu | Kartlar arasi iliski dugumleri, baglar ve path yapisi. |
| Apple Wallet / Google Wallet | Kullanici kendi kartini wallet pass olarak ekler. |

Premium icin kritik is kurallari:

1. Premium entitlement RevenueCat ile baslar, backend tarafinda dogrulanarak `wallet_entitlements` veya yeni `subscriptions` tablosuna yazilir.
2. Premium ozellik kararlari sadece client'ta tutulmamalidir; backend `tier` bilgisini authoritative sekilde donmelidir.
3. Istatistiklerde kisisel veri icin kullanici onayi, gizlilik ayarlari ve KVKK/GDPR uyumu gerekir.
4. "Kim kartimi kaydetti" ozelligi karsidaki kullanicinin gizlilik tercihine bagli olmalidir. Varsayilan olarak isimli gorunum yerine anonim/aggregated sayac daha guvenli olabilir.

### 2.3 Event Organizer / Business Plan

Asil gelir kanali bu plandir. Burada musteri bireysel kullanici degil; sirket, etkinlik sahibi, fuar organizatoru, universite kariyer merkezi veya satis ekibidir.

Onerilen kapsam:

| Ozellik | Aciklama |
| --- | --- |
| Organizasyon hesabi | Sirket veya etkinlik sahibi ana hesap olusturur. |
| Ekip uyeleri | Admin, manager, member, viewer rolleri. |
| Etkinlik bazli kisi toplama | Her etkinlik icin lead havuzu, katilimci listesi ve kaynak takibi. |
| Lead listesi | Saved card + scan + form + event group verilerinden tek liste. |
| Export | CSV/Excel, segmentli export, tarih ve etkinlik filtresi. |
| CRM entegrasyonu | HubSpot, Salesforce, Pipedrive, Zoho gibi hedeflere push. |
| Marka logolu kart sablonlari | Sirket logolu, renk paletli, kilitli tasarimlar. |
| Graph/node analitigi | Ekip uyelerinin topladigi kartlar, ortak baglantilar, path ve merkezilik metrikleri. |
| Ekip analitigi | Uye bazli scan, lead, follow-up, export ve conversion raporlari. |

Business planda satilacak ana deger:

1. "Etkinlikten kac kisi topladik?"
2. "Hangi ekip uyesi en iyi performans gosterdi?"
3. "Hangi kisiler veya sirketler agda merkezi konumda?"
4. "Bu lead'leri CRM'e nasil aktaririz?"
5. "Markamizla uyumlu dijital kart deneyimini nasil standartlastiririz?"

Business plan icin tavsiye edilen paketleme:

| Paket | Hedef | Limit |
| --- | --- | --- |
| Organizer Starter | Tek etkinlik veya kucuk ekip | 1 organization, 1-3 event, 3-5 seat |
| Business Team | Satis ve networking ekibi | Sinirsiz event, 10-50 seat, export |
| Enterprise | Buyuk sirket / fuar | SSO, audit log, custom CRM, SLA |

## 3. Ozelliklerin Paketlere Dagilimi

| Ozellik | Free | Premium | Business |
| --- | --- | --- | --- |
| Kendi karti | 1-2 | Daha fazla veya sinirsiz | Ekip politikasi ile |
| Saved cards | Temel acik | Gelismis filtre/etiket/export | Organizasyon lead havuzu |
| Event groups | Sinirli | Sinirsiz | Event workspace + ekip |
| Reklam | Var | Yok | Yok |
| Gelismis tasarim | Sinirli | Var | Marka sablonu |
| Profil istatistikleri | Temel veya yok | Var | Ekip/organization bazli |
| Export | Yok | Kisisel export | Lead/export/CRM |
| Graph gorunumu | Yok | Kisisel ag | Organizasyon ag analitigi |
| Wallet entegrasyonu | Yok/deneme | Var | Marka pass / ekip pass |
| CRM | Yok | Yok veya hafif | Var |

## 4. Kullanici Yolculuklari

### 4.1 Free kullanici

1. Kayit olur.
2. Ilk kartini onboarding ile olusturur.
3. QR ile kartini paylasir.
4. Baska kartlari kaydeder.
5. Event group limitine veya kart tasarim kilidine denk gelir.
6. Premium paywall gosterilir.

Paywall tetikleyicileri:

- Ucuncu event group olusturma.
- Premium tasarim secme.
- Profil istatistiklerini acma.
- Export butonuna basma.
- Wallet pass olusturma.

### 4.2 Premium kullanici

1. Reklamsiz deneyim yasar.
2. Sınırsız event group kullanir.
3. Kartinin kac kez goruntulendigini ve QR scan sayisini izler.
4. Saved cards listesini CSV/Excel olarak disa aktarir.
5. Network graph ekraninda kimlerle bagli oldugunu gorur.
6. Kendi kartini Apple Wallet / Google Wallet'a ekler.

### 4.3 Business kullanici

1. Organization workspace olusturur.
2. Ekip uyelerini davet eder.
3. Etkinlik workspace'i acip QR/form/scan akisini baslatir.
4. Ekip uyeleri etkinlikte kisileri toplar.
5. Admin lead listesini segmentler, export eder veya CRM'e gonderir.
6. Graph analitigi ile merkezi kisileri ve ekip performansini inceler.

## 5. Basari Metrikleri

Free:

- Ilk kart olusturma orani.
- Ilk QR paylasim orani.
- Ilk saved card ekleme orani.
- Free kullanicinin haftalik geri donus orani.

Premium:

- Paywall goruntuleme -> satin alma donusumu.
- Premium tasarim kullanim orani.
- Profil stats ekranina geri donus.
- Export ve Wallet entegrasyonu kullanim sayisi.

Business:

- Organization basina aktif seat.
- Event basina toplanan lead.
- Lead export / CRM sync sayisi.
- Ekip uyesi basina scan.
- Business deneme -> ucretli donusum.

## 6. Riskler ve Kararlar

| Risk | Etki | Oneri |
| --- | --- | --- |
| Kart saklama limitini cok sert yapmak | Ag etkisini dusurur | Temel saved card acik kalsin; premium degeri export/analitik/tasarimdan gelsin. |
| "Kim kartimi kaydetti" gizlilik sorunu | KVKK/GDPR riski | Kullanici gizlilik ayari ve anonim mod eklenmeli. |
| Graph ozelligi erken yapilirsa karmasiklik artar | MVP gecikir | Once event log ve edge tablolari hazirlanmali; gorsel graph ikinci faz. |
| RevenueCat sadece client'ta kalirsa manipule edilebilir | Gelir kaybi | Backend webhook ve server-side entitlement zorunlu. |
| Business ozellikleri bireysel modele sikisirsa | Mimari borc | Organization, team, role, event workspace domain'i ayri tasarlanmali. |

## 7. Onerilen Fazlama

1. Faz 1: Free/Premium limitlerini netlestir, RevenueCat entitlement'i backend ile dogrula, paywall tetikleyicilerini tamamla.
2. Faz 2: Profil istatistikleri, scan/view/save event logging, CSV export ve premium tasarim kilitleri.
3. Faz 3: Organization, team, event workspace, lead listesi ve business export.
4. Faz 4: CRM entegrasyonlari, graph analitigi, Apple Wallet / Google Wallet pass altyapisi.
5. Faz 5: Enterprise ozellikleri: SSO, audit log, custom branding, SLA, data retention.
