import 'dart:convert';

import 'package:csc_picker/model/select_status_model.dart';
import 'package:flutter/services.dart';

/// Ülke/il/ilçe verisini tek sefer yükler; picker açılışını hızlandırır.
class CountryLocationDataCache {
  CountryLocationDataCache._();

  static const _assetPath = 'packages/csc_picker/lib/assets/country.json';

  static List<Country>? _countries;
  static Future<List<Country>>? _loading;

  static void warmUp() {
    _loading ??= _load();
  }

  static Future<List<Country>> ensureLoaded() {
    warmUp();
    return _loading!;
  }

  static Future<List<Country>> _load() async {
    if (_countries != null) return _countries!;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List;
    _countries = decoded
        .map((item) => Country.fromJson(item as Map<String, dynamic>))
        .toList();
    return _countries!;
  }
}
