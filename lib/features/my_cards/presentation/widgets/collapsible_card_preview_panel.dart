import 'package:flutter/material.dart';

import 'my_card_preview_helpers.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';

/// Kart önizlemesi: başlığa dokunarak açılır / kapanır.
class CollapsibleCardPreviewPanel extends StatefulWidget {
  const CollapsibleCardPreviewPanel({
    super.key,
    required this.draft,
    this.initiallyExpanded = true,
    this.isLivePreview = false,
    this.emptyMessage = 'Bilgi girildikçe kartta görünür',
  });

  final OnboardingCardDraft draft;
  final bool initiallyExpanded;

  /// Düzenleme ekranında canlı güncelleme rozeti ve kısa açıklama.
  final bool isLivePreview;
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

  String? get _collapsedSubtitle {
    final name = widget.draft.displayName?.trim();
    final company = widget.draft.company?.trim();
    if (name != null && name.isNotEmpty && company != null && company.isNotEmpty) {
      return '$name · $company';
    }
    if (name != null && name.isNotEmpty) return name;
    if (company != null && company.isNotEmpty) return company;
    return widget.draft.cardName?.trim();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kart önizleme',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!_expanded) ...[
                            const SizedBox(height: 2),
                            Text(
                              _collapsedSubtitle?.isNotEmpty == true
                                  ? _collapsedSubtitle!
                                  : 'Önizlemeyi görmek için dokunun',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ] else if (widget.isLivePreview) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Değişiklikler anında yansır',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.isLivePreview && _expanded)
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Canlı',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
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
