import 'package:flutter/material.dart';

import 'my_card_preview_helpers.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';

/// Kart önizlemesi: başlığa dokunarak açılır / kapanır.
class CollapsibleCardPreviewPanel extends StatefulWidget {
  const CollapsibleCardPreviewPanel({
    super.key,
    required this.draft,
    this.initiallyExpanded = false,
    this.emptyMessage = 'Bilgi girildikçe kartta görünür',
  });

  final OnboardingCardDraft draft;
  final bool initiallyExpanded;
  final String emptyMessage;

  @override
  State<CollapsibleCardPreviewPanel> createState() =>
      _CollapsibleCardPreviewPanelState();
}

class _CollapsibleCardPreviewPanelState extends State<CollapsibleCardPreviewPanel> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final pageColor = theme.scaffoldBackgroundColor;

    return Material(
      color: pageColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: _expanded ? 'Önizlemeyi gizle' : 'Önizlemeyi göster',
            child: InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.credit_card_outlined,
                      size: 22,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kart önizleme',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            sizeCurve: Curves.easeInOut,
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: MyCardPreviewHelpers.flippableCard(
                draft: widget.draft,
                emptyMessage: widget.emptyMessage,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
