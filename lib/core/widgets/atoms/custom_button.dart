import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Uygulama genelinde tek buton atomu.
///
/// Tüm butonlar bu widget üzerinden kullanılır. Görsel hiyerarşi [variant] ile
/// belirlenir:
/// * [CustomButtonVariant.primary] – birincil dolu aksiyon
/// * [CustomButtonVariant.tonal] – ikincil yumuşak aksiyon
/// * [CustomButtonVariant.text] – metin / link aksiyonu (örn. İptal)
/// * [CustomButtonVariant.outlined] – çerçeveli ikincil aksiyon
///
/// Metin her zaman ortalanır ve [height] yalnızca **minimum** yükseklik olarak
/// uygulanır; içerik (büyük yazı tipi ölçeği veya çok satır) gerektirdiğinde
/// buton büyür, metni asla sıkıştırmaz/kırpmaz.
enum CustomButtonVariant {
  primary,
  tonal,
  text,
  outlined,
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 48,
    this.variant = CustomButtonVariant.primary,
    this.icon,
    this.labelStyle,
    this.style,
    this.visualDensity,
  });

  const CustomButton.tonal({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 44,
    this.icon,
    this.labelStyle,
    this.style,
    this.visualDensity,
  }) : variant = CustomButtonVariant.tonal;

  const CustomButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.fullWidth = false,
    this.height = 44,
    this.icon,
    this.labelStyle,
    this.style,
    this.visualDensity,
  }) : variant = CustomButtonVariant.text;

  const CustomButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 48,
    this.icon,
    this.labelStyle,
    this.style,
    this.visualDensity,
  }) : variant = CustomButtonVariant.outlined;

  final String label;
  final TextStyle? labelStyle;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final CustomButtonVariant variant;
  final IconData? icon;
  final ButtonStyle? style;
  final VisualDensity? visualDensity;

  bool get _isInteractive => enabled && !isLoading && onPressed != null;

  /// Sabit yükseklik dayatmaz; [height] minimum yükseklik olur ve metin
  /// gerektiğinde büyüyebilmesi için dikey büyüme serbest bırakılır.
  ButtonStyle _effectiveStyle() {
    final base = (style ?? const ButtonStyle()).copyWith(
      alignment: Alignment.center,
      visualDensity: visualDensity,
    );

    return base.copyWith(
      minimumSize: base.minimumSize ??
          WidgetStateProperty.all(Size(0, height)),
      maximumSize: base.maximumSize ??
          WidgetStateProperty.all(const Size.fromWidth(double.infinity)),
    );
  }

  Widget _labelText() => Text(
        label,
        style: labelStyle,
        textAlign: TextAlign.center,
      );

  Color _loadingColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (variant == CustomButtonVariant.primary) {
      return Theme.of(context).brightness == Brightness.light
          ? AppColors.textOnPrimary
          : AppColors.backgroundDark;
    }
    return colorScheme.primary;
  }

  Widget _buildButton(BuildContext context, Widget child) {
    final effectiveStyle = _effectiveStyle();
    final pressHandler = _isInteractive ? onPressed : null;
    final hasIcon = icon != null && !isLoading;

    switch (variant) {
      case CustomButtonVariant.primary:
        return hasIcon
            ? FilledButton.icon(
                onPressed: pressHandler,
                style: effectiveStyle,
                icon: Icon(icon, size: 18),
                label: child,
              )
            : FilledButton(
                onPressed: pressHandler,
                style: effectiveStyle,
                child: child,
              );
      case CustomButtonVariant.tonal:
        return hasIcon
            ? FilledButton.tonalIcon(
                onPressed: pressHandler,
                style: effectiveStyle,
                icon: Icon(icon, size: 18),
                label: child,
              )
            : FilledButton.tonal(
                onPressed: pressHandler,
                style: effectiveStyle,
                child: child,
              );
      case CustomButtonVariant.text:
        return hasIcon
            ? TextButton.icon(
                onPressed: pressHandler,
                style: effectiveStyle,
                icon: Icon(icon, size: 18),
                label: child,
              )
            : TextButton(
                onPressed: pressHandler,
                style: effectiveStyle,
                child: child,
              );
      case CustomButtonVariant.outlined:
        return hasIcon
            ? OutlinedButton.icon(
                onPressed: pressHandler,
                style: effectiveStyle,
                icon: Icon(icon, size: 18),
                label: child,
              )
            : OutlinedButton(
                onPressed: pressHandler,
                style: effectiveStyle,
                child: child,
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _loadingColor(context),
            ),
          )
        : _labelText();

    final button = _buildButton(context, child);

    final constraints = fullWidth
        ? BoxConstraints(minWidth: double.infinity, minHeight: height)
        : BoxConstraints(minHeight: height);

    return ConstrainedBox(
      constraints: constraints,
      child: button,
    );
  }
}
