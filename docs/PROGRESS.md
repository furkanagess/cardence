# Cardence – Proje İlerleme Takibi

Bu dosya projenin geliştirme fazlarının ve görevlerin takibi için kullanılır. Görevleri tamamladıkça `[ ]` işaretini `[x]` olarak güncelleyin.

---

## ⚠️ Mimari Kural: Clean Architecture (Her Durumda Geçerli)

**Bu projenin mimarisi Clean Architecture standartlarına göredir.** Tüm fazlar ve task’lar bu kurala uyularak yapılır.

- **Domain:** Entity’ler, repository interface’leri, use case’ler. Flutter/Firebase import **yok**.
- **Data:** Model’ler, data source (abstract + impl), repository impl. Sadece Domain’e bağımlı.
- **Presentation:** BLoC/Cubit, sayfalar, widget’lar. Domain ve (DI ile) repository/use case kullanır.
- **Bağımlılık yönü:** İçten dışa; dış katmanlar iç katmanları bilir, iç katmanlar dışı bilmez.

Detaylı yapı: `docs/ARCHITECTURE.md`. Cursor kuralı: `.cursor/rules/clean-architecture.mdc`.

---

## 🚀 Geliştirme Fazları

### Faz 1: Proje Kurulumu ve Temel Yapı ⏳

**Clean Architecture:** Klasör yapısı her feature için `domain/`, `data/`, `presentation/` katmanlarına uyacak şekilde kurulmalıdır.

#### Task 1.1: Proje Bağımlılıklarının Kurulumu

- [ ] `pubspec.yaml` dosyasını güncelle ve gerekli paketleri ekle
- [ ] `flutter pub get` komutunu çalıştır
- [ ] Paket versiyonlarının uyumluluğunu kontrol et

#### Task 1.2: Klasör Yapısının Oluşturulması

- [x] `lib/core/` klasör yapısını oluştur
  - [x] `constants/` klasörü
  - [x] `theme/` klasörü
  - [x] `utils/` klasörü
  - [x] `widgets/atoms/` klasörü
  - [x] `widgets/molecules/` klasörü
  - [x] `widgets/organisms/` klasörü
  - [x] `error/` klasörü
  - [x] `injection/` klasörü
- [x] `lib/features/` klasör yapısı oluşturuldu (**Clean Architecture:** her feature’da `domain/`, `data/`, `presentation/` alt yapısı)
  - [x] `onboarding/` – ilk onboarding ekranları yapıldı
  - [x] `authentication/` (placeholder)
  - [x] `business_card/` (placeholder)
  - [x] `card_collection/` (placeholder)
  - [x] `qr_share/` (placeholder)
  - [x] `search_filter/` (placeholder)
  - [x] `home/` (placeholder Home sayfası)

#### Task 1.3: Temel Sabitlerin Oluşturulması

- [ ] `lib/core/constants/app_constants.dart` dosyasını oluştur
  - [ ] Uygulama adı, versiyon gibi genel sabitler
- [ ] `lib/core/constants/field_constants.dart` dosyasını oluştur
  - [ ] Kartvizit alanlarının sabitleri (email, telefon, vs.)

**Dosya Örnekleri:**

```dart
// app_constants.dart
class AppConstants {
  static const String appName = 'Cardence';
  static const String appTagline = 'Your Digital Business Card';
  static const String appVersion = '1.0.0';
  static const int maxVisibleFields = 5;
}

// field_constants.dart
class FieldConstants {
  static const String email = 'email';
  static const String phone = 'phone';
  static const String title = 'title';
  // ... diğer alanlar
}
```

---

### Faz 2: Firebase Authentication ve Firestore Entegrasyonu 🔐

**Clean Architecture:** Data source’lar abstract interface + impl ayrımıyla yazılır; repository’ler Domain’deki interface’i implement eder. Presentation doğrudan Firebase kullanmaz; use case / repository üzerinden erişir.

**Karar – Kaydedilen kişilerin kart bilgileri:** Kullanıcının kaydettiği kişilerin (saved cards) yalnızca referansı değil, **kartvizit içeriği (isim, şirket, iletişim, sosyal medya vb.) da Firebase Firestore'da tutulacak**. Veri yapısı: `saved_cards/{userId}/cards/{cardId}` dökümanında `cardId`, `priority`, `savedAt` ile birlikte kart bilgileri (card data snapshot) saklanır. Böylece orijinal kart silinse veya güncellense bile kullanıcının kaydettiği kişi bilgisi korunur.

#### Task 2.1: Firebase Projesi Kurulumu

- [ ] Firebase Console'da yeni proje oluştur
- [ ] Firebase projesine Flutter uygulaması ekle (Android ve iOS)
- [ ] `google-services.json` dosyasını `android/app/` klasörüne ekle
- [ ] `GoogleService-Info.plist` dosyasını `ios/Runner/` klasörüne ekle
- [ ] Firebase CLI kurulumu (`npm install -g firebase-tools`)
- [ ] Firebase projesini lokal olarak bağla

#### Task 2.2: Firebase Paketlerinin Kurulumu

- [ ] `pubspec.yaml` dosyasına Firebase paketlerini ekle
  - [ ] `firebase_core: ^2.24.2`
  - [ ] `firebase_auth: ^4.15.3`
  - [ ] `cloud_firestore: ^4.13.6`
  - [ ] `firebase_storage: ^11.5.6`
  - [ ] `google_sign_in: ^6.1.6`
- [ ] `flutter pub get` komutunu çalıştır
- [ ] `main.dart` dosyasında Firebase'i initialize et

**Örnek Yapı:**

