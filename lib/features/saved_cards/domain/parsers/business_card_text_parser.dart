import '../entities/manual_saved_card_draft.dart';

/// OCR metninden kartvizit alanlarını çıkarır.
///
/// Satırları skorlayarak en uygun alana yerleştirir (ad, unvan, şirket,
/// iletişim, hakkımda, yetenekler).
class BusinessCardTextParser {
  BusinessCardTextParser._();

  static final RegExp _emailPattern = RegExp(
    r'[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}',
    caseSensitive: false,
  );

  /// TR / uluslararası telefon; OCR boşluk ve tirelerini tolere eder.
  static final RegExp _phonePattern = RegExp(
    r'(?:(?:\+|00)\d{1,3}[\s\-.]*)?(?:\(?\d{2,4}\)?[\s\-.]*)?\d{2,4}[\s\-.]*\d{2,4}[\s\-.]*\d{2,4}',
  );

  static final RegExp _urlPattern = RegExp(
    r'(?:https?://|www\.)[^\s]+|linkedin\.com/[^\s]+|[a-z0-9][\w\-]*\.(?:com|net|org|io|co|dev|app|tr|ai)(?:/[^\s]*)?',
    caseSensitive: false,
  );

  static final RegExp _linkedinPathPattern = RegExp(
    r'linkedin\.com/(?:in|company|pub)/[^\s]+',
    caseSensitive: false,
  );

  static final RegExp _labelPrefixPattern = RegExp(
    r'^(?:e[\-\s]?mail|mail|tel|telefon|phone|mobile|cep|gsm|web|www|site|website|adres|address|unvan|title|name|ad\s*soyad|şirket|company|linkedin)\s*[:：\-]\s*',
    caseSensitive: false,
  );

  static final RegExp _addressPattern = RegExp(
    r'\b(?:mah\.?|mahallesi|cad\.?|caddesi|sok\.?|sokak|bulvar|blvd|street|st\.|avenue|ave\.|apt\.?|no[:.]?\s*\d|kat[:.]?\s*\d|daire|posta\s*kodu|pk[:.]?\s*\d)\b',
    caseSensitive: false,
  );

  static final RegExp _cityPattern = RegExp(
    r'\b(?:istanbul|ankara|izmir|bursa|antalya|adana|gaziantep|konya|kayseri|eskisehir|eskisehir|mersin|diyarbakir|samsun|trabzon|kadikoy|besiktas|sisli|uskudar|baskent|turkiye|turkey)\b',
    caseSensitive: false,
  );

  static const List<String> _titleKeywords = [
    'ceo',
    'cto',
    'cfo',
    'coo',
    'cmo',
    'founder',
    'kurucu',
    'ortak',
    'partner',
    'director',
    'direktor',
    'manager',
    'mudur',
    'yonetici',
    'lead',
    'baskan',
    'president',
    'vp',
    'head',
    'uzman',
    'specialist',
    'engineer',
    'muhendis',
    'developer',
    'gelistirici',
    'designer',
    'tasarimci',
    'consultant',
    'danisman',
    'analyst',
    'analist',
    'architect',
    'mimar',
    'sales',
    'satis',
    'marketing',
    'pazarlama',
    'product',
    'urun',
    'project',
    'proje',
    'account',
    'musteri',
    'operasyon',
    'senior',
    'junior',
  ];

  static const List<String> _companyKeywords = [
    'a.s',
    'a.s.',
    'as.',
    'ltd',
    'sti',
    'şti',
    'llc',
    'inc',
    'corp',
    'gmbh',
    'holding',
    'group',
    'grup',
    'sirketi',
  ];

  static bool _hasTitleKeyword(String line) {
    final folded = ' ${_foldTr(line)} ';
    return _titleKeywords.any((keyword) => folded.contains(' $keyword'));
  }

  static bool _hasCompanyKeyword(String line) {
    final folded = _foldTr(line);
    // A.Ş. / Ltd. Şti. noktalı biçimler
    if (RegExp(r'\ba\.?\s*s\.?\b').hasMatch(folded)) return true;
    if (RegExp(r'\bltd\.?\b').hasMatch(folded)) return true;
    if (RegExp(r'\bsti\.?\b').hasMatch(folded)) return true;
    final padded = ' $folded ';
    return _companyKeywords.any((keyword) => padded.contains(' $keyword'));
  }

  static final RegExp _personNamePattern = RegExp(
    r"^[A-ZÇĞİÖŞÜ][a-zçğıöşü''’\-]+(?:\s+[A-ZÇĞİÖŞÜ][a-zçğıöşü''’\-]+){0,3}$",
  );

