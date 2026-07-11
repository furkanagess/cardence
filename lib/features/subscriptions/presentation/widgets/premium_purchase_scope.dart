import 'package:flutter/widgets.dart';

import '../helpers/premium_purchase_success_handler.dart';

/// Satın alma sonrası başarı akışına erişim sağlar.
class PremiumPurchaseScope extends InheritedWidget {
  const PremiumPurchaseScope({
    super.key,
    required this.handler,
    required super.child,
  });

  final PremiumPurchaseSuccessHandler handler;

  static PremiumPurchaseSuccessHandler? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PremiumPurchaseScope>()
        ?.handler;
  }

  @override
  bool updateShouldNotify(PremiumPurchaseScope oldWidget) =>
      handler != oldWidget.handler;
}
