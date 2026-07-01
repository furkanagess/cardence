/// Etkinlik konumu metnini ülke · il/ilçe · mekan olarak birleştirir veya ayırır.
class EventGroupLocationComposer {
  EventGroupLocationComposer._();

  static String compose({
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

  static ({String? country, String? city, String? venue}) parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return (country: null, city: null, venue: null);
    }

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
