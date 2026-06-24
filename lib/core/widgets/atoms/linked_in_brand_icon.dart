import 'package:flutter/material.dart';

/// LinkedIn marka ikonu (`linkedin_login` paketinden).
class LinkedInBrandIcon extends StatelessWidget {
  const LinkedInBrandIcon({
    super.key,
    this.size = 24,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/linked_in_logo.png',
      package: 'linkedin_login',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
