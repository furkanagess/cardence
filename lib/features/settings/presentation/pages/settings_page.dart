import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';
import '../../../auth/presentation/pages/privacy_policy_page.dart';
import '../../domain/entities/theme_preference.dart';
import '../../domain/usecases/request_app_review.dart';
import '../pages/settings_about_page.dart';
import '../widgets/settings_menu_group.dart';
import '../widgets/settings_profile_header.dart';
import '../widgets/settings_section_label.dart';
import '../widgets/settings_theme_selector.dart';

/// Ayarlar sayfası – profil, tema, yardım ve çıkış.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onLogout,
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
  final Future<void> Function() onLogout;
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
  bool _loggingOut = false;

  Future<void> _confirmAndLogout() async {
    if (_loggingOut) return;

    final confirmed = await CardenceConfirmDialog.show(
      context,
      title: 'Çıkış yap',
      message:
          'Oturumunuz kapatılacak ve giriş ekranına yönlendirileceksiniz. Kayıtlı kartlarınız bir sonraki girişinizde yeniden yüklenecektir.',
      confirmLabel: 'Çıkış yap',
      icon: Icons.logout_rounded,
      confirmIsDestructive: true,
    );
    if (!mounted || confirmed != true) return;

    setState(() => _loggingOut = true);
    try {
      await widget.onLogout();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
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
    final opened = await widget.requestAppReview();
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mağaza sayfası açılamadı. Lütfen tekrar deneyin.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayName = widget.userDisplayName?.trim();
    final email = widget.userEmail?.trim();

    return CardenceScaffold(
      appBar: const CardenceAppBar(
        title: 'Ayarlar',
      ),
      body: ColoredBox(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SettingsProfileHeader(
                        displayName: (displayName == null || displayName.isEmpty)
                            ? 'Cardence kullanıcısı'
                            : displayName,
                        email: email,
                        photoUrl: widget.userPhotoUrl,
                        uploadProfilePhoto: widget.uploadProfilePhoto,
                        onPhotoUpdated: widget.onPhotoUpdated,
                      ),
                      const SizedBox(height: 32),
                      const SettingsSectionLabel(
                        label: 'Görünüm',
                        subtitle: 'Uygulama temasını seçin',
                      ),
                      SettingsThemeSelector(
                        current: widget.currentTheme,
                        onChanged: widget.onThemeChanged,
                      ),
                      const SizedBox(height: 28),
                      const SettingsSectionLabel(
                        label: 'Genel',
                        subtitle: 'Destek, gizlilik ve uygulama bilgileri',
                      ),
                      SettingsMenuGroup(
                        items: [
                          SettingsMenuGroupItem(
                            icon: Icons.star_outline_rounded,
                            title: 'Bizi değerlendirin',
                            subtitle: 'App Store veya Play Store\'da puan verin',
                            iconTint: AppColors.warning,
                            onTap: _rateApp,
                          ),
                          SettingsMenuGroupItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Destek ve yardım',
                            subtitle: 'Sorularınız için bize ulaşın',
                            onTap: widget.onOpenSupport,
                          ),
                          SettingsMenuGroupItem(
                            icon: Icons.shield_outlined,
                            title: 'Gizlilik politikası',
                            onTap: _openPrivacyPolicy,
                          ),
                          SettingsMenuGroupItem(
                            icon: Icons.info_outline_rounded,
                            title: 'Hakkında',
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
            _SettingsLogoutBar(
              isLoading: _loggingOut,
              onPressed: _confirmAndLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsLogoutBar extends StatelessWidget {
  const _SettingsLogoutBar({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.outlineDark.withValues(alpha: 0.45)
                : AppColors.outlineVariant.withValues(alpha: 0.9),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: CustomButton(
            label: 'Çıkış yap',
            icon: Icons.logout_rounded,
            isLoading: isLoading,
            enabled: !isLoading,
            onPressed: onPressed,
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
        ),
      ),
    );
  }
}