```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

#### Task 2.3: Firebase Authentication Yapılandırması

- [ ] Firebase Console'da Authentication'ı etkinleştir
- [ ] Email/Password authentication yöntemini etkinleştir
- [ ] Google Sign-In yöntemini etkinleştir
  - [ ] Android için SHA-1 fingerprint ekle
  - [ ] iOS için bundle ID kontrolü
  - [ ] OAuth client ID'leri yapılandır
- [ ] Authentication rules oluştur

#### Task 2.4: Firestore Database Yapılandırması

- [ ] Firestore Database oluştur (Test mode veya Production mode)
- [ ] Firestore Security Rules oluştur
- [ ] Collection yapısını tasarla:
  - [ ] `users/{userId}` - Kullanıcı bilgileri
  - [ ] `business_cards/{cardId}` - Kartvizitler (userId field ile)
  - [ ] `saved_cards/{userId}/cards/{cardId}` - Kullanıcının kaydettiği kişiler; **kart bilgileri (card data) da bu dökümanlarda Firebase'de tutulacak** (referans + snapshot)
  - [ ] `public_cards/{cardId}` - Halka açık kartvizitler (QR kod ile erişim için)

**Kaydedilen kişilerin kart bilgileri:** Kullanıcı bir kartviziti "kaydet"e bastığında, yalnızca referans (cardId, priority, savedAt) değil; o anki **kartvizit içeriği (isim, şirket, iletişim, sosyal medya vb.) da Firestore'da saklanacak**. Böylece orijinal kart silinse veya güncellense bile kullanıcının kaydettiği kişi bilgisi korunur ve offline/lista görünümü için ek okuma gerekmez.

**Firestore Security Rules Örneği:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Business Cards collection
    match /business_cards/{cardId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Saved Cards collection
    match /saved_cards/{userId}/cards/{cardId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Public Cards (QR kod ile erişim)
    match /public_cards/{cardId} {
      allow read: if true; // Herkes okuyabilir (QR kod ile)
      allow write: if request.auth != null;
    }
  }
}
```

#### Task 2.5: User Entity ve Model Oluşturma

- [ ] `lib/features/authentication/domain/entities/user.dart` dosyasını oluştur
  - [ ] User ID
  - [ ] Email
  - [ ] Display Name
  - [ ] Photo URL
  - [ ] Created At
  - [ ] Updated At

**Örnek Yapı:**

```dart
class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, createdAt, updatedAt];
}
```

- [ ] `lib/features/authentication/data/models/user_model.dart` dosyasını oluştur
  - [ ] JSON serialization/deserialization
  - [ ] Firebase User'dan User Entity'ye dönüşüm
  - [ ] Firestore Document'dan User Entity'ye dönüşüm

#### Task 2.6: Authentication Data Source Oluşturma

- [ ] `lib/features/authentication/data/datasources/auth_remote_datasource.dart` dosyasını oluştur
  - [ ] `signInWithEmailAndPassword(String email, String password)` metodu
  - [ ] `signUpWithEmailAndPassword(String email, String password, String displayName)` metodu
  - [ ] `signInWithGoogle()` metodu
  - [ ] `signOut()` metodu
  - [ ] `getCurrentUser()` metodu
  - [ ] `resetPassword(String email)` metodu
  - [ ] `updateUserProfile(Map<String, dynamic> data)` metodu
  - [ ] Error handling (FirebaseAuthException)

**Örnek Yapı:**

```dart
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password, String displayName);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> resetPassword(String email);
  Future<void> updateUserProfile(Map<String, dynamic> data);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseException(e);
    }
  }

  // ... diğer metodlar
}
```

- [ ] `lib/features/authentication/data/datasources/auth_local_datasource.dart` dosyasını oluştur
  - [ ] Kullanıcı bilgilerini cache'leme (SharedPreferences)
  - [ ] Token saklama
  - [ ] Remember me özelliği

#### Task 2.7: Authentication Repository Implementation

- [ ] `lib/features/authentication/data/repositories/auth_repository_impl.dart` dosyasını oluştur
  - [ ] Remote datasource entegrasyonu
  - [ ] Local datasource entegrasyonu
  - [ ] Error handling ve exception mapping
  - [ ] User bilgilerini Firestore'a kaydetme

**Örnek Yapı:**

```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(String email, String password) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(email, password);
      await localDataSource.cacheUser(user);
      return Right(user.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }

  // ... diğer metodlar
}
```

#### Task 2.8: Authentication Use Cases

- [ ] `lib/features/authentication/domain/usecases/sign_in_with_email.dart`
- [ ] `lib/features/authentication/domain/usecases/sign_up_with_email.dart`
- [ ] `lib/features/authentication/domain/usecases/sign_in_with_google.dart`
- [ ] `lib/features/authentication/domain/usecases/sign_out.dart`
- [ ] `lib/features/authentication/domain/usecases/get_current_user.dart`
- [ ] `lib/features/authentication/domain/usecases/reset_password.dart`

#### Task 2.9: Authentication BLoC

- [ ] `lib/features/authentication/presentation/bloc/auth_event.dart` dosyasını oluştur

  - [ ] `SignInRequested` event
  - [ ] `SignUpRequested` event
  - [ ] `GoogleSignInRequested` event
  - [ ] `SignOutRequested` event
  - [ ] `AuthCheckRequested` event
  - [ ] `PasswordResetRequested` event

- [ ] `lib/features/authentication/presentation/bloc/auth_state.dart` dosyasını oluştur

  - [ ] `AuthInitial` state
  - [ ] `AuthLoading` state
  - [ ] `Authenticated` state (User bilgisi ile)
  - [ ] `Unauthenticated` state
  - [ ] `AuthError` state (Error message ile)

