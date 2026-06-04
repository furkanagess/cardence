# Cardence – Giriş Yöntemleri (4 Yöntem)

Uygulama dört giriş yöntemini destekler: **Google**, **Apple**, **Telefon**, **LinkedIn**.

---

## 1. Genel Bakış

| Yöntem    | Paket / Servis              | Firebase Auth          | Not                          |
|-----------|-----------------------------|-------------------------|------------------------------|
| **Google**  | `google_sign_in`             | Evet (native provider)  | Android SHA-1, iOS URL scheme |
| **Apple**   | `sign_in_with_apple`         | Evet (native provider)  | iOS/macOS zorunlu (App Store)  |
| **Telefon** | `firebase_auth` (Phone)      | Evet (native provider)  | reCAPTCHA / SafetyNet         |
| **LinkedIn**| `linkedin_login`             | OIDC / Custom token (*) | Firebase Console’da LinkedIn OIDC veya backend |

(*) LinkedIn için Firebase’de doğrudan “LinkedIn” provider yok; OIDC veya custom token ile bağlanılır.

---

## 2. Google ile Giriş

- **Paket:** `google_sign_in`
- **Firebase Console:** Authentication → Sign-in method → Google → Etkinleştir.
- **Android:** Proje ayarlarında SHA-1 ekleyin; `google-services.json` güncel olsun.
- **iOS:** URL scheme (Client ID’den türetilir) Xcode’da tanımlı olsun.
- **Akış:** `GoogleSignIn` → `idToken` / `accessToken` → `GoogleAuthProvider.getCredential()` → `signInWithCredential()`.

---

## 3. Apple ile Giriş

- **Paket:** `sign_in_with_apple`
- **Firebase Console:** Authentication → Sign-in method → Apple → Etkinleştir.
- **iOS:** Xcode → Signing & Capabilities → “Sign in with Apple” ekleyin.
- **Android:** İsteğe bağlı (Apple’dan gelen credential ile Firebase’de giriş).
- **Akış:** `SignInWithApple` → Apple credential → `OAuthProvider.credential(providerId: "apple.com", ...)` → `signInWithCredential()`.

---

## 4. Telefon Numarası ile Giriş

- **Paket:** Sadece `firebase_auth`.
- **Firebase Console:** Authentication → Sign-in method → Telefon → Etkinleştir.
- **Android:** reCAPTCHA / SafetyNet otomatik; test numaraları Console’dan tanımlanabilir.
- **iOS:** APNs için push certificate veya key (production için).
- **Akış:** `verifyPhoneNumber()` → kullanıcı SMS kodu girer → `PhoneAuthProvider.credential()` → `signInWithCredential()`.

---

## 5. LinkedIn ile Giriş

Firebase’de hazır “LinkedIn” provider olmadığı için iki pratik yol vardır.

### Seçenek A: Firebase OIDC (LinkedIn’i OIDC provider olarak ekleme)

- **Firebase Console:** Authentication → Sign-in method → “Add new provider” → “OpenID Connect”.
- LinkedIn’in OIDC discovery URL’i ve client bilgileri girilir (LinkedIn Developer Portal’da OIDC açık olmalı).
- Uygulama tarafında LinkedIn ile OAuth yapıp alınan **ID token** ile Firebase’de `signInWithCredential(OAuthProvider.getCredential(...))` kullanılabilir (Firebase’in OIDC provider’ı ile eşleşecek şekilde).

### Seçenek B: Backend + Custom Token (önerilen)

1. **LinkedIn:** `linkedin_login` ile kullanıcı girişi; access token / id token alınır.
2. **Backend:** Bu token doğrulanır; Firebase Admin SDK ile `createCustomToken(uid)` üretilir.
3. **Flutter:** `signInWithCustomToken(customToken)` ile Firebase’e giriş yapılır.
4. **Firestore:** İlk girişte `users/{uid}` dökümanı oluşturulur (email, displayName, photoUrl, `providerId: "linkedin.com"` benzeri bir alan).

**LinkedIn Developer:**  
- [LinkedIn Developer Portal](https://www.linkedin.com/developers/) → Uygulama oluşturma.  
- OAuth 2.0 / OpenID Connect ayarları, redirect URI ve client ID’nin uygulama ve Firebase/backend ile aynı olması gerekir.

---

## 6. Proje İçi Sabitler

Giriş türleri `lib/core/constants/auth_constants.dart` içinde tanımlıdır:

- **AuthProvider:** `google`, `apple`, `phone`, `linkedin`
- **AuthConstants:** `displayName()`, `fromProviderId()`, `providerIdGoogle`, `providerIdApple`, `providerIdPhone`, `providerIdLinkedIn`

Auth state’te veya Firestore’daki kullanıcı dökümanında “hangi yöntemle giriş yapıldı” bilgisi bu enum ve provider ID’ler ile tutulabilir.

---

## 7. Özet Kontrol Listesi

- [ ] Firebase Console’da Google, Apple, Phone (ve istenirse OIDC/Custom token için LinkedIn) etkin.
- [ ] Android: SHA-1, `google-services.json`, LinkedIn redirect URI.
- [ ] iOS: “Sign in with Apple” capability, URL scheme (Google), LinkedIn redirect.
- [ ] LinkedIn: Developer uygulaması, client ID, (OIDC veya backend için) client secret veya token doğrulama.
- [ ] Uygulama: Dört giriş butonu ve her biri için ilgili akış (Google, Apple, Phone, LinkedIn) bağlanmış olsun.
