import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';

/// Paylaşılan harita yüzeyi — sabit orta marker, harita kaydırılarak seçim.
class EventGroupLocationMapCanvas extends StatelessWidget {
  const EventGroupLocationMapCanvas({
    super.key,
    required this.mapController,
    required this.initialCenter,
    required this.hintLabel,
    this.onCenterChanged,
    this.onCenterSettled,
  });

  final MapController mapController;
  final LatLng initialCenter;
  final String hintLabel;
  final ValueChanged<LatLng>? onCenterChanged;
  final ValueChanged<LatLng>? onCenterSettled;

  static const LatLng defaultCenter = LatLng(41.0082, 28.9784);

  bool _isSettledEvent(MapEvent event) {
    return event is MapEventMoveEnd ||
        event is MapEventFlingAnimationEnd ||
        event is MapEventDoubleTapZoomEnd;
  }

  bool _isMovingEvent(MapEvent event) {
    return event is MapEventMove ||
        event is MapEventFlingAnimation ||
        event is MapEventScrollWheelZoom ||
        event is MapEventDoubleTapZoom;
  }

  void _handleMapEvent(MapEvent event) {
    final center = event.camera.center;
    if (_isMovingEvent(event)) {
      onCenterChanged?.call(center);
    }
    if (_isSettledEvent(event)) {
      onCenterSettled?.call(center);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.outlineDark.withValues(alpha: 0.35)
        : AppColors.outlineVariant.withValues(alpha: 0.85);

    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onMapEvent: _handleMapEvent,
            onMapReady: () {
              final center = mapController.camera.center;
              onCenterChanged?.call(center);
              onCenterSettled?.call(center);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.furkanages.cardenceapp',
            ),
          ],
        ),
        IgnorePointer(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.location_on_rounded,
                size: 40,
                color: AppColors.primary,
                shadows: [
                  Shadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.25),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                hintLabel,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
