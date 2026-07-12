import 'package:flutter/material.dart';

import '../../../../core/widgets/molecules/create_card_button.dart';

/// Boş kart slotu: yeni kart oluşturma aksiyonu.
class EmptyCardSlotPreview extends StatelessWidget {
  const EmptyCardSlotPreview({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CreateCardButton(
            label: label,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
