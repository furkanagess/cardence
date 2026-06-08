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

1. [railway.app](https://railway.app) → New Project → Deploy from GitHub
2. Repo: `cardence`, root directory: `backend`
3. Railway otomatik `Dockerfile` algılar
4. **Variables** ekle:

| Variable                     | Değer                        |
| ---------------------------- | ---------------------------- |
| `ASPNETCORE_ENVIRONMENT`     | `Production`                 |
| `ConnectionStrings__Default` | PostgreSQL connection string |
| `Jwt__SigningKey`            | Güçlü rastgele 32+ karakter  |
| `Api__PublicBaseUrl`         | `https://cardenceapi.app`    |
| `AllowedHosts`               | `cardenceapi.app`            |

5. PostgreSQL ekle: Railway → Add PostgreSQL → connection string'i kopyala
6. **Settings → Networking → Custom Domain** → `cardenceapi.app` ekle
7. Railway'in verdiği CNAME hedefini domain DNS'ine yaz

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
- [ ] `AllowedHosts` = `cardenceapi.app`

---

## Sorun giderme

| Sorun                | Çözüm                                                               |
| -------------------- | ------------------------------------------------------------------- |
| `NXDOMAIN`           | Domain henüz satın alınmamış veya DNS yayılmamış (24–48 saat bekle) |
| SSL hatası           | Cloudflare SSL Full; platform sertifikası aktif mi kontrol et       |
| 502 Bad Gateway      | Container çalışıyor mu; `ConnectionStrings` doğru mu                |
| Flutter bağlanamıyor | Release build mi; `ApiConfig.productionBaseUrl` kontrol et          |
