import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/auth_api_exception.dart';
import '../../domain/usecases/get_plan_entitlements.dart';
import 'plan_state.dart';

class PlanCubit extends Cubit<PlanState> {
  PlanCubit({required GetPlanEntitlements getPlanEntitlements})
      : _getPlanEntitlements = getPlanEntitlements,
        super(const PlanState());

  final GetPlanEntitlements _getPlanEntitlements;

  Future<void> load() => refresh();

  Future<void> refresh() async {
    if (state.isLoading) return;

    emit(state.copyWith(status: PlanStatus.loading, clearError: true));
    try {
      final entitlements = await _getPlanEntitlements();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: PlanStatus.loaded,
          entitlements: entitlements,
          clearError: true,
        ),
      );
    } on AuthApiException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: PlanStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: PlanStatus.failure,
          errorMessage: 'Plan bilgileri alınamadı. Lütfen tekrar deneyin.',
        ),
      );
    }
  }
}
