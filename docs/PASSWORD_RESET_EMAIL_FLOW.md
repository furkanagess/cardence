# Cardence - Mail ile Sifre Sifirlama Akisi

Bu dosya, "Sifremi unuttum" ekranindan kullanicinin e-posta adresine sifre sifirlama maili gonderme isleminin nasil tasarlanacagini ve Cardence kod tabanina hangi adimlarla eklenecegini aciklar.

## 1. Mevcut Durum

Projede sifre sifirlama icin temel endpoint ve Flutter akisi zaten var:

- Backend endpointleri:
  - `POST /ForgotPassword`
  - `POST /ResetPassword`
- Flutter katmani:
  - `ForgotPassword`
  - `ResetPassword`
  - `ForgotPasswordBloc`
  - `ForgotPasswordForm`

Mevcut akis su anda e-posta icin de OTP/kod mantigina dayanir:

1. Kullanici e-posta girer.
2. Flutter `POST /ForgotPassword` cagirir.
3. Backend kullaniciyi bulur.
4. Backend reset OTP uretir.
5. Flutter ikinci adimda "dogrulama kodu + yeni sifre" ister.
6. Flutter `POST /ResetPassword` ile `email`, `otpCode`, `newPassword` gonderir.

Kod referanslari:

- `backend/Cardence.Api/Controllers/AuthenticationController.cs`
- `backend/Cardence.Application/Services/AuthService.cs`
- `backend/Cardence.Application/DTOs/Auth/ForgotPasswordRequest.cs`
- `backend/Cardence.Application/DTOs/Auth/ResetPasswordRequest.cs`
- `lib/features/auth/presentation/pages/forgot_password_page.dart`
- `lib/features/auth/presentation/widgets/forgot_password_form.dart`

Eksik kisim: Backend'de SMTP/transactional email servisi yok. Bu nedenle kullaniciya gercek bir sifre sifirlama maili henuz gonderilemiyor.

## 2. Onerilen Urun Akisi

Kullanici deneyimi su sekilde olmali:

1. Kullanici login ekraninda "Sifremi unuttum" butonuna basar.
2. E-posta adresini girer.
3. Uygulama `POST /ForgotPassword` cagirir.
4. Backend reset token uretir ve kullaniciya mail gonderir.
5. Uygulama "Eger bu e-posta sistemde kayitliysa sifre sifirlama baglantisi gonderildi." mesajini gosterir.
6. Kullanici maildeki linke tiklar.
7. Link uygulamayi acarsa mobil reset ekranina, web acarsa basit reset sayfasina gider.
8. Kullanici yeni sifresini girer.
9. Uygulama/backend `POST /ResetPassword` ile token + yeni sifreyi dogrular.
10. Sifre guncellenir, token tek kullanimlik olarak gecersiz olur.

Onemli guvenlik karari:

- `ForgotPassword` endpoint'i "bu mail kayitli degil" bilgisini acik etmemeli.
- Kayitli olmayan e-posta icin de basarili gibi donmeli.
- Boylece saldirganlar hangi e-postalarin sistemde kayitli oldugunu anlayamaz.

## 3. Token Modeli

OTP yerine mail linki icin uzun, tahmin edilemez bir token kullanilmalidir.

Token ozellikleri:

- En az 32 byte random uretilmeli.
- Kullaniciya gonderilen token base64url formatinda olabilir.
- Veritabaninda token'in kendisi degil SHA-256 hash'i saklanmali.
- Token suresi kisa olmali: onerilen 15-30 dakika.
- Token tek kullanimlik olmali.
- Sifre basariyla degisince token kullanildi olarak isaretlenmeli.

Onerilen tablo:

```sql
CREATE TABLE password_reset_tokens (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(128) NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  used_at TIMESTAMP WITH TIME ZONE NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL,
  requested_ip VARCHAR(64) NULL,
  user_agent VARCHAR(512) NULL
);

CREATE UNIQUE INDEX ix_password_reset_tokens_token_hash
  ON password_reset_tokens(token_hash);

CREATE INDEX ix_password_reset_tokens_user_id_expires_at
  ON password_reset_tokens(user_id, expires_at);
```

Entity onerisi:

```csharp
public sealed class PasswordResetToken
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public string TokenHash { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public DateTime? UsedAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? RequestedIp { get; set; }
    public string? UserAgent { get; set; }
}
```

## 4. Backend Gelistirme Adimlari

### 4.1 Domain

Yeni entity ekle:

- `backend/Cardence.Domain/Entities/PasswordResetToken.cs`

`User` entity'sine opsiyonel navigation eklenebilir:

