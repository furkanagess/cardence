/// QR veya Kart ID ile paylaşımda kullanılan veri sözleşmesi (framework yok).
/// Kısa anahtarlar QR boyutunu küçük tutar.
class CardSharePayload {
  const CardSharePayload({
    required this.id,
    this.n,
    this.e,
    this.p,
    this.c,
    this.t,
    this.w,
    this.l,
    this.s,
    this.o,
    this.h,
    this.ph,
  });

  /// Kart benzersiz id (cardId).
  final String id;
  /// displayName
  final String? n;
  /// email
  final String? e;
  /// phone
  final String? p;
  /// company
  final String? c;
  /// title
  final String? t;
  /// website
  final String? w;
  /// linkedin
  final String? l;
  /// skills
  final String? s;
  /// school (okul)
  final String? o;
  /// about (hakkımda)
  final String? h;
  /// photoUrl
  final String? ph;

  Map<String, dynamic> toJson() => {
        'id': id,
        if (n != null && n!.isNotEmpty) 'n': n,
        if (e != null && e!.isNotEmpty) 'e': e,
        if (p != null && p!.isNotEmpty) 'p': p,
        if (c != null && c!.isNotEmpty) 'c': c,
        if (t != null && t!.isNotEmpty) 't': t,
        if (w != null && w!.isNotEmpty) 'w': w,
        if (l != null && l!.isNotEmpty) 'l': l,
        if (s != null && s!.isNotEmpty) 's': s,
        if (o != null && o!.isNotEmpty) 'o': o,
        if (h != null && h!.isNotEmpty) 'h': h,
        if (ph != null && ph!.isNotEmpty) 'ph': ph,
      };

  static CardSharePayload? fromJson(Map<String, dynamic>? json) {
    if (json == null || json['id'] == null) return null;
    return CardSharePayload(
      id: json['id'] as String,
      n: json['n'] as String?,
      e: json['e'] as String?,
      p: json['p'] as String?,
      c: json['c'] as String?,
      t: json['t'] as String?,
      w: json['w'] as String?,
      l: json['l'] as String?,
      s: json['s'] as String?,
      o: json['o'] as String?,
      h: json['h'] as String?,
      ph: json['ph'] as String?,
    );
  }
}
