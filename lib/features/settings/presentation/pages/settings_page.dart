import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';
import '../../domain/entities/theme_preference.dart';
import '../widgets/settings_menu_tile.dart';
import '../widgets/settings_profile_header.dart';
import '../widgets/settings_theme_selector.dart';

/// Ayarlar sayfası – tema, destek ve çıkış.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onLogout,
    required this.onOpenSupport,
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayName = widget.userDisplayName?.trim();
    final email = widget.userEmail?.trim();

    return CardenceScaffold(
      appBar: const CardenceAppBar(
        title: 'Ayarlar',
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
            const SizedBox(height: 24),
            Text(
              'Görünüm',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SettingsThemeSelector(
              current: widget.currentTheme,
              onChanged: widget.onThemeChanged,
            ),
            const SizedBox(height: 24),
            Text(
              'Yardım',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SettingsMenuTile(
              icon: Icons.support_agent_rounded,
              title: 'Destek',
              subtitle: 'Sorun bildir veya öneri gönder',
              onTap: widget.onOpenSupport,
            ),
            const Spacer(),
            SafeArea(
              top: false,
              child: CustomButton(
                label: 'Çıkış yap',
                icon: Icons.logout_rounded,
                isLoading: _loggingOut,
                enabled: !_loggingOut,
                onPressed: _confirmAndLogout,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
