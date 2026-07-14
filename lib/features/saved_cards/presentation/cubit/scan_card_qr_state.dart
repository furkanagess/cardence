import 'package:equatable/equatable.dart';

import '../../domain/entities/add_saved_card_result.dart';
import 'scan_physical_card_state.dart';

enum ScanCardQrPhase {
  permission,
  scanning,
  submitting,
  success,
  failure,
}

class ScanCardQrState extends Equatable {
  const ScanCardQrState({
    this.phase = ScanCardQrPhase.permission,
    this.cameraPermission = ScanCameraPermissionStatus.unknown,
    this.scannedCardId,
    this.scanHintError,
    this.result,
  });

  final ScanCardQrPhase phase;
  final ScanCameraPermissionStatus cameraPermission;
  final String? scannedCardId;
  final String? scanHintError;
  final AddSavedCardResult? result;

  bool get isScanning => phase == ScanCardQrPhase.scanning;
  bool get isSubmitting => phase == ScanCardQrPhase.submitting;
  bool get isSuccess => phase == ScanCardQrPhase.success;
  bool get isFailure => phase == ScanCardQrPhase.failure;
  bool get canScan =>
      isScanning && cameraPermission == ScanCameraPermissionStatus.granted;

  ScanCardQrState copyWith({
    ScanCardQrPhase? phase,
    ScanCameraPermissionStatus? cameraPermission,
    String? scannedCardId,
    String? scanHintError,
    bool clearScanHintError = false,
    AddSavedCardResult? result,
    bool clearResult = false,
  }) {
    return ScanCardQrState(
      phase: phase ?? this.phase,
      cameraPermission: cameraPermission ?? this.cameraPermission,
      scannedCardId: scannedCardId ?? this.scannedCardId,
      scanHintError:
          clearScanHintError ? null : (scanHintError ?? this.scanHintError),
      result: clearResult ? null : (result ?? this.result),
    );
  }

  @override
  List<Object?> get props => [
        phase,
        cameraPermission,
        scannedCardId,
        scanHintError,
        result,
      ];
}
