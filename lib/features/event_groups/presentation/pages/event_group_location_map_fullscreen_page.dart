import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../widgets/event_group_location_map_canvas.dart';

/// Tam ekran haritadan konum seçimi.
class EventGroupLocationMapFullscreenPage extends StatefulWidget {
  const EventGroupLocationMapFullscreenPage({
    super.key,
    this.initialPosition,
    this.onCenterSettled,
  });

  final LatLng? initialPosition;
  final ValueChanged<LatLng>? onCenterSettled;

  static Future<LatLng?> show(
    BuildContext context, {
    LatLng? initialPosition,
    ValueChanged<LatLng>? onCenterSettled,
  }) {
    return Navigator.of(context).push<LatLng>(
      MaterialPageRoute<LatLng>(
        fullscreenDialog: true,
        builder: (_) => EventGroupLocationMapFullscreenPage(
          initialPosition: initialPosition,
          onCenterSettled: onCenterSettled,
        ),
      ),
    );
  }

  @override
  State<EventGroupLocationMapFullscreenPage> createState() =>
      _EventGroupLocationMapFullscreenPageState();
}

class _EventGroupLocationMapFullscreenPageState
    extends State<EventGroupLocationMapFullscreenPage> {
  late final MapController _mapController;
  LatLng? _centerPosition;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _centerPosition = widget.initialPosition;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = widget.initialPosition;
      if (target != null) _centerOn(target);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  LatLng get _currentCenter =>
      _centerPosition ?? _mapController.camera.center;

  void _centerOn(LatLng target) {
    if (!mounted) return;
    final zoom = _mapController.camera.zoom;
    _mapController.move(target, zoom < 11 ? 13 : zoom);
    setState(() => _centerPosition = target);
  }

  void _handleCenterChanged(LatLng center) {
    setState(() => _centerPosition = center);
  }

  void _handleCenterSettled(LatLng center) {
    setState(() => _centerPosition = center);
    widget.onCenterSettled?.call(center);
  }

  Future<void> _handleMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final position = await _resolveCurrentPosition();
      if (!mounted || position == null) return;
      _centerOn(position);
      widget.onCenterSettled?.call(position);
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

  void _close() {
    Navigator.of(context).pop(_currentCenter);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final initialCenter = widget.initialPosition ??
        _centerPosition ??
        EventGroupLocationMapCanvas.defaultCenter;

    return CardenceScaffold(
      resizeToAvoidBottomInset: false,
      appBar: CardenceAppBar(
        title: l10n.eventMapSelectLocation,
        leading: CardenceAppBar.iconAction(
          icon: Icons.close_rounded,
          tooltip: l10n.kapat,
          onPressed: _close,
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: EventGroupLocationMapCanvas(
              mapController: _mapController,
              initialCenter: initialCenter,
              hintLabel: l10n.eventMapDragToSelect,
              onCenterChanged: _handleCenterChanged,
              onCenterSettled: _handleCenterSettled,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: Row(
              children: [
                Material(
                  color: colorScheme.surface,
                  elevation: 3,
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
                        horizontal: 14,
                        vertical: 10,
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
                              size: 18,
                              color: AppColors.primary,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.eventMapUseMyLocation,
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _close,
                  child: Text(l10n.tamam),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
