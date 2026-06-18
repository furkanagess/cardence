import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// E-posta ve telefon için harici uygulama açma.
class ContactLauncher {
  ContactLauncher._();

  static Future<void> launchEmail(BuildContext context, String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;

    final uri = Uri(scheme: 'mailto', path: trimmed);
    if (!await launchUrl(uri)) {
      if (!context.mounted) return;
      _showError(context, 'E-posta uygulaması açılamadı');
    }
  }

  static Future<void> launchPhone(BuildContext context, String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return;

    final dial = trimmed.replaceAll(RegExp(r'[^\d+]'), '');
    if (dial.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: dial);
    if (!await launchUrl(uri)) {
      if (!context.mounted) return;
      _showError(context, 'Telefon uygulaması açılamadı');
    }
  }

  static Future<void> launchWebUrl(BuildContext context, String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    final normalized = trimmed.startsWith(RegExp(r'https?://'))
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(normalized);
    if (uri == null) return;

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      _showError(context, 'Bağlantı açılamadı');
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
