import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../theme/app_colors.dart';

/// Google marka ikonu (Font Awesome Brands).
class GoogleBrandIcon extends StatelessWidget {
  const GoogleBrandIcon({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FaIcon(
      FontAwesomeIcons.google,
      size: size,
      color: AppColors.googleBlue,
    );
  }
}
