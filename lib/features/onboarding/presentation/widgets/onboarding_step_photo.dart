import 'package:flutter/material.dart';

import '../../../auth/domain/usecases/upload_profile_photo.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import 'onboarding_card_preview_frame.dart';
import 'onboarding_photo_picker.dart';
import 'onboarding_step_shell.dart';

/// İsteğe bağlı profil fotoğrafı adımı.
class OnboardingStepPhoto extends StatelessWidget {
  const OnboardingStepPhoto({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.uploadProfilePhoto,
    required this.stepIndex,
    required this.stepCount,
  });

  final OnboardingCardDraft draft;
  final ValueChanged<OnboardingCardDraft> onChanged;
  final UploadProfilePhoto uploadProfilePhoto;
  final int stepIndex;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final displayName = draft.displayName?.trim();

    return OnboardingStepShell(
      subtitle: 'Profil fotoğrafınız kartınızda görünür. İsterseniz atlayabilirsiniz.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: OnboardingPhotoPicker(
              displayName: (displayName == null || displayName.isEmpty)
                  ? 'Ad Soyad'
                  : displayName,
              photoUrl: draft.photoUrl,
              uploadProfilePhoto: uploadProfilePhoto,
              onPhotoUrlChanged: (url) =>
                  onChanged(draft.copyWith(photoUrl: url)),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: OnboardingCardPreviewFrame(draft: draft),
          ),
        ],
      ),
    );
  }
}