  static final RegExp _allCapsNamePattern = RegExp(
    r"^[A-ZÇĞİÖŞÜ]{2,}(?:\s+[A-ZÇĞİÖŞÜ]{2,}){0,3}$",
  );

  static final RegExp _skillsSeparatorPattern = RegExp(r'[,;|/•·]| - ');

  static ManualSavedCardDraft parse({
    required String frontText,
    String backText = '',
  }) {
    final frontLines = _normalizeLines(frontText);
    final backLines = _normalizeLines(backText);
    final allLines = [...frontLines, ...backLines];

    final email = _extractEmail(allLines);
    final phone = _extractPhone(allLines);
    final linkedin = _extractLinkedIn(allLines);
    final website = _extractWebsite(allLines, excludeLinkedIn: linkedin);

    final consumed = <String>{};
    void consumeMatching(String? value) {
      if (value == null) return;
      for (final line in allLines) {
        if (line.toLowerCase().contains(value.toLowerCase()) ||
            value.toLowerCase().contains(_stripLabel(line).toLowerCase())) {
          consumed.add(line);
        }
      }
    }

    consumeMatching(email);
    consumeMatching(phone);
    consumeMatching(website);
    consumeMatching(linkedin);

    final frontContent = frontLines
        .where((line) => !consumed.contains(line))
        .where((line) => !_isNoiseLine(line))
        .map(_stripLabel)
        .where((line) => line.isNotEmpty)
        .toList();

    final backContent = backLines
        .where((line) => !consumed.contains(line))
        .where((line) => !_isNoiseLine(line))
        .map(_stripLabel)
        .where((line) => line.isNotEmpty)
        .toList();

    final displayName = _pickDisplayName(frontContent) ??
        _pickDisplayName(backContent);
    final title = _pickTitle(
      frontContent,
      excluding: {if (displayName != null) displayName},
    );
    final company = _pickCompany(
      frontContent,
      excluding: {
        if (displayName != null) displayName,
        if (title != null) title,
      },
    );

    final remainingBack = backContent
        .where((line) => line != displayName && line != title && line != company)
        .toList();

    final skills = _pickSkills(remainingBack);
    final about = _pickAbout(
      remainingBack,
      excludingSkills: skills,
    );

    return ManualSavedCardDraft(
      displayName: displayName,
      email: email,
      phone: phone,
      company: company,
      title: title,
      website: website,
      linkedin: linkedin,
      about: about,
      skills: skills,
    );
  }

  static List<String> _normalizeLines(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .expand((line) {
          // OCR bazen "Ad Soyad | Unvan" tek satırda birleştirir.
          if (line.contains('|')) {
            return line.split('|').map((part) => part.trim());
          }
          return [line.trim()];
        })
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .where((line) => line.length > 1)
        .toList();
  }

  static String _stripLabel(String line) {
    return line.replaceFirst(_labelPrefixPattern, '').trim();
  }

  static bool _isNoiseLine(String line) {
    final cleaned = _stripLabel(line);
    if (cleaned.length < 2) return true;
    if (_looksLikeAddress(cleaned)) return true;
    if (RegExp(r'^[\d\W]+$').hasMatch(cleaned)) return true;
    // Saf etiket satırları
    if (RegExp(
      r'^(?:e[\-\s]?mail|tel|telefon|phone|web|www|adres|linkedin)$',
      caseSensitive: false,
    ).hasMatch(cleaned)) {
      return true;
    }
    return false;
  }

