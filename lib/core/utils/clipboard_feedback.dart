import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n_extensions.dart';

/// Kopyalama ikonunun check'e dönmesi için süre.
const Duration kClipboardCopyIconDuration = Duration(seconds: 2);

/// Panoya kopyalar; haptic + snackbar geri bildirimi verir.
Future<void> copyTextWithClipboardFeedback(
  BuildContext context, {
  required String value,
}) async {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return;

  await Clipboard.setData(ClipboardData(text: trimmed));
  if (!context.mounted) return;
  HapticFeedback.lightImpact();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(context.l10n.clipboardCopySuccess)),
  );
}