- [ ] `lib/features/authentication/presentation/bloc/auth_bloc.dart` dosyasını oluştur
  - [ ] Event handling logic
  - [ ] Stream subscription (Firebase Auth state changes)
  - [ ] Auto-logout handling

**Örnek Yapı:**

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUser();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) => emit(Authenticated(user: user)),
    );
  }

  // ... diğer event handler'lar
}
```

#### Task 2.10: Login ve Signup Sayfaları

- [ ] `lib/features/authentication/presentation/pages/login_page.dart` dosyasını oluştur

  - [ ] Email ve password input alanları
  - [ ] Login butonu
  - [ ] Google Sign-In butonu
  - [ ] Sign up'a yönlendirme linki
  - [ ] Forgot password linki
  - [ ] Form validasyonu
  - [ ] Loading state gösterimi
  - [ ] Error mesaj gösterimi
  - [ ] BLoC entegrasyonu

- [ ] `lib/features/authentication/presentation/pages/signup_page.dart` dosyasını oluştur

  - [ ] Email, password, confirm password, display name input alanları
  - [ ] Sign up butonu
  - [ ] Google Sign-In butonu
  - [ ] Login'e yönlendirme linki
  - [ ] Form validasyonu
  - [ ] Password strength indicator
  - [ ] BLoC entegrasyonu

- [ ] `lib/features/authentication/presentation/pages/forgot_password_page.dart` dosyasını oluştur
  - [ ] Email input alanı
  - [ ] Reset password butonu
  - [ ] Success/Error mesaj gösterimi

#### Task 2.11: Authentication Widgets

- [ ] `lib/features/authentication/presentation/widgets/email_text_field.dart`
  - [ ] Email format validasyonu
- [ ] `lib/features/authentication/presentation/widgets/password_text_field.dart`
  - [ ] Password visibility toggle
  - [ ] Password strength indicator
- [ ] `lib/features/authentication/presentation/widgets/google_sign_in_button.dart`
  - [ ] Google branding ile buton
- [ ] `lib/features/authentication/presentation/widgets/auth_error_message.dart`
  - [ ] Hata mesajlarını gösteren widget

#### Task 2.12: Auth Guard ve Route Protection

- [ ] `lib/core/routes/route_guard.dart` dosyasını oluştur

  - [ ] Authentication durumunu kontrol eden guard
  - [ ] Authenticated route'lar için koruma
  - [ ] Unauthenticated route'lar için yönlendirme

- [ ] `lib/core/routes/app_router.dart` dosyasını oluştur
  - [ ] Route tanımlamaları
  - [ ] Auth guard entegrasyonu
  - [ ] Initial route belirleme (login veya home)

**Örnek Yapı:**

```dart
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
    }
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Auth guard kontrolü
    final authBloc = sl<AuthBloc>();
    final isAuthenticated = authBloc.state is Authenticated;

    if (_requiresAuth(settings.name) && !isAuthenticated) {
      return MaterialPageRoute(builder: (_) => const LoginPage());
    }

    if (_requiresNoAuth(settings.name) && isAuthenticated) {
      return MaterialPageRoute(builder: (_) => const HomePage());
    }

    return generateRoute(settings);
  }

  static bool _requiresAuth(String? routeName) {
    const authRoutes = ['/home', '/profile', '/business-card'];
    return authRoutes.contains(routeName);
  }

  static bool _requiresNoAuth(String? routeName) {
    const noAuthRoutes = ['/login', '/signup'];
    return noAuthRoutes.contains(routeName);
  }
}
```

#### Task 2.13: Firestore Remote Data Source (Business Card)

- [ ] `lib/features/business_card/data/datasources/business_card_firestore_datasource.dart` dosyasını oluştur
  - [ ] `createBusinessCard(BusinessCard card)` - Kullanıcının kartvizitini oluştur
  - [ ] `updateBusinessCard(String cardId, BusinessCard card)` - Kartviziti güncelle
  - [ ] `deleteBusinessCard(String cardId)` - Kartviziti sil
  - [ ] `getBusinessCard(String cardId)` - Tek bir kartvizit getir
  - [ ] `getUserBusinessCard(String userId)` - Kullanıcının kendi kartvizitini getir
  - [ ] `getAllBusinessCards()` - Tüm kartvizitleri getir (public)
  - [ ] `searchBusinessCards(String query)` - Kartvizit arama
  - [ ] `filterBusinessCards(Map<String, dynamic> filters)` - Kartvizit filtreleme

**Örnek Yapı:**

```dart
abstract class BusinessCardFirestoreDataSource {
  Future<BusinessCardModel> createBusinessCard(BusinessCardModel card);
  Future<BusinessCardModel> updateBusinessCard(String cardId, BusinessCardModel card);
  Future<void> deleteBusinessCard(String cardId);
  Future<BusinessCardModel> getBusinessCard(String cardId);
  Future<BusinessCardModel?> getUserBusinessCard(String userId);
  Future<List<BusinessCardModel>> getAllBusinessCards();
  Future<List<BusinessCardModel>> searchBusinessCards(String query);
  Future<List<BusinessCardModel>> filterBusinessCards(Map<String, dynamic> filters);
  Stream<List<BusinessCardModel>> streamBusinessCards();
}

