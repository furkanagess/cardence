# cardenceapi.app ↔ Backend bağlantısı

Domain **Cloudflare** üzerinde (`alla.ns.cloudflare.com`). DNS kaydı + tunnel ile backend'e bağlanır.

## Mimari

```
Mobil / İnternet
      │
      ▼
https://cardenceapi.app  (Cloudflare DNS + SSL)
      │
      ▼
Cloudflare Tunnel (cloudflared)
      │
      ▼
Docker: cardence-api :8080
      │
      ▼
PostgreSQL (cardence-postgres :5432)
```

## Hızlı kurulum (tek seferlik)

### 1. API'yi başlat

```bash
cd backend/deploy
./scripts/start-api.sh
```

Doğrula:

```bash
curl http://localhost:8080/health/ready
# Healthy
```

### 2. Domain'i bağla (tarayıcı gerekir)

```bash
./scripts/connect-domain.sh
```

İlk çalıştırmada:

1. Cloudflare hesabına giriş penceresi açılır
2. `cardenceapi.app` zone'unu seç
3. Tunnel + DNS otomatik oluşturulur
4. `https://cardenceapi.app` → local API'ye yönlenir

### 3. Test

```bash
curl https://cardenceapi.app/health/ready
```

## Günlük kullanım

Tek komut (API + tunnel arka planda):

```bash
cd backend/deploy
./scripts/start-all.sh
```

Ayrı ayrı:

```bash
./scripts/start-api.sh      # Docker API :8080
./scripts/start-tunnel.sh   # cloudflared arka planda
./scripts/stop-tunnel.sh    # tunnel durdur
```

PostgreSQL:

```bash
cd backend/database && docker compose up -d
```

> **1033 hatası:** `cloudflared` kapalıysa oluşur. `curl http://localhost:8080/health/ready` Healthy iken
> `https://cardenceapi.app` 1033 veriyorsa → `./scripts/start-tunnel.sh`

## Flutter

Release build otomatik `https://cardenceapi.app` kullanır.

Local'de production API test:

```bash
flutter run --dart-define=API_BASE_URL=https://cardenceapi.app
```

## Sorun giderme

| Sorun              | Çözüm                                                  |
| ------------------ | ------------------------------------------------------ |
| `Invalid Hostname` | `AllowedHosts` docker-compose'ta localhost içeriyor mu |
| Tunnel login       | `cloudflared tunnel login` tekrar çalıştır             |
| DB bağlantı hatası | `cardence-postgres` çalışıyor mu: `docker ps`          |
| DNS yayılmadı      | Cloudflare dashboard → DNS → CNAME `cardenceapi.app`   |
