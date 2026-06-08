import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/entities/theme_preference.dart';

/// Ayarlar sayfası – tema değişimi ve diğer ayarlar.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    this.onLogout,
  });

  final ThemePreference currentTheme;
  final ValueChanged<ThemePreference> onThemeChanged;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return CardenceScaffold(
      appBar: const CardenceAppBar(
        title: 'Ayarlar',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            value: currentTheme == ThemePreference.light,
            onTap: () => onThemeChanged(ThemePreference.light),
          ),
          _ThemeTile(
            title: 'Koyu tema',
            subtitle: 'Her zaman koyu renk teması',
            value: currentTheme == ThemePreference.dark,
            onTap: () => onThemeChanged(ThemePreference.dark),
          ),
          _ThemeTile(
            title: 'Sistem',
            subtitle: 'Cihaz ayarına göre (açık/koyu)',
            value: currentTheme == ThemePreference.system,
            onTap: () => onThemeChanged(ThemePreference.system),
          ),
          if (onLogout != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Hesap',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Çıkış yap',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Oturumu kapat ve giriş ekranına dön'),
              onTap: onLogout,
            ),
          ],
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
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
