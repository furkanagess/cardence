import 'package:flutter/material.dart';

/// Kartvizit çekimi öncesi uygulama içi kamera izni açıklama diyaloğu.
Future<bool> showCameraPermissionDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final textTheme = Theme.of(dialogContext).textTheme;

      return AlertDialog(
        title: const Text('Kamera izni'),
        content: Text(
          'Kartvizit fotoğrafı çekmek için kameraya erişim gerekiyor. '
          'Devam ettiğinizde izin isteği gösterilir.',
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('İzin ver'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
