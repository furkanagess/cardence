import 'package:flutter/material.dart';

import '../../../../core/media/profile_photo_image_picker.dart';
import '../../../../core/permissions/media_permission_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';

/// Ayarlar profil kartı — fotoğraf kendi kart(lar)ı ile senkronize edilir.
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
  void didUpdateWidget(SettingsProfileHeader oldWidget) {
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
                  label: 'Ayarlar',
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
      widget.onPhotoUpdated?.call(profile.photoUrl);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Profil fotoğrafı kartlarınıza da uygulandı.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ProfileAvatar(
                  photoUrl: _photoUrl,
                  displayName: widget.displayName,
                  size: 96,
                  circular: true,
                  onTap: _busy ? null : _pickAndUploadPhoto,
                  showEditBadge: !_busy,
                ),
                if (_busy)
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(28),
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.displayName,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            if (widget.email != null && widget.email!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                widget.email!.trim(),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
