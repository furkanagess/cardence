import '../../domain/entities/wallet_paywall_result.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/revenuecat_subscription_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({RevenueCatSubscriptionDataSource? dataSource})
      : _dataSource = dataSource ?? RevenueCatSubscriptionDataSource();

  final RevenueCatSubscriptionDataSource _dataSource;

  @override
  Future<void> configure() => _dataSource.configure();

  @override
  Future<void> identifyUser(String userId) => _dataSource.identifyUser(userId);

  @override
  Future<void> logoutUser() => _dataSource.logoutUser();

  @override
  Future<bool> purchaseWalletPremium() => _dataSource.purchaseWalletPremium();

  @override
  Future<WalletPaywallResult> presentWalletPaywall({
    bool onlyIfNeeded = false,
    bool? useDarkAppearance,
  }) =>
      _dataSource.presentWalletPaywall(
        onlyIfNeeded: onlyIfNeeded,
        useDarkAppearance: useDarkAppearance,
      );

  @override
  Future<bool> restorePurchases() => _dataSource.restorePurchases();

  @override
  Future<bool> hasPremiumWalletEntitlement() =>
      _dataSource.hasPremiumWalletEntitlement();
}
