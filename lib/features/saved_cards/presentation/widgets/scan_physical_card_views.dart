import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../cubit/scan_physical_card_state.dart';

/// Fiziksel kart tarama — kamera izni gövdesi.
class ScanPhysicalCardPermissionBody extends StatelessWidget {
  const ScanPhysicalCardPermissionBody({
    super.key,
    required this.status,
    required this.onRequest,
    required this.onOpenSettings,
  });

  final ScanCameraPermissionStatus status;
  final VoidCallback onRequest;
  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final canRequestAgain =
        status != ScanCameraPermissionStatus.permanentlyDenied;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 56,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.scanCardPhysicalCameraDenied,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 20),
            if (canRequestAgain) ...[
              CustomButton(
                label: l10n.scanCardQrAllowCamera,
                onPressed: onRequest,
              ),
              const SizedBox(height: 10),
            ],
            CustomButton(
              label: l10n.scanCardOpenPermissions,
              variant: CustomButtonVariant.outlined,
              onPressed: () {
                onOpenSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
