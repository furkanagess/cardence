import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/l10n/api_error_localizer.dart';
import '../../../../core/media/authenticated_image_loader.dart';
import '../../../../core/media/profile_photo_image_picker.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// Onboarding sırasında isteğe bağlı profil fotoğrafı yükleme.
class OnboardingPhotoPicker extends StatelessWidget {
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

  static final _photoPicker = ProfilePhotoImagePicker();

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    final cubit = context.read<OnboardingCubit>();
    if (cubit.state.isPhotoUploading) return;

    cubit.setPhotoUploading(true);
    try {
      final path = await _photoPicker.pickImagePath(
        context,
        onError: (message, {bool openSettings = false}) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
      if (path == null || !context.mounted) return;

      final profile = await uploadProfilePhoto(path);
      if (!context.mounted) return;

      final uploadedPhotoUrl = profile.photoUrl?.trim();
      if (uploadedPhotoUrl != null && uploadedPhotoUrl.isNotEmpty) {
        AuthenticatedImageLoader.evictAllVariants(uploadedPhotoUrl);
      }

      onPhotoUrlChanged(profile.photoUrl);
    } on AuthApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ApiErrorLocalizer.localize(context.l10n, e.message),
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profilePhotoUploadFailed),
        ),
      );
    } finally {
      if (context.mounted) {
        cubit.setPhotoUploading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (previous, current) =>
          previous.isPhotoUploading != current.isPhotoUploading,
      builder: (context, state) {
        final busy = state.isPhotoUploading;
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  width: 6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ProfileAvatar(
                    photoUrl: photoUrl,
                    displayName: displayName,
                    size: 132,
                    circular: true,
                    onTap: busy ? null : () => _pickAndUploadPhoto(context),
                    showEditBadge: !busy,
                  ),
                  if (busy)
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              context.l10n.profilFotorafIsteeBal,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: busy ? null : () => _pickAndUploadPhoto(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.kameraVeyaGaleridenEkleyin,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
