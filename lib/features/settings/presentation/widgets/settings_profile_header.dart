import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';

class SettingsProfileHeader extends StatefulWidget {
  const SettingsProfileHeader({
    super.key,
    required this.displayName,
    required this.uploadProfilePhoto,
    this.email,
    this.photoUrl,
    this.onPhotoUpdated,
  });

  final String displayName;
  final String? email;
  final String? photoUrl;
  final UploadProfilePhoto uploadProfilePhoto;
  final ValueChanged<String?>? onPhotoUpdated;

  @override
  State<SettingsProfileHeader> createState() => _SettingsProfileHeaderState();
}

class _SettingsProfileHeaderState extends State<SettingsProfileHeader> {
  String? _photoUrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.photoUrl;
  }

  @override
  void didUpdateWidget(SettingsProfileHeader oldWidget) {
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
      widget.onPhotoUpdated?.call(profile.photoUrl);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Profil fotoğrafı güncellendi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.9),
            colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.displayName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (widget.email != null && widget.email!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.email!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '${AppConstants.appName} v${AppConstants.appVersion}',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fotoğrafa dokunarak değiştir',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
