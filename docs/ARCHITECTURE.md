# Cardence – Mimari: Clean Architecture

**Uyarı:** Bu projede tüm geliştirme **Clean Architecture** standartlarına göre yapılır. Her feature, task ve kod değişikliği bu kurallara uymalıdır.

---

## 1. Temel İlke

- **Bağımlılık kuralı:** Dış katmanlar iç katmanlara bağımlıdır; **iç katmanlar dış katmanları bilmez ve import etmez.**
- **Domain** en içte, framework’ten ve veri kaynaklarından bağımsızdır.
- **Data** katmanı domain’i kullanır; **Presentation** katmanı domain’i (ve gerekirse data’daki abstract interface’leri) kullanır.

---

## 2. Katmanlar

| Katman | İçerik | Bağımlılık yönü |
|--------|--------|------------------|
| **Domain** | Entities, Repository interfaces (abstract), Use cases | Hiçbir Flutter/Firebase/UI’a bağımlı değil |
| **Data** | Models, Repository implementations, Data sources (remote/local) | Sadece Domain’e bağımlı |
| **Presentation** | BLoC/Cubit, Pages, Widgets | Domain’e (ve gerekirse Data’daki abstract’lara) bağımlı; concrete implementation’ları **sadece DI ile** alır |

---

## 3. Feature klasör yapısı (her feature için)

Her feature (`authentication`, `business_card`, `card_collection`, `qr_share`, `search_filter`, `home` vb.) aşağıdaki yapıya uyar:

```
lib/features/<feature_name>/
  domain/
    entities/           # Saf Dart sınıfları, framework yok
    repositories/       # Abstract repository (interface)
    usecases/           # Tek sorumluluk, repository çağırır
  data/
    models/             # JSON/Firestore serialization, Entity ↔ Model dönüşümü
    datasources/        # Remote (Firestore, Auth) ve Local (cache) – abstract + impl
    repositories/       # Repository implementation (datasource kullanır)
  presentation/
    bloc/ veya cubit/   # Events, States, BLoC/Cubit
    pages/
    widgets/
```

**Uyarı:** Domain içinde `import 'package:flutter/...'` veya `import 'package:firebase_...'` **kullanılmaz**. Entity’ler ve repository interface’leri saf Dart’tır.

---

## 4. Bağımlılık yönü (kısa)

- **Presentation** → **Domain** (ve gerekirse Data’daki **abstract** sınıflar, örn. `AuthRemoteDataSource` interface).
- **Data** → **Domain** (Entity kullanır; Repository impl, Domain’deki interface’i implement eder).
- **Domain** → hiçbir şey (entity, use case, repository interface sadece).

Concrete implementation’lar (ör. `AuthRemoteDataSourceImpl`, `FirebaseAuth`) sadece **dependency injection** (GetIt, constructor injection) ile verilir; presentation veya use case doğrudan `FirebaseAuth.instance` kullanmaz.

---

## 5. Kontrol listesi (her task için)

- [ ] Yeni sınıf hangi katmana ait? (domain / data / presentation)
- [ ] Domain’de Flutter veya Firebase import’u var mı? **Olmamalı.**
- [ ] Repository, Domain’de abstract mı? Implementation sadece Data’da mı?
- [ ] Use case sadece Domain repository interface’ini mi kullanıyor?
- [ ] BLoC/Cubit sadece Use case veya Repository (interface) mi kullanıyor?

Bu kurallar **her durumda** geçerlidir; PROGRESS.md’deki tüm fazlar ve task’lar bu mimariye göre uygulanır.

---

## 6. BLoC State Management

- **Kullanım:** State management için sadece **BLoC** veya **Cubit** (flutter_bloc) kullanılır.
- **Konum:** Her feature’da `presentation/bloc/` veya `presentation/cubit/`; dosyalar `*_bloc.dart`, `*_event.dart`, `*_state.dart` veya `*_cubit.dart`.
- **Akış:** UI yalnızca event emit eder veya cubit metodunu çağırır; iş mantığı BLoC/Cubit veya use case içindedir. Sayfa/widget doğrudan repository veya use case çağırmaz.
- **State tüketimi:** BlocProvider, BlocBuilder, BlocListener, BlocConsumer kullanılır; state’ler Equatable ile tanımlanır.
- **Cubit:** Basit tek yönlü akışlarda (filtre, QR vb.) Cubit; karmaşık çok adımlı akışlarda BLoC tercih edilir.

---

## 7. Atomic Design System

- **Seviyeler:** Atoms → Molecules → Organisms. Sayfalar bu bileşenlerin birleşimiyle oluşturulur.
- **core/widgets/atoms/:** En küçük bileşenler (CustomText, CustomButton, CustomTextField, CustomIcon). Tema ile uyumlu, tekrar kullanılabilir.
- **core/widgets/molecules/:** Atom grupları (CardFieldItem, SearchBar, FilterChip, PrioritySelector). Tek işlev/veri parçası.
- **core/widgets/organisms/:** Büyük bloklar (BusinessCardPreview, BusinessCardDetail, QrCodeDisplay). Ekran bölümü veya tam kart.
- **Feature widget’ları:** Feature’a özel bileşenler `features/<feature>/presentation/widgets/` altında; paylaşılan bileşenler core’da.
- **Tema:** Atom/molecule’lar Theme.of(context) veya core/theme sabitlerini kullanır; hard-coded renk/font mümkün olduğunca kullanılmaz.

---

## 8. Renkler: Sadece AppColors

- Tüm renkler **`AppColors`** (lib/core/theme/app_colors.dart) üzerinden kullanılır. `Colors.blue`, `Color(0xFF...)` vb. kullanılmaz; istisna yalnızca `Colors.transparent`. Detay: `docs/THEME_COLORS.md`.

Cursor kuralı özeti: `.cursor/rules/clean-architecture.mdc` (Clean Architecture + BLoC + Atomic Design + renkler).