  static String _foldTr(String input) {
    return input
        .toLowerCase()
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .replaceAll('ı', 'i')
        .replaceAll('i̇', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  static bool _looksLikeAddress(String line) {
    final folded = _foldTr(line);
    if (_addressPattern.hasMatch(folded) || _addressPattern.hasMatch(line)) {
      return true;
    }
    if (_cityPattern.hasMatch(folded)) {
      // Sadece şehir/ilçe veya şehir + kısa ek.
      final words = folded.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
      if (words.length <= 3) return true;
      if (RegExp(r'\d').hasMatch(folded)) return true;
    }
    return false;
  }

  static String? _extractEmail(List<String> lines) {
    for (final line in lines) {
      final match = _emailPattern.firstMatch(line);
      if (match != null) {
        return match.group(0)!.trim().toLowerCase();
      }
    }
    return null;
  }

  static String? _extractPhone(List<String> lines) {
    String? best;
    var bestDigitCount = 0;
    for (final line in lines) {
      // E-posta içindeki sayıları telefon sanma.
      if (_emailPattern.hasMatch(line)) continue;
      for (final match in _phonePattern.allMatches(line)) {
        final raw = match.group(0)?.trim();
        if (raw == null) continue;
        final digits = raw.replaceAll(RegExp(r'\D'), '');
        if (digits.length < 10 || digits.length > 15) continue;
        // Yıl / posta kodu benzeri kısa blokları ele.
        if (RegExp(r'^\d{4}$').hasMatch(digits)) continue;
        if (digits.length > bestDigitCount) {
          bestDigitCount = digits.length;
          best = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
        }
      }
    }
    return best;
  }

  static String? _extractLinkedIn(List<String> lines) {
    for (final line in lines) {
      final path = _linkedinPathPattern.firstMatch(line)?.group(0);
      if (path != null) {
        return _normalizeWebsite(path);
      }
      if (line.toLowerCase().contains('linkedin.com')) {
        final url = _urlPattern.firstMatch(line)?.group(0);
        if (url != null) return _normalizeWebsite(url);
      }
    }
    return null;
  }

  static String? _extractWebsite(
    List<String> lines, {
    required String? excludeLinkedIn,
  }) {
    for (final line in lines) {
      if (_emailPattern.hasMatch(line)) continue;
      for (final match in _urlPattern.allMatches(line)) {
        final value = match.group(0)?.trim();
        if (value == null) continue;
        final lower = value.toLowerCase();
        if (lower.contains('linkedin')) continue;
        if (excludeLinkedIn != null &&
            lower.contains(excludeLinkedIn.toLowerCase())) {
          continue;
        }
        // @ işareti domain değil.
        if (value.contains('@')) continue;
        return _normalizeWebsite(value);
      }
    }
    return null;
  }

  static String? _normalizeWebsite(String? raw) {
    if (raw == null) return null;
    var value = raw.trim().replaceAll(RegExp(r'[.,;:]+$'), '');
    if (value.isEmpty) return null;
    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return value;
    }
    if (lower.startsWith('www.') || lower.contains('linkedin.com')) {
      return 'https://$value';
    }
    if (RegExp(r'^[a-z0-9].*\.[a-z]{2,}').hasMatch(lower)) {
      return 'https://$value';
    }
    return value;
  }

  static String? _pickDisplayName(List<String> lines) {
    _ScoredLine? best;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final score = _scoreDisplayName(line, index: i, total: lines.length);
      if (score <= 0) continue;
      if (best == null || score > best.score) {
        best = _ScoredLine(line, score);
      }
    }
    return best?.value;
  }

  static double _scoreDisplayName(
    String line, {
    required int index,
    required int total,
  }) {
    if (_looksLikeAddress(line)) return -20;
    if (_hasCompanyKeyword(line)) {
      return -10;
    }
    if (_hasTitleKeyword(line)) {
      if (line.split(' ').length > 3) return -5;
    }
    if (_emailPattern.hasMatch(line) || _urlPattern.hasMatch(line)) return -10;
    if (RegExp(r'\d').hasMatch(line)) return -3;

    final words = line.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty || words.length > 4) return -2;

    var score = 0.0;
    // Kartın üstüne yakın satırlar genelde isim.
    score += (total <= 1) ? 2 : (2.5 * (1 - (index / total)));

    if (_personNamePattern.hasMatch(line)) score += 8;
    if (_allCapsNamePattern.hasMatch(line) && words.length >= 2) score += 10;
    if (words.length >= 2 && words.length <= 3) score += 3;
    if (words.length == 1 && words.first.length >= 3) score += 1;

    // Her kelime büyük harfle başlıyorsa isim ihtimali yüksek.
    final titledWords = words.where((w) {
      if (w.isEmpty) return false;
      final first = w.substring(0, 1);
      return first.toUpperCase() == first;
    }).length;
    if (titledWords == words.length) score += 2;

    // Unvan gibi görünen kısa satırları isim sanma.
    if (_hasTitleKeyword(line) &&
        words.length <= 3) {
      score -= 4;
    }

