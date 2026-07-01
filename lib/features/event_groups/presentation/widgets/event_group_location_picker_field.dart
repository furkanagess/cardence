import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/country_city_picker_field.dart';
import '../helpers/event_group_location_composer.dart';

/// Ülke · il · ilçe seçimi ve isteğe bağlı mekan adı.
class EventGroupLocationPickerField extends StatelessWidget {
  const EventGroupLocationPickerField({
    super.key,
    required this.country,
    required this.city,
    required this.venueController,
    this.errorText,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.onVenueChanged,
  });

  final String? country;
  final String? city;
  final TextEditingController venueController;
  final String? errorText;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onCityChanged;
  final VoidCallback onVenueChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CountryCityPickerField(
          countryLabel: context.l10n.lke,
          stateLabel: context.l10n.provinceLabel,
          districtLabel: context.l10n.districtLabel,
          country: country,
          city: city,
          onCountryChanged: onCountryChanged,
          onCityChanged: onCityChanged,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
        const SizedBox(height: 14),
        CustomTextField(
          controller: venueController,
          labelText: context.l10n.eventLocationVenueLabel,
          hintText: context.l10n.eventLocationVenueHint,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => onVenueChanged(),
        ),
        const SizedBox(height: 8),
        if (EventGroupLocationComposer.isRegionComplete(country, city))
          Text(
            EventGroupLocationComposer.compose(
              venue: venueController.text,
              country: country,
              city: city,
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
      ],
    );
  }
}
