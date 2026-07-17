import 'package:equatable/equatable.dart';

import '../../domain/entities/manual_saved_card_draft.dart';

enum ScanPhysicalCardPhase {
  permission,
  capture,
  processing,
}

enum ScanCameraPermissionStatus {
  unknown,
  checking,
  granted,
  denied,
  permanentlyDenied,
}

class ScanPhysicalCardState extends Equatable {
  const ScanPhysicalCardState({
    this.phase = ScanPhysicalCardPhase.permission,
    this.frontImagePath,
    this.backImagePath,
    this.isBusy = false,
    this.errorMessage,
    this.completedDraft,
    this.cameraPermission = ScanCameraPermissionStatus.unknown,
  });

  final ScanPhysicalCardPhase phase;
  final String? frontImagePath;
  final String? backImagePath;
  final bool isBusy;
  final String? errorMessage;
  final ManualSavedCardDraft? completedDraft;
  final ScanCameraPermissionStatus cameraPermission;

  bool get isProcessing => phase == ScanPhysicalCardPhase.processing;
  bool get needsPermission => phase == ScanPhysicalCardPhase.permission;
  bool get isCapturing => phase == ScanPhysicalCardPhase.capture;

  bool get canCapture => !isBusy && isCapturing;

  bool get canReadInfo =>
      frontImagePath != null && !isBusy && !isProcessing;

  ScanPhysicalCardState copyWith({
    ScanPhysicalCardPhase? phase,
    String? frontImagePath,
    String? backImagePath,
    bool? isBusy,
    String? errorMessage,
    ManualSavedCardDraft? completedDraft,
    ScanCameraPermissionStatus? cameraPermission,
    bool clearError = false,
    bool clearCompletedDraft = false,
    bool clearBackImage = false,
  }) {
    return ScanPhysicalCardState(
      phase: phase ?? this.phase,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath:
          clearBackImage ? null : (backImagePath ?? this.backImagePath),
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
        phase,
        frontImagePath,
        backImagePath,
        isBusy,
        errorMessage,
        completedDraft,
        cameraPermission,
      ];
}

/// Eski adım enum'u — bazı importlar için alias.
typedef ScanPhysicalCardStep = ScanPhysicalCardPhase;
