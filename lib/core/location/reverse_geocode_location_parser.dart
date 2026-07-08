import 'package:csc_picker/model/select_status_model.dart';
import 'package:geocoding/geocoding.dart';

/// Harita pininden gelen [Placemark] verisini etkinlik konum alanlarına çevirir.
class ReverseGeocodeLocationParser {
  ReverseGeocodeLocationParser._();

  static const _countryAliases = <String, String>{
    'türkiye': 'Turkey',
    'turkiye': 'Turkey',
    'turkey': 'Turkey',
    'united states': 'United States',
    'united states of america': 'United States',
    'usa': 'United States',
    'united kingdom': 'United Kingdom',
    'uk': 'United Kingdom',
    'deutschland': 'Germany',
    'germany': 'Germany',
  };

  /// İlk eşleşen veya en iyi sonucu döndürür.
  static ParsedMapLocation parseBest(
    List<Placemark> placemarks, {
    required List<Country> countries,
  }) {
    ParsedMapLocation? fallback;
    for (final placemark in placemarks) {
      final parsed = parse(placemark, countries: countries);
      fallback ??= parsed;
      if (parsed.hasRegion) return parsed;
    }
    return fallback ??
        const ParsedMapLocation(country: null, city: null, venue: null);
  }

  static ParsedMapLocation parse(
    Placemark placemark, {
    required List<Country> countries,
  }) {
    final countryModel = _resolveCountryModel(placemark, countries);
    final countryName = countryModel?.name ?? _resolveCountryName(placemark, countries);

    final stateCandidates = _uniqueNonEmpty([
      placemark.administrativeArea,
      placemark.subAdministrativeArea,
    ]);
    final districtCandidates = _uniqueNonEmpty([
      placemark.subLocality,
      placemark.locality,
      if (placemark.subAdministrativeArea != placemark.administrativeArea)
        placemark.subAdministrativeArea,
      placemark.name,
    ]);

    final matched = _matchStateAndDistrict(
      country: countryModel,
      stateCandidates: stateCandidates,
      districtCandidates: districtCandidates,
    );

    final city = _composeCity(
      state: matched.state,
      district: matched.district,
      stateCandidates: stateCandidates,
      districtCandidates: districtCandidates,
    );

    final venue = _firstNonEmpty([
      placemark.name,
      _joinNonEmpty([placemark.thoroughfare, placemark.subThoroughfare]),
      placemark.street,
    ]);

    return ParsedMapLocation(
      country: countryName,
      city: city,
      venue: venue,
    );
  }

  static Country? _resolveCountryModel(
    Placemark placemark,
    List<Country> countries,
  ) {
    final iso = placemark.isoCountryCode?.trim().toUpperCase();
    if (iso != null && iso.isNotEmpty) {
      for (final country in countries) {
        if (country.iso2?.toUpperCase() == iso) return country;
      }
    }

    final name = _resolveCountryName(placemark, countries);
    if (name == null) return null;
    for (final country in countries) {
      if (country.name == name) return country;
    }
    return null;
  }

  static String? _resolveCountryName(
    Placemark placemark,
    List<Country> countries,
  ) {
    final rawCountry = placemark.country?.trim();
    if (rawCountry == null || rawCountry.isEmpty) return null;

    final normalized = rawCountry.toLowerCase();
    final alias = _countryAliases[normalized];
    final target = alias ?? rawCountry;

    for (final country in countries) {
      final name = country.name?.trim();
      if (name == null || name.isEmpty) continue;
      if (_normalize(name) == _normalize(target)) return name;
      if (_normalize(name) == _normalize(normalized)) return name;
    }

    return target;
  }

  static ({String? state, String? district}) _matchStateAndDistrict({
    required Country? country,
    required List<String> stateCandidates,
    required List<String> districtCandidates,
  }) {
    if (country?.state == null || country!.state!.isEmpty) {
      return (
        state: stateCandidates.isNotEmpty ? stateCandidates.first : null,
        district: districtCandidates.isNotEmpty ? districtCandidates.first : null,
      );
    }

    final stateNames = country.state!
        .map((region) => region.name)
        .whereType<String>()
        .toList();

    final matchedState = _matchName(stateCandidates, stateNames);
    if (matchedState == null) {
      return (
        state: stateCandidates.isNotEmpty ? stateCandidates.first : null,
        district: districtCandidates.isNotEmpty ? districtCandidates.first : null,
      );
    }

    final region = country.state!.firstWhere(
      (item) => item.name == matchedState,
      orElse: () => Region(),
    );

    final districtNames = region.city
            ?.map((city) => city.name)
            .whereType<String>()
            .toList() ??
        [];

    final matchedDistrict = _matchName(districtCandidates, districtNames);

    return (state: matchedState, district: matchedDistrict);
  }

  static String? _composeCity({
    required String? state,
    required String? district,
    required List<String> stateCandidates,
    required List<String> districtCandidates,
  }) {
    final resolvedState = state ?? (stateCandidates.isNotEmpty ? stateCandidates.first : null);
    final resolvedDistrict =
        district ?? (districtCandidates.isNotEmpty ? districtCandidates.first : null);

    if (resolvedDistrict != null &&
        resolvedState != null &&
        _normalize(resolvedDistrict) != _normalize(resolvedState)) {
      return '${resolvedDistrict.trim()}, ${resolvedState.trim()}';
    }
    if (resolvedDistrict != null && resolvedDistrict.isNotEmpty) {
      return resolvedDistrict.trim();
    }
    if (resolvedState != null && resolvedState.isNotEmpty) {
      return resolvedState.trim();
    }
    return null;
  }

  static String? _matchName(List<String> candidates, List<String> options) {
    if (options.isEmpty) return null;

    for (final candidate in candidates) {
      final exact = options.where(
        (option) => _normalize(option) == _normalize(candidate),
      );
      if (exact.isNotEmpty) return exact.first;
    }

    for (final candidate in candidates) {
      final normalizedCandidate = _normalize(candidate);
      final contains = options.where((option) {
        final normalizedOption = _normalize(option);
        return normalizedOption.contains(normalizedCandidate) ||
            normalizedCandidate.contains(normalizedOption);
      });
      if (contains.isNotEmpty) return contains.first;
    }

    return null;
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static List<String> _uniqueNonEmpty(List<String?> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) continue;
      final key = _normalize(trimmed);
      if (seen.add(key)) result.add(trimmed);
    }
    return result;
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  static String? _joinNonEmpty(List<String?> values) {
    final parts = values
        .map((value) => value?.trim())
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }
}

class ParsedMapLocation {
  const ParsedMapLocation({
    this.country,
    this.city,
    this.venue,
  });

  final String? country;
  final String? city;
  final String? venue;

  bool get hasRegion =>
      country != null &&
      country!.isNotEmpty &&
      city != null &&
      city!.isNotEmpty;
}
