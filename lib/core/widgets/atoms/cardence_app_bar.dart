import 'package:flutter/material.dart';

import 'custom_button.dart';

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
  static const IconData _backIcon = Icons.arrow_back_rounded;

  /// Tüm AppBar geri butonlarında kullanılan standart ikon.
  static Widget backButton({
    required BuildContext context,
    VoidCallback? onPressed,
    ButtonStyle? style,
  }) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      style: style,
      icon: const Icon(_backIcon, size: _actionIconSize),
    );
  }

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
    return CustomButton.text(
      label: label,
      onPressed: onPressed,
      isLoading: loading,
    );
  }

  static ButtonStyle _flowButtonStyle(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(background),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return onSurface.withValues(alpha: 0.38);
        }
        return onSurface;
      }),
    );
  }

  /// Akış ekranları için geri butonu (onboarding vb.).
  static Widget flowBackButton({
    required BuildContext context,
    required VoidCallback? onPressed,
  }) {
    return backButton(
      context: context,
      onPressed: onPressed,
      style: _flowButtonStyle(context),
    );
  }

  /// Akış ekranları için metin aksiyonu (ör. Atla).
  static Widget flowTextAction({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return CustomButton.text(
      label: label,
      onPressed: onPressed,
      style: _flowButtonStyle(context),
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

  Widget? _resolveLeading(BuildContext context) {
    if (leading != null) return leading;
    if (_isRoot || _isFlow || !automaticallyImplyLeading) return null;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    if (!canPop) return null;
    return backButton(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = theme.appBarTheme;

    final pageBackground = theme.scaffoldBackgroundColor;

    return AppBar(
      title: _buildTitle(context),
      centerTitle: _centerTitle,
      automaticallyImplyLeading: false,
      leading: _resolveLeading(context),
      actions: actions,
      backgroundColor: backgroundColor ?? pageBackground,
      foregroundColor: foregroundColor ?? appBarTheme.foregroundColor,
      elevation: elevation ?? appBarTheme.elevation ?? 0,
      scrolledUnderElevation:
          scrolledUnderElevation ?? appBarTheme.scrolledUnderElevation ?? 0,
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
