import 'package:flutter/material.dart';

/// AppBar başlık ve ikon hiyerarşisi.
///
/// - [root]: Ana kabuk sekmeleri — ortalanmış başlık, geri yok.
/// - [primary]: Detay / alt ekran — sol hizalı başlık, otomatik geri.
/// - [editor]: Düzenleme ekranı — sol hizalı başlık, geri + sağ aksiyonlar.
/// - [flow]: Adım akışı (onboarding) — başlıksız, özel leading + aksiyonlar.
enum CardenceAppBarVariant {
  root,
  primary,
  editor,
  flow,
}

/// Cardence uygulamasının tek AppBar bileşeni.
///
/// Tüm ekranlar bu widget üzerinden AppBar kullanmalıdır; başlık boyutu,
/// hizalama ve aksiyon ikonları tutarlı kalır.
class CardenceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CardenceAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.variant = CardenceAppBarVariant.primary,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.scrolledUnderElevation,
  }) : assert(
          title != null || titleWidget != null || variant == CardenceAppBarVariant.flow,
          'title, titleWidget veya flow variant gerekli',
        );

  final String? title;
  final Widget? titleWidget;
  final CardenceAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double? scrolledUnderElevation;

  static const double _actionIconSize = 24;

  /// Standart sağ üst ikon aksiyonu (24px, tooltip).
  static Widget iconAction({
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: _actionIconSize),
    );
  }

  /// Düzenleme ekranları için metin aksiyonu (ör. Kaydet).
  static Widget textAction({
    required String label,
    VoidCallback? onPressed,
    bool loading = false,
  }) {
    return TextButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }

  /// Akış ekranları için geri butonu (onboarding vb.).
  static Widget flowBackButton({
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      tooltip: 'Geri',
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
    );
  }

  /// Akış ekranları için metin aksiyonu (ör. Atla).
  static Widget flowTextAction({
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

  bool get _isRoot => variant == CardenceAppBarVariant.root;
  bool get _isFlow => variant == CardenceAppBarVariant.flow;

  bool? get _centerTitle {
    if (_isRoot) return true;
    if (_isFlow) return false;
    return false;
  }

  TextStyle? _titleStyle(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final onSurface = foregroundColor ?? theme.colorScheme.onSurface;

    return textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: onSurface,
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (titleWidget != null) return titleWidget;
    if (title == null) return null;

    return Text(
      title!,
      style: _titleStyle(context),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      title: _buildTitle(context),
      centerTitle: _centerTitle,
      automaticallyImplyLeading:
          _isRoot || _isFlow ? false : automaticallyImplyLeading,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? appBarTheme.foregroundColor,
      elevation: elevation ?? appBarTheme.elevation ?? 0,
      scrolledUnderElevation:
          scrolledUnderElevation ?? appBarTheme.scrolledUnderElevation ?? 1,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: foregroundColor ?? colorScheme.onSurface,
        size: _actionIconSize,
      ),
      actionsIconTheme: IconThemeData(
        color: foregroundColor ?? colorScheme.onSurface,
        size: _actionIconSize,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