class BusinessCardFirestoreDataSourceImpl implements BusinessCardFirestoreDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  BusinessCardFirestoreDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<BusinessCardModel> createBusinessCard(BusinessCardModel card) async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) throw UnauthenticatedException();

      final cardWithUserId = card.copyWith(userId: userId);
      final docRef = await firestore
          .collection('business_cards')
          .add(cardWithUserId.toJson());

      return await getBusinessCard(docRef.id);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Unknown error');
    }
  }

  @override
  Future<BusinessCardModel> getUserBusinessCard(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('business_cards')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw NotFoundException('Business card not found');
      }

      return BusinessCardModel.fromJson(
        querySnapshot.docs.first.data(),
        querySnapshot.docs.first.id,
      );
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Unknown error');
    }
  }

  // ... diğer metodlar
}
```

#### Task 2.14: Firestore Remote Data Source (Saved Cards)

Kullanıcının kaydettiği kişilerin **kart bilgileri (card data) da Firebase'de tutulur**: kayıt anında kartvizit verisi (BusinessCard snapshot) `saved_cards/{userId}/cards/{cardId}` dökümanına yazılır; böylece orijinal kart değişse bile kaydedilen kişi bilgisi korunur.

- [ ] `lib/features/card_collection/data/datasources/saved_card_firestore_datasource.dart` dosyasını oluştur
  - [ ] `saveCard(String userId, BusinessCard card, int priority)` - Kartviziti **kart bilgileriyle birlikte** kaydet (cardId + cardData snapshot)
  - [ ] `removeCard(String userId, String cardId)` - Kaydedilmiş kartı sil
  - [ ] `updateCardPriority(String userId, String cardId, int priority)` - Önem derecesini güncelle
  - [ ] `getSavedCards(String userId)` - Kullanıcının kaydettiği tüm kartları **kart bilgileriyle** getir
  - [ ] `getSavedCard(String userId, String cardId)` - Tek bir kaydedilmiş kartı kart bilgileriyle getir
  - [ ] Stream support - Real-time updates

**Örnek Yapı:**

```dart
abstract class SavedCardFirestoreDataSource {
  Future<SavedCardModel> saveCard(String userId, BusinessCardModel card, int priority);
  Future<void> removeCard(String userId, String cardId);
  Future<void> updateCardPriority(String userId, String cardId, int priority);
  Future<List<SavedCardModel>> getSavedCards(String userId);
  Future<SavedCardModel?> getSavedCard(String userId, String cardId);
  Stream<List<SavedCardModel>> streamSavedCards(String userId);
}

class SavedCardFirestoreDataSourceImpl implements SavedCardFirestoreDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  SavedCardFirestoreDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<SavedCardModel> saveCard(String userId, BusinessCardModel card, int priority) async {
    try {
      final currentUserId = firebaseAuth.currentUser?.uid;
      if (currentUserId == null || currentUserId != userId) {
        throw UnauthenticatedException();
      }

      // Kart bilgileri (card data) da Firestore'da tutulur; referans + snapshot
      final savedCard = SavedCardModel(
        id: card.id,
        cardId: card.id,
        userId: userId,
        priority: priority,
        savedAt: DateTime.now(),
        cardData: card, // Kaydedilen kişinin kartvizit bilgisi (email, phone, company, vb.)
      );

      await firestore
          .collection('saved_cards')
          .doc(userId)
          .collection('cards')
          .doc(card.id)
          .set(savedCard.toJson());

      return savedCard;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Unknown error');
    }
  }

  @override
  Stream<List<SavedCardModel>> streamSavedCards(String userId) {
    try {
      return firestore
          .collection('saved_cards')
          .doc(userId)
          .collection('cards')
          .orderBy('priority', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => SavedCardModel.fromJson(doc.data(), doc.id))
              .toList());
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Unknown error');
    }
  }

  // ... diğer metodlar
}
```

#### Task 2.15: Repository Implementation Güncellemesi

- [ ] `lib/features/business_card/data/repositories/business_card_repository_impl.dart` dosyasını güncelle

  - [ ] Firestore remote datasource entegrasyonu
  - [ ] Local datasource ile sync mekanizması (offline support)
  - [ ] Cache strategy (local first, then remote)
  - [ ] Error handling

- [ ] `lib/features/card_collection/data/repositories/card_collection_repository_impl.dart` dosyasını güncelle
  - [ ] Firestore remote datasource entegrasyonu
  - [ ] Real-time updates için stream support

#### Task 2.16: Dependency Injection Güncellemesi

- [ ] `lib/core/injection/injection_container.dart` dosyasını güncelle
  - [ ] Firebase instance'larını register et
    - [ ] `FirebaseAuth`
    - [ ] `FirebaseFirestore`
    - [ ] `FirebaseStorage`
    - [ ] `GoogleSignIn`
  - [ ] Authentication datasource'ları register et
  - [ ] Authentication repository'yi register et
  - [ ] Authentication use case'leri register et
  - [ ] Authentication BLoC'u register et
  - [ ] Business Card Firestore datasource'unu register et
  - [ ] Saved Card Firestore datasource'unu register et

**Örnek Yapı:**

```dart
final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<BusinessCardFirestoreDataSource>(
    () => BusinessCardFirestoreDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );

  // ... diğer registration'lar
}
```

#### Task 2.17: QR Kod ile Public Card Erişimi

- [ ] `lib/features/business_card/data/datasources/business_card_firestore_datasource.dart` dosyasına ekle
  - [ ] `createPublicCard(String cardId)` - Kartviziti public collection'a kopyala
  - [ ] `getPublicCard(String cardId)` - Public kartviziti getir (authentication olmadan)
  - [ ] QR kod ile erişim için public endpoint

**Örnek Yapı:**

```dart
@override
Future<BusinessCardModel> createPublicCard(String cardId) async {
  try {
    final card = await getBusinessCard(cardId);
    await firestore
        .collection('public_cards')
        .doc(cardId)
        .set(card.toJson());
    return card;
  } on FirebaseException catch (e) {
    throw ServerException(message: e.message ?? 'Unknown error');
  }
}