    return score;
  }

  static String? _pickTitle(
    List<String> lines, {
    required Set<String> excluding,
  }) {
    _ScoredLine? best;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (excluding.contains(line)) continue;
      final score = _scoreTitle(line, index: i);
      if (score <= 0) continue;
      if (best == null || score > best.score) {
        best = _ScoredLine(line, score);
      }
    }
    return best?.value;
  }

  static double _scoreTitle(String line, {required int index}) {
    if (_looksLikeAddress(line)) return -20;
    if (_hasCompanyKeyword(line)) {
      return -5;
    }
    if (_emailPattern.hasMatch(line) || _urlPattern.hasMatch(line)) return -10;
    if (RegExp(r'\d').hasMatch(line)) return -8;
    if (_personNamePattern.hasMatch(line) &&
        !_hasTitleKeyword(line)) {
      return -2;
    }

    final words = line.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty || words.length > 8) return -1;

    var score = 0.0;
    if (_hasTitleKeyword(line)) {
      score += 10;
    }
    if (line.contains('/') || line.contains('&') || line.contains('-')) {
      score += 2;
    }
    // Unvan genelde isimden hemen sonra gelir.
    if (index <= 2) score += 2;
    if (words.isNotEmpty && words.length <= 5) score += 1;
    if (line == line.toUpperCase() && words.length >= 2) score += 1;

    return score;
  }

  static String? _pickCompany(
    List<String> lines, {
    required Set<String> excluding,
  }) {
    _ScoredLine? best;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (excluding.contains(line)) continue;
      final score = _scoreCompany(line, index: i, total: lines.length);
      if (score <= 0) continue;
      if (best == null || score > best.score) {
        best = _ScoredLine(line, score);
      }
    }
    return best?.value;
  }

  static double _scoreCompany(
    String line, {
    required int index,
    required int total,
  }) {
    if (_looksLikeAddress(line)) return -20;
    if (_emailPattern.hasMatch(line) || _urlPattern.hasMatch(line)) return -10;
    if (RegExp(r'\d{2,}').hasMatch(line) &&
        !_hasCompanyKeyword(line)) {
      return -5;
    }
    if (_personNamePattern.hasMatch(line) && !_hasCompanyKeyword(line)) {
      return -3;
    }

    final words = line.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty || words.length > 8) return -1;

    var score = 0.0;
    if (_hasCompanyKeyword(line)) {
      score += 12;
    }
    if (line == line.toUpperCase() && line.length >= 3) score += 4;
    // Logo alanı: çok üst veya alt.
    if (index == 0 || index == total - 1) score += 1.5;
    if (_hasTitleKeyword(line)) {
      score -= 3;
    }
    if (words.isNotEmpty && words.length <= 5) score += 1;

    return score;
  }

  static String? _pickSkills(List<String> lines) {
    final skillChunks = <String>[];
    for (final line in lines) {
      if (_looksLikeSkillsLine(line)) {
        final parts = line
            .split(_skillsSeparatorPattern)
            .map((part) => part.trim())
            .where((part) => part.length >= 2 && part.length <= 40)
            .where((part) => !_emailPattern.hasMatch(part))
            .toList();
        if (parts.length >= 2) {
          skillChunks.addAll(parts);
        } else if (parts.length == 1 && line.length <= 48) {
          skillChunks.add(parts.first);
        }
      }
    }

    if (skillChunks.isEmpty) return null;
    // Tekrarları koruyarak sırayı tut.
    final seen = <String>{};
    final unique = <String>[];
    for (final skill in skillChunks) {
      final key = skill.toLowerCase();
      if (seen.add(key)) unique.add(skill);
    }
    if (unique.isEmpty) return null;
    return unique.take(16).join(', ');
  }

  static bool _looksLikeSkillsLine(String line) {
    if (_hasTitleKeyword(line) &&
        !_skillsSeparatorPattern.hasMatch(line)) {
      return false;
    }
    if (_hasCompanyKeyword(line)) return false;
    if (_personNamePattern.hasMatch(line)) return false;
    final separators = _skillsSeparatorPattern.allMatches(line).length;
    if (separators >= 1) return true;
    // Kısa, tek kelimelik teknoloji / yetenek adayları listesi arka yüzde sık gelir.
    final words = line.split(' ');
    return words.length <= 3 && line.length <= 28 && !RegExp(r'\d{4,}').hasMatch(line);
  }

  static String? _pickAbout(
    List<String> lines, {
    required String? excludingSkills,
  }) {
    final skillSet = (excludingSkills ?? '')
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toSet();

    final paragraphs = <String>[];
    for (final line in lines) {
      if (_looksLikeSkillsLine(line) &&
          _skillsSeparatorPattern.hasMatch(line)) {
        continue;
      }
      if (skillSet.contains(line.toLowerCase())) continue;
      if (_personNamePattern.hasMatch(line) && line.split(' ').length <= 3) {
        continue;
      }
      // Hakkımda genelde daha uzun cümleler.
      if (line.length >= 28 || line.split(' ').length >= 5) {
        paragraphs.add(line);
      }
    }

    if (paragraphs.isEmpty) return null;
    final joined = paragraphs.join('\n').trim();
    return joined.isEmpty ? null : joined;
  }
}

class _ScoredLine {
  const _ScoredLine(this.value, this.score);
  final String value;
  final double score;
}
