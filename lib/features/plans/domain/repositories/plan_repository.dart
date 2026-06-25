import '../entities/plan_entitlements.dart';

abstract class PlanRepository {
  Future<PlanEntitlements> getPlanEntitlements();
}
