import '../entities/wallet_plan_tier.dart';
import '../repositories/wallet_entitlement_repository.dart';

/// Paket satın alma simülasyonu; premium kotayı etkinleştirir.
class UpgradeWalletPlan {
  const UpgradeWalletPlan(this._walletRepository);

  final WalletEntitlementRepository _walletRepository;

  Future<void> call() => _walletRepository.setPlanTier(WalletPlanTier.premium);
}
