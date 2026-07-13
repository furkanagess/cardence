import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/event_group_location_map_fullscreen_page.dart';
import 'event_group_location_map_canvas.dart';

/// Haritadan konum seçimi (önizleme + tam ekran).
class EventGroupLocationMapPicker extends StatefulWidget {
  const EventGroupLocationMapPicker({
    super.key,
    required this.actionLabel,
    required this.hintLabel,
    this.initialPosition,
    this.onPositionSelected,
  });

  final String actionLabel;
  final String hintLabel;
  final LatLng? initialPosition;
  final ValueChanged<LatLng>? onPositionSelected;

  @override
  State<EventGroupLocationMapPicker> createState() =>
      _EventGroupLocationMapPickerState();
}

class _EventGroupLocationMapPickerState extends State<EventGroupLocationMapPicker> {
  late final MapController _mapController;
  LatLng? _centerPosition;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _centerPosition = widget.initialPosition;
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnInitial());
  }

  @override
  void didUpdateWidget(EventGroupLocationMapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPosition != widget.initialPosition &&
        widget.initialPosition != null) {
      _centerPosition = widget.initialPosition;
      _centerOn(widget.initialPosition!);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnInitial() {
    final target = widget.initialPosition ?? _centerPosition;
    if (target != null) {
      _centerOn(target);
    }
  }

  void _centerOn(LatLng target) {
    if (!mounted) return;
    final zoom = _mapController.camera.zoom;
    _mapController.move(target, zoom < 11 ? 13 : zoom);
    setState(() => _centerPosition = target);
  }

  Future<void> _openFullscreen() async {
    final result = await EventGroupLocationMapFullscreenPage.show(
      context,
      initialPosition: _centerPosition ?? widget.initialPosition,
      onCenterSettled: widget.onPositionSelected,
    );
    if (!mounted || result == null) return;
    setState(() => _centerPosition = result);
    _centerOn(result);
    widget.onPositionSelected?.call(result);
  }

  Future<void> _handleMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final position = await _resolveCurrentPosition();
      if (!mounted || position == null) return;
      _centerOn(position);
      widget.onPositionSelected?.call(position);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<LatLng?> _resolveCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.outlineDark.withValues(alpha: 0.35)
        : AppColors.outlineVariant.withValues(alpha: 0.85);
    final initialCenter = widget.initialPosition ??
        _centerPosition ??
        EventGroupLocationMapCanvas.defaultCenter;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 196,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: EventGroupLocationMapCanvas(
                  mapController: _mapController,
                  initialCenter: initialCenter,
                  hintLabel: widget.hintLabel,
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openFullscreen,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Tooltip(
                  message: l10n.eventMapOpenFullscreen,
                  child: Material(
                    color: colorScheme.surface,
                    elevation: 2,
                    shadowColor: AppColors.appBarShadowColor(
                      Theme.of(context).brightness,
                    ),
                    surfaceTintColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: _openFullscreen,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.fullscreen_rounded,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Material(
                  color: colorScheme.surface,
                  elevation: 2,
                  shadowColor: AppColors.appBarShadowColor(
                    Theme.of(context).brightness,
                  ),
                  surfaceTintColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: _locating ? null : _handleMyLocation,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_locating)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          else
                            Icon(
                              Icons.my_location_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            widget.actionLabel,
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
