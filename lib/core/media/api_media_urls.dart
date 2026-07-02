import '../network/api_config.dart';

/// API üzerinden servis edilen medya URL yardımcıları.
class ApiMediaUrls {
  ApiMediaUrls._();

  static bool requiresAuthentication(String? url) {
    final uri = _parse(url);
    if (uri == null) return false;
    if (!uri.path.startsWith('/uploads/')) return false;

    final baseHost = Uri.tryParse(ApiConfig.baseUrl)?.host;
    if (baseHost == null || baseHost.isEmpty) return true;
    return uri.host == baseHost;
  }

  static Uri? _parse(String? url) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return Uri.tryParse(trimmed);
  }
}
