# Cardence – Etkinlik Tarih/Saat, Konum ve Card ID Davet İş Akışı

Bu doküman, mevcut **EventGroup** yapısını gerçek etkinlik modeline yaklaştırmak için backend, database, servis ve Flutter client tarafında yapılacak geliştirme iş akışını tanımlar.

İstenen yeni davranış:

- Etkinlik oluşturulurken:
  - etkinlik adı,
  - başlangıç tarihi,
  - başlangıç saati,
  - konum,
  - opsiyonel bitiş tarihi,
  - opsiyonel bitiş saati
  ile oluşturulmalı.
- Bitiş tarihi/saati zorunlu olmamalı.
- Etkinlik oluşturma sırasında **card ID** ile kart davet edilebilmeli.
- Etkinlikler listelenirken:
  - **Devam eden / yaklaşan etkinlikler**
  - **Biten etkinlikler**
  ayrımı yapılmalı.
- DB ve servis katmanı bu ayrımı desteklemeli.

---

## 1. Mevcut Durum

### Backend

Mevcut `EventGroup` entity:

```csharp
public sealed class EventGroup
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Location { get; set; }
    public DateTime? EventDate { get; set; }
    public string? PhotoUrl { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

Mevcut problemler:

- `EventDate` sadece tek tarih gibi kullanılıyor, saat bilgisi net değil.
- Bitiş zamanı yok.
- Etkinliğin aktif mi bitti mi olduğu backend tarafından hesaplanmıyor.
- Oluşturma sırasında card ID ile davet yok.
- Kart ekleme, etkinlik oluşturulduktan sonra `LinkEventGroupCards` ile yapılıyor.

### Flutter

Mevcut `CreateEventGroupSheet`:

- ad,
- konum,
- tek tarih,
- fotoğraf,
- kayıtlı kart seçim adımı

taşıyor.

Mevcut `EventGroupCreateInput`:

```dart
class EventGroupCreateInput {
  const EventGroupCreateInput({
    required this.name,
    this.location,
    this.eventDate,
    this.photoFilePath,
  });
}
```

---

## 2. Hedef Model

### Zorunlu alanlar

- `name`
- `startAt`
- `location`

### Opsiyonel alanlar

- `endAt`
- `photoUrl`
- `invitedCardIds`

### Durum hesaplama

Etkinlik durumu runtime hesaplanmalı:

- `upcoming`: `now < startAt`
- `ongoing`: `startAt <= now <= effectiveEndAt`
- `ended`: `now > effectiveEndAt`

`effectiveEndAt` kuralı:

- `endAt` varsa `endAt`
- yoksa `startAt`

Yani bitiş zamanı girilmemiş tek zamanlı etkinlikler, başlangıç zamanı geçince `ended` olur.

Not: Ürün isterse ileride `endAt == null` için "aynı gün sonu" kuralı seçilebilir. MVP için daha net ve deterministic kural: `endAt ?? startAt`.

---

## 3. Database Değişiklikleri

### 3.1 `event_groups` tablosu

Mevcut:

- `event_date`

Önerilen:

```sql
start_at_utc timestamp with time zone not null
end_at_utc timestamp with time zone null
timezone text null
location text not null
```

Geçiş stratejisi:

1. `start_at_utc` nullable eklenir.
2. Eski `event_date` doluysa `start_at_utc = event_date`.
3. `event_date` boş eski kayıtlar için:
   - ya `created_at` kullanılır,
   - ya migration sonrası UI "tarih eksik" olarak gösterir.
4. MVP'de eski kayıtları korumak için `start_at_utc` ilk migration'da nullable bırakılabilir.
5. UI ve servis stabilize olduktan sonra zorunluluk değerlendirilebilir.

Önerilen indeksler:

```sql
index ix_event_groups_user_id_start_at_utc
index ix_event_groups_user_id_end_at_utc
index ix_event_groups_user_id_created_at
```

### 3.2 Davet Edilen Kartlar

Mevcut kart bağlama yapısı büyük ihtimalle `saved_card_event_groups` üzerinden çalışıyor. Bu yapı, kullanıcının cüzdanındaki kayıtlı kartları etkinliğe bağlamak için doğru.

Yeni gereksinim farklı: kullanıcı etkinlik oluştururken **card ID yazarak** kart davet edebilmeli.

İki yaklaşım var:

#### Yaklaşım A – Direkt saved card oluştur/linkle

Akış:

1. Kullanıcı card ID girer.
2. Backend `business_cards.card_id` ile kartı bulur.
3. Kullanıcının wallet'ında bu kart yoksa `saved_cards` kaydı oluşturulur.
4. Kart etkinliğe linklenir.

Avantaj:

- Kullanıcı "davet ettim" dediğinde kart etkinlikte hemen görünür.
- Mevcut saved card ve event group link mantığı kullanılır.

Dezavantaj:

- "Davet" ile "cüzdana kaydetme" aynı davranış olur.

#### Yaklaşım B – Ayrı event invitation tablosu

Yeni tablo:

```sql
event_group_card_invites
id uuid primary key
event_group_id uuid not null
owner_user_id uuid not null
card_id text not null
business_card_id uuid null
saved_card_id uuid null
status text not null -- invited | linked | invalid
created_at_utc timestamp not null
```

Avantaj:

- Davet ile kaydetme ayrılır.
- Geçersiz card ID audit edilebilir.
- İleride karşı tarafa bildirim/davet akışı eklenebilir.

Dezavantaj:

- MVP için daha fazla tablo ve UI durumu gerekir.

### MVP kararı

MVP için **Yaklaşım A** önerilir:

- Card ID geçerliyse kart cüzdana eklenir veya mevcut saved card bulunur.
- Ardından etkinliğe linklenir.
- Geçersiz card ID'ler response içinde `invalidCardIds` olarak döner.

İleride gerçek davet sistemi gerekirse Yaklaşım B'ye geçilir.

---

## 4. Backend DTO Değişiklikleri

### 4.1 `SaveEventGroupRequest`

Önerilen:

```csharp
public sealed class SaveEventGroupRequest
{
    public string Name { get; init; } = string.Empty;
    public string Location { get; init; } = string.Empty;
    public DateTime StartAt { get; init; }
    public DateTime? EndAt { get; init; }
    public IReadOnlyList<string> InvitedCardIds { get; init; } = [];
}
```

Geriye uyumluluk için geçiş döneminde:

```csharp
public DateTime? EventDate { get; init; }
```

bir süre korunabilir ve `StartAt` boşsa `EventDate` fallback olarak kullanılabilir.

### 4.2 `UpdateEventGroupRequest`

```csharp
public sealed class UpdateEventGroupRequest
{
    public string Id { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public string Location { get; init; } = string.Empty;
    public DateTime StartAt { get; init; }
    public DateTime? EndAt { get; init; }
    public bool ClearPhoto { get; init; }
}
```

### 4.3 `EventGroupDto`

```csharp
public sealed class EventGroupDto
{
    public string Id { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public string Location { get; init; } = string.Empty;
    public DateTime StartAt { get; init; }
    public DateTime? EndAt { get; init; }
    public string Status { get; init; } = "upcoming";
    public string? PhotoUrl { get; init; }
    public int CardCount { get; init; }
    public DateTime CreatedAt { get; init; }
}
```

Status enum:

```csharp
public static class EventGroupStatus
{
    public const string Upcoming = "upcoming";
    public const string Ongoing = "ongoing";
    public const string Ended = "ended";
}
```

---

## 5. Backend Servis İş Akışı

### 5.1 Create Event Group

Endpoint:

`POST /SaveEventGroup`

Request:

```json
{
  "name": "Web Summit 2026",
  "location": "Lisbon, Portugal",
  "startAt": "2026-11-10T09:00:00Z",
  "endAt": "2026-11-13T18:00:00Z",
  "invitedCardIds": ["CRD-123456", "CRD-987654"]
}
```

Akış:

1. Kullanıcı auth edilir.
2. Plan/quota kontrolü yapılır.
3. Name duplicate kontrolü yapılır.
4. `location`, `startAt`, `endAt` validate edilir.
5. `endAt != null && endAt < startAt` ise validation error.
6. EventGroup oluşturulur.
7. `invitedCardIds` normalize edilir:
   - trim,
   - duplicate temizleme,
   - boşları atma.
8. Her card ID için:
   - `business_cards.card_id` aranır,
   - bulunursa kullanıcı wallet'ında saved card var mı bakılır,
   - yoksa saved card oluşturulur,
   - etkinliğe linklenir.
9. Response döner.

Response önerisi:

```json
{
  "success": true,
  "data": {
    "id": "...",
    "name": "Web Summit 2026",
    "location": "Lisbon, Portugal",
    "startAt": "2026-11-10T09:00:00Z",
    "endAt": "2026-11-13T18:00:00Z",
    "status": "upcoming",
    "cardCount": 2,
    "invalidCardIds": []
  }
}
```

Not: `invalidCardIds`, DTO'da ayrı bir create-result olarak da tasarlanabilir. Temiz mimari için öneri:

- `EventGroupDto`: sadece etkinlik.
- `CreateEventGroupResultDto`: `eventGroup`, `linkedCardIds`, `invalidCardIds`.

### 5.2 List Event Groups

Endpoint seçenekleri:

#### Seçenek A – Tek endpoint + groupBy response

`GET /EventGroups`

Response:

```json
{
  "active": [],
  "ended": []
}
```

#### Seçenek B – Tek endpoint + flat list + status

`GET /EventGroups`

Response:

```json
[
  {
    "id": "...",
    "status": "ongoing"
  }
]
```

Client gruplar.

#### Seçenek C – Query ile filtre

`GET /EventGroups?status=active`

Desteklenen değerler:

- `active`: upcoming + ongoing
- `ended`
- `upcoming`
- `ongoing`
- `all`

### MVP kararı

MVP için **Seçenek B** önerilir:

- Backend her etkinliğe `status` döner.
- Client "Devam Eden / Yaklaşan" ve "Biten" olarak gruplar.
- API response breaking change minimum olur.

Sıralama:

- Active:
  - `ongoing` önce,
  - sonra `upcoming`,
  - `startAt` ascending.
- Ended:
  - `effectiveEndAt` descending.

---

## 6. Validation Kuralları

### Backend

`SaveEventGroupRequestValidator`:

- `Name`: required, max 120.
- `Location`: required, max 180.
- `StartAt`: required.
- `EndAt`: optional.
- `EndAt >= StartAt`.
- `InvitedCardIds`: max 50.
- Her card ID: max 64, trim sonrası boş olamaz.

### Flutter

Create sheet:

- İsim boş olamaz.
- Konum boş olamaz.
- Başlangıç tarihi zorunlu.
- Başlangıç saati zorunlu.
- Bitiş tarihi seçildiyse bitiş saati de istenir.
- Bitiş tarih/saati başlangıçtan önce olamaz.
- Card ID inputları duplicate ise tekilleştirilir.

---

## 7. Flutter Client İş Akışı

### 7.1 Domain Entity

`EventGroup`:

```dart
class EventGroup {
  const EventGroup({
    required this.id,
    required this.name,
    required this.location,
    required this.startAt,
    this.endAt,
    required this.status,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String location;
  final DateTime startAt;
  final DateTime? endAt;
  final EventGroupStatus status;
  final String? photoUrl;
}
```

`EventGroupStatus`:

```dart
enum EventGroupStatus {
  upcoming,
  ongoing,
  ended,
}
```

### 7.2 Create Input

```dart
class EventGroupCreateInput {
  const EventGroupCreateInput({
    required this.name,
    required this.location,
    required this.startAt,
    this.endAt,
    this.photoFilePath,
    this.invitedCardIds = const [],
  });

  final String name;
  final String location;
  final DateTime startAt;
  final DateTime? endAt;
  final String? photoFilePath;
  final List<String> invitedCardIds;
}
```

### 7.3 Create Sheet UI

Önerilen adımlar:

#### Adım 1 – Etkinlik bilgileri

Alanlar:

- Etkinlik adı
- Konum
- Başlangıç tarihi
- Başlangıç saati
- Opsiyonel: Bitiş tarihi
- Opsiyonel: Bitiş saati
- Fotoğraf

Buton:

- `Devam`

#### Adım 2 – Kart davetleri

İki sekme / iki bölüm:

1. Kayıtlı kartlardan seç
2. Card ID ile davet et

Card ID alanı:

- Text input.
- `+ Ekle` butonu.
- Eklenen card ID chip olarak listelenir.
- Duplicate ID eklenirse UI uyarır.

Buton:

- `Etkinliği oluştur`
- `X kart davet edilecek` yardımcı metni.

### 7.4 Listeleme UI

`EventGroupsPage` içinde:

```dart
final activeGroups = groups.where((g) => g.status != EventGroupStatus.ended);
final endedGroups = groups.where((g) => g.status == EventGroupStatus.ended);
```

UI:

- Section: `Devam eden etkinlikler`
  - ongoing badge: `Devam ediyor`
  - upcoming badge: `Yaklaşıyor`
- Section: `Biten etkinlikler`
  - collapsed olarak başlayabilir.

Boş state:

- Active yoksa: `Yaklaşan etkinliğiniz yok.`
- Ended yoksa section gösterilmeyebilir.

### 7.5 Tarih Formatlama

Yeni helper:

`event_group_time_formatter.dart`

Örnek çıktılar:

- `10 Kas 2026, 09:00`
- `10 Kas 09:00 – 13 Kas 18:00`
- `Bugün 14:00`
- `Devam ediyor`
- `Bitti`

Timezone:

- Backend UTC döner.
- Flutter local time'a çevirir.
- İleride timezone field kullanılacaksa display buna göre yapılır.

---

## 8. Backend Katman Dağılımı

### Domain

Değişecek:

- `EventGroup`
  - `EventDate` yerine `StartAtUtc`
  - `EndAtUtc`
  - `Location` required hale gelir.

Opsiyonel yeni value/helper:

- `EventGroupStatus`
- `EventGroupTimeStatusCalculator`

### Application DTO

Değişecek:

- `SaveEventGroupRequest`
- `UpdateEventGroupRequest`
- `EventGroupDto`

Yeni:

- `CreateEventGroupResultDto`
- `InviteEventGroupCardsRequest` (eğer create sonrası ayrı davet endpoint'i de istenirse)

### Application Service

`EventGroupService.CreateAsync`:

- start/end validation,
- create,
- card ID invite/link işlemi.

`EventGroupService.GetAllAsync`:

- status hesaplama,
- sıralama.

### Infrastructure

Değişecek:

- `EventGroupConfiguration`
- `EventGroupRepository`
- migration.

Eklenecek olası methodlar:

- `GetByUserIdOrderedAsync`
- `LinkCardsByBusinessCardIdsAsync`
- `FindOrCreateSavedCardsByCardIdsAsync` (bu aslında SavedCardService/Repository sınırında düşünülmeli)

Clean Architecture notu:

- EventGroupService, doğrudan data katmanı detaylarını bilmemeli.
- Card ID -> business card -> saved card -> link işlemi için application interface daha doğru:
  - `IEventGroupCardInviteService`
  - veya mevcut `ISavedCardService` içinde kontrollü method.

---

## 9. API Tasarım Önerisi

### MVP endpointleri

Mevcut endpoint korunur:

- `GET /EventGroups`
- `POST /SaveEventGroup`
- `PUT /UpdateEventGroup`
- `POST /LinkEventGroupCards`

Yeni veya genişletilmiş request:

- `POST /SaveEventGroup` artık `startAt`, `endAt`, `invitedCardIds` alır.

Opsiyonel yeni endpoint:

- `POST /InviteEventGroupCardsByCardId`

Request:

```json
{
  "id": "event-group-guid",
  "cardIds": ["CRD-123456"]
}
```

MVP için create içinde `invitedCardIds` yeterlidir; sonradan detay sayfasında ekleme için ayrı endpoint faydalı olur.

---

## 10. Uygulama Faz Planı

### Faz 1 – DB ve Backend Model

1. `EventGroup` entity'ye `StartAtUtc`, `EndAtUtc` ekle.
2. `EventDate` alanını geçiş için koru veya migration ile dönüştür.
3. EF configuration ve migration oluştur.
4. DTO'ları genişlet.
5. Validator kurallarını güncelle.
6. Mapper'a `status` hesaplama ekle.

Başarı kriteri:

- `GET /EventGroups` her etkinlikte `startAt`, `endAt`, `status` döner.

### Faz 2 – Create/Update Servis Akışı

1. `SaveEventGroupRequest` içinde `startAt`, `endAt`, `invitedCardIds` destekle.
2. `EndAt < StartAt` validation ekle.
3. Create sırasında card ID normalize/validate et.
4. Geçerli card ID'leri saved card olarak bul/oluştur/linkle.
5. Geçersiz card ID'leri response içinde raporla.

Başarı kriteri:

- Etkinlik oluşturulurken girilen geçerli card ID'ler etkinliğe bağlı görünür.

### Faz 3 – Flutter Domain/Data

1. `EventGroup` entity'yi güncelle.
2. `EventGroupModel.fromJson/toJson` güncelle.
3. `EventGroupCreateInput` güncelle.
4. `EventGroupRemoteDataSource.createEventGroup` body'ye `startAt`, `endAt`, `invitedCardIds` ekle.
5. Repository/usecase imzalarını güncelle.

Başarı kriteri:

- Flutter create isteği backend'in yeni DTO'su ile uyumlu olur.

### Faz 4 – Flutter Create UI

1. Create sheet adım 1'e:
   - başlangıç tarihi,
   - başlangıç saati,
   - konum required,
   - opsiyonel bitiş tarihi/saati
   ekle.
2. Adım 2'ye card ID input alanı ekle.
3. Card ID chip listesi ve silme aksiyonu ekle.
4. Form validation ve kullanıcı dostu hata mesajları ekle.

Başarı kriteri:

- Kullanıcı etkinliği başlangıç/bitiş ve card ID davetleriyle oluşturur.

### Faz 5 – Listeleme UI

1. `EventGroupsPage` içinde grupları status'a göre ayır.
2. `Devam eden / Yaklaşan` section'ı ekle.
3. `Biten etkinlikler` section'ı ekle.
4. Badge ve tarih format helper ekle.
5. Empty state'leri düzenle.

Başarı kriteri:

- Aktif ve biten etkinlikler ayrı başlıklarla listelenir.

### Faz 6 – Detay ve Sonradan Davet

1. Event detail sayfasında başlangıç/bitiş/konum banner'ı güncelle.
2. Detail sayfasına `Card ID ile davet et` aksiyonu ekle.
3. Opsiyonel `POST /InviteEventGroupCardsByCardId` endpoint'i ekle.

Başarı kriteri:

- Kullanıcı etkinlik oluşturduktan sonra da card ID ile kart ekleyebilir.

---

## 11. Test Planı

### Backend

- `startAt` boşsa validation error.
- `location` boşsa validation error.
- `endAt < startAt` ise validation error.
- `endAt == null` create başarılı.
- `invitedCardIds` duplicate ise tek link oluşur.
- Geçersiz card ID response içinde raporlanır.
- `GET /EventGroups` status hesaplar:
  - future -> upcoming
  - between -> ongoing
  - past -> ended
- Kullanıcı başka kullanıcının etkinliğine kart linkleyemez.

### Database

- Migration eski kayıtları kaybetmez.
- `start_at_utc` indeksleri query performansını destekler.
- EventGroup delete cascade linkleri temizler.

### Flutter

- Başlangıç tarihi/saati seçmeden submit edilemez.
- Bitiş başlangıçtan önceyse hata gösterilir.
- Card ID duplicate eklenmez.
- Create request doğru JSON gönderir.
- Active/ended liste ayrımı doğru çalışır.
- Local timezone display doğru görünür.

---

## 12. MVP Kararı

İlk uygulanacak en küçük güvenli kapsam:

1. `startAt` zorunlu.
2. `endAt` opsiyonel.
3. `location` zorunlu.
4. `status` backend tarafından hesaplanır ve DTO'da döner.
5. `invitedCardIds` create request içinde desteklenir.
6. Card ID geçerliyse saved card oluşturulur/linklenir.
7. Client active/ended olarak gruplar.

Bu kapsam, yeni kullanıcı ihtiyacını karşılar ve ileride gerçek davet/bildirim sistemine geçmek için yolu açık bırakır.
