import '../network/api_config.dart';

/// API üzerinden servis edilen medya URL yardımcıları.
class ApiMediaUrls {
  ApiMediaUrls._();

  static final RegExp _guidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  static final RegExp _guidCompactPattern = RegExp(r'^[0-9a-fA-F]{32}$');

  /// Göreli veya mutlak medya URL'sini tam API adresine çevirir.
  static String? resolve(String? url) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) return null;
    if (parsed.hasScheme && parsed.host.isNotEmpty) return trimmed;

    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }

  static String _normalizedPath(String? url) {
    final resolved = resolve(url);
    if (resolved == null) return '';
    return Uri.tryParse(resolved)?.path ?? '';
  }

  static bool requiresAuthentication(String? url) {
    final path = _normalizedPath(url);
    if (path.isEmpty || !path.startsWith('/uploads/')) return false;
    if (isPublicProfilePhotoPath(path)) return false;

    final resolved = resolve(url);
    if (resolved == null) return false;

    final baseHost = Uri.tryParse(ApiConfig.baseUrl)?.host;
    final uriHost = Uri.tryParse(resolved)?.host;
    if (baseHost == null || baseHost.isEmpty) return true;
    return uriHost == baseHost;
  }

  /// Kartvizit profil fotoğrafları paylaşımda herkese açıktır:
  /// `/uploads/users/{userId}/profile.{ext}`
  static bool isPublicProfilePhotoPath(String path) {
    final segments =
        path.split('/').where((segment) => segment.isNotEmpty).toList();
    if (segments.length != 4) return false;
    if (segments[0] != 'uploads' || segments[1] != 'users') return false;
    if (!_isUserIdSegment(segments[2])) return false;

    final fileName = segments[3].toLowerCase();
    return fileName.startsWith('profile.');
  }

  static bool _isUserIdSegment(String segment) {
    return _guidPattern.hasMatch(segment) ||
        _guidCompactPattern.hasMatch(segment);
  }
}