```csharp
public ICollection<PasswordResetToken> PasswordResetTokens { get; set; } = [];
```

### 4.2 Application Interface'leri

Yeni repository interface'i:

- `backend/Cardence.Application/Interfaces/IPasswordResetTokenRepository.cs`

Metodlar:

```csharp
Task AddAsync(PasswordResetToken token, CancellationToken cancellationToken = default);
Task<PasswordResetToken?> GetValidByTokenHashAsync(string tokenHash, CancellationToken cancellationToken = default);
Task InvalidateActiveTokensAsync(Guid userId, CancellationToken cancellationToken = default);
Task UpdateAsync(PasswordResetToken token, CancellationToken cancellationToken = default);
```

Yeni email interface'i:

- `backend/Cardence.Application/Interfaces/IEmailSender.cs`

```csharp
public interface IEmailSender
{
    Task SendPasswordResetEmailAsync(
        string toEmail,
        string resetUrl,
        CancellationToken cancellationToken = default);
}
```

### 4.3 Infrastructure

EF configuration:

- `backend/Cardence.Infrastructure/Persistence/Configurations/PasswordResetTokenConfiguration.cs`

Repository implementation:

- `backend/Cardence.Infrastructure/Repositories/PasswordResetTokenRepository.cs`

Email provider implementation:

- Basit SMTP icin `SmtpEmailSender`
- Daha saglam production icin SendGrid, Resend, Mailgun veya AWS SES

Onerilen options:

```json
"Email": {
  "FromName": "Cardence",
  "FromAddress": "noreply@cardenceapi.app",
  "SmtpHost": "smtp.example.com",
  "SmtpPort": 587,
  "SmtpUsername": "username",
  "SmtpPassword": "secret"
},
"PasswordReset": {
  "ResetBaseUrl": "com.furkanages.cardenceapp://auth/reset-password",
  "TokenLifetimeMinutes": 30
}
```

Production'da `SmtpPassword` ve benzeri secret'lar `appsettings.json` yerine environment variable / secret manager ile verilmelidir.

### 4.4 DTO Degisikligi

Mevcut `ForgotPasswordRequest` ayni kalabilir:

```csharp
public sealed class ForgotPasswordRequest
{
    public string? Email { get; init; }
    public string? Phone { get; init; }
}
```

`ResetPasswordRequest` token destekleyecek sekilde genisletilmeli:

```csharp
public sealed class ResetPasswordRequest
{
    public string? Email { get; init; }
    public string? Phone { get; init; }
    public string? OtpCode { get; init; }
    public string? ResetToken { get; init; }
    public string? NewPassword { get; init; }
}
```

Geriye uyumluluk icin `OtpCode` bir sure kalabilir. Mail link akisi `ResetToken` kullanir.

### 4.5 AuthService.ForgotPasswordAsync

Yeni davranis:

1. E-posta bos mu kontrol et.
2. E-posta formatini normalize et.
3. Kullanici yoksa yine basarili don.
4. Kullanici varsa once eski aktif reset token'larini gecersiz kil.
5. Yeni random token uret.
6. Token hash'ini DB'ye yaz.
7. Reset URL olustur.
8. Mail gonder.
9. Her durumda genel basari mesaji don.

Pseudo code:

```csharp
public async Task<AuthServiceResponse<object?>> ForgotPasswordAsync(
    ForgotPasswordRequest request,
    CancellationToken cancellationToken = default)
{
    if (string.IsNullOrWhiteSpace(request.Email))
    {
        return AuthServiceResponse<object?>.Fail(
            AuthErrorCodes.InvalidRequest,
            "InvalidRequest",
            "E-posta gereklidir.");
    }

    var email = request.Email.Trim().ToLowerInvariant();
    var user = await _userRepository.GetByEmailAsync(email, cancellationToken);

    if (user is null)
    {
        return AuthServiceResponse<object?>.Ok(
            null,
            "Eger bu e-posta sistemde kayitliysa sifre sifirlama baglantisi gonderildi.");
    }

    await _passwordResetTokenRepository.InvalidateActiveTokensAsync(user.Id, cancellationToken);

    var rawToken = SecureTokenGenerator.CreateUrlSafeToken();
    var tokenHash = Sha256Hasher.Hash(rawToken);

    await _passwordResetTokenRepository.AddAsync(new PasswordResetToken
    {
        Id = Guid.NewGuid(),
        UserId = user.Id,
        TokenHash = tokenHash,
        ExpiresAt = DateTime.UtcNow.AddMinutes(_passwordResetOptions.TokenLifetimeMinutes),
        CreatedAt = DateTime.UtcNow,
    }, cancellationToken);

    var resetUrl = QueryHelpers.AddQueryString(
        _passwordResetOptions.ResetBaseUrl,
        new Dictionary<string, string?>
        {
            ["token"] = rawToken,
            ["email"] = email,
        });

    await _emailSender.SendPasswordResetEmailAsync(email, resetUrl, cancellationToken);

    return AuthServiceResponse<object?>.Ok(
        null,
        "Eger bu e-posta sistemde kayitliysa sifre sifirlama baglantisi gonderildi.");
}
```

