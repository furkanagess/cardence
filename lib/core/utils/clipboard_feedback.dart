import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n_extensions.dart';

/// Kopyalama ikonunun check'e dönmesi için süre.
const Duration kClipboardCopyIconDuration = Duration(seconds: 2);

/// Panoya kopyalar; platform kanalı UI thread'ini bekletmez.
void copyTextToClipboard(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return;
  unawaited(Clipboard.setData(ClipboardData(text: trimmed)));
}

/// Haptic ve isteğe bağlı snackbar — anında çalışır.
void showClipboardCopyFeedback(
  BuildContext context, {
  bool showSnackBar = true,
}) {
  HapticFeedback.lightImpact();
  if (!showSnackBar || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(context.l10n.clipboardCopySuccess),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Panoya kopyalar; haptic + snackbar geri bildirimi verir (UI'ı bloklamaz).
void copyTextWithClipboardFeedback(
  BuildContext context, {
  required String value,
  bool showSnackBar = true,
}) {
  copyTextToClipboard(value);
  if (!context.mounted) return;
  showClipboardCopyFeedback(context, showSnackBar: showSnackBar);
}
