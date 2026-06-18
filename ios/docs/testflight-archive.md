# iOS TestFlight / App Store Archive

## Hata: `Invalid Signature` — `App.framework` / `Flutter.framework` / `objective_c.framework` / `Runner`

Bu hatalar genelde şu nedenlerle oluşur:

1. Gömülü framework'ler **Apple Development** ile imzalanmış (App Store **Apple Distribution** ister).
2. Framework'ler yeniden imzalandıktan sonra **Runner.app** mührü tazelenmemiş.
3. `objective_c.framework` Flutter native asset'idir; diğer framework'lerle birlikte imzalanmalıdır.

## Önerilen yol (Flutter CLI)

```bash
cd /path/to/cardence
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
```

Oluşan IPA: `build/ios/ipa/*.ipa` — Transporter veya Xcode Organizer ile yükleyin.

## Xcode ile archive

1. **Keychain:** `Apple Distribution` sertifikası ve App Store provisioning profile yüklü olsun.
2. **Temiz build:**
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```
3. `ios/Runner.xcworkspace` açın (`.xcodeproj` değil).
4. Scheme: **Runner** → cihaz: **Any iOS Device (arm64)** (simülatör değil).
5. **Product → Clean Build Folder** (⇧⌘K).
6. **Product → Archive**.
7. Organizer → **Distribute App** → App Store Connect.

`Runner` hedefinde **Sign Embedded Frameworks** build phase'i (son adım):

- Tüm `Frameworks/*.framework` dosyalarını (App, Flutter, objective_c, …) imzalar
- Ardından **Runner.app**'i yeniden mühürler
- Release archive'da Development kimliği algılanırsa keychain'deki **Apple Distribution** sertifikasına geçer

**Keychain:** Archive almadan önce **Apple Distribution** sertifikasının yüklü olduğundan emin olun (Xcode → Settings → Accounts → Manage Certificates).

**Önemli:** Xcode Organizer'dan validate başarısız oluyorsa önce `flutter build ipa --release` ile üretilen `build/ios/ipa/*.ipa` dosyasını Transporter ile yüklemeyi deneyin.

## Xcode kontrol listesi

| Ayar | Değer |
|------|--------|
| Team | `4NZ23FB632` |
| Signing | Automatic |
| Bundle ID | `com.furkanages.cardenceapp` |
| Archive configuration | **Release** |
| Build configuration (Archive) | Release (Scheme → Archive) |

Target **Runner** → Build Settings → **Code Signing** ayarlarının Project seviyesini ezdiğinden emin olun.

## Hâlâ hata alırsanız

- Apple Developer → Certificates: süresi dolmuş **Distribution** sertifikasını yenileyin.
- Xcode → Settings → Accounts → **Download Manual Profiles**.
- Debug build sonrası archive almayın; önce `flutter clean` çalıştırın.
