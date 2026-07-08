import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/media/profile_photo_image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';

/// Ayarlar profil başlığı — ortalanmış avatar, ad ve e-posta.
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
  static const double _avatarSize = 96;

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

  Future<void> _pickAndUploadPhoto() async {
    if (_busy) return;

    setState(() => _busy = true);
    try {
      final path = await _photoPicker.pickImagePath(
        context,
        onError: (_, {bool openSettings = false}) {},
      );
      if (path == null || !mounted) return;

      final profile = await widget.uploadProfilePhoto(path);
      if (!mounted) return;
      setState(() => _photoUrl = profile.photoUrl);
      widget.onPhotoUpdated?.call(profile.photoUrl);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = widget.displayName.trim().isEmpty
        ? AppL10n.cardenceUser(context.l10n)
        : widget.displayName.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ProfileAvatar(
                photoUrl: _photoUrl,
                displayName: displayName,
                size: _avatarSize,
                circular: true,
                onTap: _busy ? null : _pickAndUploadPhoto,
              ),
              if (_busy)
                Container(
                  width: _avatarSize,
                  height: _avatarSize,
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              else
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    elevation: 2,
                    shadowColor: AppColors.primary.withValues(alpha: 0.35),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _pickAndUploadPhoto,
                      child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.35,
              height: 1.15,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          if (widget.email != null && widget.email!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.email!.trim(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
