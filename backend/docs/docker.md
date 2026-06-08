# Docker — Cardence Geliştirme Rehberi

Bu doküman, macOS'ta Docker'ın **nerede** kurulu olduğunu, **nasıl** kullanılacağını ve Cardence backend + PostgreSQL projesiyle **nasıl entegre** edileceğini açıklar.

**İlgili dosyalar:**

| Dosya | İçerik |
|-------|--------|
| [docker.md](./docker.md) | **Bu dosya** — Docker kurulum ve kullanım |
| [database/README.md](../database/README.md) | PostgreSQL hızlı başlangıç |
| [database-design.md](./database-design.md) | Veritabanı şeması |

---

## İçindekiler

1. [Docker bu sistemde nerede?](#1-docker-bu-sistemde-nerede)
2. [Docker Desktop arayüzü](#2-docker-desktop-arayüzü)
3. [Cardence'te Docker ne işe yarar?](#3-cardencete-docker-ne-işe-yarar)
4. [Proje yapısı](#4-proje-yapısı)
5. [İlk kurulum](#5-ilk-kurulum)
6. [Günlük kullanım komutları](#6-günlük-kullanım-komutları)
7. [Veritabanı takibi](#7-veritabanı-takibi)
8. [Backend ile entegrasyon](#8-backend-ile-entegrasyon)
9. [Mobil (Flutter) ile ilişki](#9-mobil-flutter-ile-ilişki)
10. [Docker vs Homebrew PostgreSQL](#10-docker-vs-homebrew-postgresql)
11. [Sorun giderme](#11-sorun-giderme)
12. [Komut özeti](#12-komut-özeti)

---

## 1. Docker bu sistemde nerede?

### Kurulum konumları (macOS)

| Bileşen | Yol |
|---------|-----|
| Docker Desktop uygulaması | `/Applications/Docker.app` |
| `docker` CLI | `/usr/local/bin/docker` |
| `docker-compose` (legacy) | `/usr/local/bin/docker-compose` |
| Compose eklentisi | `~/.docker/cli-plugins/docker-compose` |
| Docker veri / ayarlar | `~/.docker/` |
| Container volume'ları | Docker Desktop VM içinde (`cardence_pg_data`) |

### Sürüm kontrolü

```bash
docker --version
# Docker version 29.x.x

docker compose version
# Docker Compose version v5.x.x

docker info
# Daemon çalışıyorsa Server bölümü görünür
```

### Docker Desktop çalışıyor mu?

Terminalde şu hata alırsan Docker Desktop kapalıdır:

```
Cannot connect to the Docker daemon...
```

**Çözüm:** Spotlight'ta `Docker` ara → uygulamayı aç → menü çubuğunda balina ikonu yeşil olana kadar bekle.

---

## 2. Docker Desktop arayüzü

Docker Desktop, container'ları görsel olarak yönetmeni sağlar.

| Sekme | Ne yaparsın |
|-------|-------------|
| **Containers** | Çalışan/duran container'lar (`cardence-postgres`) |
| **Images** | İndirilen imajlar (`postgres:16-alpine`) |
| **Volumes** | Kalıcı veri (`cardence_pg_data`) |
| **Logs** | Container loglarını canlı izle |

**Container'a tıkla** → Logs / Exec / Files sekmelerinden DB'yi takip edebilirsin.

---

## 3. Cardence'te Docker ne işe yarar?

Cardence projesinde Docker şu an **yalnızca PostgreSQL** için kullanılır:

```
┌─────────────────┐     HTTP      ┌─────────────────┐     EF Core     ┌──────────────────────┐
│  Flutter (mobil)│ ────────────► │  Cardence.Api   │ ──────────────► │  PostgreSQL (Docker) │
│  iOS / Android  │               │  .NET 10        │                 │  cardence-postgres   │
└─────────────────┘               └─────────────────┘                 └──────────────────────┘
```

- **Mobil** → API'ye istek atar (PostgreSQL'e doğrudan bağlanmaz)
- **Backend** → `localhost:5432` üzerinden Docker'daki PostgreSQL'e bağlanır
- **Docker** → PostgreSQL'i izole container'da çalıştırır; veri volume'da kalıcıdır

> API şu an Docker'da değil, doğrudan `dotnet run` ile çalışır. Yalnızca veritabanı container'dadır.

---

## 4. Proje yapısı

```
backend/database/
├── docker-compose.yml    # PostgreSQL servis tanımı
├── .env.example          # Ortam değişkenleri şablonu
├── .env                  # Local ayarlar (git'e girmez)
├── init/
│   └── 01-init.sql       # İlk kurulum SQL (pgcrypto vb.)
└── scripts/
    ├── start.sh          # Docker veya Homebrew ile DB başlat
    ├── stop.sh           # DB durdur
    └── migrate.sh        # EF Core migration uygula
```

### `docker-compose.yml` özeti

| Ayar | Değer |
|------|-------|
| Container adı | `cardence-postgres` |
| İmaj | `postgres:16-alpine` |
| Port | `5432:5432` (host:container) |
| Veritabanı | `cardence` |
| Kullanıcı / şifre | `postgres` / `dev` |
| Kalıcı volume | `cardence_pg_data` |

---

## 5. İlk kurulum

### Adım 1 — Docker Desktop'ı aç

Uygulamayı başlat ve daemon'un hazır olmasını bekle.

### Adım 2 — Ortam dosyasını oluştur

```bash
cd backend/database
cp .env.example .env
```

`.env` içeriği (varsayılan):

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=dev
POSTGRES_DB=cardence
POSTGRES_PORT=5432
```

### Adım 3 — PostgreSQL container'ını başlat

```bash
chmod +x scripts/*.sh
./scripts/start.sh
```

`start.sh` önce Docker'ı dener; Docker yoksa Homebrew PostgreSQL'e düşer.

Alternatif (doğrudan compose):

```bash
cd backend/database
docker compose up -d
```

### Adım 4 — Tabloları oluştur (EF migration)

```bash
./scripts/migrate.sh
```

veya:

```bash
cd backend
dotnet ef database update \
  --project Cardence.Infrastructure \
  --startup-project Cardence.Api
```

### Adım 5 — Backend'i çalıştır

```bash
cd backend
dotnet watch run --project Cardence.Api
```

Swagger: https://localhost:7241/swagger

---

## 6. Günlük kullanım komutları

Tüm komutlar `backend/database` dizininden çalıştırılır.

### Başlat / durdur

```bash
# Başlat (arka planda)
docker compose up -d

# Durdur (veri korunur)
docker compose down

# Durdur + volume sil (TÜM VERİ SİLİNİR!)
docker compose down -v
```

Script ile:

```bash
./scripts/start.sh
./scripts/stop.sh
```

### Durum kontrolü

```bash
docker compose ps
docker compose logs postgres
docker compose logs -f postgres    # canlı log
```

### Container içine girme

```bash
# psql shell
docker compose exec postgres psql -U postgres -d cardence

# bash shell
docker compose exec postgres sh
```

### İmaj ve volume listesi

```bash
docker images | grep postgres
docker volume ls | grep cardence
```

---

## 7. Veritabanı takibi

### Terminal (psql)

```bash
docker compose exec postgres psql -U postgres -d cardence
```

```sql
\dt                                    -- tablolar
SELECT * FROM users;                   -- kullanıcılar
SELECT * FROM business_cards;          -- kartlar
SELECT * FROM "__EFMigrationsHistory"; -- migration geçmişi
\q
```

### GUI araçları

DBeaver, TablePlus veya pgAdmin ile bağlan:

| Alan | Değer |
|------|-------|
| Host | `localhost` |
| Port | `5432` |
| Database | `cardence` |
| User | `postgres` |
| Password | `dev` |

### Docker Desktop

**Containers** → `cardence-postgres` → **Logs** sekmesi.

---

## 8. Backend ile entegrasyon

Backend bağlantı ayarı `Cardence.Api/appsettings.Development.json`:

```json
{
  "Database": {
    "UseInMemory": false
  },
  "ConnectionStrings": {
    "Default": "Host=localhost;Port=5432;Database=cardence;Username=postgres;Password=dev"
  }
}
```

| `UseInMemory` | Davranış |
|---------------|----------|
| `false` | Docker/Homebrew PostgreSQL kullanılır |
| `true` | Bellek içi DB (veri API yeniden başlayınca silinir) |

API açılışında (`Program.cs`):

- PostgreSQL → `MigrateAsync()` (EF migration otomatik uygulanır)
- In-memory → `EnsureCreatedAsync()`

### Servis ↔ tablo eşlemesi

| API endpoint | Tablo |
|--------------|-------|
| `POST /Authentication` | `users` |
| `POST /LoginWithPhone`, `/LoginWithEmail` | `users` |
| `GET /BusinessCards`, `POST /SaveBusinessCard`… | `business_cards` |
| `GET /PublicBusinessCardShare?cardId=` | `business_cards` |

---

## 9. Mobil (Flutter) ile ilişki

Flutter uygulaması **Docker'a veya PostgreSQL'e doğrudan bağlanmaz**. Yalnızca backend API'ye HTTP isteği atar.

| Ortam | API base URL |
|-------|----------------|
| iOS Simulator | `https://localhost:7241` |
| Android Emulator | `https://10.0.2.2:7241` |
| Fiziksel cihaz | Mac'in LAN IP'si (ör. `https://192.168.1.42:7241`) |

**Geliştirme akışı:**

1. `docker compose up -d` → PostgreSQL hazır
2. `dotnet watch run --project Cardence.Api` → API hazır
3. Flutter uygulamasını çalıştır → API'ye istek at
4. API → Docker PostgreSQL'e yazar/okur

---

## 10. Docker vs Homebrew PostgreSQL

Sistemde iki seçenek var; **ikisi aynı anda 5432 portunu kullanamaz**.

| | Docker (önerilen) | Homebrew |
|--|-------------------|----------|
| Kurulum | Docker Desktop | `brew install postgresql@16` |
| Başlatma | `docker compose up -d` | `brew services start postgresql@16` |
| Veri izolasyonu | Container volume | `/opt/homebrew/var/postgresql@16` |
| Temizlik | `docker compose down -v` | `brew services stop` + data dir sil |
| Takip | Docker Desktop + `docker compose logs` | `brew services list` + `psql` |

`./scripts/start.sh` öncelik sırası:

1. Docker varsa → `docker compose up -d`
2. Yoksa Homebrew PostgreSQL → `brew services start`

**Port çakışması** alırsan birini durdur:

```bash
# Homebrew PostgreSQL'i durdur
brew services stop postgresql@16

# Sonra Docker'ı başlat
cd backend/database && docker compose up -d
```

---

## 11. Sorun giderme

### `Cannot connect to the Docker daemon`

Docker Desktop kapalı. Uygulamayı aç ve balina ikonunun yeşil olmasını bekle.

### Port 5432 already in use

Başka bir PostgreSQL (Homebrew veya eski container) portu kullanıyor.

```bash
lsof -i :5432
brew services stop postgresql@16
docker compose down
docker compose up -d
```

### Container başlıyor ama API bağlanamıyor

```bash
docker compose ps                          # healthy mi?
docker compose exec postgres pg_isready -U postgres -d cardence
```

Connection string'de `Host=localhost;Port=5432` olduğundan emin ol.

### Tablolar yok

```bash
cd backend/database && ./scripts/migrate.sh
```

### Veriyi sıfırla (sıfırdan başla)

```bash
cd backend/database
docker compose down -v          # volume silinir
docker compose up -d
./scripts/migrate.sh
```

### `docker: command not found`

PATH'e ekle (genelde Docker Desktop bunu otomatik yapar):

```bash
export PATH="/usr/local/bin:$PATH"
```

Kalıcı çözüm — `~/.zshrc`:

```bash
export PATH="/usr/local/bin:$PATH"
```

---

## 12. Komut özeti

```bash
# ── Kurulum (bir kez) ──
cd backend/database
cp .env.example .env
chmod +x scripts/*.sh

# ── Her geliştirme oturumu ──
./scripts/start.sh                              # PostgreSQL başlat
./scripts/migrate.sh                            # migration (gerekirse)
cd .. && dotnet watch run --project Cardence.Api  # API başlat

# ── Takip ──
docker compose ps                               # durum
docker compose logs -f postgres                 # log
docker compose exec postgres psql -U postgres -d cardence  # SQL shell

# ── Bitir ──
./scripts/stop.sh                               # DB durdur
```

---

## Doküman seti

| Dosya | Rol |
|-------|-----|
| `backend/docs/docker.md` | Docker rehberi — bu dosya |
| `backend/database/README.md` | PostgreSQL hızlı başlangıç |
| `backend/docs/database-design.md` | Şema ve tablo detayları |
| `backend/docs/dotnet-backend-api.md` | API endpoint referansı |
| `backend/README.md` | Backend genel bakış |

*Son güncelleme: Docker Desktop + `backend/database/docker-compose.yml` yapılandırmasına göre hazırlanmıştır.*
