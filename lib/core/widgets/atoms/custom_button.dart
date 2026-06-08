import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Uygulama genelinde birincil aksiyon butonu.
///
/// Tema [FilledButtonTheme] ile uyumludur; tüm ekranlarda bu widget kullanılmalıdır.
enum CustomButtonVariant {
  primary,
  tonal,
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

  static ButtonStyle _effectiveStyle(
    ButtonStyle? style, {
    VisualDensity? visualDensity,
  }) {
    return (style ?? const ButtonStyle()).copyWith(
      alignment: Alignment.center,
      visualDensity: visualDensity,
    );
  }

  Widget _labelText() => Text(
        label,
        style: labelStyle,
        textAlign: TextAlign.center,
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loadingColor = variant == CustomButtonVariant.primary
        ? (Theme.of(context).brightness == Brightness.light
            ? AppColors.textOnPrimary
            : AppColors.backgroundDark)
        : colorScheme.primary;

    if (isLoading) {
      final loadingButton = FilledButton(
        onPressed: null,
        style: _effectiveStyle(style),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: loadingColor,
          ),
        ),
      );
      if (!fullWidth) return loadingButton;
      return SizedBox(width: double.infinity, height: height, child: loadingButton);
    }

    final Widget button;
    switch (variant) {
      case CustomButtonVariant.primary:
        button = icon != null
            ? FilledButton.icon(
                onPressed: _isInteractive ? onPressed : null,
                style: _effectiveStyle(style),
                icon: Icon(icon, size: 18),
                label: _labelText(),
              )
            : FilledButton(
                onPressed: _isInteractive ? onPressed : null,
                style: _effectiveStyle(style),
                child: _labelText(),
              );
      case CustomButtonVariant.tonal:
        button = icon != null
            ? FilledButton.tonalIcon(
                onPressed: _isInteractive ? onPressed : null,
                style: _effectiveStyle(style, visualDensity: visualDensity),
                icon: Icon(icon, size: 18),
                label: _labelText(),
              )
            : FilledButton.tonal(
                onPressed: _isInteractive ? onPressed : null,
                style: _effectiveStyle(style, visualDensity: visualDensity),
                child: _labelText(),
              );
    }

    if (!fullWidth) return button;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: button,
    );
  }
}
