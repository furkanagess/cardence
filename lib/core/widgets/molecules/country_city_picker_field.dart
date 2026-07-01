import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/location/country_location_data_cache.dart';

import 'package:csc_picker/dropdown_with_search.dart';
import 'package:csc_picker/model/select_status_model.dart';
import 'package:flutter/material.dart';

/// Ülke, il ve ilçe seçimi; formdaki diğer alanlarla aynı görünümde.
class CountryCityPickerField extends StatefulWidget {
  const CountryCityPickerField({
    super.key,
    required this.countryLabel,
    required this.stateLabel,
    required this.districtLabel,
    this.country,
    this.city,
    required this.onCountryChanged,
    required this.onCityChanged,
  });

  final String countryLabel;
  final String stateLabel;
  final String districtLabel;
  final String? country;
  final String? city;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onCityChanged;

  @override
  State<CountryCityPickerField> createState() => _CountryCityPickerFieldState();
}

class _CountryCityPickerFieldState extends State<CountryCityPickerField> {
  final List<String> _countryOptions = [];
  final List<String> _stateOptions = [];
  final List<String> _districtOptions = [];
  List<Country> _countries = [];

  String? _selectedCountryLabel;
  String? _selectedState;
  String? _selectedDistrict;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(CountryCityPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.country != widget.country ||
        oldWidget.city != widget.city) {
      _syncFromWidget();
    }
  }

  Future<void> _bootstrap() async {
    _countries = await CountryLocationDataCache.ensureLoaded();

    _countryOptions
      ..clear()
      ..addAll(
        _countries.map((country) => _countryLabel(country)),
      );

    _syncFromWidget();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _syncFromWidget() {
    if (_countries.isEmpty) return;

    final parsedCity = _parseCity(widget.city);
    _selectedCountryLabel = _findCountryLabel(widget.country);
    _reloadStates(keepSelection: false);

    if (parsedCity.state != null &&
        _stateOptions.contains(parsedCity.state)) {
      _selectedState = parsedCity.state;
      _reloadDistricts(keepSelection: false);
      if (parsedCity.district != null &&
          _districtOptions.contains(parsedCity.district)) {
        _selectedDistrict = parsedCity.district;
      } else {
        _selectedDistrict = null;
      }
    } else {
      _selectedState = null;
      _selectedDistrict = null;
      _districtOptions.clear();
    }
  }

  String _countryLabel(Country country) =>
      '${country.emoji}    ${country.name}';

  String? _cleanCountryName(String? label) {
    if (label == null || label.trim().isEmpty) return null;
    if (label.contains('    ')) {
      return label.split('    ').last.trim();
    }
    return label.trim();
  }

  String? _findCountryLabel(String? countryName) {
    if (countryName == null || countryName.trim().isEmpty) return null;
    final normalized = countryName.trim().toLowerCase();
    for (final country in _countries) {
      if (country.name?.toLowerCase() == normalized) {
        return _countryLabel(country);
      }
    }
    return null;
  }

  Country? _selectedCountryModel() {
    final label = _selectedCountryLabel;
    if (label == null) return null;
    final name = _cleanCountryName(label)?.toLowerCase();
    if (name == null) return null;
    for (final country in _countries) {
      if (country.name?.toLowerCase() == name) return country;
    }
    return null;
  }

  void _reloadStates({required bool keepSelection}) {
    _stateOptions.clear();
    final country = _selectedCountryModel();
    if (country?.state == null) return;

    final states = country!.state!
        .map((region) => region.name)
        .whereType<String>()
        .toList()
      ..sort();
    _stateOptions.addAll(states);

    if (!keepSelection ||
        _selectedState == null ||
        !_stateOptions.contains(_selectedState)) {
      _selectedState = null;
      _selectedDistrict = null;
      _districtOptions.clear();
    }
  }

  void _reloadDistricts({required bool keepSelection}) {
    _districtOptions.clear();
    final country = _selectedCountryModel();
    if (country?.state == null || _selectedState == null) return;

    final region = country!.state!.firstWhere(
      (item) => item.name == _selectedState,
      orElse: () => Region(),
    );
    if (region.city == null) return;

    final districts = region.city!
        .map((city) => city.name)
        .whereType<String>()
        .toList()
      ..sort();
    _districtOptions.addAll(districts);

    if (!keepSelection ||
        _selectedDistrict == null ||
        !_districtOptions.contains(_selectedDistrict)) {
      _selectedDistrict = null;
    }
  }

  String? _composeCityValue() {
    if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
      if (_selectedState != null && _selectedDistrict != _selectedState) {
        return '${_selectedDistrict!.trim()}, ${_selectedState!.trim()}';
      }
      return _selectedDistrict!.trim();
    }
    if (_selectedState != null && _selectedState!.isNotEmpty) {
      return _selectedState!.trim();
    }
    return null;
  }

  ({String? state, String? district}) _parseCity(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return (state: null, district: null);
    }
    final parts = raw.split(',').map((part) => part.trim()).toList();
    if (parts.length >= 2) {
      return (state: parts.last, district: parts.first);
    }
    return (state: parts.first, district: null);
  }

  InputDecoration _fieldDecoration(
    ColorScheme colorScheme, {
    required String label,
    required bool enabled,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabled: enabled,
      suffixIcon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: enabled
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurface.withValues(alpha: 0.38),
      ),
    );
  }

  Future<void> _openPicker({
    required String title,
    required String placeholder,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) async {
    if (items.isEmpty) return;
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SearchDialog(
        title: title,
        placeHolder: placeholder,
        items: items,
        dialogRadius: 16,
        searchInputRadius: 10,
      ),
    );
    if (picked == null || !mounted) return;
    onSelected(picked);
  }

  void _onCountryPicked(String label) {
    setState(() {
      _selectedCountryLabel = label;
      _selectedState = null;
      _selectedDistrict = null;
      _reloadStates(keepSelection: false);
    });
    widget.onCountryChanged(_cleanCountryName(label));
    widget.onCityChanged(null);
  }

  void _onStatePicked(String state) {
    setState(() {
      _selectedState = state;
      _selectedDistrict = null;
      _reloadDistricts(keepSelection: false);
    });
    widget.onCityChanged(_composeCityValue());
  }

  void _onDistrictPicked(String district) {
    setState(() => _selectedDistrict = district);
    widget.onCityChanged(_composeCityValue());
  }

  Widget _buildPickerField({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String label,
    required String? value,
    required bool enabled,
    required VoidCallback? onTap,
  }) {
    final hasValue = value != null && value.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          isEmpty: !hasValue,
          decoration: _fieldDecoration(
            colorScheme,
            label: label,
            enabled: enabled,
          ),
          child: Text(
            hasValue ? value : '',
            style: textTheme.bodyLarge?.copyWith(
              color: hasValue
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: LinearProgressIndicator(
          color: colorScheme.primary,
          backgroundColor:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        ),
      );
    }

    final countryEnabled = _countryOptions.isNotEmpty;
    final stateEnabled =
        _selectedCountryLabel != null && _stateOptions.isNotEmpty;
    final districtEnabled = _selectedState != null && _districtOptions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPickerField(
          colorScheme: colorScheme,
          textTheme: textTheme,
          label: widget.countryLabel,
          value: _cleanCountryName(_selectedCountryLabel),
          enabled: countryEnabled,
          onTap: () => _openPicker(
            title: widget.countryLabel,
            placeholder: context.l10n.lkeAra,
            items: _countryOptions,
            onSelected: _onCountryPicked,
          ),
        ),
        _buildPickerField(
          colorScheme: colorScheme,
          textTheme: textTheme,
          label: widget.stateLabel,
          value: _selectedState,
          enabled: stateEnabled,
          onTap: () => _openPicker(
            title: widget.stateLabel,
            placeholder: context.l10n.ilAra,
            items: _stateOptions,
            onSelected: _onStatePicked,
          ),
        ),
        _buildPickerField(
          colorScheme: colorScheme,
          textTheme: textTheme,
          label: widget.districtLabel,
          value: _selectedDistrict,
          enabled: districtEnabled,
          onTap: () => _openPicker(
            title: widget.districtLabel,
            placeholder: context.l10n.ileAra,
            items: _districtOptions,
            onSelected: _onDistrictPicked,
          ),
        ),
      ],
    );
  }
}
