import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';

class LegalSection {
  const LegalSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.sections,
    this.bottomBar,
  });

  final String title;
  final List<LegalSection> sections;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return CardenceScaffold(
      appBar: CardenceAppBar(title: title),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: bottomBar == null,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < sections.length; i++) ...[
                      if (i > 0) const SizedBox(height: 20),
                      Text(
                        sections[i].title,
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sections[i].body,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (bottomBar != null) bottomBar!,
        ],
      ),
    );
  }
}
