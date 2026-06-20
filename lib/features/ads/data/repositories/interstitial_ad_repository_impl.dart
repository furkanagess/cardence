import '../../domain/repositories/interstitial_ad_repository.dart';
import '../datasources/admob_interstitial_datasource.dart';

class InterstitialAdRepositoryImpl implements InterstitialAdRepository {
  InterstitialAdRepositoryImpl({AdMobInterstitialDataSource? dataSource})
      : _dataSource = dataSource ?? AdMobInterstitialDataSource();

  final AdMobInterstitialDataSource _dataSource;

  @override
  Future<void> initialize() => _dataSource.initialize();

  @override
  Future<void> preload() => _dataSource.load();

  @override
  Future<void> show() => _dataSource.show();
}
