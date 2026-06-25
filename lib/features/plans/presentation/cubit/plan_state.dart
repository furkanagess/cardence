import 'package:equatable/equatable.dart';

import '../../domain/entities/plan_entitlements.dart';

enum PlanStatus { initial, loading, loaded, failure }

class PlanState extends Equatable {
  const PlanState({
    this.status = PlanStatus.initial,
    this.entitlements,
    this.errorMessage,
  });

  final PlanStatus status;
  final PlanEntitlements? entitlements;
  final String? errorMessage;

  bool get isLoading => status == PlanStatus.loading;

  PlanState copyWith({
    PlanStatus? status,
    PlanEntitlements? entitlements,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlanState(
      status: status ?? this.status,
      entitlements: entitlements ?? this.entitlements,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, entitlements, errorMessage];
}
