# Cardence: Your Digital Business Card

Modern, kullanıcı dostu ve profesyonel bir dijital kartvizit uygulaması.

## 📱 Uygulama Özellikleri

### Temel Özellikler

- ✅ Kişisel dijital kartvizit oluşturma ve düzenleme
- ✅ Kartvizit üzerinde 5 özel bilgi seçimi ve gösterimi
- ✅ Detaylı kartvizit bilgileri sayfası
- ✅ QR kod ile kartvizit paylaşımı
- ✅ Diğer kullanıcıların kartvizitlerini kaydetme
- ✅ Kartvizit önem derecesi belirleme
- ✅ Sektör, şirket ve diğer kriterlere göre arama ve filtreleme
- ✅ Modern ve profesyonel kullanıcı arayüzü

### Kartvizit Bilgileri

Kullanıcılar aşağıdaki bilgilerden 5 tanesini kartvizit üzerinde gösterebilir:

- Email
- Telefon
- Ünvan (Title)
- Departman (Department)
- Sektör (Sector)
- Kurumsal Telefon
- Website
- Lokasyon
- LinkedIn
- Twitter
- Instagram
- Şirket (Company)
- Etkinlik (Event)
- Özet (Summary)
- Ek Notlar (Additional Notes)

## 🛠 Teknik Gereksinimler

### Teknoloji Stack

- **Framework**: Flutter 3.11+
- **Dil**: Dart
- **State Management**: BLoC/Cubit (flutter_bloc)
- **Mimari**: Clean Architecture + Feature-First Structure — **tüm geliştirmeler bu standartlara göre yapılır.** Detay: `docs/ARCHITECTURE.md`, Cursor kuralı: `.cursor/rules/clean-architecture.mdc`
- **Widget Yapısı**: Atomic Design Pattern

### Paket Bağımlılıkları (Gerekli)

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  qr_flutter: ^4.1.0
  qr_code_scanner: ^1.0.1
  shared_preferences: ^2.2.2
  get_it: ^7.6.4
  injectable: ^2.3.2
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  path_provider: ^2.1.1
  share_plus: ^7.2.1
  image_picker: ^1.0.5
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  intl: ^0.18.1
  url_launcher: ^6.2.2
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  google_sign_in: ^6.1.6

dev_dependencies:
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
  bloc_test: ^9.1.5
  mocktail: ^1.0.1
  flutter_launcher_icons: ^0.13.1
```

## 📁 Proje Yapısı

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── field_constants.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_theme.dart
│   │   └── app_dimensions.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── extensions.dart
│   ├── widgets/
│   │   ├── atoms/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── custom_text.dart
│   │   │   └── custom_icon.dart
│   │   ├── molecules/
│   │   │   ├── card_field_item.dart
│   │   │   ├── search_bar.dart
│   │   │   └── filter_chip.dart
│   │   └── organisms/
│   │       ├── business_card_preview.dart
│   │       ├── business_card_detail.dart
│   │       └── qr_code_display.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── injection/
│       └── injection_container.dart
├── features/
│   ├── business_card/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── business_card_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── business_card_repository_impl.dart
│   │   │   └── datasources/
│   │   │       ├── business_card_local_datasource.dart
│   │   │       └── business_card_remote_datasource.dart
│   │   │           └── business_card_firestore_datasource.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── business_card.dart
│   │   │   ├── repositories/
│   │   │   │   └── business_card_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_business_card.dart
│   │   │       ├── update_business_card.dart
│   │   │       ├── delete_business_card.dart
│   │   │       ├── get_business_card.dart
│   │   │       └── get_all_business_cards.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── business_card_bloc.dart
│   │       │   ├── business_card_event.dart
│   │       │   └── business_card_state.dart
│   │       └── pages/
│   │           ├── create_business_card_page.dart
│   │           ├── edit_business_card_page.dart
│   │           └── business_card_detail_page.dart
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository_impl.dart
│   │   │   └── datasources/
│   │   │       ├── auth_remote_datasource.dart
│   │   │       └── auth_local_datasource.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_email.dart
│   │   │       ├── sign_up_with_email.dart
│   │   │       ├── sign_in_with_google.dart
│   │   │       ├── sign_out.dart
│   │   │       ├── get_current_user.dart
│   │   │       └── reset_password.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── pages/
│   │           ├── login_page.dart
│   │           ├── signup_page.dart
│   │           └── forgot_password_page.dart
│   ├── card_collection/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── saved_card_model.dart
│   │   │   └── repositories/
│   │   │       └── card_collection_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── saved_card.dart
│   │   │   └── repositories/
│   │   │       └── card_collection_repository.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── card_collection_bloc.dart
│   │       │   ├── card_collection_event.dart
│   │       │   └── card_collection_state.dart
│   │       └── pages/
│   │           ├── card_collection_page.dart
│   │           └── saved_card_detail_page.dart
│   ├── qr_share/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   ├── qr_share_bloc.dart
│   │   │   │   ├── qr_share_event.dart
│   │   │   │   └── qr_share_state.dart
│   │   │   └── pages/
│   │   │       ├── qr_generate_page.dart
│   │   │       └── qr_scan_page.dart
│   ├── search_filter/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   ├── search_filter_bloc.dart
│   │   │   │   ├── search_filter_event.dart
│   │   │   │   └── search_filter_state.dart
│   │   │   └── pages/
│   │   │       └── search_filter_page.dart
│   └── home/
│       └── presentation/
│           ├── bloc/
│           │   ├── home_bloc.dart
│           │   ├── home_event.dart
│           │   └── home_state.dart
│           └── pages/
│               └── home_page.dart
└── main.dart
```