### 4.6 AuthService.ResetPasswordAsync

Yeni token davranisi:

1. `NewPassword` dogrula.
2. `ResetToken` varsa token hash'i hesapla.
3. DB'de token var mi, suresi dolmamis mi, kullanilmamis mi kontrol et.
4. Ilgili kullaniciyi bul.
5. Sifreyi hash'le ve kaydet.
6. Token'i `UsedAt = DateTime.UtcNow` ile kullanildi yap.
7. Istersen kullaniciyi otomatik login edip session don; ya da sadece success don.

Mevcut Cardence akisi `ResetPasswordAsync` sonunda session donuyor. Bunu korumak kullanici deneyimi icin iyi olur.

Pseudo code:

```csharp
if (!string.IsNullOrWhiteSpace(request.ResetToken))
{
    var tokenHash = Sha256Hasher.Hash(request.ResetToken.Trim());
    var resetToken = await _passwordResetTokenRepository
        .GetValidByTokenHashAsync(tokenHash, cancellationToken);

    if (resetToken is null)
    {
        return FailSession(
            AuthErrorCodes.InvalidOtp,
            "InvalidResetToken",
            "Sifre sifirlama baglantisi gecersiz veya suresi dolmus.");
    }

    var user = resetToken.User;
    user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
    user.UpdatedAt = DateTime.UtcNow;

    resetToken.UsedAt = DateTime.UtcNow;

    await _userRepository.UpdateAsync(user, cancellationToken);
    await _passwordResetTokenRepository.UpdateAsync(resetToken, cancellationToken);

    return await CreateSessionAsync(user, "Sifre guncellendi.", cancellationToken);
}
```

OTP ile sifirlama desteklenmeye devam edecekse mevcut `OtpCode` bloklari korunabilir.

## 5. Flutter Gelistirme Adimlari

### 5.1 API Katmani

`AuthRemoteDataSource.resetPassword` imzasi token destekleyecek sekilde genisletilir:

```dart
Future<AuthSessionModel> resetPassword({
  String? email,
  String? phone,
  String? otpCode,
  String? resetToken,
  required String newPassword,
});
```

Request body:

```dart
final body = <String, dynamic>{
  'newPassword': newPassword,
};
if (email != null && email.isNotEmpty) body['email'] = email;
if (otpCode != null && otpCode.isNotEmpty) body['otpCode'] = otpCode;
if (resetToken != null && resetToken.isNotEmpty) body['resetToken'] = resetToken;
```

### 5.2 Domain

`ResetPassword` use case'i token alabilmeli:

```dart
Future<AuthSession> call({
  String? email,
  String? phone,
  String? otpCode,
  String? resetToken,
  required String newPassword,
});
```

### 5.3 UI Secenekleri

Iki makul yaklasim var:

1. Mail linki sadece web sayfasina gider.
   - En hizli backend odakli cozum.
   - Mobil app deep link gerekmez.
   - Kullanici maildeki web sayfasinda yeni sifresini girer.

2. Mail linki mobil app'i acar.
   - Daha iyi mobil deneyim.
   - iOS/Android deep link kurulumu gerekir.
   - Flutter'da `ResetPasswordFromLinkPage` gibi token alan yeni ekran gerekir.

Cardence mobil uygulama oldugu icin uzun vadede 2. secenek onerilir.

### 5.4 Deep Link

Onerilen link:

```text
com.furkanages.cardenceapp://auth/reset-password?token=...&email=...
```

iOS:

- `ios/Runner/Info.plist` icinde URL scheme zaten LinkedIn icin kullaniliyor olabilir.
- Ayni scheme altinda `/auth/reset-password` path'i uygulama tarafinda yakalanmali.

Android:

- `android/app/src/main/AndroidManifest.xml` icinde intent-filter eklenmeli.

Flutter:

- `app_links` veya benzer paket ile cold start / foreground linkleri dinlenmeli.
- Linkten `token` ve opsiyonel `email` okunup reset ekranina gidilmeli.

