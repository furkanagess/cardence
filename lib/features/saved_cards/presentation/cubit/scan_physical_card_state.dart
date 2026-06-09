import 'package:equatable/equatable.dart';

import '../../domain/entities/manual_saved_card_draft.dart';

enum ScanPhysicalCardStep { front, back, processing }

enum ScanCameraPermissionStatus {
  checking,
  granted,
  denied,
  permanentlyDenied,
}

class ScanPhysicalCardState extends Equatable {
  const ScanPhysicalCardState({
    this.step = ScanPhysicalCardStep.front,
    this.frontImagePath,
    this.backImagePath,
    this.isBusy = false,
    this.errorMessage,
    this.completedDraft,
    this.cameraPermission = ScanCameraPermissionStatus.checking,
  });

  final ScanPhysicalCardStep step;
  final String? frontImagePath;
  final String? backImagePath;
  final bool isBusy;
  final String? errorMessage;
  final ManualSavedCardDraft? completedDraft;
  final ScanCameraPermissionStatus cameraPermission;

  bool get canCapture =>
      cameraPermission == ScanCameraPermissionStatus.granted && !isBusy;

  ScanPhysicalCardState copyWith({
    ScanPhysicalCardStep? step,
    String? frontImagePath,
    String? backImagePath,
    bool? isBusy,
    String? errorMessage,
    ManualSavedCardDraft? completedDraft,
    ScanCameraPermissionStatus? cameraPermission,
    bool clearError = false,
    bool clearCompletedDraft = false,
  }) {
    return ScanPhysicalCardState(
      step: step ?? this.step,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      completedDraft: clearCompletedDraft
          ? null
          : (completedDraft ?? this.completedDraft),
      cameraPermission: cameraPermission ?? this.cameraPermission,
    );
  }

  @override
  List<Object?> get props => [
        step,
        frontImagePath,
        backImagePath,
        isBusy,
        errorMessage,
        completedDraft,
        cameraPermission,
      ];
}
