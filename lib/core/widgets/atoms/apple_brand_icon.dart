import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../theme/app_colors.dart';

/// Apple marka ikonu (Font Awesome Brands).
class AppleBrandIcon extends StatelessWidget {
  const AppleBrandIcon({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FaIcon(
      FontAwesomeIcons.apple,
      size: size,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    );
  }
}
