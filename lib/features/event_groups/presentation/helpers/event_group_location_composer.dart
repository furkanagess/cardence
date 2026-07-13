/// Etkinlik konumu metnini ülke - il - mekan olarak birleştirir veya ayırır.
class EventGroupLocationComposer {
  EventGroupLocationComposer._();

  static const _displaySeparator = ' - ';

  /// Kayıt ve önizleme için: `ülke - il - mekan`.
  static String compose({
    String? venue,
    required String? country,
    required String? city,
  }) {
    final parts = <String>[];
    final trimmedCountry = country?.trim();
    if (trimmedCountry != null && trimmedCountry.isNotEmpty) {
      parts.add(trimmedCountry);
    }

    final province = extractProvince(city);
    if (province != null && province.isNotEmpty) {
      parts.add(province);
    }

    final trimmedVenue = venue?.trim();
    if (trimmedVenue != null && trimmedVenue.isNotEmpty) {
      parts.add(trimmedVenue);
    }

    return parts.join(_displaySeparator);
  }

  /// Geocoding sorgusu için: mekan, il/ilçe, ülke (virgülle).
  static String composeGeocodeQuery({
    String? venue,
    required String? country,
    required String? city,
  }) {
    final parts = <String>[];
    final trimmedVenue = venue?.trim();
    if (trimmedVenue != null && trimmedVenue.isNotEmpty) {
      parts.add(trimmedVenue);
    }
    final trimmedCity = city?.trim();
    if (trimmedCity != null && trimmedCity.isNotEmpty) {
      parts.add(trimmedCity);
    }
    final trimmedCountry = country?.trim();
    if (trimmedCountry != null && trimmedCountry.isNotEmpty) {
      parts.add(trimmedCountry);
    }
    return parts.join(', ');
  }

  static bool isRegionComplete(String? country, String? city) {
    return country != null &&
        country.trim().isNotEmpty &&
        city != null &&
        city.trim().isNotEmpty;
  }

  /// İl/ilçe metninden il (province) değerini çıkarır.
  static String? extractProvince(String? city) {
    final parsed = parseCityParts(city);
    if (parsed.state != null && parsed.state!.isNotEmpty) {
      return parsed.state;
    }
    return parsed.district;
  }

  static ({String? state, String? district}) parseCityParts(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return (state: null, district: null);
    }
    final parts = raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return (state: parts.last, district: parts.first);
    }
    if (parts.length == 1) {
      return (state: parts.first, district: null);
    }
    return (state: null, district: null);
  }

  static ({String? country, String? city, String? venue}) parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return (country: null, city: null, venue: null);
    }

    final trimmed = raw.trim();
    if (trimmed.contains(_displaySeparator)) {
      return _parseDisplayFormat(trimmed);
    }

    return _parseLegacyCommaFormat(trimmed);
  }

  static ({String? country, String? city, String? venue}) _parseDisplayFormat(
    String raw,
  ) {
    final parts = raw
        .split(_displaySeparator)
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return (country: null, city: null, venue: null);
    }
    if (parts.length == 1) {
      return (country: null, city: null, venue: parts.first);
    }
    if (parts.length == 2) {
      return (country: parts[0], city: parts[1], venue: null);
    }

    return (
      country: parts.first,
      city: parts.sublist(1, parts.length - 1).join(_displaySeparator),
      venue: parts.last,
    );
  }

  static ({String? country, String? city, String? venue})
      _parseLegacyCommaFormat(String raw) {
    final parts = raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return (country: null, city: null, venue: null);
    }
    if (parts.length == 1) {
      return (country: null, city: null, venue: parts.first);
    }
    if (parts.length == 2) {
      return (country: parts[1], city: parts[0], venue: null);
    }

    return (
      country: parts.last,
      city: parts.sublist(1, parts.length - 1).join(', '),
      venue: parts.first,
    );
  }
}
