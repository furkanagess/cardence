import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @aZ.
  ///
  /// In tr, this message translates to:
  /// **'A → Z'**
  String get aZ;

  /// No description provided for @adSoyad.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get adSoyad;

  /// No description provided for @adYalnzcaHarfIermeliEn.
  ///
  /// In tr, this message translates to:
  /// **'Ad yalnızca harf içermeli (en az 2 karakter)'**
  String get adYalnzcaHarfIermeliEn;

  /// No description provided for @adZorunludur.
  ///
  /// In tr, this message translates to:
  /// **'Ad zorunludur'**
  String get adZorunludur;

  /// No description provided for @adres.
  ///
  /// In tr, this message translates to:
  /// **'Adres'**
  String get adres;

  /// No description provided for @adresSosyalMedyaVeEtkinlik.
  ///
  /// In tr, this message translates to:
  /// **'Adres, sosyal medya ve etkinlik gibi isteğe bağlı alanlar.'**
  String get adresSosyalMedyaVeEtkinlik;

  /// No description provided for @aiConsultant.
  ///
  /// In tr, this message translates to:
  /// **'AI Consultant'**
  String get aiConsultant;

  /// No description provided for @ak.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get ak;

  /// No description provided for @alanKaldr.
  ///
  /// In tr, this message translates to:
  /// **'Alanı kaldır'**
  String get alanKaldr;

  /// No description provided for @alanlarDoldukaGrnr.
  ///
  /// In tr, this message translates to:
  /// **'Alanlar doldukça görünür'**
  String get alanlarDoldukaGrnr;

  /// No description provided for @appStorePlayStorezerinden.
  ///
  /// In tr, this message translates to:
  /// **'App Store / Play Store üzerinden güvenli ödeme.'**
  String get appStorePlayStorezerinden;

  /// No description provided for @appStoreVeyaPlayStore.
  ///
  /// In tr, this message translates to:
  /// **'App Store veya Play Store\\'**
  String get appStoreVeyaPlayStore;

  /// No description provided for @apple.
  ///
  /// In tr, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @aramaVeyaFiltreKriterleriniDeitirin.
  ///
  /// In tr, this message translates to:
  /// **'Arama veya filtre kriterlerini değiştirin.'**
  String get aramaVeyaFiltreKriterleriniDeitirin;

  /// No description provided for @aramayKapat.
  ///
  /// In tr, this message translates to:
  /// **'Aramayı kapat'**
  String get aramayKapat;

  /// No description provided for @aramayTemizle.
  ///
  /// In tr, this message translates to:
  /// **'Aramayı temizle'**
  String get aramayTemizle;

  /// No description provided for @aramayaUyanKartYok.
  ///
  /// In tr, this message translates to:
  /// **'Aramaya uyan kart yok'**
  String get aramayaUyanKartYok;

  /// No description provided for @arkaPlanMetinRengiVe.
  ///
  /// In tr, this message translates to:
  /// **'Arka plan, metin rengi ve kart stili.'**
  String get arkaPlanMetinRengiVe;

  /// No description provided for @arkaPlanVeMetinRengi.
  ///
  /// In tr, this message translates to:
  /// **'Arka plan ve metin rengi seçimleri anında kaydedilir.'**
  String get arkaPlanVeMetinRengi;

  /// No description provided for @arkaYz.
  ///
  /// In tr, this message translates to:
  /// **'Arka yüz'**
  String get arkaYz;

  /// No description provided for @arkaYzFotorafYok.
  ///
  /// In tr, this message translates to:
  /// **'Arka yüz fotoğrafı yok'**
  String get arkaYzFotorafYok;

  /// No description provided for @arkaYzdeGster.
  ///
  /// In tr, this message translates to:
  /// **'Arka yüzde göster'**
  String get arkaYzdeGster;

  /// No description provided for @arkadalarnaner.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlarına öner'**
  String get arkadalarnaner;

  /// No description provided for @artDirector.
  ///
  /// In tr, this message translates to:
  /// **'Art Director'**
  String get artDirector;

  /// No description provided for @ayarlar.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get ayarlar;

  /// No description provided for @balantHatasLtfenTekrarDeneyin.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası. Lütfen tekrar deneyin.'**
  String get balantHatasLtfenTekrarDeneyin;

  /// No description provided for @beceriEkle.
  ///
  /// In tr, this message translates to:
  /// **'Beceri ekle'**
  String get beceriEkle;

  /// No description provided for @beceriler.
  ///
  /// In tr, this message translates to:
  /// **'Beceriler'**
  String get beceriler;

  /// No description provided for @bilgiEkle.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi ekle'**
  String get bilgiEkle;

  /// No description provided for @bilgiGirildikeKarttaGrnr.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi girildikçe kartta görünür'**
  String get bilgiGirildikeKarttaGrnr;

  /// No description provided for @bilgiler.
  ///
  /// In tr, this message translates to:
  /// **'Bilgiler'**
  String get bilgiler;

  /// No description provided for @bilgilerOkunuyor.
  ///
  /// In tr, this message translates to:
  /// **'Bilgiler okunuyor…'**
  String get bilgilerOkunuyor;

  /// No description provided for @bilgileriDzenle.
  ///
  /// In tr, this message translates to:
  /// **'Bilgileri düzenle'**
  String get bilgileriDzenle;

  /// No description provided for @bilgileriElleGir.
  ///
  /// In tr, this message translates to:
  /// **'Bilgileri elle gir'**
  String get bilgileriElleGir;

  /// No description provided for @bilgileriOku.
  ///
  /// In tr, this message translates to:
  /// **'Bilgileri oku'**
  String get bilgileriOku;

  /// No description provided for @bilinmiyor.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmiyor'**
  String get bilinmiyor;

  /// No description provided for @biziDeerlendirin.
  ///
  /// In tr, this message translates to:
  /// **'Bizi değerlendirin'**
  String get biziDeerlendirin;

  /// No description provided for @brakmakIinKonumuSein.
  ///
  /// In tr, this message translates to:
  /// **'Bırakmak için konumu seçin'**
  String get brakmakIinKonumuSein;

  /// No description provided for @brandStrategist.
  ///
  /// In tr, this message translates to:
  /// **'Brand Strategist'**
  String get brandStrategist;

  /// No description provided for @buAlanCardenceKartndaDzenlenemez.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan Cardence kartında düzenlenemez'**
  String get buAlanCardenceKartndaDzenlenemez;

  /// No description provided for @buGrubuSil.
  ///
  /// In tr, this message translates to:
  /// **'Bu grubu sil'**
  String get buGrubuSil;

  /// No description provided for @buGruptaKartYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu grupta kart yok'**
  String get buGruptaKartYok;

  /// No description provided for @buKartZatenCzdannzda.
  ///
  /// In tr, this message translates to:
  /// **'Bu kart zaten cüzdanınızda.'**
  String get buKartZatenCzdannzda;

  /// No description provided for @buKartZatenKaytl.
  ///
  /// In tr, this message translates to:
  /// **'Bu kart zaten kayıtlı'**
  String get buKartZatenKaytl;

  /// No description provided for @buKiiHakkndaEklemekIstediiniz.
  ///
  /// In tr, this message translates to:
  /// **'Bu kişi hakkında eklemek istediğiniz notlar...'**
  String get buKiiHakkndaEklemekIstediiniz;

  /// No description provided for @buKiiHakkndaNotYazn.
  ///
  /// In tr, this message translates to:
  /// **'Bu kişi hakkında not yazın'**
  String get buKiiHakkndaNotYazn;

  /// No description provided for @buKisiHakkindaNotYazin.
  ///
  /// In tr, this message translates to:
  /// **'Bu kisi hakkinda not yazin'**
  String get buKisiHakkindaNotYazin;

  /// No description provided for @cardence.
  ///
  /// In tr, this message translates to:
  /// **'Cardence'**
  String get cardence;

  /// No description provided for @cardence2.
  ///
  /// In tr, this message translates to:
  /// **'Cardence\\'**
  String get cardence2;

  /// No description provided for @cardenceProOl.
  ///
  /// In tr, this message translates to:
  /// **'Cardence Pro ol'**
  String get cardenceProOl;

  /// No description provided for @cretsizHakknzDolduPremiumGerekli.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz hakkınız doldu · Premium gerekli'**
  String get cretsizHakknzDolduPremiumGerekli;

  /// No description provided for @cretsizPlandaTekKartOluturabilirsiniz.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz planda tek kart oluşturabilirsiniz. Premium ile daha fazla kart ekleyin.'**
  String get cretsizPlandaTekKartOluturabilirsiniz;

  /// No description provided for @cretsizPlandaYalnzca1Kart.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz planda yalnızca 1 kart oluşturabilirsiniz. Premium ile daha fazla kart ekleyin.'**
  String get cretsizPlandaYalnzca1Kart;

  /// No description provided for @czdanKotanz.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdan kotanız'**
  String get czdanKotanz;

  /// No description provided for @czdanKotasAlnamad.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdan kotası alınamadı.'**
  String get czdanKotasAlnamad;

  /// No description provided for @czdanVeAbonelik.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdan ve abonelik'**
  String get czdanVeAbonelik;

  /// No description provided for @czdanaEklendi.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdana Eklendi'**
  String get czdanaEklendi;

  /// No description provided for @dahaFazlaKiiKartSaklayn.
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla kişi kartı saklayın ve etkinliklerinizi ölçeklendirin.'**
  String get dahaFazlaKiiKartSaklayn;

  /// No description provided for @dataScientist.
  ///
  /// In tr, this message translates to:
  /// **'Data Scientist'**
  String get dataScientist;

  /// No description provided for @deiikliklernizlemeyeAnndaYansrKaydetmek.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikler önizlemeye anında yansır; kaydetmek için Kaydet\\'**
  String get deiikliklernizlemeyeAnndaYansrKaydetmek;

  /// No description provided for @departman.
  ///
  /// In tr, this message translates to:
  /// **'Departman'**
  String get departman;

  /// No description provided for @destek.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get destek;

  /// No description provided for @destekGizlilikVeUygulamaBilgileri.
  ///
  /// In tr, this message translates to:
  /// **'Destek, gizlilik ve uygulama bilgileri'**
  String get destekGizlilikVeUygulamaBilgileri;

  /// No description provided for @destekTalebiGnderilemedi.
  ///
  /// In tr, this message translates to:
  /// **'Destek talebi gönderilemedi.'**
  String get destekTalebiGnderilemedi;

  /// No description provided for @destekTalebiGnderilemediLtfenTekrar.
  ///
  /// In tr, this message translates to:
  /// **'Destek talebi gönderilemedi. Lütfen tekrar deneyin.'**
  String get destekTalebiGnderilemediLtfenTekrar;

  /// No description provided for @destekTalebinizAlndEnKsa.
  ///
  /// In tr, this message translates to:
  /// **'Destek talebiniz alındı. En kısa sürede dönüş yapacağız.'**
  String get destekTalebinizAlndEnKsa;

  /// No description provided for @destekVeYardm.
  ///
  /// In tr, this message translates to:
  /// **'Destek ve yardım'**
  String get destekVeYardm;

  /// No description provided for @devam.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get devam;

  /// No description provided for @dil.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get dil;

  /// No description provided for @devopsEngineer.
  ///
  /// In tr, this message translates to:
  /// **'DevOps Engineer'**
  String get devopsEngineer;

  /// No description provided for @dierKiiBuQr.
  ///
  /// In tr, this message translates to:
  /// **'Diğer kişi bu QR\\'**
  String get dierKiiBuQr;

  /// No description provided for @dorulamaKodu.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodu'**
  String get dorulamaKodu;

  /// No description provided for @doumGn.
  ///
  /// In tr, this message translates to:
  /// **'Doğum günü'**
  String get doumGn;

  /// No description provided for @doumGnSein.
  ///
  /// In tr, this message translates to:
  /// **'Doğum günü seçin'**
  String get doumGnSein;

  /// No description provided for @duzenle.
  ///
  /// In tr, this message translates to:
  /// **'Duzenle'**
  String get duzenle;

  /// No description provided for @dzenle.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get dzenle;

  /// No description provided for @ePosta.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get ePosta;

  /// No description provided for @ePostaZorunludur.
  ///
  /// In tr, this message translates to:
  /// **'E-posta zorunludur'**
  String get ePostaZorunludur;

  /// No description provided for @ehir.
  ///
  /// In tr, this message translates to:
  /// **'Şehir'**
  String get ehir;

  /// No description provided for @ekBilgiler.
  ///
  /// In tr, this message translates to:
  /// **'Ek bilgiler'**
  String get ekBilgiler;

  /// No description provided for @ekle.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get ekle;

  /// No description provided for @eklenmeTarihi.
  ///
  /// In tr, this message translates to:
  /// **'Eklenme tarihi'**
  String get eklenmeTarihi;

  /// No description provided for @etkinlikAd.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik adı'**
  String get etkinlikAd;

  /// No description provided for @etkinlikEklernWebSummit.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik ekle (örn. Web Summit)'**
  String get etkinlikEklernWebSummit;

  /// No description provided for @etkinlikFotoraf.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik fotoğrafı'**
  String get etkinlikFotoraf;

  /// No description provided for @etkinlikFotorafYklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik fotoğrafı yüklenemedi.'**
  String get etkinlikFotorafYklenemedi;

  /// No description provided for @etkinlikGrubu.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik Grubu'**
  String get etkinlikGrubu;

  /// No description provided for @etkinlikGrubu2.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grubu'**
  String get etkinlikGrubu2;

  /// No description provided for @etkinlikGrubuAlnamad.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grubu alınamadı.'**
  String get etkinlikGrubuAlnamad;

  /// No description provided for @etkinlikGrubuEkle.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grubu ekle'**
  String get etkinlikGrubuEkle;

  /// No description provided for @etkinlikGrubuOluturulamad.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grubu oluşturulamadı.'**
  String get etkinlikGrubuOluturulamad;

  /// No description provided for @etkinlikGrubuSe.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grubu seç'**
  String get etkinlikGrubuSe;

  /// No description provided for @etkinlikGrubuSilinemedi.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grubu silinemedi.'**
  String get etkinlikGrubuSilinemedi;

  /// No description provided for @etkinlikGruplar.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grupları'**
  String get etkinlikGruplar;

  /// No description provided for @etkinlikGruplarAlnamad.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grupları alınamadı.'**
  String get etkinlikGruplarAlnamad;

  /// No description provided for @etkinlikTarihi.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik tarihi'**
  String get etkinlikTarihi;

  /// No description provided for @farklBirAramaTerimiDeneyin.
  ///
  /// In tr, this message translates to:
  /// **'Farklı bir arama terimi deneyin.'**
  String get farklBirAramaTerimiDeneyin;

  /// No description provided for @farklFiltreDeneyinVeyaFiltreleri.
  ///
  /// In tr, this message translates to:
  /// **'Farklı filtre deneyin veya filtreleri temizleyin.'**
  String get farklFiltreDeneyinVeyaFiltreleri;

  /// No description provided for @filtreler.
  ///
  /// In tr, this message translates to:
  /// **'Filtreler'**
  String get filtreler;

  /// No description provided for @filtreleriTemizle.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri temizle'**
  String get filtreleriTemizle;

  /// No description provided for @filtreyeUyanKartYok.
  ///
  /// In tr, this message translates to:
  /// **'Filtreye uyan kart yok'**
  String get filtreyeUyanKartYok;

  /// No description provided for @finansAnalisti.
  ///
  /// In tr, this message translates to:
  /// **'Finans Analisti'**
  String get finansAnalisti;

  /// No description provided for @fotorafKaldr.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafı kaldır'**
  String get fotorafKaldr;

  /// No description provided for @fotorafekilemediKameraIzniniKontrol.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf çekilemedi. Kamera iznini kontrol edin.'**
  String get fotorafekilemediKameraIzniniKontrol;

  /// No description provided for @frontendDeveloper.
  ///
  /// In tr, this message translates to:
  /// **'Frontend Developer'**
  String get frontendDeveloper;

  /// No description provided for @galeri.
  ///
  /// In tr, this message translates to:
  /// **'Galeri'**
  String get galeri;

  /// No description provided for @geerliBirEPostaAdresi.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi girin'**
  String get geerliBirEPostaAdresi;

  /// No description provided for @geerliBirPozisyonGirin.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir pozisyon girin'**
  String get geerliBirPozisyonGirin;

  /// No description provided for @geerliBirTelefonNumarasGirin.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir telefon numarası girin.'**
  String get geerliBirTelefonNumarasGirin;

  /// No description provided for @geerliBirirketAdGirin.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir şirket adı girin'**
  String get geerliBirirketAdGirin;

  /// No description provided for @geersizKartKimlii.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz kart kimliği.'**
  String get geersizKartKimlii;

  /// No description provided for @geersizKartYant.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz kart yanıtı.'**
  String get geersizKartYant;

  /// No description provided for @geersizOturumYant.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz oturum yanıtı.'**
  String get geersizOturumYant;

  /// No description provided for @geersizProfilYant.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz profil yanıtı.'**
  String get geersizProfilYant;

  /// No description provided for @genel.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get genel;

  /// No description provided for @genelSoru.
  ///
  /// In tr, this message translates to:
  /// **'Genel soru'**
  String get genelSoru;

  /// No description provided for @geri.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get geri;

  /// No description provided for @geriYklenecekSatnAlmBulunamad.
  ///
  /// In tr, this message translates to:
  /// **'Geri yüklenecek satın alım bulunamadı.'**
  String get geriYklenecekSatnAlmBulunamad;

  /// No description provided for @giriYap.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get giriYap;

  /// No description provided for @gizlilikPolitikas.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get gizlilikPolitikas;

  /// No description provided for @gizlilikPolitikas2.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik politikası'**
  String get gizlilikPolitikas2;

  /// No description provided for @google.
  ///
  /// In tr, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @grnm.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get grnm;

  /// No description provided for @growthManager.
  ///
  /// In tr, this message translates to:
  /// **'Growth Manager'**
  String get growthManager;

  /// No description provided for @grubaEkle.
  ///
  /// In tr, this message translates to:
  /// **'Gruba ekle'**
  String get grubaEkle;

  /// No description provided for @grubaEklenecekKaytlKartKalmad.
  ///
  /// In tr, this message translates to:
  /// **'Gruba eklenecek kayıtlı kart kalmadı'**
  String get grubaEklenecekKaytlKartKalmad;

  /// No description provided for @grubuSil.
  ///
  /// In tr, this message translates to:
  /// **'Grubu sil'**
  String get grubuSil;

  /// No description provided for @grupsuz.
  ///
  /// In tr, this message translates to:
  /// **'Grupsuz'**
  String get grupsuz;

  /// No description provided for @gvenliPaylam.
  ///
  /// In tr, this message translates to:
  /// **'Güvenli Paylaşım'**
  String get gvenliPaylam;

  /// No description provided for @gvenliinizIinHesabnzaTekrarGiri.
  ///
  /// In tr, this message translates to:
  /// **'Güvenliğiniz için lütfen tekrar giriş yapın.'**
  String get gvenliinizIinHesabnzaTekrarGiri;

  /// No description provided for @hakkmda.
  ///
  /// In tr, this message translates to:
  /// **'Hakkımda'**
  String get hakkmda;

  /// No description provided for @hakkimdaBilgisiYok.
  ///
  /// In tr, this message translates to:
  /// **'Hakkımda bilgisi yok'**
  String get hakkimdaBilgisiYok;

  /// No description provided for @hakkmdaHerZamanGsterilir.
  ///
  /// In tr, this message translates to:
  /// **'Hakkımda her zaman gösterilir.'**
  String get hakkmdaHerZamanGsterilir;

  /// No description provided for @hakknda.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get hakknda;

  /// No description provided for @hataBildirimi.
  ///
  /// In tr, this message translates to:
  /// **'Hata bildirimi'**
  String get hataBildirimi;

  /// No description provided for @henzEtkinlikGrubuYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz etkinlik grubu yok'**
  String get henzEtkinlikGrubuYok;

  /// No description provided for @henzEtkinlikGrubuYokEtkinlik.
  ///
  /// In tr, this message translates to:
  /// **'Henüz etkinlik grubu yok. Etkinlik grupları sekmesinden yeni grup oluşturabilirsiniz.'**
  String get henzEtkinlikGrubuYokEtkinlik;

  /// No description provided for @henzKartYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kart yok'**
  String get henzKartYok;

  /// No description provided for @henzKartnYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kartın yok'**
  String get henzKartnYok;

  /// No description provided for @henzKartnzYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kartınız yok'**
  String get henzKartnzYok;

  /// No description provided for @henzKartnzYokProfildenKart.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kartınız yok. Profilden kart oluşturduktan sonra görünüm ayarlarını yapabilirsiniz.'**
  String get henzKartnzYokProfildenKart;

  /// No description provided for @henzKaydedilmiKartYokKaydedilen.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kaydedilmiş kart yok. Kaydedilen Kartlar sekmesinden QR ile kart ekleyebilirsiniz.'**
  String get henzKaydedilmiKartYokKaydedilen;

  /// No description provided for @henzKaytlKartYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıtlı kart yok'**
  String get henzKaytlKartYok;

  /// No description provided for @hesabnzaGiriYapn.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınıza giriş yapın'**
  String get hesabnzaGiriYapn;

  /// No description provided for @authOrDivider.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get authOrDivider;

  /// No description provided for @authJoinCardenceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cardence\'a Katılın'**
  String get authJoinCardenceTitle;

  /// No description provided for @authNoAccountPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu? '**
  String get authNoAccountPrompt;

  /// No description provided for @authAlreadyHaveAccountPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabınız var mı? '**
  String get authAlreadyHaveAccountPrompt;

  /// No description provided for @linkedinIleDevamEt.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn ile devam et'**
  String get linkedinIleDevamEt;

  /// No description provided for @ad.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get ad;

  /// No description provided for @sifre.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get sifre;

  /// No description provided for @authPasswordMinHint.
  ///
  /// In tr, this message translates to:
  /// **'En az {minLength} karakter'**
  String authPasswordMinHint(int minLength);

  /// No description provided for @sifreEnAzKarakter.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az {minLength} karakter olmalıdır.'**
  String sifreEnAzKarakter(int minLength);

  /// No description provided for @sifrelerEslesmiyor.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor.'**
  String get sifrelerEslesmiyor;

  /// No description provided for @registerLegalPrefix.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt olarak '**
  String get registerLegalPrefix;

  /// No description provided for @registerLegalAnd.
  ///
  /// In tr, this message translates to:
  /// **' ve '**
  String get registerLegalAnd;

  /// No description provided for @registerLegalSuffix.
  ///
  /// In tr, this message translates to:
  /// **'\'nı kabul etmiş sayılırsınız.'**
  String get registerLegalSuffix;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cardence\'e Hoş Geldin !'**
  String get loginWelcomeTitle;

  /// No description provided for @loginWithPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon ile giriş yap'**
  String get loginWithPhone;

  /// No description provided for @loginOtpSentHint.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodu telefonunuza gönderildi.'**
  String get loginOtpSentHint;

  /// No description provided for @loginChangePhone.
  ///
  /// In tr, this message translates to:
  /// **'Numarayı değiştir'**
  String get loginChangePhone;

  /// No description provided for @loginResendOtp.
  ///
  /// In tr, this message translates to:
  /// **'Kodu tekrar gönder'**
  String get loginResendOtp;

  /// No description provided for @loginOtpRequired.
  ///
  /// In tr, this message translates to:
  /// **'6 haneli kodu girin'**
  String get loginOtpRequired;

  /// No description provided for @loginWithEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta ile giriş yap'**
  String get loginWithEmail;

  /// No description provided for @hesapVeGiri.
  ///
  /// In tr, this message translates to:
  /// **'Hesap ve giriş'**
  String get hesapVeGiri;

  /// No description provided for @hrManager.
  ///
  /// In tr, this message translates to:
  /// **'HR Manager'**
  String get hrManager;

  /// No description provided for @iOrtaklklarVeGvenlikBildirimleri.
  ///
  /// In tr, this message translates to:
  /// **'İş ortaklıkları ve güvenlik bildirimleri için gereklidir.'**
  String get iOrtaklklarVeGvenlikBildirimleri;

  /// No description provided for @ingilizce.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get ingilizce;

  /// No description provided for @ifremiUnuttum.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get ifremiUnuttum;

  /// No description provided for @ifreniziTekrarGirin.
  ///
  /// In tr, this message translates to:
  /// **'Şifrenizi tekrar girin'**
  String get ifreniziTekrarGirin;

  /// No description provided for @ifreyiGncelle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi güncelle'**
  String get ifreyiGncelle;

  /// No description provided for @ilAra.
  ///
  /// In tr, this message translates to:
  /// **'İl ara'**
  String get ilAra;

  /// No description provided for @ileAra.
  ///
  /// In tr, this message translates to:
  /// **'İlçe ara'**
  String get ileAra;

  /// No description provided for @ilemBaarsz.
  ///
  /// In tr, this message translates to:
  /// **'İşlem başarısız.'**
  String get ilemBaarsz;

  /// No description provided for @ilemTamamlanamadLtfenTekrarDeneyin.
  ///
  /// In tr, this message translates to:
  /// **'İşlem tamamlanamadı. Lütfen tekrar deneyin.'**
  String get ilemTamamlanamadLtfenTekrarDeneyin;

  /// No description provided for @iletiimIinEPostaAdresiniz.
  ///
  /// In tr, this message translates to:
  /// **'İletişim için e-posta adresiniz'**
  String get iletiimIinEPostaAdresiniz;

  /// No description provided for @iletiimProfilVeKiiselNot.
  ///
  /// In tr, this message translates to:
  /// **'İletişim, profil ve kişisel not bilgilerini ekleyin'**
  String get iletiimProfilVeKiiselNot;

  /// No description provided for @ilkKartnzOluturunIEtkinlik.
  ///
  /// In tr, this message translates to:
  /// **'İlk kartınızı oluşturun; iş, etkinlik veya kişisel kullanım için ayrı kartlar ekleyebilirsiniz.'**
  String get ilkKartnzOluturunIEtkinlik;

  /// No description provided for @instagram.
  ///
  /// In tr, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @iptal.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get iptal;

  /// No description provided for @irket.
  ///
  /// In tr, this message translates to:
  /// **'Şirket'**
  String get irket;

  /// No description provided for @irketAdnGiriniz.
  ///
  /// In tr, this message translates to:
  /// **'Şirket adını giriniz'**
  String get irketAdnGiriniz;

  /// No description provided for @irketZorunludur.
  ///
  /// In tr, this message translates to:
  /// **'Şirket zorunludur'**
  String get irketZorunludur;

  /// No description provided for @isimSirketCom.
  ///
  /// In tr, this message translates to:
  /// **'isim@sirket.com'**
  String get isimSirketCom;

  /// No description provided for @isimirketEPosta.
  ///
  /// In tr, this message translates to:
  /// **'İsim, şirket, e-posta…'**
  String get isimirketEPosta;

  /// No description provided for @savedCardsSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'İsim, şirket veya e-posta ile ara...'**
  String get savedCardsSearchHint;

  /// No description provided for @listeGorunumu.
  ///
  /// In tr, this message translates to:
  /// **'Liste Görünümü'**
  String get listeGorunumu;

  /// No description provided for @yeniKartEkle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kart Ekle'**
  String get yeniKartEkle;

  /// No description provided for @isimsizKart.
  ///
  /// In tr, this message translates to:
  /// **'İsimsiz kart'**
  String get isimsizKart;

  /// No description provided for @isteeBalEtkinliiListedeGrsel.
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlı — etkinliği listede görsel olarak ayırt edin.'**
  String get isteeBalEtkinliiListedeGrsel;

  /// No description provided for @istersenWebSiteniVeLinkedin.
  ///
  /// In tr, this message translates to:
  /// **'İstersen web siteni ve LinkedIn profilini ekle.'**
  String get istersenWebSiteniVeLinkedin;

  /// No description provided for @istersenizimdiEkleyinSonraDa.
  ///
  /// In tr, this message translates to:
  /// **'İsterseniz şimdi ekleyin, sonra da düzenleyebilirsiniz'**
  String get istersenizimdiEkleyinSonraDa;

  /// No description provided for @k.
  ///
  /// In tr, this message translates to:
  /// **'Çık'**
  String get k;

  /// No description provided for @kYap.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get kYap;

  /// No description provided for @kamera.
  ///
  /// In tr, this message translates to:
  /// **'Kamera'**
  String get kamera;

  /// No description provided for @kameraVeyaGaleridenEkleyin.
  ///
  /// In tr, this message translates to:
  /// **'Kamera veya galeriden ekleyin'**
  String get kameraVeyaGaleridenEkleyin;

  /// No description provided for @kamerayKullanarakBilgileriTara.
  ///
  /// In tr, this message translates to:
  /// **'Kamerayı kullanarak bilgileri tara'**
  String get kamerayKullanarakBilgileriTara;

  /// No description provided for @kapasiteyiArtr.
  ///
  /// In tr, this message translates to:
  /// **'Kapasiteyi artır'**
  String get kapasiteyiArtr;

  /// No description provided for @kapat.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get kapat;

  /// No description provided for @kart.
  ///
  /// In tr, this message translates to:
  /// **'Kart'**
  String get kart;

  /// No description provided for @kartAd.
  ///
  /// In tr, this message translates to:
  /// **'Kart adı'**
  String get kartAd;

  /// No description provided for @kartAdZorunludur.
  ///
  /// In tr, this message translates to:
  /// **'Kart adı zorunludur'**
  String get kartAdZorunludur;

  /// No description provided for @kartBilgileri.
  ///
  /// In tr, this message translates to:
  /// **'Kart bilgileri'**
  String get kartBilgileri;

  /// No description provided for @kartBilgisiAlnamad.
  ///
  /// In tr, this message translates to:
  /// **'Kart bilgisi alınamadı.'**
  String get kartBilgisiAlnamad;

  /// No description provided for @kartBilgisiYok.
  ///
  /// In tr, this message translates to:
  /// **'Kart bilgisi yok'**
  String get kartBilgisiYok;

  /// No description provided for @kartBilgisiYokDzenleIle.
  ///
  /// In tr, this message translates to:
  /// **'Kart bilgisi yok — düzenle ile ekleyin'**
  String get kartBilgisiYokDzenleIle;

  /// No description provided for @kartBulunamad.
  ///
  /// In tr, this message translates to:
  /// **'Kart bulunamadı.'**
  String get kartBulunamad;

  /// No description provided for @kartCzdanaEklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Kart cüzdana eklenemedi.'**
  String get kartCzdanaEklenemedi;

  /// No description provided for @addCardByIdSending.
  ///
  /// In tr, this message translates to:
  /// **'Kart cüzdana ekleniyor…'**
  String get addCardByIdSending;

  /// No description provided for @kartCzdandanSil.
  ///
  /// In tr, this message translates to:
  /// **'Kartı cüzdandan sil'**
  String get kartCzdandanSil;

  /// No description provided for @kartCzdannzaEklendi.
  ///
  /// In tr, this message translates to:
  /// **'Kart cüzdanınıza eklendi'**
  String get kartCzdannzaEklendi;

  /// No description provided for @kartEkle.
  ///
  /// In tr, this message translates to:
  /// **'Kart ekle'**
  String get kartEkle;

  /// No description provided for @kartEkle2.
  ///
  /// In tr, this message translates to:
  /// **'Kartı ekle'**
  String get kartEkle2;

  /// No description provided for @kartGncellenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Kart güncellenemedi.'**
  String get kartGncellenemedi;

  /// No description provided for @kartGrnm.
  ///
  /// In tr, this message translates to:
  /// **'Kart Görünümü'**
  String get kartGrnm;

  /// No description provided for @kartGrnm2.
  ///
  /// In tr, this message translates to:
  /// **'Kart görünümü'**
  String get kartGrnm2;

  /// No description provided for @kartGruptankarlamad.
  ///
  /// In tr, this message translates to:
  /// **'Kart gruptan çıkarılamadı.'**
  String get kartGruptankarlamad;

  /// No description provided for @kartId.
  ///
  /// In tr, this message translates to:
  /// **'KART ID'**
  String get kartId;

  /// No description provided for @kartId2.
  ///
  /// In tr, this message translates to:
  /// **'Kart ID'**
  String get kartId2;

  /// No description provided for @kartId3.
  ///
  /// In tr, this message translates to:
  /// **'Kart ID\\'**
  String get kartId3;

  /// No description provided for @kartIdCardid.
  ///
  /// In tr, this message translates to:
  /// **'Kart ID: \$cardId'**
  String get kartIdCardid;

  /// No description provided for @kartIdGirin.
  ///
  /// In tr, this message translates to:
  /// **'Kart ID girin'**
  String get kartIdGirin;

  /// No description provided for @kartIdIleEkle.
  ///
  /// In tr, this message translates to:
  /// **'Kart ID ile ekle'**
  String get kartIdIleEkle;

  /// No description provided for @kartIdKopyaland.
  ///
  /// In tr, this message translates to:
  /// **'Kart ID kopyalandı'**
  String get kartIdKopyaland;

  /// No description provided for @kartIdKopyalandId.
  ///
  /// In tr, this message translates to:
  /// **'Kart ID kopyalandı: \$id'**
  String get kartIdKopyalandId;

  /// No description provided for @clipboardCopySuccess.
  ///
  /// In tr, this message translates to:
  /// **'Başarıyla panoya kopyalandı'**
  String get clipboardCopySuccess;

  /// No description provided for @kartIdOluturulamadLtfenTekrar.
  ///
  /// In tr, this message translates to:
  /// **'Kart ID oluşturulamadı. Lütfen tekrar deneyin.'**
  String get kartIdOluturulamadLtfenTekrar;

  /// No description provided for @kartIdTam6Haneli.
  ///
  /// In tr, this message translates to:
  /// **'Kart ID tam 6 haneli sayı olmalıdır'**
  String get kartIdTam6Haneli;

  /// No description provided for @kartKaydedildi.
  ///
  /// In tr, this message translates to:
  /// **'Kart kaydedildi'**
  String get kartKaydedildi;

  /// No description provided for @kartKaydedilemedi.
  ///
  /// In tr, this message translates to:
  /// **'Kart kaydedilemedi.'**
  String get kartKaydedilemedi;

  /// No description provided for @kartKaydedilemediLtfenTekrarDeneyin.
  ///
  /// In tr, this message translates to:
  /// **'Kart kaydedilemedi. Lütfen tekrar deneyin.'**
  String get kartKaydedilemediLtfenTekrarDeneyin;

  /// No description provided for @kartKaydetmedennceSonKez.
  ///
  /// In tr, this message translates to:
  /// **'Kartı kaydetmeden önce son kez kontrol edin.'**
  String get kartKaydetmedennceSonKez;

  /// No description provided for @kartKaytSays.
  ///
  /// In tr, this message translates to:
  /// **'Kart kayıt sayısı'**
  String get kartKaytSays;

  /// No description provided for @kartKimliiEksik.
  ///
  /// In tr, this message translates to:
  /// **'Kart kimliği eksik.'**
  String get kartKimliiEksik;

  /// No description provided for @kartKimliiOluturulamadLtfenTekrar.
  ///
  /// In tr, this message translates to:
  /// **'Kart kimliği oluşturulamadı. Lütfen tekrar deneyin.'**
  String get kartKimliiOluturulamadLtfenTekrar;

  /// No description provided for @kartKotasDoldu.
  ///
  /// In tr, this message translates to:
  /// **'Kart kotası doldu'**
  String get kartKotasDoldu;

  /// No description provided for @kartPayla.
  ///
  /// In tr, this message translates to:
  /// **'Kartı paylaş'**
  String get kartPayla;

  /// No description provided for @kartPaylaDediinizdeBenzersizBir.
  ///
  /// In tr, this message translates to:
  /// **'Kartı paylaş dediğinizde benzersiz bir numara atanır.'**
  String get kartPaylaDediinizdeBenzersizBir;

  /// No description provided for @kartRengi.
  ///
  /// In tr, this message translates to:
  /// **'KART RENGİ'**
  String get kartRengi;

  /// No description provided for @kartRengi2.
  ///
  /// In tr, this message translates to:
  /// **'Kart rengi'**
  String get kartRengi2;

  /// No description provided for @kartRenkleri.
  ///
  /// In tr, this message translates to:
  /// **'Kart renkleri'**
  String get kartRenkleri;

  /// No description provided for @kartSahibiHakkndaKsaBilgi.
  ///
  /// In tr, this message translates to:
  /// **'Kart sahibi hakkında kısa bilgi...'**
  String get kartSahibiHakkndaKsaBilgi;

  /// No description provided for @kartSil.
  ///
  /// In tr, this message translates to:
  /// **'Kartı sil'**
  String get kartSil;

  /// No description provided for @kartSilinemedi.
  ///
  /// In tr, this message translates to:
  /// **'Kart silinemedi.'**
  String get kartSilinemedi;

  /// No description provided for @kartSilinemediLtfenTekrarDeneyin.
  ///
  /// In tr, this message translates to:
  /// **'Kart silinemedi. Lütfen tekrar deneyin.'**
  String get kartSilinemediLtfenTekrarDeneyin;

  /// No description provided for @kartVeMetinRenginiDzenleyin.
  ///
  /// In tr, this message translates to:
  /// **'Kart ve metin rengini düzenleyin.'**
  String get kartVeMetinRenginiDzenleyin;

  /// No description provided for @kartYzVeAlanDzeni.
  ///
  /// In tr, this message translates to:
  /// **'Kart yüzü ve alan düzeni'**
  String get kartYzVeAlanDzeni;

  /// No description provided for @kartYzndeGrnecekIletiimVe.
  ///
  /// In tr, this message translates to:
  /// **'Kart yüzünde görünecek iletişim ve profil alanları.'**
  String get kartYzndeGrnecekIletiimVe;

  /// No description provided for @kartZatenKaytl.
  ///
  /// In tr, this message translates to:
  /// **'Kart zaten kayıtlı'**
  String get kartZatenKaytl;

  /// No description provided for @cannotAddOwnCardToWallet.
  ///
  /// In tr, this message translates to:
  /// **'Kendi kartınızı kaydedilen kartlara ekleyemezsiniz.'**
  String get cannotAddOwnCardToWallet;

  /// No description provided for @kartaEklemekIstediinizAlanSein.
  ///
  /// In tr, this message translates to:
  /// **'Karta eklemek istediğiniz alanı seçin'**
  String get kartaEklemekIstediinizAlanSein;

  /// No description provided for @kartevirmekIinSaAlttaki.
  ///
  /// In tr, this message translates to:
  /// **'Kartı çevirmek için sağ alttaki ikona dokunun'**
  String get kartevirmekIinSaAlttaki;

  /// No description provided for @kartlar.
  ///
  /// In tr, this message translates to:
  /// **'Kartlar'**
  String get kartlar;

  /// No description provided for @kartlarAlnamad.
  ///
  /// In tr, this message translates to:
  /// **'Kartlar alınamadı.'**
  String get kartlarAlnamad;

  /// No description provided for @kartlarGrubaEklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Kartlar gruba eklenemedi.'**
  String get kartlarGrubaEklenemedi;

  /// No description provided for @kartlarm.
  ///
  /// In tr, this message translates to:
  /// **'Kartlarım'**
  String get kartlarm;

  /// No description provided for @kartndaGrnsn.
  ///
  /// In tr, this message translates to:
  /// **'Kartında Görünsün'**
  String get kartndaGrnsn;

  /// No description provided for @kartnizleme.
  ///
  /// In tr, this message translates to:
  /// **'Kart önizleme'**
  String get kartnizleme;

  /// No description provided for @kartnzOluturunPaylanVeAnz.
  ///
  /// In tr, this message translates to:
  /// **'Kartınızı oluşturun, paylaşın ve ağınızı genişletin.'**
  String get kartnzOluturunPaylanVeAnz;

  /// No description provided for @kartnzPaylan.
  ///
  /// In tr, this message translates to:
  /// **'Kartınızı paylaşın'**
  String get kartnzPaylan;

  /// No description provided for @kartnzdaGrnecekAdnzGirin.
  ///
  /// In tr, this message translates to:
  /// **'Kartınızda görünecek adınızı girin'**
  String get kartnzdaGrnecekAdnzGirin;

  /// No description provided for @kartnznDijitalKimliinizelletirin.
  ///
  /// In tr, this message translates to:
  /// **'Kartınızın dijital kimliğini özelleştirin.'**
  String get kartnznDijitalKimliinizelletirin;

  /// No description provided for @kartnznnYzndeGrnecekBilgiler.
  ///
  /// In tr, this message translates to:
  /// **'Kartınızın ön yüzünde görünecek bilgiler'**
  String get kartnznnYzndeGrnecekBilgiler;

  /// No description provided for @kartvizitBilgileriniManuelYazn.
  ///
  /// In tr, this message translates to:
  /// **'Kartvizit bilgilerini manuel yazın'**
  String get kartvizitBilgileriniManuelYazn;

  /// No description provided for @kartvizitFotorafla.
  ///
  /// In tr, this message translates to:
  /// **'Kartvizit fotoğrafla'**
  String get kartvizitFotorafla;

  /// No description provided for @kartvizitinnYzndeGrnecekBilgiler.
  ///
  /// In tr, this message translates to:
  /// **'Kartvizitin ön yüzünde görünecek bilgiler'**
  String get kartvizitinnYzndeGrnecekBilgiler;

  /// No description provided for @kartvizitteGrnenAdGirin.
  ///
  /// In tr, this message translates to:
  /// **'Kartvizitte görünen adı girin'**
  String get kartvizitteGrnenAdGirin;

  /// No description provided for @kartzelletir.
  ///
  /// In tr, this message translates to:
  /// **'Kartı özelleştir'**
  String get kartzelletir;

  /// No description provided for @katldEtkinlikler.
  ///
  /// In tr, this message translates to:
  /// **'Katıldığı etkinlikler'**
  String get katldEtkinlikler;

  /// No description provided for @kaydedildiTarihBilinmiyor.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi: tarih bilinmiyor'**
  String get kaydedildiTarihBilinmiyor;

  /// No description provided for @kaydedilenKartlar.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilen Kartlar'**
  String get kaydedilenKartlar;

  /// No description provided for @kaydedilenKartlardanSe.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilen kartlardan seç'**
  String get kaydedilenKartlardanSe;

  /// No description provided for @kaydedilenKartlarnzdanSeerekBuGruba.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilen kartlarınızdan seçerek bu gruba kart ekleyebilirsiniz.'**
  String get kaydedilenKartlarnzdanSeerekBuGruba;

  /// No description provided for @kaydedilmemiDeiiklikler.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilmemiş değişiklikler'**
  String get kaydedilmemiDeiiklikler;

  /// No description provided for @kaydet.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get kaydet;

  /// No description provided for @kaytOl.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get kaytOl;

  /// No description provided for @kaytlEPostaAdresinizeSfrlama.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı e-posta adresinize şifre sıfırlama bağlantısı gönderilir.'**
  String get kaytlEPostaAdresinizeSfrlama;

  /// No description provided for @sifreSifirlamaBaglantisiGonder.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama bağlantısı gönder'**
  String get sifreSifirlamaBaglantisiGonder;

  /// No description provided for @sifreSifirlamaBaglantisiGonderildi.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama bağlantısı gönderildi'**
  String get sifreSifirlamaBaglantisiGonderildi;

  /// No description provided for @ePostaKutunuzuKontrolEdin.
  ///
  /// In tr, this message translates to:
  /// **'E-posta kutunuzu kontrol edin ve gelen bağlantıya tıklayarak yeni şifrenizi belirleyin.'**
  String get ePostaKutunuzuKontrolEdin;

  /// No description provided for @sifreSifirlamaLinkAcildi.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifrenizi aşağıdan belirleyebilirsiniz.'**
  String get sifreSifirlamaLinkAcildi;

  /// No description provided for @sifreSifirlamaBaglantisiGecersiz.
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırlama bağlantısı geçersiz veya süresi dolmuş.'**
  String get sifreSifirlamaBaglantisiGecersiz;

  /// No description provided for @kaytlKartLimitinizDolduPremium.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı kart limitiniz doldu. Premium ile sınırsız kart saklayabilir ve manuel / fotoğrafla eklemeye devam edebilirsiniz.'**
  String get kaytlKartLimitinizDolduPremium;

  /// No description provided for @kaytlKartlar.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı kartlar'**
  String get kaytlKartlar;

  /// No description provided for @kaytlKartlarAlnamad.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı kartlar alınamadı.'**
  String get kaytlKartlarAlnamad;

  /// No description provided for @kendiKartlarm.
  ///
  /// In tr, this message translates to:
  /// **'Kendi kartlarım'**
  String get kendiKartlarm;

  /// No description provided for @kendinizdenKsacaBahsedin.
  ///
  /// In tr, this message translates to:
  /// **'Kendinizden kısaca bahsedin...'**
  String get kendinizdenKsacaBahsedin;

  /// No description provided for @kiiNotu.
  ///
  /// In tr, this message translates to:
  /// **'Kişi notu'**
  String get kiiNotu;

  /// No description provided for @kisiNotu.
  ///
  /// In tr, this message translates to:
  /// **'Kisi notu'**
  String get kisiNotu;

  /// No description provided for @kodGnder.
  ///
  /// In tr, this message translates to:
  /// **'Kod gönder'**
  String get kodGnder;

  /// No description provided for @kodGnderildi.
  ///
  /// In tr, this message translates to:
  /// **'Kod gönderildi'**
  String get kodGnderildi;

  /// No description provided for @konu.
  ///
  /// In tr, this message translates to:
  /// **'Konu'**
  String get konu;

  /// No description provided for @konum.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get konum;

  /// No description provided for @kopyala.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get kopyala;

  /// No description provided for @kotaDoldu.
  ///
  /// In tr, this message translates to:
  /// **'Kota doldu'**
  String get kotaDoldu;

  /// No description provided for @koyu.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get koyu;

  /// No description provided for @kullanmKoullar.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get kullanmKoullar;

  /// No description provided for @learningDesigner.
  ///
  /// In tr, this message translates to:
  /// **'Learning Designer'**
  String get learningDesigner;

  /// No description provided for @linkedin.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn'**
  String get linkedin;

  /// No description provided for @linkedinAlamad.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn açılamadı'**
  String get linkedinAlamad;

  /// No description provided for @linkedinComInKullanici.
  ///
  /// In tr, this message translates to:
  /// **'linkedin.com/in/kullanici'**
  String get linkedinComInKullanici;

  /// No description provided for @linkedinComInUsername.
  ///
  /// In tr, this message translates to:
  /// **'linkedin.com/in/username'**
  String get linkedinComInUsername;

  /// No description provided for @linkedinIleGiri.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn ile giriş'**
  String get linkedinIleGiri;

  /// No description provided for @linkedinIleGiriBaarsz.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn ile giriş başarısız.'**
  String get linkedinIleGiriBaarsz;

  /// No description provided for @linkedinProfilLinki.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn profil linki'**
  String get linkedinProfilLinki;

  /// No description provided for @liste.
  ///
  /// In tr, this message translates to:
  /// **'Liste'**
  String get liste;

  /// No description provided for @listeVeKartGrnmneBirlikte.
  ///
  /// In tr, this message translates to:
  /// **'Liste ve kart görünümüne birlikte uygulanır.'**
  String get listeVeKartGrnmneBirlikte;

  /// No description provided for @lke.
  ///
  /// In tr, this message translates to:
  /// **'Ülke'**
  String get lke;

  /// No description provided for @lkeAra.
  ///
  /// In tr, this message translates to:
  /// **'Ülke ara'**
  String get lkeAra;

  /// No description provided for @ltfenZorunluAlanlarDoldurun.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen zorunlu alanları doldurun.'**
  String get ltfenZorunluAlanlarDoldurun;

  /// No description provided for @maazaSayfasAlamadLtfenTekrar.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza sayfası açılamadı. Lütfen tekrar deneyin.'**
  String get maazaSayfasAlamadLtfenTekrar;

  /// No description provided for @manuelFotorafEkleme.
  ///
  /// In tr, this message translates to:
  /// **'Manuel & fotoğraf ekleme'**
  String get manuelFotorafEkleme;

  /// No description provided for @marketingSpecialist.
  ///
  /// In tr, this message translates to:
  /// **'Marketing Specialist'**
  String get marketingSpecialist;

  /// No description provided for @mesajnz.
  ///
  /// In tr, this message translates to:
  /// **'Mesajınız'**
  String get mesajnz;

  /// No description provided for @metinOkunamadBilgileriManuelDzenleyerek.
  ///
  /// In tr, this message translates to:
  /// **'Metin okunamadı. Bilgileri manuel düzenleyerek kaydedebilirsiniz.'**
  String get metinOkunamadBilgileriManuelDzenleyerek;

  /// No description provided for @metinRengi.
  ///
  /// In tr, this message translates to:
  /// **'METİN RENGİ'**
  String get metinRengi;

  /// No description provided for @metinRengi2.
  ///
  /// In tr, this message translates to:
  /// **'Metin rengi'**
  String get metinRengi2;

  /// No description provided for @rastgeleRenk.
  ///
  /// In tr, this message translates to:
  /// **'Rastgele renk'**
  String get rastgeleRenk;

  /// No description provided for @mobileEngineer.
  ///
  /// In tr, this message translates to:
  /// **'Mobile Engineer'**
  String get mobileEngineer;

  /// No description provided for @motionDesigner.
  ///
  /// In tr, this message translates to:
  /// **'Motion Designer'**
  String get motionDesigner;

  /// No description provided for @msg1HizmetinKapsam.
  ///
  /// In tr, this message translates to:
  /// **'1. Hizmetin kapsamı'**
  String get msg1HizmetinKapsam;

  /// No description provided for @msg1KartKald.
  ///
  /// In tr, this message translates to:
  /// **'1 kart kaldı'**
  String get msg1KartKald;

  /// No description provided for @msg1ToplananVeriler.
  ///
  /// In tr, this message translates to:
  /// **'1. Toplanan veriler'**
  String get msg1ToplananVeriler;

  /// No description provided for @msg1cretsizDenemeSonrasndaPremium.
  ///
  /// In tr, this message translates to:
  /// **'1 ücretsiz deneme · sonrasında Premium gerekir'**
  String get msg1cretsizDenemeSonrasndaPremium;

  /// No description provided for @msg2HesapOluturma.
  ///
  /// In tr, this message translates to:
  /// **'2. Hesap oluşturma'**
  String get msg2HesapOluturma;

  /// No description provided for @msg2VerilerinKullanm.
  ///
  /// In tr, this message translates to:
  /// **'2. Verilerin kullanımı'**
  String get msg2VerilerinKullanm;

  /// No description provided for @msg3KabulEdilebilirKullanm.
  ///
  /// In tr, this message translates to:
  /// **'3. Kabul edilebilir kullanım'**
  String get msg3KabulEdilebilirKullanm;

  /// No description provided for @msg3VeriPaylam.
  ///
  /// In tr, this message translates to:
  /// **'3. Veri paylaşımı'**
  String get msg3VeriPaylam;

  /// No description provided for @msg4FikriMlkiyet.
  ///
  /// In tr, this message translates to:
  /// **'4. Fikri mülkiyet'**
  String get msg4FikriMlkiyet;

  /// No description provided for @msg4SaklamaSresi.
  ///
  /// In tr, this message translates to:
  /// **'4. Saklama süresi'**
  String get msg4SaklamaSresi;

  /// No description provided for @msg5Haklarnz.
  ///
  /// In tr, this message translates to:
  /// **'5. Haklarınız'**
  String get msg5Haklarnz;

  /// No description provided for @msg5HizmetDeiiklikleri.
  ///
  /// In tr, this message translates to:
  /// **'5. Hizmet değişiklikleri'**
  String get msg5HizmetDeiiklikleri;

  /// No description provided for @msg5xxXxxXxXx.
  ///
  /// In tr, this message translates to:
  /// **'5XX XXX XX XX'**
  String get msg5xxXxxXxXx;

  /// No description provided for @msg5xxXxxXxXx2.
  ///
  /// In tr, this message translates to:
  /// **'5xx xxx xx xx'**
  String get msg5xxXxxXxXx2;

  /// No description provided for @msg6Gvenlik.
  ///
  /// In tr, this message translates to:
  /// **'6. Güvenlik'**
  String get msg6Gvenlik;

  /// No description provided for @msg6HaneliKod.
  ///
  /// In tr, this message translates to:
  /// **'6 haneli kod'**
  String get msg6HaneliKod;

  /// No description provided for @msg6HanelizelKimlikIle.
  ///
  /// In tr, this message translates to:
  /// **'6 haneli özel kimlik ile ekle'**
  String get msg6HanelizelKimlikIle;

  /// No description provided for @msg6SorumlulukSnr.
  ///
  /// In tr, this message translates to:
  /// **'6. Sorumluluk sınırı'**
  String get msg6SorumlulukSnr;

  /// No description provided for @msg7PolitikaGncellemeleri.
  ///
  /// In tr, this message translates to:
  /// **'7. Politika güncellemeleri'**
  String get msg7PolitikaGncellemeleri;

  /// No description provided for @msg7letiim.
  ///
  /// In tr, this message translates to:
  /// **'7. İletişim'**
  String get msg7letiim;

  /// No description provided for @nYz.
  ///
  /// In tr, this message translates to:
  /// **'Ön yüz'**
  String get nYz;

  /// No description provided for @nYzIletiim.
  ///
  /// In tr, this message translates to:
  /// **'Ön yüz — iletişim'**
  String get nYzIletiim;

  /// No description provided for @nYzdeGster.
  ///
  /// In tr, this message translates to:
  /// **'Ön yüzde göster'**
  String get nYzdeGster;

  /// No description provided for @nYzdeIletiimBilgileriniEn.
  ///
  /// In tr, this message translates to:
  /// **'Ön yüzde iletişim bilgilerini (en fazla 3), arka yüzde isteğe bağlı yetenekleri seç.'**
  String get nYzdeIletiimBilgileriniEn;

  /// No description provided for @niversiteVeyaLiseAd.
  ///
  /// In tr, this message translates to:
  /// **'Üniversite veya lise adı'**
  String get niversiteVeyaLiseAd;

  /// No description provided for @nizleme.
  ///
  /// In tr, this message translates to:
  /// **'Önizleme'**
  String get nizleme;

  /// No description provided for @not.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get not;

  /// No description provided for @notEkle.
  ///
  /// In tr, this message translates to:
  /// **'Not ekle'**
  String get notEkle;

  /// No description provided for @notKaydedildi.
  ///
  /// In tr, this message translates to:
  /// **'Not kaydedildi'**
  String get notKaydedildi;

  /// No description provided for @notlar.
  ///
  /// In tr, this message translates to:
  /// **'Notlar'**
  String get notlar;

  /// No description provided for @savedCardContactInfoTitle.
  ///
  /// In tr, this message translates to:
  /// **'İletişim Bilgileri'**
  String get savedCardContactInfoTitle;

  /// No description provided for @savedCardEducationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eğitim'**
  String get savedCardEducationTitle;

  /// No description provided for @savedCardPrivateNotesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Özel Notlar'**
  String get savedCardPrivateNotesTitle;

  /// No description provided for @notunuzuBurayaYazn.
  ///
  /// In tr, this message translates to:
  /// **'Notunuzu buraya yazın…'**
  String get notunuzuBurayaYazn;

  /// No description provided for @okul.
  ///
  /// In tr, this message translates to:
  /// **'Okul'**
  String get okul;

  /// No description provided for @onboarding.
  ///
  /// In tr, this message translates to:
  /// **'Onboarding\\'**
  String get onboarding;

  /// No description provided for @operationsManager.
  ///
  /// In tr, this message translates to:
  /// **'Operations Manager'**
  String get operationsManager;

  /// No description provided for @opsiyonel.
  ///
  /// In tr, this message translates to:
  /// **'Opsiyonel'**
  String get opsiyonel;

  /// No description provided for @ornekEmailCom.
  ///
  /// In tr, this message translates to:
  /// **'ornek@email.com'**
  String get ornekEmailCom;

  /// No description provided for @ornekMailCom.
  ///
  /// In tr, this message translates to:
  /// **'ornek@mail.com'**
  String get ornekMailCom;

  /// No description provided for @otomatik.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik'**
  String get otomatik;

  /// No description provided for @otomatikArkaPlanaGreOkunabilir.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik: arka plana göre okunabilir renk.'**
  String get otomatikArkaPlanaGreOkunabilir;

  /// No description provided for @oturumBilgisiAlnamad.
  ///
  /// In tr, this message translates to:
  /// **'Oturum bilgisi alınamadı.'**
  String get oturumBilgisiAlnamad;

  /// No description provided for @oturumBulunamad.
  ///
  /// In tr, this message translates to:
  /// **'Oturum bulunamadı.'**
  String get oturumBulunamad;

  /// No description provided for @oturumBulunamadLtfenTekrarGiri.
  ///
  /// In tr, this message translates to:
  /// **'Oturum bulunamadı. Lütfen tekrar giriş yapın.'**
  String get oturumBulunamadLtfenTekrarGiri;

  /// No description provided for @oturumSonaErdi.
  ///
  /// In tr, this message translates to:
  /// **'Oturum sona erdi'**
  String get oturumSonaErdi;

  /// No description provided for @oturumunuzKapatlacakVeGiriEkranna.
  ///
  /// In tr, this message translates to:
  /// **'Oturumunuz kapatılacak ve giriş ekranına yönlendirileceksiniz. Kayıtlı kartlarınız bir sonraki girişinizde yeniden yüklenecektir.'**
  String get oturumunuzKapatlacakVeGiriEkranna;

  /// No description provided for @paylalanKartKimliiniGirinBilgiler.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılan kart kimliğini girin. Bilgiler sunucudaki güncel kartvizitten alınır.'**
  String get paylalanKartKimliiniGirinBilgiler;

  /// No description provided for @pozisyon.
  ///
  /// In tr, this message translates to:
  /// **'Pozisyon'**
  String get pozisyon;

  /// No description provided for @pozisyonZorunludur.
  ///
  /// In tr, this message translates to:
  /// **'Pozisyon zorunludur'**
  String get pozisyonZorunludur;

  /// No description provided for @pozisyonuGiriniz.
  ///
  /// In tr, this message translates to:
  /// **'Pozisyonu giriniz'**
  String get pozisyonuGiriniz;

  /// No description provided for @pozisyonunuzuGiriniz.
  ///
  /// In tr, this message translates to:
  /// **'Pozisyonunuzu giriniz'**
  String get pozisyonunuzuGiriniz;

  /// No description provided for @premiumCzdan.
  ///
  /// In tr, this message translates to:
  /// **'Premium cüzdan'**
  String get premiumCzdan;

  /// No description provided for @premiumCzdanEtkinletirilemedi.
  ///
  /// In tr, this message translates to:
  /// **'Premium cüzdan etkinleştirilemedi.'**
  String get premiumCzdanEtkinletirilemedi;

  /// No description provided for @productDesigner.
  ///
  /// In tr, this message translates to:
  /// **'Product Designer'**
  String get productDesigner;

  /// No description provided for @productManager.
  ///
  /// In tr, this message translates to:
  /// **'Product Manager'**
  String get productManager;

  /// No description provided for @profesyonelKimliiniziYnetmekIinYeni.
  ///
  /// In tr, this message translates to:
  /// **'Profesyonel kimliğinizi yönetmek için yeni bir hesap oluşturun.'**
  String get profesyonelKimliiniziYnetmekIinYeni;

  /// No description provided for @profilBilgileriniziDoldurupIlkKartnz.
  ///
  /// In tr, this message translates to:
  /// **'Profil bilgilerinizi doldurup ilk kartınızı oluşturun veya aşağıdan yeni kart ekleyin.'**
  String get profilBilgileriniziDoldurupIlkKartnz;

  /// No description provided for @profilBilgisiAlnamad.
  ///
  /// In tr, this message translates to:
  /// **'Profil bilgisi alınamadı.'**
  String get profilBilgisiAlnamad;

  /// No description provided for @profilFotorafIsteeBal.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı (isteğe bağlı)'**
  String get profilFotorafIsteeBal;

  /// No description provided for @profilFotorafKartlarnzaDaUyguland.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı kartlarınıza da uygulandı.'**
  String get profilFotorafKartlarnzaDaUyguland;

  /// No description provided for @profilFotorafYklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı yüklenemedi.'**
  String get profilFotorafYklenemedi;

  /// No description provided for @profilFotorafnzKartnzdaGrnrsterseniz.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafınız kartınızda görünür. İsterseniz atlayabilirsiniz.'**
  String get profilFotorafnzKartnzdaGrnrsterseniz;

  /// No description provided for @profilIstatistikleriAlnamad.
  ///
  /// In tr, this message translates to:
  /// **'Profil istatistikleri alınamadı.'**
  String get profilIstatistikleriAlnamad;

  /// No description provided for @qrIlePayla.
  ///
  /// In tr, this message translates to:
  /// **'QR ile paylaş'**
  String get qrIlePayla;

  /// No description provided for @renkleriDzenle.
  ///
  /// In tr, this message translates to:
  /// **'Renkleri düzenle'**
  String get renkleriDzenle;

  /// No description provided for @rnKartmKonferans2025.
  ///
  /// In tr, this message translates to:
  /// **'Örn. İş kartım, Konferans 2025'**
  String get rnKartmKonferans2025;

  /// No description provided for @rnMehmet.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Mehmet'**
  String get rnMehmet;

  /// No description provided for @rnWebSummit2026.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Web Summit 2026'**
  String get rnWebSummit2026;

  /// No description provided for @rnYlmaz.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Yılmaz'**
  String get rnYlmaz;

  /// No description provided for @rnekKartlarGsteriliyorlkKartnz.
  ///
  /// In tr, this message translates to:
  /// **'Örnek kartlar gösteriliyor. İlk kartınızı eklediğinizde gerçek cüzdanınız başlar.'**
  String get rnekKartlarGsteriliyorlkKartnz;

  /// No description provided for @rnstanbulKongreMerkezi.
  ///
  /// In tr, this message translates to:
  /// **'Örn. İstanbul Kongre Merkezi'**
  String get rnstanbulKongreMerkezi;

  /// No description provided for @saAlttakiEkleIleQr.
  ///
  /// In tr, this message translates to:
  /// **'Sağ alttaki Ekle ile QR okutun veya kart ID girin'**
  String get saAlttakiEkleIleQr;

  /// No description provided for @saAlttakiIleYeniEtkinlik.
  ///
  /// In tr, this message translates to:
  /// **'Sağ alttaki + ile yeni etkinlik grubu oluşturabilirsiniz.'**
  String get saAlttakiIleYeniEtkinlik;

  /// No description provided for @sadeceSaysalKarakterlerKabulEdilir.
  ///
  /// In tr, this message translates to:
  /// **'Sadece sayısal karakterler kabul edilir.'**
  String get sadeceSaysalKarakterlerKabulEdilir;

  /// No description provided for @sadeceSizinGrdnzEtiketKart.
  ///
  /// In tr, this message translates to:
  /// **'Sadece sizin gördüğünüz etiket; kart yüzündeki isim “Ad Soyad” alanıdır.'**
  String get sadeceSizinGrdnzEtiketKart;

  /// No description provided for @salesLead.
  ///
  /// In tr, this message translates to:
  /// **'Sales Lead'**
  String get salesLead;

  /// No description provided for @satnAlmlarGeriYkle.
  ///
  /// In tr, this message translates to:
  /// **'Satın alımları geri yükle'**
  String get satnAlmlarGeriYkle;

  /// No description provided for @securityArchitect.
  ///
  /// In tr, this message translates to:
  /// **'Security Architect'**
  String get securityArchitect;

  /// No description provided for @sfrla.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get sfrla;

  /// No description provided for @sfrlamaKoduGnderildi.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama kodu gönderildi.'**
  String get sfrlamaKoduGnderildi;

  /// No description provided for @sil.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get sil;

  /// No description provided for @sistem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get sistem;

  /// No description provided for @snrsz.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız'**
  String get snrsz;

  /// No description provided for @snrszKartSaklama.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız kart saklama'**
  String get snrszKartSaklama;

  /// No description provided for @son30Gn.
  ///
  /// In tr, this message translates to:
  /// **'Son 30 gün'**
  String get son30Gn;

  /// No description provided for @son7Gn.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 gün'**
  String get son7Gn;

  /// No description provided for @sonEtkileimler.
  ///
  /// In tr, this message translates to:
  /// **'Son etkileşimler'**
  String get sonEtkileimler;

  /// No description provided for @sonuBulunamad.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get sonuBulunamad;

  /// No description provided for @sorularnzIinBizeUlan.
  ///
  /// In tr, this message translates to:
  /// **'Sorularınız için bize ulaşın'**
  String get sorularnzIinBizeUlan;

  /// No description provided for @sorununuzuVeyaTalebiniziKsacaAklayn.
  ///
  /// In tr, this message translates to:
  /// **'Sorununuzu veya talebinizi kısaca açıklayın…'**
  String get sorununuzuVeyaTalebiniziKsacaAklayn;

  /// No description provided for @soyad.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get soyad;

  /// No description provided for @soyadYalnzcaHarfIermeliEn.
  ///
  /// In tr, this message translates to:
  /// **'Soyad yalnızca harf içermeli (en az 2 karakter)'**
  String get soyadYalnzcaHarfIermeliEn;

  /// No description provided for @soyadZorunludur.
  ///
  /// In tr, this message translates to:
  /// **'Soyad zorunludur'**
  String get soyadZorunludur;

  /// No description provided for @sralama.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama'**
  String get sralama;

  /// No description provided for @srm.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get srm;

  /// No description provided for @sunucuYantOkunamad.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu yanıtı okunamadı.'**
  String get sunucuYantOkunamad;

  /// No description provided for @supplyChainLead.
  ///
  /// In tr, this message translates to:
  /// **'Supply Chain Lead'**
  String get supplyChainLead;

  /// No description provided for @talebiGnder.
  ///
  /// In tr, this message translates to:
  /// **'Talebi gönder'**
  String get talebiGnder;

  /// No description provided for @tamam.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get tamam;

  /// No description provided for @tarih.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get tarih;

  /// No description provided for @tarihSein.
  ///
  /// In tr, this message translates to:
  /// **'Tarih seçin'**
  String get tarihSein;

  /// No description provided for @turkce.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkce;

  /// No description provided for @tasarm.
  ///
  /// In tr, this message translates to:
  /// **'Tasarım'**
  String get tasarm;

  /// No description provided for @telefon.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get telefon;

  /// No description provided for @telefonNumarasEnFazla20.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numarası en fazla 20 karakter olabilir.'**
  String get telefonNumarasEnFazla20;

  /// No description provided for @telefonNumarasEnFazlaMaxphonelength.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numarası en fazla \$maxPhoneLength karakter olabilir.'**
  String get telefonNumarasEnFazlaMaxphonelength;

  /// No description provided for @temizle.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get temizle;

  /// No description provided for @tm.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get tm;

  /// No description provided for @tmEtkinlikler.
  ///
  /// In tr, this message translates to:
  /// **'Tüm etkinlikler'**
  String get tmEtkinlikler;

  /// No description provided for @tmTarihler.
  ///
  /// In tr, this message translates to:
  /// **'Tüm tarihler'**
  String get tmTarihler;

  /// No description provided for @toplantProjeVeyaHatrlatmaNotu.
  ///
  /// In tr, this message translates to:
  /// **'Toplantı, proje veya hatırlatma notu ekleyin'**
  String get toplantProjeVeyaHatrlatmaNotu;

  /// No description provided for @uAnrnekKartlarGryorsunuz.
  ///
  /// In tr, this message translates to:
  /// **'Şu an örnek kartlar görüyorsunuz. İlk kartınızı eklediğinizde gerçek kotanız burada görünür.'**
  String get uAnrnekKartlarGryorsunuz;

  /// No description provided for @uxResearcher.
  ///
  /// In tr, this message translates to:
  /// **'UX Researcher'**
  String get uxResearcher;

  /// No description provided for @uygula.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get uygula;

  /// No description provided for @uygulamaDiliniSein.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama dilini seçin'**
  String get uygulamaDiliniSein;

  /// No description provided for @uygulamaDili.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Dili'**
  String get uygulamaDili;

  /// No description provided for @uygulamaTemasnSein.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama temasını seçin'**
  String get uygulamaTemasnSein;

  /// No description provided for @temaModu.
  ///
  /// In tr, this message translates to:
  /// **'Tema Modu'**
  String get temaModu;

  /// No description provided for @uygulamaRengi.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama rengi'**
  String get uygulamaRengi;

  /// No description provided for @uygulamaRengiPaletteHint.
  ///
  /// In tr, this message translates to:
  /// **'Dokununca renk seçici açılır; istediğiniz rengi seçebilirsiniz'**
  String get uygulamaRengiPaletteHint;

  /// No description provided for @webSitesi.
  ///
  /// In tr, this message translates to:
  /// **'Web sitesi'**
  String get webSitesi;

  /// No description provided for @webSitesiHttps.
  ///
  /// In tr, this message translates to:
  /// **'Web sitesi (https://...)'**
  String get webSitesiHttps;

  /// No description provided for @webSosyal.
  ///
  /// In tr, this message translates to:
  /// **'Web & Sosyal'**
  String get webSosyal;

  /// No description provided for @wwwExampleCom.
  ///
  /// In tr, this message translates to:
  /// **'www.example.com'**
  String get wwwExampleCom;

  /// No description provided for @wwwSirketCom.
  ///
  /// In tr, this message translates to:
  /// **'www.sirket.com'**
  String get wwwSirketCom;

  /// No description provided for @xTwitter.
  ///
  /// In tr, this message translates to:
  /// **'X (Twitter)'**
  String get xTwitter;

  /// No description provided for @yaptnzDeiikliklerKaydedilmedikmakIstediinize.
  ///
  /// In tr, this message translates to:
  /// **'Yaptığınız değişiklikler kaydedilmedi. Çıkmak istediğinize emin misiniz?'**
  String get yaptnzDeiikliklerKaydedilmedikmakIstediinize;

  /// No description provided for @yeniEtkinlikGrubu.
  ///
  /// In tr, this message translates to:
  /// **'Yeni etkinlik grubu'**
  String get yeniEtkinlikGrubu;

  /// No description provided for @etkinlikOlutur.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik oluştur'**
  String get etkinlikOlutur;

  /// No description provided for @yeniKart.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kart'**
  String get yeniKart;

  /// No description provided for @yeniKartOlutur.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kart oluştur'**
  String get yeniKartOlutur;

  /// No description provided for @profileActiveCardStatus.
  ///
  /// In tr, this message translates to:
  /// **'AKTİF KART: {current} / {total}'**
  String profileActiveCardStatus(int current, int total);

  /// No description provided for @agGrafigi.
  ///
  /// In tr, this message translates to:
  /// **'Ağ Grafiği'**
  String get agGrafigi;

  /// No description provided for @profileCardsSavedByOthersInfo.
  ///
  /// In tr, this message translates to:
  /// **'Kartlarınız toplam {count} kez başkaları tarafından kaydedildi.'**
  String profileCardsSavedByOthersInfo(int count);

  /// No description provided for @yenidenek.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden çek'**
  String get yenidenek;

  /// No description provided for @yeniifre.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get yeniifre;

  /// No description provided for @yeniifreTekrar.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre tekrar'**
  String get yeniifreTekrar;

  /// No description provided for @yetenekler.
  ///
  /// In tr, this message translates to:
  /// **'Yetenekler'**
  String get yetenekler;

  /// No description provided for @ykleniyor.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor…'**
  String get ykleniyor;

  /// No description provided for @zA.
  ///
  /// In tr, this message translates to:
  /// **'Z → A'**
  String get zA;

  /// No description provided for @zelAralk.
  ///
  /// In tr, this message translates to:
  /// **'Özel aralık'**
  String get zelAralk;

  /// No description provided for @zelKartRengi.
  ///
  /// In tr, this message translates to:
  /// **'Özel kart rengi'**
  String get zelKartRengi;

  /// No description provided for @zelMetinRengi.
  ///
  /// In tr, this message translates to:
  /// **'Özel metin rengi'**
  String get zelMetinRengi;

  /// No description provided for @kartEfekti.
  ///
  /// In tr, this message translates to:
  /// **'Kart efekti'**
  String get kartEfekti;

  /// No description provided for @efektYok.
  ///
  /// In tr, this message translates to:
  /// **'Yok'**
  String get efektYok;

  /// No description provided for @efektYildiz.
  ///
  /// In tr, this message translates to:
  /// **'Yıldız'**
  String get efektYildiz;

  /// No description provided for @efektParlama.
  ///
  /// In tr, this message translates to:
  /// **'Parlama'**
  String get efektParlama;

  /// No description provided for @efektShimmer.
  ///
  /// In tr, this message translates to:
  /// **'Shimmer'**
  String get efektShimmer;

  /// No description provided for @efektNeon.
  ///
  /// In tr, this message translates to:
  /// **'Neon'**
  String get efektNeon;

  /// No description provided for @efektIsilti.
  ///
  /// In tr, this message translates to:
  /// **'Işıltı'**
  String get efektIsilti;

  /// No description provided for @efektAurora.
  ///
  /// In tr, this message translates to:
  /// **'Aurora'**
  String get efektAurora;

  /// No description provided for @efektNabiz.
  ///
  /// In tr, this message translates to:
  /// **'Nabız'**
  String get efektNabiz;

  /// No description provided for @efektHolografik.
  ///
  /// In tr, this message translates to:
  /// **'Holografik'**
  String get efektHolografik;

  /// No description provided for @efektYagmur.
  ///
  /// In tr, this message translates to:
  /// **'Yağmur'**
  String get efektYagmur;

  /// No description provided for @efektKar.
  ///
  /// In tr, this message translates to:
  /// **'Kar'**
  String get efektKar;

  /// No description provided for @efektAtes.
  ///
  /// In tr, this message translates to:
  /// **'Ateş'**
  String get efektAtes;

  /// No description provided for @efektKonfeti.
  ///
  /// In tr, this message translates to:
  /// **'Konfeti'**
  String get efektKonfeti;

  /// No description provided for @efektKozmik.
  ///
  /// In tr, this message translates to:
  /// **'Kozmik'**
  String get efektKozmik;

  /// No description provided for @efektDalga.
  ///
  /// In tr, this message translates to:
  /// **'Dalga'**
  String get efektDalga;

  /// No description provided for @efektElmas.
  ///
  /// In tr, this message translates to:
  /// **'Elmas'**
  String get efektElmas;

  /// No description provided for @efektGunbatimi.
  ///
  /// In tr, this message translates to:
  /// **'Gün batımı'**
  String get efektGunbatimi;

  /// No description provided for @efektBuz.
  ///
  /// In tr, this message translates to:
  /// **'Buz'**
  String get efektBuz;

  /// No description provided for @efektMatrix.
  ///
  /// In tr, this message translates to:
  /// **'Matrix'**
  String get efektMatrix;

  /// No description provided for @kartEfektleriDeneyinKayitPro.
  ///
  /// In tr, this message translates to:
  /// **'Efektleri deneyebilirsiniz; kaydetmek için Pro gerekir.'**
  String get kartEfektleriDeneyinKayitPro;

  /// No description provided for @seciliKartEfektiProGerekli.
  ///
  /// In tr, this message translates to:
  /// **'Seçili efekt Pro gerektirir. Kartınızı oluşturmak için efekti kaldırın veya Pro\'ya geçin.'**
  String get seciliKartEfektiProGerekli;

  /// No description provided for @efektKayitProGerekli.
  ///
  /// In tr, this message translates to:
  /// **'Efekti kaydetmek için Pro gerekir. Kart efektsiz kaydedildi.'**
  String get efektKayitProGerekli;

  /// No description provided for @pro.
  ///
  /// In tr, this message translates to:
  /// **'Pro'**
  String get pro;

  /// No description provided for @zelliknerisi.
  ///
  /// In tr, this message translates to:
  /// **'Özellik önerisi'**
  String get zelliknerisi;

  /// No description provided for @sessionNotFoundLogin.
  ///
  /// In tr, this message translates to:
  /// **'Oturum bulunamadı. Lütfen tekrar giriş yapın.'**
  String get sessionNotFoundLogin;

  /// No description provided for @sessionNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Oturum bulunamadı.'**
  String get sessionNotFound;

  /// No description provided for @sessionExpired.
  ///
  /// In tr, this message translates to:
  /// **'Güvenliğiniz için lütfen tekrar giriş yapın.'**
  String get sessionExpired;

  /// No description provided for @operationFailed.
  ///
  /// In tr, this message translates to:
  /// **'İşlem başarısız.'**
  String get operationFailed;

  /// No description provided for @sessionInfoUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Oturum bilgisi alınamadı.'**
  String get sessionInfoUnavailable;

  /// No description provided for @invalidSessionResponse.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz oturum yanıtı.'**
  String get invalidSessionResponse;

  /// No description provided for @profileInfoUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Profil bilgisi alınamadı.'**
  String get profileInfoUnavailable;

  /// No description provided for @invalidProfileResponse.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz profil yanıtı.'**
  String get invalidProfileResponse;

  /// No description provided for @linkedinLoginFailed.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn ile giriş başarısız.'**
  String get linkedinLoginFailed;

  /// No description provided for @profilePhotoUploadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı yüklenemedi.'**
  String get profilePhotoUploadFailed;

  /// No description provided for @serverResponseUnreadable.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu yanıtı okunamadı.'**
  String get serverResponseUnreadable;

  /// No description provided for @cardIdMissing.
  ///
  /// In tr, this message translates to:
  /// **'Kart kimliği eksik.'**
  String get cardIdMissing;

  /// No description provided for @eventGroupsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grupları alınamadı.'**
  String get eventGroupsLoadFailed;

  /// No description provided for @eventGroupLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grubu alınamadı.'**
  String get eventGroupLoadFailed;

  /// No description provided for @eventGroupCreateFailed.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grubu oluşturulamadı.'**
  String get eventGroupCreateFailed;

  /// No description provided for @eventPhotoUploadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik fotoğrafı yüklenemedi.'**
  String get eventPhotoUploadFailed;

  /// No description provided for @eventGroupDeleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik grubu silinemedi.'**
  String get eventGroupDeleteFailed;

  /// No description provided for @cardsLinkToGroupFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kartlar gruba eklenemedi.'**
  String get cardsLinkToGroupFailed;

  /// No description provided for @cardRemoveFromGroupFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kart gruptan çıkarılamadı.'**
  String get cardRemoveFromGroupFailed;

  /// No description provided for @supportRequestFailed.
  ///
  /// In tr, this message translates to:
  /// **'Destek talebi gönderilemedi.'**
  String get supportRequestFailed;

  /// No description provided for @walletQuotaLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdan kotası alınamadı.'**
  String get walletQuotaLoadFailed;

  /// No description provided for @cardAddToWalletFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kart cüzdana eklenemedi.'**
  String get cardAddToWalletFailed;

  /// No description provided for @cardInfoLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kart bilgisi alınamadı.'**
  String get cardInfoLoadFailed;

  /// No description provided for @invalidCardId.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz kart kimliği.'**
  String get invalidCardId;

  /// No description provided for @invalidCardResponse.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz kart yanıtı.'**
  String get invalidCardResponse;

  /// No description provided for @connectionError.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası. Lütfen tekrar deneyin.'**
  String get connectionError;

  /// No description provided for @authEmailRequired.
  ///
  /// In tr, this message translates to:
  /// **'E-posta gereklidir.'**
  String get authEmailRequired;

  /// No description provided for @authPasswordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre gereklidir.'**
  String get authPasswordRequired;

  /// No description provided for @authEmailUserNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta ile kayıtlı kullanıcı bulunamadı. Önce kayıt olun.'**
  String get authEmailUserNotFound;

  /// No description provided for @authInvalidEmailPassword.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı.'**
  String get authInvalidEmailPassword;

  /// No description provided for @authPhoneRequired.
  ///
  /// In tr, this message translates to:
  /// **'Telefon gereklidir.'**
  String get authPhoneRequired;

  /// No description provided for @authPhoneUserNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bu telefon ile kayıtlı kullanıcı bulunamadı. Önce kayıt olun.'**
  String get authPhoneUserNotFound;

  /// No description provided for @authInvalidPhonePassword.
  ///
  /// In tr, this message translates to:
  /// **'Telefon veya şifre hatalı.'**
  String get authInvalidPhonePassword;

  /// No description provided for @authDisplayNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad gereklidir.'**
  String get authDisplayNameRequired;

  /// No description provided for @authDisplayNameMinLength.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad en az 2 karakter olmalıdır.'**
  String get authDisplayNameMinLength;

  /// No description provided for @authInvalidEmailFormat.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta girin.'**
  String get authInvalidEmailFormat;

  /// No description provided for @authInvalidPhoneFormat.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir telefon numarası girin.'**
  String get authInvalidPhoneFormat;

  /// No description provided for @authEmailAlreadyRegistered.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresi başka bir hesapta kayıtlı.'**
  String get authEmailAlreadyRegistered;

  /// No description provided for @authPhoneAlreadyRegistered.
  ///
  /// In tr, this message translates to:
  /// **'Bu telefon numarası başka bir hesapta kayıtlı.'**
  String get authPhoneAlreadyRegistered;

  /// No description provided for @authPasswordMinLengthError.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az {minLength} karakter olmalıdır.'**
  String authPasswordMinLengthError(int minLength);

  /// No description provided for @authLinkedInCodeRequired.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn yetkilendirme kodu gereklidir.'**
  String get authLinkedInCodeRequired;

  /// No description provided for @authInvalidRedirectUri.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz yönlendirme adresi.'**
  String get authInvalidRedirectUri;

  /// No description provided for @authLinkedInSessionInvalid.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn oturumu doğrulanamadı.'**
  String get authLinkedInSessionInvalid;

  /// No description provided for @authLinkedInUserNotFound.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn hesabına bağlı kullanıcı bulunamadı.'**
  String get authLinkedInUserNotFound;

  /// No description provided for @authInvalidOtp.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodu geçersiz veya süresi dolmuş.'**
  String get authInvalidOtp;

  /// No description provided for @supportRequestFailedRetry.
  ///
  /// In tr, this message translates to:
  /// **'Destek talebi gönderilemedi. Lütfen tekrar deneyin.'**
  String get supportRequestFailedRetry;

  /// No description provided for @supportInvalidRequest.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta ve en az 10 karakterlik bir mesaj girin.'**
  String get supportInvalidRequest;

  /// No description provided for @enAz10Karakter.
  ///
  /// In tr, this message translates to:
  /// **'En az 10 karakter'**
  String get enAz10Karakter;

  /// No description provided for @cardencePaylasBirlikteBaglanti.
  ///
  /// In tr, this message translates to:
  /// **'Cardence\'i paylaş, birlikte bağlantı kurun'**
  String get cardencePaylasBirlikteBaglanti;

  /// No description provided for @balang.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get balang;

  /// No description provided for @kimlik.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik'**
  String get kimlik;

  /// No description provided for @iBilgileri.
  ///
  /// In tr, this message translates to:
  /// **'İş bilgileri'**
  String get iBilgileri;

  /// No description provided for @letiim.
  ///
  /// In tr, this message translates to:
  /// **'İletişim'**
  String get letiim;

  /// No description provided for @adnz.
  ///
  /// In tr, this message translates to:
  /// **'Adınız'**
  String get adnz;

  /// No description provided for @profilFotoraf.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı'**
  String get profilFotoraf;

  /// No description provided for @kartNizlemesi.
  ///
  /// In tr, this message translates to:
  /// **'Kart önizlemesi'**
  String get kartNizlemesi;

  /// No description provided for @nvlan.
  ///
  /// In tr, this message translates to:
  /// **'Ünvan'**
  String get nvlan;

  /// No description provided for @henzBilgiYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bilgi yok'**
  String get henzBilgiYok;

  /// No description provided for @onboardingCardListedHere.
  ///
  /// In tr, this message translates to:
  /// **'Onboarding\'de oluşturduğun kart burada listelenecek.'**
  String get onboardingCardListedHere;

  /// No description provided for @changesReflectInPreview.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikler önizlemeye anında yansır; kaydetmek için Kaydet\'e basın.'**
  String get changesReflectInPreview;

  /// No description provided for @editCard.
  ///
  /// In tr, this message translates to:
  /// **'Kartı düzenle'**
  String get editCard;

  /// No description provided for @newCard.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kart'**
  String get newCard;

  /// No description provided for @scanQrToSaveCard.
  ///
  /// In tr, this message translates to:
  /// **'Diğer kişi bu QR\'ı Cardence ile okutarak kartınızı kaydedebilir.'**
  String get scanQrToSaveCard;

  /// No description provided for @shareCardIdSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kart ID\'nizi gönderin; karşı taraf Cardence\'te kartınızı ekleyebilir.'**
  String get shareCardIdSubtitle;

  /// No description provided for @rateOnAppStore.
  ///
  /// In tr, this message translates to:
  /// **'App Store üzerinden geri bildirim verin'**
  String get rateOnAppStore;

  /// No description provided for @selectCards.
  ///
  /// In tr, this message translates to:
  /// **'Kartları seç'**
  String get selectCards;

  /// No description provided for @upgradeToPremium.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a geç'**
  String get upgradeToPremium;

  /// No description provided for @signUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get signUp;

  /// No description provided for @noCardsInGroup.
  ///
  /// In tr, this message translates to:
  /// **'Bu grupta kart yok'**
  String get noCardsInGroup;

  /// No description provided for @apply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get apply;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @savedCardsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıtlı kart'**
  String savedCardsCount(int count);

  /// No description provided for @kartYzundeGosterilecekAlanlar.
  ///
  /// In tr, this message translates to:
  /// **'Kart yüzünde gösterilecek alanlar'**
  String get kartYzundeGosterilecekAlanlar;

  /// No description provided for @enFazlaAlanSecin.
  ///
  /// In tr, this message translates to:
  /// **'En fazla {max} alan seçin'**
  String enFazlaAlanSecin(int count, int max);

  /// No description provided for @cardsShowing.
  ///
  /// In tr, this message translates to:
  /// **'{shown} / {total} kart gösteriliyor'**
  String cardsShowing(int shown, int total);

  /// No description provided for @ornekKartlar.
  ///
  /// In tr, this message translates to:
  /// **'Örnek kartlar'**
  String ornekKartlar(int shown, int total);

  /// No description provided for @cardenceIleDijitalKartvizitlerinizi.
  ///
  /// In tr, this message translates to:
  /// **'Cardence ile dijital kartvizitlerinizi oluşturabilir, paylaşabilir ve cüzdanınızda yönetebilirsiniz.'**
  String get cardenceIleDijitalKartvizitlerinizi;

  /// No description provided for @uygulamaSrme.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama sürümü:'**
  String get uygulamaSrme;

  /// No description provided for @sagAlttakiEkleIleQr.
  ///
  /// In tr, this message translates to:
  /// **'Sağ alttaki Ekle ile QR okutun veya kart ID girin'**
  String get sagAlttakiEkleIleQr;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicyTitle;

  /// No description provided for @privacySection1Title.
  ///
  /// In tr, this message translates to:
  /// **'1. Toplanan veriler'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Body.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştururken ad soyad, e-posta ve isteğe bağlı telefon numaranızı toplarız. Kartvizit bilgileriniz ve uygulama kullanımınıza ilişkin teknik veriler hizmetin sunulması için işlenir.'**
  String get privacySection1Body;

  /// No description provided for @privacySection2Title.
  ///
  /// In tr, this message translates to:
  /// **'2. Verilerin kullanımı'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Body.
  ///
  /// In tr, this message translates to:
  /// **'Verileriniz hesabınızı yönetmek, kartvizitlerinizi paylaşmak, güvenliği sağlamak ve hizmeti iyileştirmek amacıyla kullanılır. Pazarlama iletişimi yalnızca açık rızanız varsa gönderilir.'**
  String get privacySection2Body;

  /// No description provided for @privacySection3Title.
  ///
  /// In tr, this message translates to:
  /// **'3. Veri paylaşımı'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Body.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel verilerinizi üçüncü taraflara satmayız. Yasal zorunluluklar, hizmet sağlayıcıları (barındırma, analitik) ve açık rızanız kapsamında sınırlı paylaşım yapılabilir.'**
  String get privacySection3Body;

  /// No description provided for @privacySection4Title.
  ///
  /// In tr, this message translates to:
  /// **'4. Saklama süresi'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Body.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız aktif olduğu sürece verileriniz saklanır. Hesabınızı sildiğinizde, yasal yükümlülükler dışında verileriniz makul süre içinde silinir veya anonimleştirilir.'**
  String get privacySection4Body;

  /// No description provided for @privacySection5Title.
  ///
  /// In tr, this message translates to:
  /// **'5. Haklarınız'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Body.
  ///
  /// In tr, this message translates to:
  /// **'KVKK kapsamında verilerinize erişme, düzeltme, silme ve işlemeyi kısıtlama haklarına sahipsiniz. Taleplerinizi Destek bölümünden iletebilirsiniz.'**
  String get privacySection5Body;

  /// No description provided for @privacySection6Title.
  ///
  /// In tr, this message translates to:
  /// **'6. Güvenlik'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Body.
  ///
  /// In tr, this message translates to:
  /// **'Verilerinizi korumak için şifreleme, erişim kontrolü ve düzenli güvenlik değerlendirmeleri uygularız. Hiçbir sistem %100 güvenli değildir; güçlü bir şifre kullanmanızı öneririz.'**
  String get privacySection6Body;

  /// No description provided for @privacySection7Title.
  ///
  /// In tr, this message translates to:
  /// **'7. Politika güncellemeleri'**
  String get privacySection7Title;

  /// No description provided for @privacySection7Body.
  ///
  /// In tr, this message translates to:
  /// **'Bu politikayı zaman zaman güncelleyebiliriz. Önemli değişiklikler uygulama içinden bildirilir. Güncellemeden sonra hizmeti kullanmaya devam etmeniz yeni politikayı kabul ettiğiniz anlamına gelir.'**
  String get privacySection7Body;

  /// No description provided for @termsOfUseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get termsOfUseTitle;

  /// No description provided for @termsSection1Title.
  ///
  /// In tr, this message translates to:
  /// **'1. Hizmetin kapsamı'**
  String get termsSection1Title;

  /// No description provided for @termsSection1Body.
  ///
  /// In tr, this message translates to:
  /// **'Cardence; dijital kartvizit oluşturma, paylaşma ve yönetme hizmeti sunar. Uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.'**
  String get termsSection1Body;

  /// No description provided for @termsSection2Title.
  ///
  /// In tr, this message translates to:
  /// **'2. Hesap oluşturma'**
  String get termsSection2Title;

  /// No description provided for @termsSection2Body.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt sırasında verdiğiniz bilgilerin doğru ve güncel olması sizin sorumluluğunuzdadır. Hesap güvenliğinizi korumak için şifrenizi üçüncü kişilerle paylaşmamalısınız.'**
  String get termsSection2Body;

  /// No description provided for @termsSection3Title.
  ///
  /// In tr, this message translates to:
  /// **'3. Kabul edilebilir kullanım'**
  String get termsSection3Title;

  /// No description provided for @termsSection3Body.
  ///
  /// In tr, this message translates to:
  /// **'Hizmeti yasa dışı, yanıltıcı veya başkalarının haklarını ihlal edecek şekilde kullanamazsınız. Kartvizit içeriklerinden yalnızca siz sorumlusunuz.'**
  String get termsSection3Body;

  /// No description provided for @termsSection4Title.
  ///
  /// In tr, this message translates to:
  /// **'4. Fikri mülkiyet'**
  String get termsSection4Title;

  /// No description provided for @termsSection4Body.
  ///
  /// In tr, this message translates to:
  /// **'Cardence markası, arayüzü ve yazılımı Cardence\'e aittir. Oluşturduğunuz kartvizit içeriklerinin hakları size aittir; hizmeti sunmak için gerekli sınırlı kullanım lisansı vermiş olursunuz.'**
  String get termsSection4Body;

  /// No description provided for @termsSection5Title.
  ///
  /// In tr, this message translates to:
  /// **'5. Hizmet değişiklikleri'**
  String get termsSection5Title;

  /// No description provided for @termsSection5Body.
  ///
  /// In tr, this message translates to:
  /// **'Özellikleri geliştirmek veya yasal yükümlülükleri karşılamak için hizmette değişiklik yapabiliriz. Önemli güncellemeler uygulama içinden veya e-posta yoluyla bildirilebilir.'**
  String get termsSection5Body;

  /// No description provided for @termsSection6Title.
  ///
  /// In tr, this message translates to:
  /// **'6. Sorumluluk sınırı'**
  String get termsSection6Title;

  /// No description provided for @termsSection6Body.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet \"olduğu gibi\" sunulur. Makul özeni gösteririz; ancak kesintisiz veya hatasız çalışma garantisi verilmez. Yasal olarak izin verilen ölçüde dolaylı zararlardan sorumlu tutulamayız.'**
  String get termsSection6Body;

  /// No description provided for @termsSection7Title.
  ///
  /// In tr, this message translates to:
  /// **'7. İletişim'**
  String get termsSection7Title;

  /// No description provided for @termsSection7Body.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım koşulları hakkında sorularınız için uygulama içindeki Destek bölümünden bize ulaşabilirsiniz.'**
  String get termsSection7Body;

  /// No description provided for @hidePreview.
  ///
  /// In tr, this message translates to:
  /// **'Önizlemeyi gizle'**
  String get hidePreview;

  /// No description provided for @showPreview.
  ///
  /// In tr, this message translates to:
  /// **'Önizlemeyi göster'**
  String get showPreview;

  /// No description provided for @createdOnShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşınca oluşturulur'**
  String get createdOnShare;

  /// No description provided for @shareCardSubject.
  ///
  /// In tr, this message translates to:
  /// **'Cardence kartım'**
  String get shareCardSubject;

  /// No description provided for @shareCardMessage.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba! Cardence kartımı seninle paylaşıyorum.\n\nKart: {name}\nKart ID: {cardId}\n\nCardence uygulamasında Kayıtlı Kartlar bölümünden \"Kart ID ile ekle\" seçeneğine bu numarayı yazarak kartımı kaydedebilirsin.'**
  String shareCardMessage(String name, String cardId);

  /// No description provided for @provinceLabel.
  ///
  /// In tr, this message translates to:
  /// **'İl'**
  String get provinceLabel;

  /// No description provided for @districtLabel.
  ///
  /// In tr, this message translates to:
  /// **'İlçe'**
  String get districtLabel;

  /// No description provided for @twitterX.
  ///
  /// In tr, this message translates to:
  /// **'Twitter / X'**
  String get twitterX;

  /// No description provided for @walletUnlimitedCardsCanAdd.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız kart ekleyebilirsiniz.'**
  String get walletUnlimitedCardsCanAdd;

  /// No description provided for @walletRemainingCardsCanAdd.
  ///
  /// In tr, this message translates to:
  /// **'{count} kart daha ekleyebilirsiniz.'**
  String walletRemainingCardsCanAdd(int count);

  /// No description provided for @walletFullUpgradeLimit.
  ///
  /// In tr, this message translates to:
  /// **'Cüzdanınız dolu. Paket yükselterek sınırı artırabilirsiniz.'**
  String get walletFullUpgradeLimit;

  /// No description provided for @premiumBenefitUnlimitedSavedCards.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız kart kaydı'**
  String get premiumBenefitUnlimitedSavedCards;

  /// No description provided for @premiumBenefitUnlimitedEventGroups.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız etkinlik grubu organizasyonu'**
  String get premiumBenefitUnlimitedEventGroups;

  /// No description provided for @premiumBenefitUnlimitedManualPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız elle ve fotoğrafla kart ekleme'**
  String get premiumBenefitUnlimitedManualPhoto;

  /// No description provided for @premiumBenefitQrAndCardId.
  ///
  /// In tr, this message translates to:
  /// **'QR ve kart ID ile hızlı ekleme'**
  String get premiumBenefitQrAndCardId;

  /// No description provided for @quotaPremiumAllLimitsRemoved.
  ///
  /// In tr, this message translates to:
  /// **'Premium ile tüm limitler kalktı'**
  String get quotaPremiumAllLimitsRemoved;

  /// No description provided for @quotaFreePlanRights.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz plandaki haklarınız'**
  String get quotaFreePlanRights;

  /// No description provided for @oneTrial.
  ///
  /// In tr, this message translates to:
  /// **'1 deneme'**
  String get oneTrial;

  /// No description provided for @premiumRequired.
  ///
  /// In tr, this message translates to:
  /// **'Premium gerekli'**
  String get premiumRequired;

  /// No description provided for @canCreateNewCard.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kart oluşturabilirsiniz'**
  String get canCreateNewCard;

  /// No description provided for @cardLimitReached.
  ///
  /// In tr, this message translates to:
  /// **'Kart limitine ulaşıldı'**
  String get cardLimitReached;

  /// No description provided for @createUnlimitedGroups.
  ///
  /// In tr, this message translates to:
  /// **'İstediğiniz kadar grup oluşturun'**
  String get createUnlimitedGroups;

  /// No description provided for @eventGroupsRemaining.
  ///
  /// In tr, this message translates to:
  /// **'{count} grup hakkı kaldı'**
  String eventGroupsRemaining(int count);

  /// No description provided for @groupLimitReached.
  ///
  /// In tr, this message translates to:
  /// **'Grup limitine ulaşıldı'**
  String get groupLimitReached;

  /// No description provided for @addUnlimitedManualPhoto.
  ///
  /// In tr, this message translates to:
  /// **'İstediğiniz kadar ekleyin'**
  String get addUnlimitedManualPhoto;

  /// No description provided for @limitedTrialOnFreePlan.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz planda sınırlı deneme'**
  String get limitedTrialOnFreePlan;

  /// No description provided for @eventFilterFallback.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik'**
  String get eventFilterFallback;

  /// No description provided for @eventGroupNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik adı boş olamaz'**
  String get eventGroupNameRequired;

  /// No description provided for @eventGroupNameDuplicate.
  ///
  /// In tr, this message translates to:
  /// **'Bu isimde bir etkinlik grubu zaten var'**
  String get eventGroupNameDuplicate;

  /// No description provided for @eventGroupDetailsStepSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Etkinliğin adını, konumunu, başlangıç saatini ve isteğe bağlı bitiş saatini girin.'**
  String get eventGroupDetailsStepSubtitle;

  /// No description provided for @eventCreateStepProgress.
  ///
  /// In tr, this message translates to:
  /// **'Adım {current} / {total}'**
  String eventCreateStepProgress(int current, int total);

  /// No description provided for @eventCreateNameSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Etkinliğinize bir ad verin.'**
  String get eventCreateNameSubtitle;

  /// No description provided for @eventCreateLocationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ülke, il ve ilçe seçin; isteğe bağlı mekan adı ekleyin.'**
  String get eventCreateLocationSubtitle;

  /// No description provided for @eventLocationVenueLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mekan adı'**
  String get eventLocationVenueLabel;

  /// No description provided for @eventLocationProvinceDistrictLabel.
  ///
  /// In tr, this message translates to:
  /// **'İl · İlçe'**
  String get eventLocationProvinceDistrictLabel;

  /// No description provided for @eventLocationProvinceDistrictHint.
  ///
  /// In tr, this message translates to:
  /// **'İl ve ilçe seçin'**
  String get eventLocationProvinceDistrictHint;

  /// No description provided for @eventShowOnMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritada Göster'**
  String get eventShowOnMap;

  /// No description provided for @eventMapTapToSelect.
  ///
  /// In tr, this message translates to:
  /// **'Haritaya dokunarak konum seçin'**
  String get eventMapTapToSelect;

  /// No description provided for @eventMapDragToSelect.
  ///
  /// In tr, this message translates to:
  /// **'Haritayı kaydırarak konum seçin'**
  String get eventMapDragToSelect;

  /// No description provided for @eventMapUseMyLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konumum'**
  String get eventMapUseMyLocation;

  /// No description provided for @eventMapSelectLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum seç'**
  String get eventMapSelectLocation;

  /// No description provided for @eventMapOpenFullscreen.
  ///
  /// In tr, this message translates to:
  /// **'Tam ekran harita'**
  String get eventMapOpenFullscreen;

  /// No description provided for @eventLocationVenueHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. İstanbul Kongre Merkezi'**
  String get eventLocationVenueHint;

  /// No description provided for @eventLocationRegionRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ülke ve il/ilçe seçimi gereklidir.'**
  String get eventLocationRegionRequired;

  /// No description provided for @eventCreateStartSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç tarihi ve saatini seçin.'**
  String get eventCreateStartSubtitle;

  /// No description provided for @eventCreateScheduleSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç tarih ve saatini seçin; isterseniz bitiş de ekleyin.'**
  String get eventCreateScheduleSubtitle;

  /// No description provided for @eventCreateDetailsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gündem, kıyafet kodu veya diğer detayları paylaşın. Atlayabilirsiniz.'**
  String get eventCreateDetailsSubtitle;

  /// No description provided for @eventDescription.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik hakkında'**
  String get eventDescription;

  /// No description provided for @eventDescriptionHint.
  ///
  /// In tr, this message translates to:
  /// **'Gündem, konuşmacılar, kıyafet kodu, park bilgisi…'**
  String get eventDescriptionHint;

  /// No description provided for @eventDescriptionTooLong.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama en fazla 2000 karakter olabilir.'**
  String get eventDescriptionTooLong;

  /// No description provided for @eventAboutSection.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get eventAboutSection;

  /// No description provided for @eventAboutSectionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik hakkında'**
  String get eventAboutSectionLabel;

  /// No description provided for @eventGroupCardsSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gruptaki kartlar'**
  String get eventGroupCardsSectionTitle;

  /// No description provided for @eventShowMore.
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla göster'**
  String get eventShowMore;

  /// No description provided for @eventDetailCardsChip.
  ///
  /// In tr, this message translates to:
  /// **'{count} kart'**
  String eventDetailCardsChip(int count);

  /// No description provided for @eventDetailInvitesChip.
  ///
  /// In tr, this message translates to:
  /// **'{count} davet'**
  String eventDetailInvitesChip(int count);

  /// No description provided for @eventDetailNetworkingChip.
  ///
  /// In tr, this message translates to:
  /// **'Networking'**
  String get eventDetailNetworkingChip;

  /// No description provided for @eventAddCardPlus.
  ///
  /// In tr, this message translates to:
  /// **'+ Kart ekle'**
  String get eventAddCardPlus;

  /// No description provided for @eventLinkedCardsSection.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı kartlar ({count})'**
  String eventLinkedCardsSection(int count);

  /// No description provided for @eventCreateEndSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İsterseniz bitiş tarihi ve saatini belirleyin. Atlayabilirsiniz.'**
  String get eventCreateEndSubtitle;

  /// No description provided for @eventCreatePhotoSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Listede görünecek bir kapak fotoğrafı ekleyin. Atlayabilirsiniz.'**
  String get eventCreatePhotoSubtitle;

  /// No description provided for @eventPhotoUpload.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Yükle'**
  String get eventPhotoUpload;

  /// No description provided for @eventPhotoFormatHint.
  ///
  /// In tr, this message translates to:
  /// **'PNG, JPG veya WEBP (Max. 5MB)'**
  String get eventPhotoFormatHint;

  /// No description provided for @eventPhotoAdd.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf ekle'**
  String get eventPhotoAdd;

  /// No description provided for @eventPhotoChange.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafı değiştir'**
  String get eventPhotoChange;

  /// No description provided for @eventCreateNoSavedCards.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kaydedilmiş kart yok.'**
  String get eventCreateNoSavedCards;

  /// No description provided for @eventSkip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get eventSkip;

  /// No description provided for @eventGroupCardsStepSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı kart seçin veya Card ID ile davet edin. İsterseniz kart seçmeden de etkinliği oluşturabilirsiniz.'**
  String get eventGroupCardsStepSubtitle;

  /// No description provided for @eventStartRequired.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç tarihi ve saati seçin.'**
  String get eventStartRequired;

  /// No description provided for @eventLocationRequired.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik konumu gereklidir.'**
  String get eventLocationRequired;

  /// No description provided for @eventEndRequiresDateAndTime.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş için tarih ve saat birlikte seçilmelidir.'**
  String get eventEndRequiresDateAndTime;

  /// No description provided for @eventEndBeforeStart.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş zamanı başlangıçtan önce olamaz.'**
  String get eventEndBeforeStart;

  /// No description provided for @eventStart.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get eventStart;

  /// No description provided for @eventEndOptional.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş (opsiyonel)'**
  String get eventEndOptional;

  /// No description provided for @eventPickTime.
  ///
  /// In tr, this message translates to:
  /// **'Saat seç'**
  String get eventPickTime;

  /// No description provided for @eventScheduleStartHelper.
  ///
  /// In tr, this message translates to:
  /// **'Katılımcılar etkinliğin bu tarih ve saatte başlayacağını görür.'**
  String get eventScheduleStartHelper;

  /// No description provided for @eventScheduleEndHelper.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş eklemek zorunlu değildir; etkinlik süresini netleştirmek isterseniz doldurun.'**
  String get eventScheduleEndHelper;

  /// No description provided for @eventScheduleDateField.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get eventScheduleDateField;

  /// No description provided for @eventScheduleTimeField.
  ///
  /// In tr, this message translates to:
  /// **'Saat'**
  String get eventScheduleTimeField;

  /// No description provided for @eventSchedulePlannedStart.
  ///
  /// In tr, this message translates to:
  /// **'Planlanan başlangıç'**
  String get eventSchedulePlannedStart;

  /// No description provided for @eventSchedulePlannedRange.
  ///
  /// In tr, this message translates to:
  /// **'Planlanan süre'**
  String get eventSchedulePlannedRange;

  /// No description provided for @eventScheduleRequired.
  ///
  /// In tr, this message translates to:
  /// **'Zorunlu'**
  String get eventScheduleRequired;

  /// No description provided for @eventStartDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç tarihi'**
  String get eventStartDateLabel;

  /// No description provided for @eventStartTimeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç saati'**
  String get eventStartTimeLabel;

  /// No description provided for @eventEndDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş tarihi'**
  String get eventEndDateLabel;

  /// No description provided for @eventEndTimeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş saati'**
  String get eventEndTimeLabel;

  /// No description provided for @eventAddEnd.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş ekle'**
  String get eventAddEnd;

  /// No description provided for @eventInviteByCardId.
  ///
  /// In tr, this message translates to:
  /// **'Card ID ile davet et'**
  String get eventInviteByCardId;

  /// No description provided for @eventActiveSection.
  ///
  /// In tr, this message translates to:
  /// **'Devam eden / Yaklaşan'**
  String get eventActiveSection;

  /// No description provided for @eventOngoingSection.
  ///
  /// In tr, this message translates to:
  /// **'Devam eden'**
  String get eventOngoingSection;

  /// No description provided for @eventUpcomingSection.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan'**
  String get eventUpcomingSection;

  /// No description provided for @eventInvitationTitle.
  ///
  /// In tr, this message translates to:
  /// **'\"{eventName}\" etkinliğine davetlisiniz'**
  String eventInvitationTitle(String eventName);

  /// No description provided for @eventInvitationInvitedBy.
  ///
  /// In tr, this message translates to:
  /// **'{inviterName} sizi davet etti'**
  String eventInvitationInvitedBy(String inviterName);

  /// No description provided for @eventInvitationMessage.
  ///
  /// In tr, this message translates to:
  /// **'{inviterName} sizi \"{eventName}\" etkinliğine davet etti'**
  String eventInvitationMessage(String inviterName, String eventName);

  /// No description provided for @eventInvitationCardLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kartınız: {cardName}'**
  String eventInvitationCardLabel(String cardName);

  /// No description provided for @eventInvitationAccept.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get eventInvitationAccept;

  /// No description provided for @eventInvitationInvitedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Davet edildiniz'**
  String get eventInvitationInvitedSubtitle;

  /// No description provided for @eventInvitationAcceptHint.
  ///
  /// In tr, this message translates to:
  /// **'Kartınız bu etkinliğe bağlanır'**
  String get eventInvitationAcceptHint;

  /// No description provided for @eventInvitationReject.
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get eventInvitationReject;

  /// No description provided for @eventInvitationRejectHint.
  ///
  /// In tr, this message translates to:
  /// **'Davet listenizden kaldırılır'**
  String get eventInvitationRejectHint;

  /// No description provided for @eventInvitationResponsePrompt.
  ///
  /// In tr, this message translates to:
  /// **'Bu davete nasıl yanıt vermek istersiniz?'**
  String get eventInvitationResponsePrompt;

  /// No description provided for @eventInvitationDaysRemaining.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =0{Bugün başlıyor} =1{1 gün kaldı} other{{count} gün kaldı}}'**
  String eventInvitationDaysRemaining(int count);

  /// No description provided for @eventInvitationAccepted.
  ///
  /// In tr, this message translates to:
  /// **'Davet kabul edildi'**
  String get eventInvitationAccepted;

  /// No description provided for @eventInvitationRejected.
  ///
  /// In tr, this message translates to:
  /// **'Davet reddedildi'**
  String get eventInvitationRejected;

  /// No description provided for @eventInvitationsSection.
  ///
  /// In tr, this message translates to:
  /// **'Davetler'**
  String get eventInvitationsSection;

  /// No description provided for @eventEndedSection.
  ///
  /// In tr, this message translates to:
  /// **'Sona eren'**
  String get eventEndedSection;

  /// No description provided for @eventGroupLinkedCardCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} kart'**
  String eventGroupLinkedCardCount(int count);

  /// No description provided for @eventGroupToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get eventGroupToday;

  /// No description provided for @eventGroupEndedLastMonth.
  ///
  /// In tr, this message translates to:
  /// **'Geçen ay sona erdi'**
  String get eventGroupEndedLastMonth;

  /// No description provided for @eventGroupEndedThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay sona erdi'**
  String get eventGroupEndedThisMonth;

  /// No description provided for @eventStatusUpcoming.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşıyor'**
  String get eventStatusUpcoming;

  /// No description provided for @eventStatusOngoing.
  ///
  /// In tr, this message translates to:
  /// **'Devam ediyor'**
  String get eventStatusOngoing;

  /// No description provided for @eventStatusEnded.
  ///
  /// In tr, this message translates to:
  /// **'Bitti'**
  String get eventStatusEnded;

  /// No description provided for @eventEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Etkinliği düzenle'**
  String get eventEditTitle;

  /// No description provided for @eventGroupUpdatedMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" güncellendi'**
  String eventGroupUpdatedMessage(String name);

  /// No description provided for @eventInviteCardsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Card ID ile kart davet et'**
  String get eventInviteCardsTitle;

  /// No description provided for @eventInviteCardsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Card ID girerek bu etkinliğe kart ekleyin. Geçersiz ID\'ler raporlanır.'**
  String get eventInviteCardsSubtitle;

  /// No description provided for @eventSendInvites.
  ///
  /// In tr, this message translates to:
  /// **'Davet gönder'**
  String get eventSendInvites;

  /// No description provided for @eventSendingInvites.
  ///
  /// In tr, this message translates to:
  /// **'Davetler gönderiliyor…'**
  String get eventSendingInvites;

  /// No description provided for @eventGroupCreating.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik oluşturuluyor…'**
  String get eventGroupCreating;

  /// No description provided for @eventGroupCreatedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik oluşturuldu'**
  String get eventGroupCreatedSuccess;

  /// No description provided for @eventInvitesSentSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Davetler başarıyla gönderildi'**
  String get eventInvitesSentSuccess;

  /// No description provided for @eventInviteSendFailed.
  ///
  /// In tr, this message translates to:
  /// **'Davetler gönderilemedi. Lütfen tekrar deneyin.'**
  String get eventInviteSendFailed;

  /// No description provided for @eventCardIdHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. 123456'**
  String get eventCardIdHint;

  /// No description provided for @eventInvitedCardIdsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Card ID eklendi'**
  String eventInvitedCardIdsCount(int count);

  /// No description provided for @eventCardsInvitedMessage.
  ///
  /// In tr, this message translates to:
  /// **'{count} kart davet edildi'**
  String eventCardsInvitedMessage(int count);

  /// No description provided for @eventInvalidCardIdsMessage.
  ///
  /// In tr, this message translates to:
  /// **'{count} geçersiz Card ID'**
  String eventInvalidCardIdsMessage(int count);

  /// No description provided for @noCardsSelectedYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kart seçilmedi'**
  String get noCardsSelectedYet;

  /// No description provided for @cardsSelectedCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} kart seçildi'**
  String cardsSelectedCount(int count);

  /// No description provided for @createGroup.
  ///
  /// In tr, this message translates to:
  /// **'Grubu oluştur'**
  String get createGroup;

  /// No description provided for @createGroupWithCards.
  ///
  /// In tr, this message translates to:
  /// **'{count} kartla oluştur'**
  String createGroupWithCards(int count);

  /// No description provided for @pickSavedCardsForGroupSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{groupName} grubuna eklenecek kayıtlı kartları seçin.'**
  String pickSavedCardsForGroupSubtitle(String groupName);

  /// No description provided for @addCardsToGroup.
  ///
  /// In tr, this message translates to:
  /// **'Kartları gruba ekle'**
  String get addCardsToGroup;

  /// No description provided for @addCardsToGroupCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} kartı gruba ekle'**
  String addCardsToGroupCount(int count);

  /// No description provided for @pickEventGroupsForCardSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{cardTitle} kartının eklenebileceği grupları işaretleyin.'**
  String pickEventGroupsForCardSubtitle(String cardTitle);

  /// No description provided for @addToGroups.
  ///
  /// In tr, this message translates to:
  /// **'Gruplara ekle'**
  String get addToGroups;

  /// No description provided for @addToGroupsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} gruba ekle'**
  String addToGroupsCount(int count);

  /// No description provided for @savedCardFieldHintDisplayName.
  ///
  /// In tr, this message translates to:
  /// **'Kişinin adı ve soyadı'**
  String get savedCardFieldHintDisplayName;

  /// No description provided for @savedCardFieldHintEmail.
  ///
  /// In tr, this message translates to:
  /// **'ornek@firma.com'**
  String get savedCardFieldHintEmail;

  /// No description provided for @savedCardFieldHintPhone.
  ///
  /// In tr, this message translates to:
  /// **'+90 5XX XXX XX XX'**
  String get savedCardFieldHintPhone;

  /// No description provided for @savedCardFieldHintCompany.
  ///
  /// In tr, this message translates to:
  /// **'Çalıştığı şirket'**
  String get savedCardFieldHintCompany;

  /// No description provided for @savedCardFieldHintTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ünvan veya rol'**
  String get savedCardFieldHintTitle;

  /// No description provided for @savedCardFieldHintWebsite.
  ///
  /// In tr, this message translates to:
  /// **'https://...'**
  String get savedCardFieldHintWebsite;

  /// No description provided for @savedCardFieldHintLinkedin.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn profil URL'**
  String get savedCardFieldHintLinkedin;

  /// No description provided for @savedCardFieldHintAddress.
  ///
  /// In tr, this message translates to:
  /// **'Açık adres'**
  String get savedCardFieldHintAddress;

  /// No description provided for @savedCardFieldHintCity.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul'**
  String get savedCardFieldHintCity;

  /// No description provided for @savedCardFieldHintCountry.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye'**
  String get savedCardFieldHintCountry;

  /// No description provided for @savedCardFieldHintDepartment.
  ///
  /// In tr, this message translates to:
  /// **'Satış, AR-GE vb.'**
  String get savedCardFieldHintDepartment;

  /// No description provided for @savedCardFieldHintSchool.
  ///
  /// In tr, this message translates to:
  /// **'Mezun olunan okul'**
  String get savedCardFieldHintSchool;

  /// No description provided for @savedCardFieldHintAbout.
  ///
  /// In tr, this message translates to:
  /// **'Kısa tanıtım'**
  String get savedCardFieldHintAbout;

  /// No description provided for @savedCardFieldHintSkills.
  ///
  /// In tr, this message translates to:
  /// **'Virgülle ayırın'**
  String get savedCardFieldHintSkills;

  /// No description provided for @savedCardFieldHintAttendedEvents.
  ///
  /// In tr, this message translates to:
  /// **'Web Summit 2025, SaaStr Annual…'**
  String get savedCardFieldHintAttendedEvents;

  /// No description provided for @savedCardFieldHintTwitter.
  ///
  /// In tr, this message translates to:
  /// **'@kullanici veya profil URL'**
  String get savedCardFieldHintTwitter;

  /// No description provided for @savedCardFieldHintInstagram.
  ///
  /// In tr, this message translates to:
  /// **'@kullanici veya profil URL'**
  String get savedCardFieldHintInstagram;

  /// No description provided for @savedCardFieldHintBirthday.
  ///
  /// In tr, this message translates to:
  /// **'15 Mart veya 15.03.1990'**
  String get savedCardFieldHintBirthday;

  /// No description provided for @deleteEventGroupConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{groupName}\" etkinlik grubunu silmek istediğinize emin misiniz?'**
  String deleteEventGroupConfirmMessage(String groupName);

  /// No description provided for @deleteEventGroupConfirmSubMessage.
  ///
  /// In tr, this message translates to:
  /// **'Gruptaki kart bağlantıları kaldırılır.'**
  String get deleteEventGroupConfirmSubMessage;

  /// No description provided for @eventGroupDeletedMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{groupName}\" silindi'**
  String eventGroupDeletedMessage(String groupName);

  /// No description provided for @viewEventNetwork.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik ağını görüntüle'**
  String get viewEventNetwork;

  /// No description provided for @cardsAddedToGroupMessage.
  ///
  /// In tr, this message translates to:
  /// **'{count} kart gruba eklendi'**
  String cardsAddedToGroupMessage(int count);

  /// No description provided for @eventGroupCreatedMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{groupName}\" etkinlik grubu oluşturuldu'**
  String eventGroupCreatedMessage(String groupName);

  /// No description provided for @eventGroupCreatedWithCardsMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{groupName}\" grubu {count} kartla oluşturuldu'**
  String eventGroupCreatedWithCardsMessage(String groupName, int count);

  /// No description provided for @networkGraph.
  ///
  /// In tr, this message translates to:
  /// **'Ağ Grafiği'**
  String get networkGraph;

  /// No description provided for @networkGraphLegendMe.
  ///
  /// In tr, this message translates to:
  /// **'Ben'**
  String get networkGraphLegendMe;

  /// No description provided for @networkGraphLegendConnection.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı'**
  String get networkGraphLegendConnection;

  /// No description provided for @networkStatistics.
  ///
  /// In tr, this message translates to:
  /// **'Ağ İstatistikleri'**
  String get networkStatistics;

  /// No description provided for @networkGraphLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Ağ grafiği alınamadı.'**
  String get networkGraphLoadFailed;

  /// No description provided for @networkGraphEventDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu etkinlikteki kartlar, şirketler ve bağlantılar görsel olarak gösterilir.'**
  String get networkGraphEventDescription;

  /// No description provided for @networkGraphPersonalDescription.
  ///
  /// In tr, this message translates to:
  /// **'Senin kaydettiğin kişiler ile seni kaydeden kişiler arasındaki bağlantılar; şirket ve etkinlik düğümleriyle birlikte gösterilir.'**
  String get networkGraphPersonalDescription;

  /// No description provided for @viewScope.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm kapsamı'**
  String get viewScope;

  /// No description provided for @personalNetwork.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel ağ'**
  String get personalNetwork;

  /// No description provided for @eventNetwork.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik ağı'**
  String get eventNetwork;

  /// No description provided for @createEventGroupFirstForNetwork.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik ağı için önce bir etkinlik grubu oluşturun.'**
  String get createEventGroupFirstForNetwork;

  /// No description provided for @networkGraphNotYetCreated.
  ///
  /// In tr, this message translates to:
  /// **'Ağ grafiği henüz oluşmadı'**
  String get networkGraphNotYetCreated;

  /// No description provided for @networkGraphEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kart kaydettikçe, QR okutuldukça ve etkinlik grupları kullandıkça bağlantılar burada görünür.'**
  String get networkGraphEmptySubtitle;

  /// No description provided for @refresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  /// No description provided for @connections.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantılar'**
  String get connections;

  /// No description provided for @edgeTypeSaved.
  ///
  /// In tr, this message translates to:
  /// **'Senin kaydettiğin'**
  String get edgeTypeSaved;

  /// No description provided for @edgeTypeScanned.
  ///
  /// In tr, this message translates to:
  /// **'QR tarandı'**
  String get edgeTypeScanned;

  /// No description provided for @edgeTypeViewed.
  ///
  /// In tr, this message translates to:
  /// **'Görüntülendi'**
  String get edgeTypeViewed;

  /// No description provided for @edgeTypeContactClicked.
  ///
  /// In tr, this message translates to:
  /// **'İletişim tıklandı'**
  String get edgeTypeContactClicked;

  /// No description provided for @edgeTypeWorksAt.
  ///
  /// In tr, this message translates to:
  /// **'Şirkette çalışıyor'**
  String get edgeTypeWorksAt;

  /// No description provided for @edgeTypeMetAtEvent.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlikte tanışıldı'**
  String get edgeTypeMetAtEvent;

  /// No description provided for @edgeTypeCoSaved.
  ///
  /// In tr, this message translates to:
  /// **'Aynı cüzdanda'**
  String get edgeTypeCoSaved;

  /// No description provided for @edgeTypeSameCompany.
  ///
  /// In tr, this message translates to:
  /// **'Aynı şirket'**
  String get edgeTypeSameCompany;

  /// No description provided for @edgeTypeAssignedLead.
  ///
  /// In tr, this message translates to:
  /// **'Lead atandı'**
  String get edgeTypeAssignedLead;

  /// No description provided for @edgeTypeOrgEventLink.
  ///
  /// In tr, this message translates to:
  /// **'Organizasyon etkinliği'**
  String get edgeTypeOrgEventLink;

  /// No description provided for @edgeTypeEventLink.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik bağı'**
  String get edgeTypeEventLink;

  /// No description provided for @strongestNodes.
  ///
  /// In tr, this message translates to:
  /// **'En güçlü düğümler'**
  String get strongestNodes;

  /// No description provided for @connectionsCount.
  ///
  /// In tr, this message translates to:
  /// **'bağ'**
  String get connectionsCount;

  /// No description provided for @nodeTypeUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get nodeTypeUser;

  /// No description provided for @nodeTypeCompany.
  ///
  /// In tr, this message translates to:
  /// **'Şirket'**
  String get nodeTypeCompany;

  /// No description provided for @nodeTypeOrganizationEvent.
  ///
  /// In tr, this message translates to:
  /// **'Organizasyon etkinliği'**
  String get nodeTypeOrganizationEvent;

  /// No description provided for @node.
  ///
  /// In tr, this message translates to:
  /// **'Düğüm'**
  String get node;

  /// No description provided for @edge.
  ///
  /// In tr, this message translates to:
  /// **'Bağ'**
  String get edge;

  /// No description provided for @connectionPath.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı yolu'**
  String get connectionPath;

  /// No description provided for @selectDestinationCard.
  ///
  /// In tr, this message translates to:
  /// **'Hedef kart seçin: {label}'**
  String selectDestinationCard(String label);

  /// No description provided for @noPathFoundBetweenCards.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen kartlar arasında bu grafikte doğrudan bir yol bulunamadı.'**
  String get noPathFoundBetweenCards;

  /// No description provided for @pathStepsAndNodes.
  ///
  /// In tr, this message translates to:
  /// **'{steps} adım • {nodes} düğüm'**
  String pathStepsAndNodes(int steps, int nodes);

  /// No description provided for @tapTwoNodesToFindPath.
  ///
  /// In tr, this message translates to:
  /// **'İki kart düğümüne dokunarak aralarındaki en kısa yolu bulun.'**
  String get tapTwoNodesToFindPath;

  /// No description provided for @networkGraphConnectedNodes.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı düğümler ({count})'**
  String networkGraphConnectedNodes(int count);

  /// No description provided for @networkGraphNoConnectedNodes.
  ///
  /// In tr, this message translates to:
  /// **'Bu grafikte bağlı düğüm yok.'**
  String get networkGraphNoConnectedNodes;

  /// No description provided for @networkGraphConnectionTypes.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı türleri'**
  String get networkGraphConnectionTypes;

  /// No description provided for @createMyCard.
  ///
  /// In tr, this message translates to:
  /// **'Kartımı oluştur'**
  String get createMyCard;

  /// No description provided for @continueWithArrow.
  ///
  /// In tr, this message translates to:
  /// **'Devam →'**
  String get continueWithArrow;

  /// No description provided for @swipeHorizontalToSwitchCards.
  ///
  /// In tr, this message translates to:
  /// **'Yatay kaydırarak kartlar arasında geçin.'**
  String get swipeHorizontalToSwitchCards;

  /// No description provided for @tapCardToEdit.
  ///
  /// In tr, this message translates to:
  /// **'Detay için karttaki detay düğmesini kullanın.'**
  String get tapCardToEdit;

  /// No description provided for @kartDetay.
  ///
  /// In tr, this message translates to:
  /// **'Detay'**
  String get kartDetay;

  /// No description provided for @cardLimitReachedPremiumUpgrade.
  ///
  /// In tr, this message translates to:
  /// **'Kart limitine ulaştınız. Yeni kart oluşturmak için Premium\'a geçebilirsiniz.'**
  String get cardLimitReachedPremiumUpgrade;

  /// No description provided for @viewNetworkGraph.
  ///
  /// In tr, this message translates to:
  /// **'Ağ grafiğini görüntüle'**
  String get viewNetworkGraph;

  /// No description provided for @cardsNotYetSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kartlarınız henüz kaydedilmedi.'**
  String get cardsNotYetSaved;

  /// No description provided for @cardsAddedToWalletTimes.
  ///
  /// In tr, this message translates to:
  /// **'Kartlarınız toplam {count} kez cüzdana eklendi.'**
  String cardsAddedToWalletTimes(int count);

  /// No description provided for @cardenceDataSecurityMessage.
  ///
  /// In tr, this message translates to:
  /// **'Cardence ağındaki tüm veri transferleri uçtan uca şifrelenir ve kimlik doğrulama protokolleri ile korunur.'**
  String get cardenceDataSecurityMessage;

  /// No description provided for @saveCard.
  ///
  /// In tr, this message translates to:
  /// **'Kartı kaydet'**
  String get saveCard;

  /// No description provided for @cardAlreadyInAllGroups.
  ///
  /// In tr, this message translates to:
  /// **'Bu kart zaten tüm gruplarda'**
  String get cardAlreadyInAllGroups;

  /// No description provided for @deleteCardConfirmQuestion.
  ///
  /// In tr, this message translates to:
  /// **'\"{displayName}\" kartını cüzdanınızdan silmek istediğinize emin misiniz?'**
  String deleteCardConfirmQuestion(String displayName);

  /// No description provided for @cardDeletedFromWalletMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{displayName}\" cüzdandan silindi'**
  String cardDeletedFromWalletMessage(String displayName);

  /// No description provided for @februaryShort.
  ///
  /// In tr, this message translates to:
  /// **'Şub'**
  String get februaryShort;

  /// No description provided for @augustShort.
  ///
  /// In tr, this message translates to:
  /// **'Ağu'**
  String get augustShort;

  /// No description provided for @copiedToClipboardMessage.
  ///
  /// In tr, this message translates to:
  /// **'{label} panoya kopyalandı'**
  String copiedToClipboardMessage(String label);

  /// No description provided for @couldNotOpenLink.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı açılamadı'**
  String get couldNotOpenLink;

  /// No description provided for @noExtraInfoYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz ek bilgi yok. Bilgi ekle ile adres, etkinlik ve daha fazlasını ekleyin.'**
  String get noExtraInfoYet;

  /// No description provided for @open.
  ///
  /// In tr, this message translates to:
  /// **'Aç'**
  String get open;

  /// No description provided for @takeFrontSidePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Ön yüzü çekin'**
  String get takeFrontSidePhoto;

  /// No description provided for @addBackSidePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Arka yüzü ekleyin (varsa)'**
  String get addBackSidePhoto;

  /// No description provided for @requiredField.
  ///
  /// In tr, this message translates to:
  /// **'ZORUNLU'**
  String get requiredField;

  /// No description provided for @optionalField.
  ///
  /// In tr, this message translates to:
  /// **'OPSİYONEL'**
  String get optionalField;

  /// No description provided for @freePlanMaxCardsLimitMessage.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz planda en fazla {count} kart saklayabilirsiniz.'**
  String freePlanMaxCardsLimitMessage(int count);

  /// No description provided for @upgradeLimitOption.
  ///
  /// In tr, this message translates to:
  /// **'Paket al, sınırı artır'**
  String get upgradeLimitOption;

  /// No description provided for @goToPremiumOption.
  ///
  /// In tr, this message translates to:
  /// **'Premium pakete geç'**
  String get goToPremiumOption;

  /// No description provided for @premium.
  ///
  /// In tr, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @free.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz'**
  String get free;

  /// No description provided for @remainingCardsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} kart kaldı'**
  String remainingCardsCount(int count);

  /// No description provided for @cardenceUser.
  ///
  /// In tr, this message translates to:
  /// **'Cardence kullanıcısı'**
  String get cardenceUser;

  /// No description provided for @userLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get userLabel;

  /// No description provided for @selectDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih seçin'**
  String get selectDate;

  /// No description provided for @purchaseSuccessful.
  ///
  /// In tr, this message translates to:
  /// **'Satın alım başarılı'**
  String get purchaseSuccessful;

  /// No description provided for @premiumWalletActivatedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Premium cüzdanınız etkinleştirildi. Artık tüm premium özelliklerden yararlanabilirsiniz.'**
  String get premiumWalletActivatedMessage;

  /// No description provided for @addSkillHint.
  ///
  /// In tr, this message translates to:
  /// **'Yetenek ekle (örn. Flutter)'**
  String get addSkillHint;

  /// No description provided for @noInfoYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bilgi yok'**
  String get noInfoYet;

  /// No description provided for @addAboutDescriptionPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Hakkımda bilginizi ekleyebilirsiniz.'**
  String get addAboutDescriptionPlaceholder;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @nodeTypeCard.
  ///
  /// In tr, this message translates to:
  /// **'Kart'**
  String get nodeTypeCard;

  /// No description provided for @nodeTypeEvent.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik'**
  String get nodeTypeEvent;

  /// No description provided for @nodeTypeOrganization.
  ///
  /// In tr, this message translates to:
  /// **'Organizasyon'**
  String get nodeTypeOrganization;

  /// No description provided for @nodeTypeSkill.
  ///
  /// In tr, this message translates to:
  /// **'Yetenek'**
  String get nodeTypeSkill;

  /// No description provided for @nodeTypeLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get nodeTypeLocation;

  /// No description provided for @edgeTypeOwns.
  ///
  /// In tr, this message translates to:
  /// **'Kart sahibi'**
  String get edgeTypeOwns;

  /// No description provided for @edgeTypeSavedBy.
  ///
  /// In tr, this message translates to:
  /// **'Seni kaydeden'**
  String get edgeTypeSavedBy;

  /// No description provided for @graphMetricNode.
  ///
  /// In tr, this message translates to:
  /// **'Düğüm'**
  String get graphMetricNode;

  /// No description provided for @graphMetricEdge.
  ///
  /// In tr, this message translates to:
  /// **'Bağ'**
  String get graphMetricEdge;

  /// No description provided for @graphMetricCenter.
  ///
  /// In tr, this message translates to:
  /// **'Merkez'**
  String get graphMetricCenter;

  /// No description provided for @graphMetricCenterFallback.
  ///
  /// In tr, this message translates to:
  /// **'—'**
  String get graphMetricCenterFallback;

  /// No description provided for @you.
  ///
  /// In tr, this message translates to:
  /// **'Sen'**
  String get you;

  /// No description provided for @clear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clear;

  /// No description provided for @searchActive.
  ///
  /// In tr, this message translates to:
  /// **'Arama aktif'**
  String get searchActive;

  /// No description provided for @search.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get search;

  /// No description provided for @filterActive.
  ///
  /// In tr, this message translates to:
  /// **'Filtre ({count})'**
  String filterActive(int count);

  /// No description provided for @filter.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get filter;

  /// No description provided for @noExtraInfoInThisCard.
  ///
  /// In tr, this message translates to:
  /// **'Bu kartta ek bilgi yok.'**
  String get noExtraInfoInThisCard;

  /// No description provided for @fieldSaved.
  ///
  /// In tr, this message translates to:
  /// **'{fieldName} kaydedildi'**
  String fieldSaved(String fieldName);

  /// No description provided for @addedToGroupsMessage.
  ///
  /// In tr, this message translates to:
  /// **'{count} gruba eklendi'**
  String addedToGroupsMessage(int count);

  /// No description provided for @savedAtLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi: {date}'**
  String savedAtLabel(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
