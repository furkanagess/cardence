import '../../domain/entities/wallet_plan_tier.dart';
import '../../domain/repositories/wallet_entitlement_repository.dart';
import '../datasources/wallet_entitlement_local_datasource.dart';

class WalletEntitlementRepositoryImpl implements WalletEntitlementRepository {
  WalletEntitlementRepositoryImpl(this._dataSource);

  final WalletEntitlementLocalDataSource _dataSource;

  @override
  Future<WalletPlanTier> getPlanTier() => _dataSource.getPlanTier();

  @override
  Future<void> setPlanTier(WalletPlanTier tier) => _dataSource.setPlanTier(tier);
}
