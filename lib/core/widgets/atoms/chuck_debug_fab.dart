import 'package:flutter/material.dart';

import '../../config/app_env.dart';
import '../../network/interceptors/chuck_interceptor_service.dart';

/// Chuck HTTP inspector kısayolu (sağ kenar FAB).
class ChuckDebugFab extends StatelessWidget {
  const ChuckDebugFab({super.key});

  static bool get isEnabled => AppEnv.isChuckEnabled;

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 6,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      color: colorScheme.primary,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: ChuckInterceptorService.instance.showInspector,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.bug_report_outlined,
            color: colorScheme.onPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
