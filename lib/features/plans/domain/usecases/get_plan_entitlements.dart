import '../entities/plan_entitlements.dart';
import '../repositories/plan_repository.dart';

class GetPlanEntitlements {
  const GetPlanEntitlements(this._repository);

  final PlanRepository _repository;

  Future<PlanEntitlements> call() => _repository.getPlanEntitlements();
}
