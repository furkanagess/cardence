import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/datasources/camera_permission_datasource.dart';
import '../../data/datasources/physical_card_ocr_datasource.dart';
import '../../domain/entities/manual_saved_card_draft.dart';
import '../../domain/parsers/business_card_text_parser.dart';
import 'scan_physical_card_state.dart';

class ScanPhysicalCardCubit extends Cubit<ScanPhysicalCardState> {
  ScanPhysicalCardCubit({
    required PhysicalCardOcrDataSource ocrDataSource,
    required CameraPermissionDataSource cameraPermissionDataSource,
    ImagePicker? imagePicker,
  })  : _ocrDataSource = ocrDataSource,
        _cameraPermissionDataSource = cameraPermissionDataSource,
        _imagePicker = imagePicker ?? ImagePicker(),
        super(const ScanPhysicalCardState());

  final PhysicalCardOcrDataSource _ocrDataSource;
  final CameraPermissionDataSource _cameraPermissionDataSource;
  final ImagePicker _imagePicker;

  Future<void> requestCameraPermission() async {
    emit(
      state.copyWith(
        cameraPermission: ScanCameraPermissionStatus.checking,
        clearError: true,
      ),
    );

    final outcome = await _cameraPermissionDataSource.requestCameraAccess();
    if (isClosed) return;

    final status = switch (outcome) {
      CameraPermissionOutcome.granted => ScanCameraPermissionStatus.granted,
      CameraPermissionOutcome.denied => ScanCameraPermissionStatus.denied,
      CameraPermissionOutcome.permanentlyDenied =>
        ScanCameraPermissionStatus.permanentlyDenied,
    };

    emit(state.copyWith(cameraPermission: status));
  }

  Future<void> openCameraSettings() async {
    await _cameraPermissionDataSource.openSettings();
  }

  Future<void> captureFront() async {
    await _capture(isFront: true);
  }

  Future<void> captureBack() async {
    await _capture(isFront: false);
  }

  Future<void> _capture({required bool isFront}) async {
    if (state.isBusy) return;

    if (state.cameraPermission != ScanCameraPermissionStatus.granted) {
      await requestCameraPermission();
      if (state.cameraPermission != ScanCameraPermissionStatus.granted) {
        emit(
          state.copyWith(
            errorMessage: 'Kartvizit çekmek için kamera izni gerekli.',
          ),
        );
        return;
      }
    }

    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 88,
      );
      if (image == null) {
        emit(state.copyWith(isBusy: false));
        return;
      }

      if (isFront) {
        emit(
          state.copyWith(
            frontImagePath: image.path,
            step: ScanPhysicalCardStep.back,
            isBusy: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            backImagePath: image.path,
            step: ScanPhysicalCardStep.back,
            isBusy: false,
          ),
        );
        await finishScan();
      }
    } catch (_) {
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
        step: ScanPhysicalCardStep.processing,
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
        step: ScanPhysicalCardStep.processing,
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

  void retakeFront() {
    emit(
      ScanPhysicalCardState(
        step: ScanPhysicalCardStep.front,
        cameraPermission: state.cameraPermission,
      ),
    );
  }
}
