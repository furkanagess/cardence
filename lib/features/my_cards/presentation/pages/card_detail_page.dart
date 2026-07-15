import '../../../../core/l10n/l10n_extensions.dart';

import 'package:cardence/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
import '../../../../core/widgets/molecules/card_appearance_customize_section.dart';
import '../../../../core/widgets/organisms/card_share_options_sheet.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../card_customize_colors.dart';
import '../widgets/collapsible_card_preview_panel.dart';
import '../widgets/my_card_preview_helpers.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import 'my_card_edit_page.dart';

/// Tek bir kartın detay ekranı; önizleme, kartı özelleştir (bottom sheet) ve paylaşım.
class CardDetailPage extends StatefulWidget {
  const CardDetailPage({
    super.key,
    required this.draft,
    required this.persistOnboardingCard,
    this.onDraftUpdated,
  });

  final OnboardingCardDraft draft;
  final PersistOnboardingCard persistOnboardingCard;
  final ValueChanged<OnboardingCardDraft>? onDraftUpdated;

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late OnboardingCardDraft _draft;
  late OnboardingCardDraft _savedDraft;
  bool _saving = false;
  bool _sharing = false;

  bool get _hasUnsavedChanges => !_draft.contentEquals(_savedDraft);

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _savedDraft = widget.draft;
  }

  void _applyDraft(OnboardingCardDraft updated) {
    setState(() => _draft = updated);
  }

  Future<void> _save() async {
    if (_saving || !_hasUnsavedChanges) return;
    setState(() => _saving = true);
    var draftToSave = _draft;
    if (!CardIdGenerator.isValid(draftToSave.cardId)) {
      draftToSave = draftToSave.copyWith(cardId: CardIdGenerator.generateBusinessCandidate());
    }
    try {
      final synced = await widget.persistOnboardingCard(draftToSave);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _draft = synced;
        _savedDraft = synced;
      });
      widget.onDraftUpdated?.call(synced);
          } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
          } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
          }
  }

  Future<bool> _confirmDiscardChanges() {
    return CardenceConfirmDialog.show(
      context,
      title: context.l10n.kaydedilmemiDeiiklikler,
      message:
          context.l10n.yaptnzDeiikliklerKaydedilmedikmakIstediinize,
      confirmLabel: context.l10n.k,
      cancelLabel: context.l10n.iptal,
      icon: Icons.warning_amber_rounded,
      confirmIsDestructive: true,
    ).then((value) => value == true);
  }

  void _setDefaultBackground() {
    _applyDraft(_draft.copyWith(clearBackgroundColor: true));
  }

  void _setBackgroundColor(String hex) {
    _applyDraft(_draft.copyWith(backgroundColor: hex));
  }

  void _setBackgroundColorFromPalette(String hex) {
    _applyDraft(
      _draft.copyWith(
        backgroundColor: hex,
        lastUsedPaletteBackgroundColor: hex,
      ),
    );
  }

  void _setDefaultTextColor() {
    _applyDraft(_draft.copyWith(clearAccentColor: true));
  }

  void _setTextColor(String hex) {
    _applyDraft(_draft.copyWith(accentColor: hex));
  }

  void _showCustomizeBottomSheet() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.88,
              minChildSize: 0.45,
              maxChildSize: 0.92,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    16 + MediaQuery.paddingOf(sheetContext).bottom,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      context.l10n.kartzelletir,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.arkaPlanVeMetinRengi,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    CardAppearanceCustomizeSection(
                      backgroundColor: _draft.backgroundColor,
                      accentColor: _draft.accentColor,
                      compact: true,
                      lastUsedPaletteBackgroundColor:
                          _draft.lastUsedPaletteBackgroundColor,
                      previewBuilder: (bg, accent) => AspectRatio(
                        aspectRatio: FlippablePersonCard.cardAspectRatio,
                        child: MyCardPreviewHelpers.flippableCardWithColors(
                          draft: _draft,
                          l10n: context.l10n,
                          backgroundColor: bg,
                          accentColor: accent,
                        ),
                      ),
                      onBackgroundColorChanged: (hex) {
                        if (hex == null) {
                          _setDefaultBackground();
                        } else if (cardBackgroundColorOptions.contains(hex) ||
                            hex == _draft.lastUsedPaletteBackgroundColor) {
                          _setBackgroundColor(hex);
                        } else {
                          _setBackgroundColorFromPalette(hex);
                        }
                        setSheetState(() {});
                      },
                      onAccentColorChanged: (hex) {
                        if (hex == null) {
                          _setDefaultTextColor();
                        } else {
                          _setTextColor(hex);
                        }
                        setSheetState(() {});
                      },
                      onLastUsedPaletteBackgroundChanged: (hex) {
                        _setBackgroundColorFromPalette(hex);
                        setSheetState(() {});
                      },
                      showSaveButton: true,
                      onSave: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<OnboardingCardDraft> _ensureShareableDraft() async {
    var draftToSave = _draft;
    if (!CardIdGenerator.isValid(draftToSave.cardId)) {
      draftToSave = draftToSave.copyWith(cardId: CardIdGenerator.generateBusinessCandidate());
      _applyDraft(draftToSave);
    }
    if (_hasUnsavedChanges || draftToSave.cardId != _savedDraft.cardId) {
      final synced = await widget.persistOnboardingCard(draftToSave);
      if (!mounted) return synced;
      setState(() {
        _draft = synced;
        _savedDraft = synced;
      });
      widget.onDraftUpdated?.call(synced);
      return synced;
    }
    return draftToSave;
  }

  Future<void> _shareCard() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final synced = await _ensureShareableDraft();
      final cardId = synced.cardId?.trim();
      if (!mounted) return;
      if (cardId == null || !CardIdGenerator.isValid(cardId)) {
        throw AuthApiException(context.l10n.kartIdOluturulamadLtfenTekrar);
      }
      await CardShareOptionsSheet.show(
        context,
        cardId: cardId,
      );
    } on AuthApiException {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_hasUnsavedChanges) return;
        final shouldLeave = await _confirmDiscardChanges();
        if (!mounted || !shouldLeave) return;
        Navigator.of(context).pop();
      },
      child: CardenceScaffold(
      appBar: CardenceAppBar(
        variant: CardenceAppBarVariant.editor,
        title: _draft.listTitle,
        actions: [
          CardenceAppBar.textAction(
            label: context.l10n.kaydet,
            onPressed: _hasUnsavedChanges ? _save : null,
            loading: _saving,
          ),
          CardenceAppBar.iconAction(
            icon: Icons.edit_outlined,
            tooltip: context.l10n.bilgileriDzenle,
            onPressed: () async {
              final updated =
                  await Navigator.of(context).push<OnboardingCardDraft>(
                MaterialPageRoute(
                  builder: (context) => MyCardEditPage(
                    initialDraft: _draft,
                    persistOnboardingCard: widget.persistOnboardingCard,
                    onDraftUpdated: (synced) {
                      widget.onDraftUpdated?.call(synced);
                      if (!mounted) return;
                      setState(() {
                        _draft = synced;
                        _savedDraft = synced;
                      });
                    },
                  ),
                ),
              );
              if (!mounted || updated == null) return;
              setState(() {
                _draft = updated;
                _savedDraft = updated;
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CollapsibleCardPreviewPanel(
            draft: _draft,
            emptyMessage: context.l10n.kartBilgisiYokDzenleIle,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                _DetailSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        title: context.l10n.grnm,
                        subtitle: context.l10n.arkaPlanMetinRengiVe,
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: context.l10n.kartzelletir,
                        icon: Icons.palette_outlined,
                        onPressed: _showCustomizeBottomSheet,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _DetailSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        title: context.l10n.kartnzPaylan,
                        subtitle: context.l10n.shareCardIdSubtitle,
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: context.l10n.kartPayla,
                        icon: Icons.share_outlined,
                        onPressed: _shareCard,
                        isLoading: _sharing,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
