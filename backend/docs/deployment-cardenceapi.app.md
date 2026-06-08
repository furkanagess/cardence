# cardenceapi.app — Domain ve Production Deploy

Production API adresi: **https://cardenceapi.app**

---

## Mevcut durum

`cardenceapi.app` Cloudflare nameserver'larında (`alla.ns.cloudflare.com`).  
DNS kaydı yoksa **Cloudflare Tunnel** ile bağlanır — bkz. [`deploy/README.md`](../deploy/README.md).

```bash
cd backend/deploy
./scripts/start-api.sh
./scripts/connect-domain.sh   # ilk seferde tarayıcı ile Cloudflare login
```

---

## Adım 1 — Domain satın al

`.app` domainleri Google Registry üzerinden satılır.

1. [Cloudflare Registrar](https://dash.cloudflare.com/?to=/:account/domains/register) veya Namecheap'e git
2. `cardenceapi.app` ara ve satın al
3. Nameserver'ları hosting sağlayıcına veya Cloudflare'e yönlendir

---

## Adım 2 — API'yi deploy et

### Seçenek A — Railway (önerilen, hızlı)

#### Monorepo — zorunlu Railway ayarı

Set the **Root Directory** to `backend` in the Railway service settings.

This is a monorepo where the repo root is a **Flutter** project, but the **.NET API** lives in the `backend` subdirectory. Without this setting, Railway builds from the Flutter root, ignores the config files in `backend/`, and **Railpack** fails because Flutter/Dart is not a supported deploy language.

Railway Dashboard → API servisi → **Settings**:

| Ayar | Değer | Neden |
|------|-------|-------|
| **Root Directory** | `backend` | Build `backend/Dockerfile` üzerinden yapılır |
| **Config file path** | `/backend/railway.toml` | Config dosyası root directory'yi takip etmez |
| **Builder** | **Dockerfile** | Railpack Flutter kökünü build etmeye çalışır |

1. [railway.app](https://railway.app) → New Project → Deploy from GitHub
2. Repo: `cardence`
3. Yukarıdaki **Settings** tablosunu uygula
4. **PostgreSQL ekle** (aşağıdaki bölüm — API bu olmadan crash eder)
5. **Variables** ekle:

| Variable                     | Değer                        |
| ---------------------------- | ---------------------------- |
| `ASPNETCORE_ENVIRONMENT`     | `Production`                 |
| `ConnectionStrings__Default` | `${{Postgres.DATABASE_PRIVATE_URL}}` (bkz. PostgreSQL bölümü) |
| `Jwt__SigningKey`            | Güçlü rastgele 32+ karakter  |
| `Api__PublicBaseUrl`         | `https://cardenceapi.app`    |
| `AllowedHosts`               | `cardenceapi.app;www.cardenceapi.app;healthcheck.railway.app` |
| `Database__UseInMemory`      | `false`                      |

6. **Settings → Networking → Custom Domain** → `cardenceapi.app` ekle
7. Railway'in verdiği CNAME hedefini domain DNS'ine yaz

#### PostgreSQL (Railway) — zorunlu

API başlangıçta EF Core migration çalıştırır (`Program.cs`). `appsettings.json` içindeki
varsayılan `localhost:5432` Railway container'ında yoktur; PostgreSQL servisi olmadan uygulama
**startup'ta crash** eder.

**1. PostgreSQL servisi ekle**

Railway proje canvas → **+ New** → **Database** → **PostgreSQL**

Servis adı genelde `Postgres` olur (farklıysa aşağıdaki referansta adı değiştirin).

**2. cardence API servisine connection string bağla**

cardence API servisi → **Variables** → **New Variable**:

| Name | Value |
|------|-------|
| `ConnectionStrings__Default` | `${{Postgres.DATABASE_PRIVATE_URL}}` |

Railway UI'da **Add Reference** → PostgreSQL servisi → `DATABASE_PRIVATE_URL` seçmek de aynı işi yapar.

> `DATABASE_PRIVATE_URL` internal network üzerinden bağlanır (önerilen).  
> Alternatif: `DATABASE_PUBLIC_URL` (dış erişim; genelde gerekmez).

**3. Npgsql format (manuel kopyalarsanız)**

PostgreSQL servisi → **Connect** → **Public Network** veya **Private Network** URL:

```
Host=containers-us-west-xxx.railway.app;Port=5432;Database=railway;Username=postgres;Password=SECRET;SSL Mode=Require;Trust Server Certificate=true
```

**4. Redeploy**

Variables kaydedildikten sonra API servisini **Redeploy** edin. Log'da şunu görmelisiniz:

```
Database migrations applied.
```

**5. Otomatik fallback (kod)**

API ayrıca şu ortam değişkenlerini de okur (ConnectionStrings set edilmemişse):

- `DATABASE_URL` / `DATABASE_PRIVATE_URL`
- `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`

Yine de Railway'de `ConnectionStrings__Default` referansını açıkça set etmek en güvenilir yoldur.

Örnek env listesi: [`railway.env.example`](../railway.env.example)

### Seçenek B — Docker (VPS / Fly.io)

```bash
cd backend
docker build -t cardence-api .
docker run -d -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__Default="Host=...;..." \
  -e Jwt__SigningKey="..." \
  -e Api__PublicBaseUrl="https://cardenceapi.app" \
  cardence-api
```

Fly.io:

```bash
fly launch --dockerfile Dockerfile
fly secrets set Jwt__SigningKey=... ConnectionStrings__Default=...
fly certs add cardenceapi.app
```

---

## Adım 3 — DNS kayıtları

Domain panelinde (Cloudflare önerilir):

| Tip   | Ad    | Hedef                        |
| ----- | ----- | ---------------------------- |
| CNAME | `@`   | Railway/Fly verilen hostname |
| CNAME | `www` | Railway/Fly verilen hostname |

Cloudflare'de **SSL/TLS → Full** seç; proxy (turuncu bulut) açık olsun.

`.app` TLD **HTTPS zorunlu** tutar — HTTP-only çalışmaz.

---

## Adım 4 — Doğrula

```bash
curl https://cardenceapi.app/health/ready
```

Swagger (yalnızca Development ortamında açık):

- Production'da kapalıdır (`Program.cs`)

---

## Adım 5 — Flutter production build

Release build otomatik `https://cardenceapi.app` kullanır:

```bash
flutter build ios --release
flutter build appbundle --release
```

Override:

```bash
flutter run --dart-define=API_BASE_URL=https://cardenceapi.app
```

---

## Ortam özeti

| Ortam                   | API URL                   |
| ----------------------- | ------------------------- |
| Local dev (simulator)   | `http://localhost:5241`   |
| Local dev (Android emu) | `http://10.0.2.2:5241`    |
| Production              | `https://cardenceapi.app` |

---

## Güvenlik checklist

- [ ] `Jwt__SigningKey` production'da güçlü ve gizli
- [ ] `appsettings.Production.json` git'e **girmez**
- [ ] PostgreSQL SSL (`SSL Mode=Require`)
- [ ] Swagger production'da kapalı (mevcut)
- [ ] `AllowedHosts` = `cardenceapi.app;www.cardenceapi.app;healthcheck.railway.app`

---

## Sorun giderme

| Sorun                | Çözüm                                                               |
| -------------------- | ------------------------------------------------------------------- |
| `railpack process exited with an error` | Root Directory = `backend`; Config = `/backend/railway.toml`; Builder = Dockerfile |
| `Railpack could not determine how to build` | Aynı — Flutter kökü build edilmeye çalışılıyor |
| `scheduling build on Metal builder` sonra fail | Settings → Build → Metal build environment kapat; veya config path doğrula |
| `NXDOMAIN`           | Domain henüz satın alınmamış veya DNS yayılmamış (24–48 saat bekle) |
| SSL hatası           | Cloudflare SSL Full; platform sertifikası aktif mi kontrol et       |
| 502 Bad Gateway      | Container çalışıyor mu; `ConnectionStrings` doğru mu                |
| Startup crash / `localhost:5432` | PostgreSQL servisi ekle; `ConnectionStrings__Default=${{Postgres.DATABASE_PRIVATE_URL}}` |
| `Database startup failed` log | Postgres servisi ayakta mı; variable referansı doğru servis adına mı bağlı |
| Healthcheck 14x "service unavailable" | `AllowedHosts` içinde `healthcheck.railway.app` olmalı; PORT/ASPNETCORE_URLS uyumu |
| Flutter bağlanamıyor | Release build mi; `ApiConfig.productionBaseUrl` kontrol et          |

### Railway deploy log'unda ne görmelisiniz?

Başarılı build:
```
Using Detected Dockerfile
# veya
builder = DOCKERFILE
```

Yanlış build (düzeltilmeli):
```
Railpack 0.x.x
No start command was found
```
