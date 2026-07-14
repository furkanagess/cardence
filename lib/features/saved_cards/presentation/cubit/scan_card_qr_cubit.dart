import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/camera_permission_datasource.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/card_creation_method.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_card_origin.dart';
import '../../domain/helpers/card_share_qr_codec.dart';
import '../../domain/usecases/add_saved_card.dart';
import 'scan_card_qr_state.dart';
import 'scan_physical_card_state.dart';

class ScanCardQrCubit extends Cubit<ScanCardQrState> {
  ScanCardQrCubit({
    required AddSavedCard addSavedCard,
    required CameraPermissionDataSource cameraPermissionDataSource,
  })  : _addSavedCard = addSavedCard,
        _cameraPermissionDataSource = cameraPermissionDataSource,
        super(const ScanCardQrState());

  final AddSavedCard _addSavedCard;
  final CameraPermissionDataSource _cameraPermissionDataSource;

  Future<void> initialize() async {
    await syncCameraPermissionStatus(requestIfNeeded: true);
  }

  Future<void> syncCameraPermissionStatus({
    bool requestIfNeeded = false,
  }) async {
    final outcome = requestIfNeeded
        ? await _cameraPermissionDataSource.requestCameraAccess()
        : await _cameraPermissionDataSource.readCameraAccess();
    final status = _statusFromOutcome(outcome);
    if (isClosed) return;

    if (status == ScanCameraPermissionStatus.granted) {
      emit(
        state.copyWith(
          phase: ScanCardQrPhase.scanning,
          cameraPermission: status,
          clearScanHintError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: ScanCardQrPhase.permission,
        cameraPermission: status,
      ),
    );
  }

  Future<bool> openSettings() => _cameraPermissionDataSource.openSettings();

  Future<void> onRawQrDetected(String? rawValue) async {
    if (!state.canScan || state.isSubmitting) return;

    final cardId = CardShareQrCodec.tryParseCardId(rawValue);
    if (cardId == null) {
      emit(state.copyWith(scanHintError: 'invalid'));
      return;
    }

    emit(
      state.copyWith(
        phase: ScanCardQrPhase.submitting,
        scannedCardId: cardId,
        clearScanHintError: true,
        clearResult: true,
      ),
    );

    final result = await _addSavedCard(
      SavedCard(
        cardId: cardId,
        origin: SavedCardOrigin.cardence,
        creationMethod: CardCreationMethod.qrScan,
        savedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (isClosed) return;

    switch (result) {
      case AddSavedCardSuccess():
        emit(
          state.copyWith(
            phase: ScanCardQrPhase.success,
            result: result,
          ),
        );
      case AddSavedCardDuplicate():
      case AddSavedCardOwnCard():
      case AddSavedCardInvalidPayload():
        emit(
          state.copyWith(
            phase: ScanCardQrPhase.scanning,
            result: result,
            scanHintError: 'result',
          ),
        );
      case AddSavedCardLimitReached():
      case AddSavedCardPremiumRequired():
        emit(
          state.copyWith(
            phase: ScanCardQrPhase.failure,
            result: result,
          ),
        );
    }
  }

  void clearScanFeedback() {
    if (state.scanHintError == null && state.result == null) return;
    emit(
      state.copyWith(
        clearScanHintError: true,
        clearResult: true,
      ),
    );
  }

  ScanCameraPermissionStatus _statusFromOutcome(
    CameraPermissionOutcome outcome,
  ) {
    return switch (outcome) {
      CameraPermissionOutcome.granted => ScanCameraPermissionStatus.granted,
      CameraPermissionOutcome.denied => ScanCameraPermissionStatus.denied,
      CameraPermissionOutcome.permanentlyDenied =>
        ScanCameraPermissionStatus.permanentlyDenied,
    };
  }
}