@override
Future<BusinessCardModel> getPublicCard(String cardId) async {
  try {
    final doc = await firestore
        .collection('public_cards')
        .doc(cardId)
        .get();

    if (!doc.exists) {
      throw NotFoundException('Public card not found');
    }

    return BusinessCardModel.fromJson(doc.data()!, doc.id);
  } on FirebaseException catch (e) {
    throw ServerException(message: e.message ?? 'Unknown error');
  }
}
```

#### Task 2.18: Search ve Filter Implementation (Firestore)

- [ ] `lib/features/business_card/data/datasources/business_card_firestore_datasource.dart` dosyasına ekle
  - [ ] Firestore query ile arama implementasyonu
  - [ ] Sektör, şirket, departman, lokasyon filtreleme
  - [ ] Composite index'ler oluştur (Firebase Console'da)
  - [ ] Pagination support

**Örnek Yapı:**

```dart
@override
Future<List<BusinessCardModel>> searchBusinessCards(String query) async {
  try {
    final querySnapshot = await firestore
        .collection('business_cards')
        .where('searchKeywords', arrayContains: query.toLowerCase())
        .limit(50)
        .get();

    return querySnapshot.docs
        .map((doc) => BusinessCardModel.fromJson(doc.data(), doc.id))
        .toList();
  } on FirebaseException catch (e) {
    throw ServerException(message: e.message ?? 'Unknown error');
  }
}

