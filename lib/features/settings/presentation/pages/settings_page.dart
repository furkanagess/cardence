import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/entities/theme_preference.dart';

/// Ayarlar sayfası – tema değişimi ve çıkış.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onLogout,
  });

  final ThemePreference currentTheme;
  final ValueChanged<ThemePreference> onThemeChanged;
  final Future<void> Function() onLogout;

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
    return CardenceScaffold(
      appBar: const CardenceAppBar(
        title: 'Ayarlar',
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Görünüm',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                _ThemeTile(
                  title: 'Açık tema',
                  subtitle: 'Her zaman açık renk teması',
                  value: widget.currentTheme == ThemePreference.light,
                  onTap: () => widget.onThemeChanged(ThemePreference.light),
                ),
                _ThemeTile(
                  title: 'Koyu tema',
                  subtitle: 'Her zaman koyu renk teması',
                  value: widget.currentTheme == ThemePreference.dark,
                  onTap: () => widget.onThemeChanged(ThemePreference.dark),
                ),
                _ThemeTile(
                  title: 'Sistem',
                  subtitle: 'Cihaz ayarına göre (açık/koyu)',
                  value: widget.currentTheme == ThemePreference.system,
                  onTap: () => widget.onThemeChanged(ThemePreference.system),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: value
          ? Icon(Icons.check_circle,
              color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
