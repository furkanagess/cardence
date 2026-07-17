import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/camera_permission_datasource.dart';
import '../../data/datasources/physical_card_ocr_datasource.dart';
import '../../data/datasources/physical_card_photo_capture_datasource.dart';
import '../../domain/entities/manual_saved_card_draft.dart';
import '../../domain/parsers/business_card_text_parser.dart';
import 'scan_physical_card_state.dart';

class ScanPhysicalCardCubit extends Cubit<ScanPhysicalCardState> {
  ScanPhysicalCardCubit({
    required PhysicalCardOcrDataSource ocrDataSource,
    required CameraPermissionDataSource cameraPermissionDataSource,
    PhysicalCardPhotoCaptureDataSource? photoCaptureDataSource,
  })  : _ocrDataSource = ocrDataSource,
        _cameraPermissionDataSource = cameraPermissionDataSource,
        _photoCapture =
            photoCaptureDataSource ?? PhysicalCardPhotoCaptureDataSource(),
        super(const ScanPhysicalCardState());

  final PhysicalCardOcrDataSource _ocrDataSource;
  final CameraPermissionDataSource _cameraPermissionDataSource;
  final PhysicalCardPhotoCaptureDataSource _photoCapture;

  Future<void> initialize() async {
    emit(
      state.copyWith(
        cameraPermission: ScanCameraPermissionStatus.checking,
        clearError: true,
      ),
    );
    await syncCameraPermissionStatus(requestIfNeeded: true);
  }

  Future<void> syncCameraPermissionStatus({
    bool requestIfNeeded = false,
  }) async {
    if (requestIfNeeded &&
        state.cameraPermission != ScanCameraPermissionStatus.granted) {
      final outcome = await _cameraPermissionDataSource.requestCameraAccess();
      if (isClosed) return;
      final status = _statusFromOutcome(outcome);
      emit(
        state.copyWith(
          cameraPermission: status,
          phase: status == ScanCameraPermissionStatus.granted
              ? ScanPhysicalCardPhase.capture
              : ScanPhysicalCardPhase.permission,
          clearError: true,
        ),
      );
      return;
    }

    final status = await _readPermissionStatus();
    if (isClosed) return;
    emit(
      state.copyWith(
        cameraPermission: status,
        phase: status == ScanCameraPermissionStatus.granted
            ? (state.isProcessing
                ? ScanPhysicalCardPhase.processing
                : ScanPhysicalCardPhase.capture)
            : ScanPhysicalCardPhase.permission,
      ),
    );
  }

  Future<bool> openCameraSettings() {
    return _cameraPermissionDataSource.openSettings();
  }

  Future<void> captureFront({required String cropTitle}) {
    return _capture(isFront: true, cropTitle: cropTitle);
  }

  Future<void> captureBack({required String cropTitle}) {
    return _capture(isFront: false, cropTitle: cropTitle);
  }

  Future<void> _capture({
    required bool isFront,
    required String cropTitle,
  }) async {
    if (!state.canCapture) return;

    emit(state.copyWith(isBusy: true, clearError: true));

    if (state.cameraPermission != ScanCameraPermissionStatus.granted) {
      final outcome = await _cameraPermissionDataSource.requestCameraAccess();
      if (isClosed) return;
      final status = _statusFromOutcome(outcome);
      if (status != ScanCameraPermissionStatus.granted) {
        emit(
          state.copyWith(
            isBusy: false,
            cameraPermission: status,
            phase: ScanPhysicalCardPhase.permission,
            errorMessage: status == ScanCameraPermissionStatus.permanentlyDenied
                ? 'Kamera izni kapalı. Ayarlardan izin verip tekrar deneyin.'
                : 'Kartvizit çekmek için kamera izni gerekli.',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          cameraPermission: status,
          phase: ScanPhysicalCardPhase.capture,
        ),
      );
    }

    try {
      final path = await _photoCapture.captureRearAndCrop(cropTitle: cropTitle);
      if (isClosed) return;
      if (path == null) {
        emit(state.copyWith(isBusy: false));
        return;
      }

      if (isFront) {
        emit(
          state.copyWith(
            frontImagePath: path,
            isBusy: false,
            clearBackImage: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            backImagePath: path,
            isBusy: false,
          ),
        );
      }
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: 'Fotoğraf çekilemedi. Kamera iznini kontrol edin.',
        ),
      );
    }
  }

  Future<void> finishScan() async {
    final draft = await buildDraftFromPhotos();
    if (draft == null || isClosed) return;
    emit(
      state.copyWith(
        phase: ScanPhysicalCardPhase.processing,
        completedDraft: draft,
        isBusy: false,
      ),
    );
  }

  Future<ManualSavedCardDraft?> buildDraftFromPhotos() async {
    final front = state.frontImagePath;
    if (front == null) return null;

    emit(
      state.copyWith(
        phase: ScanPhysicalCardPhase.processing,
        isBusy: true,
        clearError: true,
      ),
    );

    try {
      final frontText = await _ocrDataSource.recognizeText(front);
      final backText = state.backImagePath != null
          ? await _ocrDataSource.recognizeText(state.backImagePath!)
          : '';

      final draft = BusinessCardTextParser.parse(
        frontText: frontText,
        backText: backText,
      ).copyWith(
        frontImagePath: front,
        backImagePath: state.backImagePath,
      );

      if (!isClosed) {
        emit(state.copyWith(isBusy: false));
      }
      return draft;
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isBusy: false,
            errorMessage:
                'Metin okunamadı. Bilgileri manuel düzenleyerek kaydedebilirsiniz.',
          ),
        );
      }
      return ManualSavedCardDraft(
        frontImagePath: front,
        backImagePath: state.backImagePath,
      );
    }
  }

  Future<ScanCameraPermissionStatus> _readPermissionStatus() async {
    final outcome = await _cameraPermissionDataSource.readCameraAccess();
    return _statusFromOutcome(outcome);
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
