import '../network/api_config.dart';
import 'media_image_size.dart';

/// API üzerinden servis edilen medya URL yardımcıları.
class ApiMediaUrls {
  ApiMediaUrls._();

  static final RegExp _guidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  static final RegExp _guidCompactPattern = RegExp(r'^[0-9a-fA-F]{32}$');
  static final RegExp _profileSizedPattern =
      RegExp(r'profile-\d+\.[a-zA-Z0-9]+$');
  static final RegExp _eventGroupSizedPattern = RegExp(
    r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'
    r'-\d+\.[a-zA-Z0-9]+$',
  );

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

  static String normalizedPath(String? url) {
    final resolved = resolve(url);
    if (resolved == null) return '';
    return Uri.tryParse(resolved)?.path ?? '';
  }

  /// Cardence API `/uploads` dosyası mı?
  static bool isApiUploadUrl(String? url) {
    final resolved = resolve(url);
    if (resolved == null) return false;

    final parsed = Uri.tryParse(resolved);
    if (parsed == null || !parsed.path.startsWith('/uploads/')) {
      return false;
    }

    final baseHost = Uri.tryParse(ApiConfig.baseUrl)?.host;
    if (baseHost == null || baseHost.isEmpty) return true;
    return parsed.host == baseHost;
  }

  /// Ekran boyutuna uygun varyant URL'si üretir; harici URL'ler olduğu gibi kalır.
  static String? variantUrl(String? url, MediaImageSize size) {
    final resolved = resolve(url);
    if (resolved == null) return null;
    if (!isApiUploadUrl(url)) return resolved;

    final uri = Uri.parse(resolved);
    final variantPath = _applyVariantToPath(uri.path, size.width);
    if (variantPath == uri.path) return resolved;

    return uri.replace(path: variantPath).toString();
  }

  /// Kartvizit profil fotoğrafları paylaşımda herkese açıktır.
  static bool isPublicProfilePhotoUrl(String? url) =>
      isPublicProfilePhotoPath(normalizedPath(url));

  /// Etkinlik kapak fotoğrafları herkese açıktır.
  static bool isPublicEventGroupPhotoUrl(String? url) =>
      isPublicEventGroupPhotoPath(normalizedPath(url));

  /// Herkese açık Cardence `/uploads` yolu.
  static bool isPublicUploadUrl(String? url) =>
      isPublicProfilePhotoUrl(url) || isPublicEventGroupPhotoUrl(url);

  static bool isPublicProfilePhotoPath(String path) {
    final segments =
        path.split('/').where((segment) => segment.isNotEmpty).toList();
    if (segments.length != 4) return false;
    if (segments[0] != 'uploads' || segments[1] != 'users') return false;
    if (!_isUserIdSegment(segments[2])) return false;

    final fileName = segments[3].toLowerCase();
    return fileName.startsWith('profile-') && fileName.endsWith('.jpg') ||
        fileName.startsWith('profile.');
  }

  static bool isPublicEventGroupPhotoPath(String path) {
    final segments =
        path.split('/').where((segment) => segment.isNotEmpty).toList();
    if (segments.length != 5) return false;
    if (segments[0] != 'uploads' ||
        segments[1] != 'users' ||
        segments[3] != 'event-groups') {
      return false;
    }
    if (!_isUserIdSegment(segments[2])) return false;

    return _eventGroupSizedPattern.hasMatch(segments[4]);
  }

  static String _applyVariantToPath(String path, int width) {
    if (path.contains('/event-groups/')) {
      final fileName = path.split('/').last;
      if (!_eventGroupSizedPattern.hasMatch(fileName)) {
        return path;
      }
      final groupId = fileName.split('-').take(5).join('-');
      return path.replaceFirst(fileName, '$groupId-$width.jpg');
    }

    if (path.contains('/users/') && path.contains('profile')) {
      final fileName = path.split('/').last;
      if (!_profileSizedPattern.hasMatch(fileName)) {
        return path;
      }
      return path.replaceFirst(fileName, 'profile-$width.jpg');
    }

    return path;
  }

  static bool _isUserIdSegment(String segment) {
    return _guidPattern.hasMatch(segment) ||
        _guidCompactPattern.hasMatch(segment);
  }
}
