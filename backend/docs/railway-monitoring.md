# Railway üzerinden Cardence izleme

Production API (`cardenceapi.app`) ve PostgreSQL servisini Railway dashboard + API health endpoint'leri ile takip etme rehberi.

---

## Hızlı kontrol (terminal)

```bash
cd backend/deploy/scripts
chmod +x railway-monitor.sh

# API + DB bağlantısı (Railway healthcheck ile aynı)
./railway-monitor.sh

# Tablo sayıları dahil (Railway'de Monitoring__ApiKey tanımlı olmalı)
MONITORING_KEY="your-secret-key" ./railway-monitor.sh
```

Tek satır:

```bash
curl -s https://cardenceapi.app/health/ready | python3 -m json.tool
curl -s https://cardenceapi.app/health/status -H "X-Monitoring-Key: YOUR_KEY" | python3 -m json.tool
```

---

## Endpoint'ler

| Endpoint | Amaç | Railway |
|----------|------|---------|
| `GET /health/ready` | API + PostgreSQL canlı mı | Otomatik healthcheck (`railway.toml`) |
| `GET /health/status` | Ortam, DB gecikmesi, isteğe bağlı tablo sayıları | Manuel / script / UptimeRobot |
| `GET /Health` | Basit API yanıtı (legacy) | Opsiyonel |

### `/health/ready` örnek yanıt

```json
{
  "status": "Healthy",
  "totalDurationMs": 42.5,
  "checks": {
    "postgresql": {
      "status": "Healthy",
      "durationMs": 38.2,
      "description": null,
      "exception": null
    }
  }
}
```

PostgreSQL erişilemezse HTTP **503** döner; Railway servisi yeniden başlatmayı dener.

### `/health/status` örnek yanıt (detaylı)

`Monitoring__ApiKey` Railway'de set edilmiş ve istekte `X-Monitoring-Key` header'ı gönderilmişse:

```json
{
  "status": "healthy",
  "service": "Cardence.Api",
  "environment": "Production",
  "publicBaseUrl": "https://cardenceapi.app",
  "database": {
    "status": "healthy",
    "provider": "PostgreSQL",
    "latencyMs": 15,
    "counts": {
      "users": 12,
      "businessCards": 8,
      "savedCards": 24,
      "walletEntitlements": 12,
      "authRefreshTokens": 5
    }
  },
  "timestamp": "2026-06-04T12:00:00Z",
  "detailsIncluded": true
}
```

Key olmadan yalnızca bağlantı durumu ve gecikme döner (`counts: null`, `detailsIncluded: false`).

---

## Railway Dashboard

### 1. API servisi (cardence)

| Sekme | Ne izlersin |
|-------|-------------|
| **Deployments** | Son deploy, healthcheck geçti mi |
| **Metrics** | CPU, bellek, istek hacmi |
| **Logs** | `Database migrations applied.`, hata logları |
| **Settings → Healthcheck** | Path: `/health/ready` (otomatik `railway.toml`) |

### 2. PostgreSQL servisi

| Sekme | Ne izlersin |
|-------|-------------|
| **Metrics** | Disk, bağlantı, CPU |
| **Data / Query** | SQL ile canlı veri (`SELECT * FROM users LIMIT 10`) |
| **Connect** | Public/Private URL (TablePlus, DBeaver) |

### 3. Zorunlu environment variables (API servisi)

| Variable | Değer |
|----------|--------|
| `ConnectionStrings__Default` | `${{Postgres.DATABASE_PRIVATE_URL}}` |
| `Database__UseInMemory` | `false` |
| `Monitoring__ApiKey` | Güçlü rastgele anahtar (tablo sayıları için) |

Örnek tam liste: [`railway.env.example`](../railway.env.example)

---

## Periyodik izleme (7/24)

Ücretsiz uptime servisi (UptimeRobot, Better Stack vb.):

- URL: `https://cardenceapi.app/health/ready`
- Aralık: 5 dakika
- Beklenen: HTTP 200, body'de `"status": "Healthy"`

Tablo sayıları için ayrı monitor (HTTP header destekleyen):

- URL: `https://cardenceapi.app/health/status`
- Header: `X-Monitoring-Key: <Monitoring__ApiKey>`
- Beklenen: HTTP 200, `"status": "healthy"`

---

## GUI ile veri takibi

Railway → PostgreSQL → **Connect** → Public Network URL:

| Alan | Kaynak |
|------|--------|
| Host / Port | Connect sekmesi |
| Database | genelde `railway` |
| User | `postgres` |
| SSL | Require |

**TablePlus / DBeaver** ile bağlan; sık kullanılan sorgular:

```sql
SELECT count(*) FROM users;
SELECT count(*) FROM cards;
-- Wallet entries live on users.saved_card_ids (compat view: saved_cards)
SELECT COALESCE(SUM(jsonb_array_length(COALESCE(saved_card_ids, '[]'::jsonb))), 0)
FROM users;
SELECT "Id", display_name, email, created_at FROM users ORDER BY created_at DESC LIMIT 20;
```

---

## Local vs Production

| Ortam | API | Veritabanı |
|-------|-----|------------|
| Production | `https://cardenceapi.app` | Railway PostgreSQL |
| Local | `http://localhost:5241` | `docker compose` → `localhost:5432/cardence` |

Local izleme:

```bash
curl -s http://localhost:5241/health/ready | python3 -m json.tool
cd backend/database && docker compose exec postgres psql -U postgres -d cardence -c "SELECT count(*) FROM users;"
```

---

## Sorun giderme

| Belirti | Kontrol |
|---------|---------|
| `/health/ready` 503 | Postgres servisi ayakta mı; `ConnectionStrings__Default` referansı doğru mu |
| `postgresql: Unhealthy` | Railway Postgres logları; migration hatası API loglarında |
| `detailsIncluded: false` | `Monitoring__ApiKey` set edilmemiş veya header eksik |
| Healthcheck 14x fail | `AllowedHosts` içinde `healthcheck.railway.app` olmalı |

Detaylı deploy: [`deployment-cardenceapi.app.md`](deployment-cardenceapi.app.md)
