import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  String? _photoUrl;
  bool _uploading = false;

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

  Future<void> _pickAndUploadPhoto() async {
    if (_uploading) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final profile = await widget.uploadProfilePhoto(image.path);
      if (!mounted) return;
      setState(() => _photoUrl = profile.photoUrl);
      widget.onPhotoUrlChanged(profile.photoUrl);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('AuthApiException: ', ''),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _uploading = false);
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
              onTap: _uploading ? null : _pickAndUploadPhoto,
              showEditBadge: !_uploading,
            ),
            if (_uploading)
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
          'Profil fotoğrafı (isteğe bağlı)',
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Kartınızda görünür',
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
