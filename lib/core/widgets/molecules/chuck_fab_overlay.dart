import 'package:flutter/material.dart';

import '../atoms/chuck_debug_fab.dart';

/// Tüm ekranların üzerinde sağ ortada Chuck debug FAB gösterir.
class ChuckFabOverlay extends StatelessWidget {
  const ChuckFabOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!ChuckDebugFab.isEnabled) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        const Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: Center(
            child: ChuckDebugFab(),
          ),
        ),
      ],
    );
  }
}
