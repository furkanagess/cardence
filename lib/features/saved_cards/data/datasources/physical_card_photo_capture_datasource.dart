import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';

/// Sistem arka kamerası ile çekim + kullanıcı kırpma.
class PhysicalCardPhotoCaptureDataSource {
  PhysicalCardPhotoCaptureDataSource({
    ImagePicker? imagePicker,
    ImageCropper? imageCropper,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _imageCropper = imageCropper ?? ImageCropper();

  final ImagePicker _imagePicker;
  final ImageCropper _imageCropper;

  /// Arka kamera ile fotoğraf alır, kartvizit oranında kırptırır.
  /// İptalde `null` döner.
  Future<String?> captureRearAndCrop({required String cropTitle}) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 92,
    );
    if (picked == null) return null;

    return cropExisting(
      sourcePath: picked.path,
      cropTitle: cropTitle,
    );
  }

  Future<String?> cropExisting({
    required String sourcePath,
    required String cropTitle,
  }) async {
    final cropped = await _imageCropper.cropImage(
      sourcePath: sourcePath,
      maxWidth: 2048,
      maxHeight: 2048,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 92,
      aspectRatio: const CropAspectRatio(
        ratioX: FlippablePersonCard.cardAspectRatio,
        ratioY: 1,
      ),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: cropTitle,
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: AppColors.surfaceLight,
          statusBarLight: false,
          navBarLight: false,
          backgroundColor: AppColors.pureBlack,
          activeControlsWidgetColor: AppColors.primary,
          cropFrameColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
          hideBottomControls: false,
          aspectRatioPresets: const [
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.original,
          ],
        ),
        IOSUiSettings(
          title: cropTitle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          rotateButtonsHidden: false,
          aspectRatioPickerButtonHidden: true,
          aspectRatioPresets: const [
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.original,
          ],
        ),
      ],
    );

    return cropped?.path;
  }

  /// Android Activity ölümü sonrası kayıp kırpma sonucunu kurtarır.
  Future<String?> recoverLostCrop() async {
    final recovered = await _imageCropper.recoverImage();
    return recovered?.path;
  }
}
