import 'package:flutter/material.dart';

import '../atoms/card_watermark.dart';

/// Tüm ekranlarda merkezi filigranlı [Scaffold] sarmalayıcısı.
class CardenceScaffold extends StatelessWidget {
  const CardenceScaffold({
    super.key,
    this.appBar,
    this.body,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.resizeToAvoidBottomInset,
    this.floatingActionButton,
    this.showWatermark = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final bool? resizeToAvoidBottomInset;
  final Widget? floatingActionButton;
  final bool showWatermark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    Widget? wrappedBody = body;
    if (wrappedBody != null && showWatermark) {
      wrappedBody = Stack(
        fit: StackFit.expand,
        children: [
          CardWatermark(
            surfaceColor: pageColor,
            variant: CardWatermarkVariant.screen,
          ),
          wrappedBody,
        ],
      );
    }

    final scaffold = Scaffold(
      appBar: appBar,
      backgroundColor: pageColor,
      body: wrappedBody,
      bottomNavigationBar: bottomNavigationBar,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
    );

    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: pageColor,
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: pageColor,
        ),
      ),
      child: scaffold,
    );
  }
}
