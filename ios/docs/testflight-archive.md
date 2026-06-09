# iOS TestFlight / App Store Archive

## Hata: `Invalid Signature` — `App.framework` / `Flutter.framework`

Bu hata, gömülü Flutter framework'lerinin **development** sertifikasıyla imzalanıp archive'ın **distribution** ile gönderilmesinden kaynaklanır.

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

`Runner` hedefinde **Sign Embedded Frameworks** build phase'i archive sırasında framework'leri yeniden imzalar (`--timestamp=none`; aksi halde bazı Xcode sürümlerinde `Only HTTP timestamp URLs are supported` hatası oluşur).

## Xcode kontrol listesi

| Ayar | Değer |
|------|--------|
| Team | `4NZ23FB632` |
| Signing | Automatic |
| Bundle ID | `com.furkanages.cardence` |
| Archive configuration | **Release** |
| Build configuration (Archive) | Release (Scheme → Archive) |

Target **Runner** → Build Settings → **Code Signing** ayarlarının Project seviyesini ezdiğinden emin olun.

## Hâlâ hata alırsanız

- Apple Developer → Certificates: süresi dolmuş **Distribution** sertifikasını yenileyin.
- Xcode → Settings → Accounts → **Download Manual Profiles**.
- Debug build sonrası archive almayın; önce `flutter clean` çalıştırın.
