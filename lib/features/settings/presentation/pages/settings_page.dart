import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/api_error_localizer.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/network/auth_api_exception.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
import '../../../../core/widgets/molecules/cardence_error_dialog.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';
import '../../../auth/presentation/pages/privacy_policy_page.dart';
import '../../domain/entities/locale_preference.dart';
import '../../domain/entities/theme_preference.dart';
import '../../domain/usecases/request_app_review.dart';
import '../pages/settings_about_page.dart';
import '../widgets/settings_appearance_panel.dart';
import '../widgets/settings_menu_group.dart';
import '../widgets/settings_profile_header.dart';
import '../widgets/settings_section_label.dart';

/// Ayarlar sayfası – profil, tema, yardım, hesap silme ve çıkış.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onOpenSupport,
    required this.requestAppReview,
    required this.uploadProfilePhoto,
    this.userDisplayName,
    this.userEmail,
    this.userPhotoUrl,
    this.onPhotoUpdated,
  });

  final ThemePreference currentTheme;
  final ValueChanged<ThemePreference> onThemeChanged;
  final LocalePreference currentLocale;
  final ValueChanged<LocalePreference> onLocaleChanged;
  final Future<void> Function() onLogout;
  final Future<void> Function() onDeleteAccount;
  final VoidCallback onOpenSupport;
  final RequestAppReview requestAppReview;
  final UploadProfilePhoto uploadProfilePhoto;
  final String? userDisplayName;
  final String? userEmail;
  final String? userPhotoUrl;
  final ValueChanged<String?>? onPhotoUpdated;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _busy = false;

  Future<void> _confirmAndLogout() async {
    if (_busy) return;

    final confirmed = await CardenceConfirmDialog.show(
      context,
      title: context.l10n.kYap,
      message: context.l10n.oturumunuzKapatlacakVeGiriEkranna,
      confirmLabel: context.l10n.kYap,
      icon: Icons.logout_rounded,
      confirmIsDestructive: true,
    );
    if (!mounted || confirmed != true) return;

    setState(() => _busy = true);
    try {
      await widget.onLogout();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmAndDeleteAccount() async {
    if (_busy) return;

    final confirmed = await CardenceConfirmDialog.show(
      context,
      title: context.l10n.deleteAccountTitle,
      message: context.l10n.deleteAccountConfirmMessage,
      confirmLabel: context.l10n.deleteAccountConfirmAction,
      icon: Icons.delete_forever_rounded,
      confirmIsDestructive: true,
    );
    if (!mounted || confirmed != true) return;

    setState(() => _busy = true);
    try {
      await widget.onDeleteAccount();
    } on AuthApiException catch (e) {
      if (!mounted) return;
      await CardenceErrorDialog.show(
        context,
        title: context.l10n.operationFailed,
        message: ApiErrorLocalizer.localize(context.l10n, e.message),
      );
    } catch (_) {
      if (!mounted) return;
      await CardenceErrorDialog.show(
        context,
        title: context.l10n.operationFailed,
        message: context.l10n.deleteAccountFailed,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PrivacyPolicyPage(),
      ),
    );
  }

  void _openAbout() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SettingsAboutPage(),
      ),
    );
  }

  Future<void> _rateApp() async {
    await widget.requestAppReview();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.userDisplayName?.trim();
    final email = widget.userEmail?.trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CardenceScaffold(
      appBar: CardenceAppBar(
        title: context.l10n.ayarlar,
      ),
      body: ColoredBox(
        color: isDark
            ? AppColors.settingsScreenBackgroundDark
            : AppColors.settingsScreenBackgroundLight,
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SettingsProfileHeader(
                        displayName: (displayName == null || displayName.isEmpty)
                            ? AppL10n.cardenceUser(context.l10n)
                            : displayName,
                        email: email,
                        photoUrl: widget.userPhotoUrl,
                        uploadProfilePhoto: widget.uploadProfilePhoto,
                        onPhotoUpdated: widget.onPhotoUpdated,
                      ),
                      const SizedBox(height: 20),
                      SettingsSectionLabel(label: context.l10n.grnm),
                      SettingsAppearancePanel(
                        currentTheme: widget.currentTheme,
                        onThemeChanged: widget.onThemeChanged,
                        currentLocale: widget.currentLocale,
                        onLocaleChanged: widget.onLocaleChanged,
                      ),
                      const SizedBox(height: 24),
                      SettingsSectionLabel(
                        label: context.l10n.genel,
                        subtitle: context.l10n.destekGizlilikVeUygulamaBilgileri,
                      ),
                      SettingsMenuGroup(
                        items: [
                          SettingsMenuGroupItem(
                            icon: Icons.star_outline_rounded,
                            title: context.l10n.biziDeerlendirin,
                            subtitle: context.l10n.rateOnAppStore,
                            onTap: _rateApp,
                          ),
                          SettingsMenuGroupItem(
                            icon: Icons.help_outline_rounded,
                            title: context.l10n.destekVeYardm,
                            onTap: widget.onOpenSupport,
                          ),
                          SettingsMenuGroupItem(
                            icon: Icons.shield_outlined,
                            title: context.l10n.gizlilikPolitikas2,
                            onTap: _openPrivacyPolicy,
                          ),
                          SettingsMenuGroupItem(
                            icon: Icons.info_outline_rounded,
                            title: context.l10n.hakknda,
                            subtitle:
                                '${AppConstants.appName} v${AppConstants.appVersion}',
                            onTap: _openAbout,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _SettingsAccountActionsBar(
              isLoading: _busy,
              onDeleteAccount: _confirmAndDeleteAccount,
              onLogout: _confirmAndLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsAccountActionsBar extends StatelessWidget {
  const _SettingsAccountActionsBar({
    required this.isLoading,
    required this.onDeleteAccount,
    required this.onLogout,
  });

  final bool isLoading;
  final VoidCallback onDeleteAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.outlineDark.withValues(alpha: 0.4)
                : AppColors.outlineVariant.withValues(alpha: 0.9),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomButton.outlined(
                label: context.l10n.deleteAccountTitle,
                icon: Icons.delete_forever_rounded,
                enabled: !isLoading,
                onPressed: isLoading ? null : onDeleteAccount,
                height: 52,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.55),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: context.l10n.kYap,
                icon: Icons.logout_rounded,
                isLoading: isLoading,
                enabled: !isLoading,
                onPressed: onLogout,
                height: 52,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textOnPrimary,
                  disabledBackgroundColor:
                      AppColors.error.withValues(alpha: 0.45),
                  disabledForegroundColor:
                      AppColors.textOnPrimary.withValues(alpha: 0.75),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
