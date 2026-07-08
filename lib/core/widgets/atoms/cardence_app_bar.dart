import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
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

/// Özel üst şeritler (ör. kaydedilen kartlar başlığı) için AppBar ile aynı yüzey.
class CardenceAppBarRegion extends StatelessWidget {
  const CardenceAppBarRegion({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 12),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final background = AppColors.appBarBackgroundFor(brightness);

    return Material(
      color: background,
      elevation: AppColors.appBarElevation,
      shadowColor: AppColors.appBarShadowColor(brightness),
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.appBarBorderColorFor(brightness),
              ),
            ),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Adım akışı ve oluşturma ekranlarında alt aksiyon alanı — AppBar ile aynı yüzey.
class CardenceFlowBottomBarRegion extends StatelessWidget {
  const CardenceFlowBottomBarRegion({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final background = AppColors.appBarBackgroundFor(brightness);

    return Material(
      color: background,
      elevation: AppColors.appBarElevation,
      shadowColor: AppColors.appBarShadowColor(brightness),
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.appBarBorderColorFor(brightness),
              ),
            ),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
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
          title != null ||
              titleWidget != null ||
              variant == CardenceAppBarVariant.flow,
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
  static const double _bottomBorderHeight = 1;
  static const IconData _backIcon = Icons.arrow_back_rounded;

  static Color resolveBackground(BuildContext context) =>
      AppColors.appBarBackgroundFor(Theme.of(context).brightness);

  static Color resolveForeground(BuildContext context) =>
      AppColors.appBarForegroundFor(Theme.of(context).brightness);

  /// Ana kabuk sekmeleri (Cardence, Etkinlik grupları, Kartlarım) başlık stili.
  static TextStyle shellTabTitleTextStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          color: resolveForeground(context),
        ) ??
        TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          color: resolveForeground(context),
        );
  }

  static Widget shellTabTitle(BuildContext context, String title) {
    return Text(
      title,
      style: shellTabTitleTextStyle(context),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

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
    final background = resolveBackground(context);
    final onSurface = resolveForeground(context);
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

  TextStyle? _titleStyle(BuildContext context, Color foreground) {
    final textTheme = Theme.of(context).textTheme;

    return textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: foreground,
    );
  }

  Widget? _buildTitle(BuildContext context, Color foreground) {
    if (titleWidget != null) return titleWidget;
    if (title == null) return null;

    return Text(
      title!,
      style: _titleStyle(context, foreground),
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
    final appBarTheme = Theme.of(context).appBarTheme;
    final resolvedBackground = backgroundColor ?? resolveBackground(context);
    final resolvedForeground = foregroundColor ?? resolveForeground(context);
    final resolvedElevation =
        elevation ?? appBarTheme.elevation ?? AppColors.appBarElevation;

    return AppBar(
      title: _buildTitle(context, resolvedForeground),
      centerTitle: _centerTitle,
      automaticallyImplyLeading: false,
      leading: _resolveLeading(context),
      actions: actions,
      backgroundColor: resolvedBackground,
      foregroundColor: resolvedForeground,
      elevation: resolvedElevation,
      scrolledUnderElevation: 0,
      shadowColor: appBarTheme.shadowColor ??
          AppColors.appBarShadowColor(Theme.of(context).brightness),
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: resolvedForeground,
        size: _actionIconSize,
      ),
      actionsIconTheme: IconThemeData(
        color: resolvedForeground,
        size: _actionIconSize,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_bottomBorderHeight),
        child: Divider(
          height: _bottomBorderHeight,
          thickness: _bottomBorderHeight,
          color: AppColors.appBarBorderColorFor(
            Theme.of(context).brightness,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + _bottomBorderHeight);
}