@override
Future<List<BusinessCardModel>> filterBusinessCards(Map<String, dynamic> filters) async {
  try {
    Query query = firestore.collection('business_cards');

    if (filters.containsKey('sector')) {
      query = query.where('sector', isEqualTo: filters['sector']);
    }

    if (filters.containsKey('company')) {
      query = query.where('company', isEqualTo: filters['company']);
    }

    if (filters.containsKey('department')) {
      query = query.where('department', isEqualTo: filters['department']);
    }

    if (filters.containsKey('location')) {
      query = query.where('location', isEqualTo: filters['location']);
    }

    final querySnapshot = await query.limit(50).get();

    return querySnapshot.docs
        .map((doc) => BusinessCardModel.fromJson(doc.data(), doc.id))
        .toList();
  } on FirebaseException catch (e) {
    throw ServerException(message: e.message ?? 'Unknown error');
  }
}
```

#### Task 2.19: Error Handling ve Exception Mapping

- [ ] `lib/core/error/exceptions.dart` dosyasını güncelle
  - [ ] `FirebaseAuthException` mapping
  - [ ] `FirebaseException` mapping
  - [ ] Custom exception sınıfları
    - [ ] `UnauthenticatedException`
    - [ ] `ServerException`
    - [ ] `NetworkException`
    - [ ] `NotFoundException`

#### Task 2.20: Testing

- [ ] Authentication BLoC testleri
- [ ] Firestore datasource testleri (mock)
- [ ] Repository testleri
- [ ] Integration testleri (test environment)

---

### Faz 3: Tema ve Design System 🎨

**Clean Architecture:** Tema ve widget’lar presentation/core’da kalır; domain katmanına tema veya UI bağımlılığı eklenmez.

#### Task 3.1: Renk Paleti Oluşturma

- [ ] `lib/core/theme/app_colors.dart` dosyasını oluştur
  - [ ] Primary renk paleti
  - [ ] Secondary renk paleti
  - [ ] Background renkleri
  - [ ] Text renkleri
  - [ ] Error/Warning/Success renkleri
  - [ ] Dark mode renkleri

**Örnek Yapı:**

```dart
class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Card Colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x1A000000);
}
```

#### Task 3.2: Typography Sistemi

- [ ] `lib/core/theme/app_text_styles.dart` dosyasını oluştur
  - [ ] Heading stilleri (H1, H2, H3, H4, H5, H6)
  - [ ] Body stilleri (Large, Medium, Small)
  - [ ] Caption stilleri
  - [ ] Button stilleri
  - [ ] Label stilleri

**Örnek Yapı:**

```dart
class AppTextStyles {
  // Headings
  static TextStyle heading1({Color? color}) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.textPrimary,
  );

  static TextStyle heading2({Color? color}) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.textPrimary,
  );

  // Body
  static TextStyle bodyLarge({Color? color}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: color ?? AppColors.textPrimary,
  );

  // ... diğer stiller
}
```

#### Task 3.3: Spacing ve Dimensions

- [ ] `lib/core/theme/app_dimensions.dart` dosyasını oluştur
  - [ ] Padding değerleri
  - [ ] Margin değerleri
  - [ ] Border radius değerleri
  - [ ] Icon size değerleri
  - [ ] Card dimensions

#### Task 3.4: Ana Tema Dosyası

- [ ] `lib/core/theme/app_theme.dart` dosyasını oluştur
  - [ ] Light theme konfigürasyonu
  - [ ] Dark theme konfigürasyonu
  - [ ] MaterialApp theme wrapper

**Örnek Yapı:**

```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.heading1(),
        bodyLarge: AppTextStyles.bodyLarge(),
        // ... diğer stiller
      ),
      // ... diğer tema ayarları
    );
  }

  static ThemeData get darkTheme {
    // Dark theme konfigürasyonu
  }
}
```

---

### Faz 4: Veri Modelleri ve State Management 📊

**Clean Architecture:** Entity’ler Domain’de (saf Dart); Model’ler Data’da (serialization, Entity ↔ Model dönüşümü). BLoC/Cubit sadece use case veya repository interface kullanır.

#### Task 4.1: Business Card Entity Oluşturma

- [ ] `lib/features/business_card/domain/entities/business_card.dart` dosyasını oluştur
  - [ ] Tüm kartvizit alanlarını içeren entity sınıfı
  - [ ] Equatable implementasyonu

**Örnek Yapı:**

```dart
class BusinessCard extends Equatable {
  final String id;
  final String userId; // Firebase'de kullanıcı ID'si
  final String? email;
  final String? summary;
  final String? phone;
  final String? title;
  final String? department;
  final String? sector;
  final String? corporatePhone;
  final String? website;
  final String? location;
  final String? linkedin;
  final String? twitter;
  final String? instagram;
  final String? company;
  final String? event;
  final String? additionalNotes;
  final List<String> visibleFields; // Seçilen 5 alan
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor ve methods
}
```

#### Task 4.2: Business Card Model Oluşturma

- [ ] `lib/features/business_card/data/models/business_card_model.dart` dosyasını oluştur
  - [ ] JSON serialization/deserialization
  - [ ] Entity'den Model'e, Model'den Entity'ye dönüşüm metodları

#### Task 4.3: Saved Card Entity ve Model

Kullanıcının kaydettiği kişilerin **kart bilgileri Firebase'de tutulduğu** için entity/model hem referans hem de kart içeriğini taşır.

- [ ] `lib/features/card_collection/domain/entities/saved_card.dart` dosyasını oluştur
  - [ ] cardId (referans)
  - [ ] **cardData / businessCard** – Kaydedilen kişinin kartvizit bilgisi (BusinessCard entity; Firestore'da snapshot olarak saklanır)
  - [ ] Önem derecesi (priority) alanı
  - [ ] Kaydedilme tarihi (savedAt)
- [ ] `lib/features/card_collection/data/models/saved_card_model.dart` dosyasını oluştur
  - [ ] Firestore'a yazarken `cardData` (BusinessCard alanları) tek döküman içinde veya nested map olarak serialize
  - [ ] Okurken `cardData`'dan BusinessCard entity rehydration

#### Task 4.4: BLoC/Cubit Yapılarının Oluşturulması

- [ ] Business Card BLoC oluştur
  - [ ] `business_card_event.dart` - Create, Update, Delete, Get events
  - [ ] `business_card_state.dart` - Initial, Loading, Loaded, Error states
  - [ ] `business_card_bloc.dart` - Event handling logic
- [ ] Card Collection BLoC oluştur
  - [ ] Save card, Delete card, Update priority events
  - [ ] İlgili state'ler
- [ ] QR Share Cubit oluştur
  - [ ] Generate QR, Scan QR logic
- [ ] Search Filter Cubit oluştur
  - [ ] Search, Filter logic

---

### Faz 5: Atomic Widget Sistemi 🧩

**Clean Architecture:** Widget’lar presentation/core’da; domain’e referans vermezler, sadece veri (entity/model) alırlar.

#### Task 5.1: Atom Widget'ları

- [ ] `lib/core/widgets/atoms/custom_text.dart`
  - [ ] Tema ile entegre text widget'ı
- [ ] `lib/core/widgets/atoms/custom_button.dart`
  - [ ] Primary, Secondary, Outlined button varyasyonları
- [ ] `lib/core/widgets/atoms/custom_text_field.dart`
  - [ ] Validasyon, hint, label desteği
- [ ] `lib/core/widgets/atoms/custom_icon.dart`
  - [ ] Icon wrapper with size ve color kontrolü

#### Task 5.2: Molecule Widget'ları

- [ ] `lib/core/widgets/molecules/card_field_item.dart`
  - [ ] Kartvizit alan gösterimi için widget
- [ ] `lib/core/widgets/molecules/search_bar.dart`
  - [ ] Arama çubuğu widget'ı
- [ ] `lib/core/widgets/molecules/filter_chip.dart`
  - [ ] Filtreleme için chip widget'ı
- [ ] `lib/core/widgets/molecules/priority_selector.dart`
  - [ ] Önem derecesi seçici widget

#### Task 5.3: Organism Widget'ları

- [ ] `lib/core/widgets/organisms/business_card_preview.dart`
  - [ ] Kartvizit önizleme widget'ı (5 alan gösterimi)
- [ ] `lib/core/widgets/organisms/business_card_detail.dart`
  - [ ] Kartvizit detay gösterim widget'ı
- [ ] `lib/core/widgets/organisms/qr_code_display.dart`
  - [ ] QR kod gösterim widget'ı

---

### Faz 6: Kartvizit Oluşturma ve Düzenleme ✏️

**Clean Architecture:** Sayfalar BLoC/Cubit ile konuşur; doğrudan repository veya data source çağrılmaz. Form verisi use case’e gider.

#### Task 6.1: Create Business Card Page

- [ ] `lib/features/business_card/presentation/pages/create_business_card_page.dart`
  - [ ] Form alanları (tüm kartvizit bilgileri)
  - [ ] 5 alan seçim mekanizması (checkbox/list)
  - [ ] Validasyon
  - [ ] BLoC entegrasyonu
  - [ ] Kaydet butonu

#### Task 6.2: Edit Business Card Page

- [ ] `lib/features/business_card/presentation/pages/edit_business_card_page.dart`
  - [ ] Mevcut verileri yükleme
  - [ ] Form düzenleme
  - [ ] Güncelleme işlemi

#### Task 6.3: Field Selection Widget

- [ ] 5 alan seçimi için özel widget
  - [ ] Checkbox listesi
  - [ ] Maximum 5 seçim kontrolü
  - [ ] Görsel geri bildirim

#### Task 6.4: Form Validators

- [ ] `lib/core/utils/validators.dart` dosyasını oluştur
  - [ ] Email validator
  - [ ] Phone validator
  - [ ] URL validator
  - [ ] Required field validator

---

### Faz 7: Kartvizit Detay Sayfası 📄

**Clean Architecture:** Detay sayfası BLoC/Cubit üzerinden entity alır; veri Domain/Data katmanından use case → presentation akışıyla gelir.

#### Task 7.1: Business Card Detail Page

- [ ] `lib/features/business_card/presentation/pages/business_card_detail_page.dart`
  - [ ] Tüm bilgilerin gösterimi
  - [ ] Sosyal medya linkleri (tıklanabilir)
  - [ ] Telefon numarası (arama özelliği)
  - [ ] Email (mail gönderme özelliği)
  - [ ] Website (açma özelliği)
  - [ ] QR kod paylaşım butonu
  - [ ] Düzenle butonu

#### Task 7.2: Action Buttons

- [ ] Call button
- [ ] Email button
- [ ] Website button
- [ ] Share button
- [ ] Social media buttons (LinkedIn, Twitter, Instagram)

#### Task 7.3: URL Launcher Integration

- [ ] `url_launcher` paketi ile entegrasyon
- [ ] Telefon arama
- [ ] Email gönderme
- [ ] Web sitesi açma
- [ ] Sosyal medya profillerini açma

---

### Faz 8: QR Kod Oluşturma ve Paylaşım 📱

**Clean Architecture:** QR feature’da domain (entity/use case), data (repository impl), presentation (Cubit, sayfalar) ayrımı korunur; encoding/decoding data veya domain’de, UI presentation’da.

#### Task 8.1: QR Code Generation

- [ ] `lib/features/qr_share/presentation/pages/qr_generate_page.dart`
  - [ ] Kartvizit ID'sini QR koda dönüştürme
  - [ ] QR kod görselleştirme
  - [ ] QR kod paylaşım özelliği

#### Task 8.2: QR Code Scanning

- [ ] `lib/features/qr_share/presentation/pages/qr_scan_page.dart`
  - [ ] QR kod okuma
  - [ ] Okunan ID ile kartvizit yükleme
  - [ ] Kartvizit detay sayfasına yönlendirme

#### Task 8.3: QR Share Cubit

- [ ] QR kod oluşturma logic
- [ ] QR kod okuma logic
- [ ] Paylaşım logic (share_plus paketi)

#### Task 8.4: Data Encoding/Decoding

- [ ] Kartvizit verilerini JSON'a çevirme
- [ ] JSON'u QR kod formatına dönüştürme
- [ ] QR kod'dan JSON'a geri dönüştürme

---

### Faz 9: Kartvizit Koleksiyonu ve Önem Derecesi ⭐

**Clean Architecture:** Koleksiyon BLoC’u use case/repository kullanır; kaydedilen kartlar Domain entity ile temsil edilir, Data katmanı Firestore/cache ile konuşur.

#### Task 9.1: Card Collection Page

- [ ] `lib/features/card_collection/presentation/pages/card_collection_page.dart`
  - [ ] Kaydedilmiş kartvizitlerin listelenmesi
  - [ ] Grid/List görünüm toggle
  - [ ] Önem derecesine göre sıralama
  - [ ] Kartvizit silme özelliği

#### Task 9.2: Priority Management

- [ ] Önem derecesi güncelleme
  - [ ] Drag & drop ile sıralama
  - [ ] Star/priority selector
  - [ ] Priority levels: High, Medium, Low, None

#### Task 9.3: Saved Card Detail Page

- [ ] `lib/features/card_collection/presentation/pages/saved_card_detail_page.dart`
  - [ ] Kartvizit detay gösterimi
  - [ ] Önem derecesi güncelleme
  - [ ] Kartvizitten çıkarma özelliği

#### Task 9.4: Card Collection BLoC

- [ ] Save card event
- [ ] Delete card event
- [ ] Update priority event
- [ ] Get all saved cards event

---

### Faz 10: Arama ve Filtreleme 🔍

**Clean Architecture:** Arama/filtre use case’i Domain’de; repository interface Data’da implement edilir; Cubit sadece use case çağırır.

#### Task 10.1: Search Filter Page

- [ ] `lib/features/search_filter/presentation/pages/search_filter_page.dart`
  - [ ] Arama çubuğu
  - [ ] Filtre seçenekleri
    - [ ] Sektör bazlı filtreleme
    - [ ] Şirket bazlı filtreleme
    - [ ] Departman bazlı filtreleme
    - [ ] Lokasyon bazlı filtreleme
  - [ ] Sonuç listesi
  - [ ] Filtreleri temizle butonu

#### Task 10.2: Search Filter Cubit

- [ ] Search event
- [ ] Filter event
- [ ] Clear filters event
- [ ] Filtered results state

#### Task 10.3: Filter Chips Widget

- [ ] Aktif filtreleri gösteren chip'ler
- [ ] Chip'leri kaldırma özelliği
- [ ] Filtre kombinasyonları

#### Task 10.4: Search Implementation

- [ ] İsim, şirket, sektör, departman araması
- [ ] Case-insensitive arama
- [ ] Real-time arama (debounce)

---

### Faz 11: Veri Kalıcılığı (Local Storage - Offline Support) 💾

**Clean Architecture:** Local data source Data katmanında abstract + impl; repository önce local’e sonra remote’a gidecek şekilde yazılır; Domain değişmez.

#### Task 11.1: Local Data Source (Cache)

- [ ] `lib/features/business_card/data/datasources/business_card_local_datasource.dart`
  - [ ] SharedPreferences veya Hive entegrasyonu
  - [ ] Cache CRUD işlemleri
  - [ ] JSON serialization/deserialization
  - [ ] Offline için fallback mekanizması

#### Task 11.2: Repository Implementation Güncellemesi

- [ ] `lib/features/business_card/data/repositories/business_card_repository_impl.dart`
  - [ ] Local cache kullanımı (offline support)
  - [ ] Firestore ile sync mekanizması
  - [ ] Cache-first strategy (network fallback)
  - [ ] Error handling

#### Task 11.3: Saved Cards Local Cache

- [ ] Kaydedilmiş kartvizitlerin local cache'i
  - [ ] Priority bilgisi ile birlikte
  - [ ] Timestamp bilgisi
  - [ ] Offline erişim desteği

---

### Faz 12: Ana Sayfa ve Navigasyon 🏠

**Clean Architecture:** Ana sayfa ve navigasyon presentation’da; auth check use case/repository üzerinden yapılır, doğrudan Firebase Auth çağrılmaz.

#### Task 12.1: Splash Screen ve Auth Check

- [ ] `lib/features/authentication/presentation/pages/splash_page.dart` dosyasını oluştur
  - [ ] Uygulama açılışında authentication kontrolü
  - [ ] Auth state'e göre yönlendirme (login veya home)
  - [ ] Loading indicator

#### Task 12.2: Home Page

- [ ] `lib/features/home/presentation/pages/home_page.dart`
  - [ ] Bottom navigation bar
  - [ ] Kullanıcının kendi kartviziti önizlemesi (Firestore'dan)
  - [ ] Hızlı erişim butonları
    - [ ] Kartvizit oluştur/düzenle
    - [ ] QR kod oluştur
    - [ ] QR kod oku
    - [ ] Koleksiyonum
    - [ ] Ara
  - [ ] Logout butonu
  - [ ] User profile bilgileri

#### Task 12.3: Navigation Setup

- [ ] Route tanımlamaları
  - [ ] `/` - Splash
  - [ ] `/login` - Login
  - [ ] `/signup` - Signup
  - [ ] `/home` - Home (protected)
  - [ ] `/business-card/create` - Create Card (protected)
  - [ ] `/business-card/edit` - Edit Card (protected)
  - [ ] `/business-card/detail` - Card Detail
  - [ ] `/card-collection` - Card Collection (protected)
  - [ ] `/search` - Search (protected)
- [ ] Navigator entegrasyonu
- [ ] Auth guard entegrasyonu
- [ ] Deep linking hazırlığı

#### Task 12.4: Home BLoC

- [ ] Kullanıcının kendi kartvizitini Firestore'dan yükleme
- [ ] İstatistikler (toplam kayıtlı kart sayısı, vs.)
- [ ] Real-time updates (stream)

---

### Faz 13: Test ve Optimizasyon ✅

**Clean Architecture:** Unit test’lerde Domain use case ve entity’ler mock’sız test edilebilir; Data ve Presentation mock repository/use case ile test edilir.

#### Task 13.1: Unit Tests

- [ ] BLoC/Cubit testleri
- [ ] Repository testleri
- [ ] Use case testleri
- [ ] Validator testleri

#### Task 13.2: Widget Tests

- [ ] Atom widget testleri
- [ ] Molecule widget testleri
- [ ] Organism widget testleri
- [ ] Page widget testleri

#### Task 13.3: Integration Tests

- [ ] Kartvizit oluşturma akışı
- [ ] QR kod paylaşım akışı
- [ ] Arama ve filtreleme akışı

#### Task 13.4: Performance Optimization

- [ ] Image caching
- [ ] List optimization (ListView.builder)
- [ ] Lazy loading
- [ ] Memory leak kontrolü

#### Task 13.5: Code Quality

- [ ] Linter kurallarının uygulanması
- [ ] Code formatting
- [ ] Documentation
- [ ] Error handling iyileştirmeleri

---

## 📝 Geliştirme Notları

### Best Practices

1. **Atomic Design**: Tüm widget'lar atomic seviyede tutulmalı
2. **BLoC Pattern**: Tüm state management BLoC/Cubit ile yapılmalı
3. **Clean Architecture**: Feature bazlı klasör yapısı korunmalı
4. **Error Handling**: Tüm hatalar uygun şekilde handle edilmeli
5. **Validation**: Form validasyonları eksiksiz olmalı
6. **Localization**: Tüm metinler constant olarak tanımlanmalı (ileride i18n için hazır)

### Önemli Notlar

- Her faz bağımsız olarak test edilebilir olmalı
- Her task tamamlandığında commit yapılmalı
- Code review yapılmadan merge edilmemeli
- Her feature için minimum test coverage: %70

### Sonraki Adımlar (Opsiyonel)

- [ ] Çoklu dil desteği (i18n)
- [ ] Dark mode toggle
- [ ] Kartvizit şablonları
- [ ] Firebase Analytics entegrasyonu
- [ ] Firebase Cloud Messaging (Push notifications)
- [ ] Export/Import özelliği (PDF, vCard)
- [ ] Profile fotoğrafı yükleme (Firebase Storage)
- [ ] Kartvizit görsel tasarım özelleştirme
- [ ] Batch operations (toplu kartvizit işlemleri)
- [ ] Kartvizit istatistikleri (görüntülenme sayısı, vs.)

