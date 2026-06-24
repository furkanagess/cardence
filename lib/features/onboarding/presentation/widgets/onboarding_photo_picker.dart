import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/media/profile_photo_image_picker.dart';
import '../../../../core/permissions/media_permission_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';

/// Onboarding sırasında isteğe bağlı profil fotoğrafı yükleme.
class OnboardingPhotoPicker extends StatefulWidget {
  const OnboardingPhotoPicker({
    super.key,
    required this.displayName,
    required this.photoUrl,
    required this.uploadProfilePhoto,
    required this.onPhotoUrlChanged,
  });

  final String displayName;
  final String? photoUrl;
  final UploadProfilePhoto uploadProfilePhoto;
  final ValueChanged<String?> onPhotoUrlChanged;

  @override
  State<OnboardingPhotoPicker> createState() => _OnboardingPhotoPickerState();
}

class _OnboardingPhotoPickerState extends State<OnboardingPhotoPicker> {
  final _photoPicker = ProfilePhotoImagePicker();
  static const _mediaPermission = MediaPermissionDataSource();

  String? _photoUrl;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.photoUrl;
  }

  @override
  void didUpdateWidget(OnboardingPhotoPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl) {
      _photoUrl = widget.photoUrl;
    }
  }

  void _showError(String message, {bool openSettings = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: openSettings
              ? SnackBarAction(
                  label: context.l10n.ayarlar,
                  onPressed: _mediaPermission.openSettings,
                )
              : null,
        ),
      );
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_busy) return;

    setState(() => _busy = true);
    try {
      final path = await _photoPicker.pickImagePath(
        context,
        onError: _showError,
      );
      if (path == null || !mounted) return;

      final profile = await widget.uploadProfilePhoto(path);
      if (!mounted) return;
      setState(() => _photoUrl = profile.photoUrl);
      widget.onPhotoUrlChanged(profile.photoUrl);
    } catch (e) {
      _showError(e.toString().replaceFirst('AuthApiException: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ProfileAvatar(
              photoUrl: _photoUrl,
              displayName: widget.displayName,
              size: 72,
              onTap: _busy ? null : _pickAndUploadPhoto,
              showEditBadge: !_busy,
            ),
            if (_busy)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.profilFotorafIsteeBal,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          context.l10n.kameraVeyaGaleridenEkleyin,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
