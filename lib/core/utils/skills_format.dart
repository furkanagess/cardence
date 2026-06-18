/// Yetenek metnini virgül/satır ayracıyla liste haline getirir.
class SkillsFormat {
  SkillsFormat._();

  static final RegExp _separator = RegExp(r'[,،\n]+');

  static List<String> parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    return raw
        .split(_separator)
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String join(Iterable<String> skills) => skills.join(', ');
}
