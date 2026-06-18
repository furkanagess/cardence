# Cardence – Giriş Yöntemleri

> **Güncel rehber:** Google, Apple ve LinkedIn bağlantısı için ayrıntılı adımlar → **[SOCIAL_LOGIN_SETUP.md](./SOCIAL_LOGIN_SETUP.md)**

---

## Desteklenen yöntemler

| Yöntem | Durum | Oturum |
|--------|-------|--------|
| E-posta + şifre | ✅ Çalışıyor | Cardence API JWT |
| Telefon + şifre | ✅ Çalışıyor | Cardence API JWT |
| E-posta / telefon OTP | ✅ Backend hazır | Cardence API JWT |
| **Google** | ⏳ UI placeholder | Planlandı → [rehber](./SOCIAL_LOGIN_SETUP.md#3-google-ile-giriş) |
| **Apple** | ⏳ UI placeholder | Planlandı → [rehber](./SOCIAL_LOGIN_SETUP.md#4-apple-ile-giriş) |
| **LinkedIn** | ⏳ Henüz UI yok | Planlandı → [rehber](./SOCIAL_LOGIN_SETUP.md#5-linkedin-ile-giriş) |

---

## Mimari (özet)

Sosyal girişler **Firebase Auth kullanmaz**. Akış:

1. Flutter → native SDK (Google / Apple / LinkedIn)
2. Token veya authorization code → `POST /LoginWithGoogle|Apple|LinkedIn`
3. Backend doğrular → JWT + refresh token döner
4. Flutter mevcut `AuthRepository` ile oturumu saklar

---

## Proje sabitleri

`lib/core/constants/auth_constants.dart`:

- `AuthProvider`: `google`, `apple`, `phone`, `linkedin`
- Provider ID’ler: `google.com`, `apple.com`, `phone`, `linkedin.com`

---

## Paketler (`pubspec.yaml`)

```yaml
google_sign_in: ^6.2.2
sign_in_with_apple: ^6.1.3
linkedin_login: ^2.2.1
```

Entegrasyon adımları ve konsol yapılandırması → **[SOCIAL_LOGIN_SETUP.md](./SOCIAL_LOGIN_SETUP.md)**

---

## Eski Firebase notu

Bu dosyanın önceki sürümü Firebase Auth (`signInWithCredential`, Firestore) akışını anlatıyordu. Cardence backend’i (.NET + PostgreSQL + JWT) devreye girdiği için sosyal giriş dokümantasyonu **SOCIAL_LOGIN_SETUP.md** altında güncellenmiştir.
