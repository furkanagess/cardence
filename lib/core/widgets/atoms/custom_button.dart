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
/// Metin her zaman ortalanır; [height] buton yüksekliğini belirler.
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

  /// [style] içindeki minimumSize, [height] değerinden büyükse o değer kullanılır.
  double _resolvedHeight() {
    final styleMinHeight =
        style?.minimumSize?.resolve(const <WidgetState>{})?.height ?? 0;
    return styleMinHeight > height ? styleMinHeight : height;
  }

  /// Sabit yükseklik dayatmaz; [height] minimum yükseklik olur ve metin
  /// gerektiğinde büyüyebilmesi için dikey büyüme serbest bırakılır.
  ButtonStyle _effectiveStyle(double resolvedHeight) {
    final base = (style ?? const ButtonStyle()).copyWith(
      alignment: Alignment.center,
      visualDensity: visualDensity ?? VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return base.copyWith(
      minimumSize: WidgetStateProperty.all(
        Size(fullWidth ? double.infinity : 0, resolvedHeight),
      ),
      padding: base.padding ??
          WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16),
          ),
    );
  }

  Widget _labelText() => Text(
        label,
        style: labelStyle,
        textAlign: TextAlign.center,
        textHeightBehavior: const TextHeightBehavior(
          leadingDistribution: TextLeadingDistribution.even,
        ),
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

  Widget _buildButton(
    BuildContext context,
    Widget child,
    double resolvedHeight,
  ) {
    final effectiveStyle = _effectiveStyle(resolvedHeight);
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
    final resolvedHeight = _resolvedHeight();
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

    final button = _buildButton(context, child, resolvedHeight);

    return SizedBox(
      height: resolvedHeight,
      width: fullWidth ? double.infinity : null,
      child: button,
    );
  }
}