### 5.5 Mevcut ForgotPasswordForm Degisikligi

Mail link akisi kullanilacaksa ilk adimdan sonra OTP ekranina gecilmez.

Yeni davranis:

1. Kullanici e-posta girer.
2. `ForgotPasswordOtpRequested` yerine isim olarak `ForgotPasswordLinkRequested` daha dogru olur.
3. Backend basarili donunce sayfa bilgi durumuna gecer:
   - "Eger bu e-posta sistemde kayitliysa sifre sifirlama baglantisi gonderildi."
4. Kullanici maili acip linke tiklar.

OTP akisi korunacaksa, formda iki mod olabilir:

- `ForgotPasswordMode.emailLink`
- `ForgotPasswordMode.otpCode`

## 6. Mail Icerigi

Ornek mail konusu:

```text
Cardence sifre sifirlama baglantiniz
```

Ornek HTML govde:

```html
<h2>Sifrenizi sifirlayin</h2>
<p>Cardence hesabiniz icin sifre sifirlama talebi aldik.</p>
<p>
  <a href="{{resetUrl}}">Sifremi sifirla</a>
</p>
<p>Bu baglanti 30 dakika boyunca gecerlidir.</p>
<p>Bu istegi siz yapmadiysaniz bu e-postayi yok sayabilirsiniz.</p>
```

Guvenlik icin mailde yeni sifre, OTP veya kullaniciya ait hassas veri yazilmaz.

## 7. Rate Limit ve Guvenlik

Mutlaka eklenmeli:

- IP bazli rate limit: orn. 10 dakikada 5 istek.
- E-posta bazli rate limit: orn. 10 dakikada 3 istek.
- Her istekte ayni genel mesaj.
- Token hash saklama.
- Token tek kullanimlik.
- Token suresi kisa.
- Sifre degisince aktif refresh token'lari iptal etmeyi degerlendir.
- Mail gonderim hatalari loglanmali ama kullaniciya detayli provider hatasi verilmemeli.

## 8. Test Plani

Backend unit/integration testleri:

- Kayitli e-posta icin token olusur ve mail sender cagrilir.
- Kayitsiz e-posta icin endpoint basarili doner, mail gonderilmez.
- Suresi dolmus token reddedilir.
- Kullanilmis token reddedilir.
- Gecersiz token reddedilir.
- Gecerli token ile sifre guncellenir.
- Sifre guncellendikten sonra eski sifreyle login basarisiz, yeni sifreyle login basarili olur.

Flutter testleri:

- Gecersiz e-posta form validasyon hatasi verir.
- Forgot password basarili donunce bilgi mesaji gosterilir.
- Deep link token ile reset ekranini acar.
- Yeni sifre ve tekrar sifre eslesmiyorsa hata gosterilir.
- Reset basarili olunca kullanici login olur veya login ekranina yonlenir.

## 9. Uygulama Sirasi

1. Backend'e `PasswordResetToken` entity + migration ekle.
2. `IPasswordResetTokenRepository` ve EF repository implementasyonunu ekle.
3. `IEmailSender` interface'i ve SMTP/transactional provider implementasyonunu ekle.
4. `PasswordResetOptions` ve `EmailOptions` configuration ekle.
5. `AuthService.ForgotPasswordAsync` metodunu token + mail akisi ile guncelle.
6. `ResetPasswordRequest` icine `ResetToken` ekle.
7. `AuthService.ResetPasswordAsync` metoduna token dogrulama kolu ekle.
8. Flutter `AuthRemoteDataSource`, `AuthRepository`, `ResetPassword` use case'ini token destekleyecek sekilde genislet.
9. Mail linki web reset sayfasina mi mobil deep link'e mi gidecek karar ver.
10. Mobil deep link secilecekse iOS/Android link ayarlarini ve Flutter route'unu ekle.
11. UI metinlerini ARB dosyalarina ekle.
12. Backend ve Flutter testlerini yaz.
13. Staging ortaminda gercek mail provider ile uc tan uca test et.

## 10. Minimum MVP

En hizli calisir MVP:

1. Backend token tablosu.
2. SMTP/Resend/SendGrid email sender.
3. `ForgotPassword` mail link gonderir.
4. Link basit bir web reset sayfasina gider.
5. Web sayfasi `ResetPassword` endpoint'ine `resetToken + newPassword` gonderir.

Mobil deep link ikinci faza birakilabilir. Ancak Cardence'in ana deneyimi mobil oldugu icin production kalitesi icin deep link destekli reset ekranina gecilmesi onerilir.
