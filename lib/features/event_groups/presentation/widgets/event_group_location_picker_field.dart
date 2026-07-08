import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/location/country_location_data_cache.dart';
import '../../../../core/location/reverse_geocode_location_parser.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/molecules/country_city_picker_field.dart';
import '../../../../core/widgets/molecules/location_picker_text_field_row.dart';
import '../helpers/event_group_location_composer.dart';
import 'event_group_location_map_picker.dart';

/// Ülke · il · ilçe seçimi, harita seçimi ve isteğe bağlı mekan adı.
class EventGroupLocationPickerField extends StatefulWidget {
  const EventGroupLocationPickerField({
    super.key,
    required this.country,
    required this.city,
    required this.venueController,
    this.errorText,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.onVenueChanged,
    this.showComposedPreview = true,
    this.showMapPreview = true,
    this.onMapLocationResolved,
  });

  final String? country;
  final String? city;
  final TextEditingController venueController;
  final String? errorText;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onCityChanged;
  final VoidCallback onVenueChanged;
  final bool showComposedPreview;
  final bool showMapPreview;

  /// Harita seçiminden gelen ülke + il/ilçe + mekan tek seferde güncellenir.
  final void Function({
    String? country,
    String? city,
    String? venue,
  })? onMapLocationResolved;

  @override
  State<EventGroupLocationPickerField> createState() =>
      _EventGroupLocationPickerFieldState();
}

class _EventGroupLocationPickerFieldState
    extends State<EventGroupLocationPickerField> {
  LatLng? _mapPosition;
  bool _resolvingAddress = false;

  @override
  void initState() {
    super.initState();
    _syncMapFromAddress();
  }

  @override
  void didUpdateWidget(EventGroupLocationPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.country != widget.country || oldWidget.city != widget.city) {
      _syncMapFromAddress();
    }
  }

  Future<void> _syncMapFromAddress() async {
    if (!EventGroupLocationComposer.isRegionComplete(
      widget.country,
      widget.city,
    )) {
      return;
    }

    final query = EventGroupLocationComposer.compose(
      venue: widget.venueController.text,
      country: widget.country,
      city: widget.city,
    );
    if (query.trim().isEmpty) return;

    try {
      final geocoding = Geocoding();
      final locations = await geocoding.locationFromAddress(query);
      if (!mounted || locations.isEmpty) return;
      setState(() {
        _mapPosition = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
      });
    } catch (_) {
      // Adres çözümlenemezse varsayılan merkez kullanılır.
    }
  }

  Future<void> _onMapPositionSelected(LatLng position) async {
    final locale = Localizations.localeOf(context);
    setState(() {
      _mapPosition = position;
      _resolvingAddress = true;
    });

    try {
      final countries = await CountryLocationDataCache.ensureLoaded();
      final geocoding = Geocoding(locale: locale);
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted || placemarks.isEmpty) return;

      final parsed = ReverseGeocodeLocationParser.parseBest(
        placemarks,
        countries: countries,
      );

      if (widget.onMapLocationResolved != null) {
        widget.onMapLocationResolved!(
          country: parsed.country,
          city: parsed.city,
          venue: parsed.venue,
        );
      } else {
        if (parsed.country != null) {
          widget.onCountryChanged(parsed.country);
        }
        if (parsed.city != null) {
          widget.onCityChanged(parsed.city);
        }
        if (parsed.venue != null && parsed.venue!.trim().isNotEmpty) {
          widget.venueController.text = parsed.venue!.trim();
          widget.onVenueChanged();
        }
      }
    } catch (_) {
      // Kullanıcı haritadan seçim yaptı; alanlar manuel düzenlenebilir.
    } finally {
      if (mounted) setState(() => _resolvingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showMapPreview) ...[
          EventGroupLocationMapPicker(
            actionLabel: l10n.eventMapUseMyLocation,
            hintLabel: l10n.eventMapDragToSelect,
            initialPosition: _mapPosition,
            onPositionSelected: _onMapPositionSelected,
          ),
          if (_resolvingAddress) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              color: colorScheme.primary,
              backgroundColor:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            ),
          ],
          const SizedBox(height: 16),
        ],
        CountryCityPickerField(
          layout: CountryCityPickerLayout.eventGroup,
          countryLabel: l10n.lke,
          stateLabel: l10n.provinceLabel,
          districtLabel: l10n.districtLabel,
          combinedStateDistrictLabel: l10n.eventLocationProvinceDistrictLabel,
          combinedStateDistrictHint: l10n.eventLocationProvinceDistrictHint,
          country: widget.country,
          city: widget.city,
          onCountryChanged: widget.onCountryChanged,
          onCityChanged: widget.onCityChanged,
        ),
        const SizedBox(height: 14),
        LocationPickerTextFieldRow(
          label: l10n.eventLocationVenueLabel,
          leadingIcon: Icons.apartment_outlined,
          controller: widget.venueController,
          hintText: l10n.eventLocationVenueHint,
          showOptionalBadge: true,
          optionalBadgeLabel: l10n.opsiyonel.toUpperCase(),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onChanged: (_) => widget.onVenueChanged(),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ],
        if (widget.showComposedPreview &&
            EventGroupLocationComposer.isRegionComplete(
              widget.country,
              widget.city,
            )) ...[
          const SizedBox(height: 8),
          Text(
            EventGroupLocationComposer.compose(
              venue: widget.venueController.text,
              country: widget.country,
              city: widget.city,
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