## 📋 Proje İlerlemesi

Proje ilerlemesi ve görev takibi **[PROGRESS.md](PROGRESS.md)** dosyasında tutulmaktadır. Tüm fazlar (1–13), task listeleri ve geliştirme notları orada yer alır.

| Faz | Konu |
|-----|------|
| 1 | Proje Kurulumu ve Temel Yapı |
| 2 | Firebase Auth ve Firestore |
| 3 | Tema ve Design System |
| 4 | Veri Modelleri ve State Management |
| 5 | Atomic Widget Sistemi |
| 6 | Kartvizit Oluşturma ve Düzenleme |
| 7 | Kartvizit Detay Sayfası |
| 8 | QR Kod ve Paylaşım |
| 9 | Kartvizit Koleksiyonu |
| 10 | Arama ve Filtreleme |
| 11 | Local Storage / Offline |
| 12 | Ana Sayfa ve Navigasyon |
| 13 | Test ve Optimizasyon |

---


## 🎯 Hızlı Başlangıç

### Gereksinimler

- Flutter SDK 3.11+
- Dart 3.0+
- Android Studio / VS Code
- Git

### Kurulum

```bash
# Projeyi klonla
git clone <repository-url>
cd cardence

# Bağımlılıkları yükle
flutter pub get

# Firebase CLI kurulumu (eğer yoksa)
npm install -g firebase-tools

# Firebase'i başlat (ilk kez)
flutterfire configure

# Code generation (eğer freezed/json_serializable kullanılıyorsa)
flutter pub run build_runner build --delete-conflicting-outputs

# Firebase options dosyasını kontrol et
# lib/firebase_options.dart dosyasının oluştuğundan emin ol

# Uygulamayı çalıştır
flutter run
```

### Firebase Kurulum Adımları

1. Firebase Console'da proje oluştur: https://console.firebase.google.com/
2. Flutter uygulamasını Firebase projesine ekle
3. Android için `google-services.json` dosyasını `android/app/` klasörüne ekle
4. iOS için `GoogleService-Info.plist` dosyasını `ios/Runner/` klasörüne ekle
5. Firebase CLI ile konfigürasyon: `flutterfire configure`
6. Authentication'ı etkinleştir (Email/Password ve Google Sign-In)
7. Firestore Database oluştur
8. Firestore Security Rules'ı yapılandır
9. Firebase Storage'ı etkinleştir (ileride profile fotoğrafı için)

### Geliştirme Komutları

```bash
# Test çalıştır
flutter test

# Code analysis
flutter analyze

# Build (Android)
flutter build apk --release

# Build (iOS)
flutter build ios --release
```

---

## 📚 Kaynaklar

- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Atomic Design](https://atomicdesign.bradfrost.com/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

## 👥 Katkıda Bulunma

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 Lisans

Bu proje özel bir projedir.

---

**Son Güncelleme**: 2024
**Versiyon**: 1.0.0
