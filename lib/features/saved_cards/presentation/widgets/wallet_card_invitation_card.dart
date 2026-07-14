import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../domain/entities/wallet_card_invitation.dart';

class WalletCardInvitationCard extends StatelessWidget {
  const WalletCardInvitationCard({
    super.key,
    required this.invitation,
    required this.onAccept,
    required this.onReject,
    this.isResponding = false,
    this.canAccept = true,
  });

  final WalletCardInvitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isResponding;
  final bool canAccept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    final title = invitation.proposedCardTitle?.trim();
    final company = invitation.proposedCardCompany?.trim();
    final subtitleParts = <String>[
      if (title != null && title.isNotEmpty) title,
      if (company != null && company.isNotEmpty) company,
    ];

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark
              ? AppColors.outlineDark.withValues(alpha: 0.35)
              : AppColors.outlineVariant.withValues(alpha: 0.85),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileAvatar(
                  photoUrl: invitation.proposedCardPhotoUrl ??
                      invitation.inviterPhotoUrl,
                  displayName: invitation.displayCardName,
                  size: 56,
                  circular: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.displayCardName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.walletCardInvitationAddedYou(invitation.inviterName),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitleParts.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitleParts.join(' · '),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.walletCardInvitationPrompt(invitation.inviterName),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.35,
              ),
            ),
            if (!canAccept) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    l10n.walletCardInvitationQuotaFull,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: l10n.walletCardInvitationReject,
                    onPressed: isResponding ? null : onReject,
                    variant: CustomButtonVariant.outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    label: canAccept
                        ? l10n.walletCardInvitationAccept
                        : l10n.walletCardInvitationUpgradeToAccept,
                    onPressed: isResponding ? null : onAccept,
                    isLoading: isResponding,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
