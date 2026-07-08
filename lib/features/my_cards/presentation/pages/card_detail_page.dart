import 'dart:convert';
import '../../../../core/l10n/l10n_extensions.dart';

import 'package:cardence/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/utils/clipboard_feedback.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
import '../../../../core/widgets/molecules/card_appearance_customize_section.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../../core/domain/card_visual_effect.dart';
import '../card_customize_colors.dart';
import '../widgets/collapsible_card_preview_panel.dart';
import '../widgets/my_card_preview_helpers.dart';
import '../helpers/card_effect_premium_helper.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import 'my_card_edit_page.dart';
import '../../../saved_cards/domain/entities/card_share_payload.dart';

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
      final resolved = await prepareCardDraftForPersist(context, draftToSave);
      if (!mounted) return;
      if (resolved == null) {
        setState(() => _saving = false);
        return;
      }
      draftToSave = resolved;
      if (resolved.cardEffect != _draft.cardEffect) {
        _applyDraft(resolved);
      }
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

  void _setCardEffect(CardVisualEffect effect) {
    _applyDraft(_draft.copyWith(cardEffect: effect));
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
                      cardEffect: _draft.cardEffect,
                      compact: true,
                      lastUsedPaletteBackgroundColor:
                          _draft.lastUsedPaletteBackgroundColor,
                      previewBuilder: (bg, accent, effect) => AspectRatio(
                        aspectRatio: FlippablePersonCard.cardAspectRatio,
                        child: MyCardPreviewHelpers.flippableCardWithColors(
                          draft: _draft,
                          l10n: context.l10n,
                          backgroundColor: bg,
                          accentColor: accent,
                          cardEffect: effect,
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
                      onEffectChanged: (effect) {
                        _setCardEffect(effect);
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

  String? get _visibleCardId {
    final id = _draft.cardId?.trim();
    if (id == null || id.isEmpty || !CardIdGenerator.isValid(id)) return null;
    return id;
  }

  void _copyCardId(String cardId) {
    copyTextToClipboard(cardId);
    if (!mounted) return;
    showClipboardCopyFeedback(context);
  }

  String _shareMessage(BuildContext context, String cardId) {
    final name = _draft.listTitle;
    return context.l10n.shareCardMessage(name, cardId);
  }

  Future<OnboardingCardDraft> _ensureShareableDraft() async {
    var draftToSave = _draft;
    if (!CardIdGenerator.isValid(draftToSave.cardId)) {
      draftToSave = draftToSave.copyWith(cardId: CardIdGenerator.generateBusinessCandidate());
      _applyDraft(draftToSave);
    }
    if (_hasUnsavedChanges || draftToSave.cardId != _savedDraft.cardId) {
      final resolved = await prepareCardDraftForPersist(context, draftToSave);
      if (!mounted) return draftToSave;
      if (resolved == null) return draftToSave;
      draftToSave = resolved;
      if (resolved.cardEffect != _draft.cardEffect) {
        _applyDraft(resolved);
      }
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
      if (!mounted || cardId == null || !CardIdGenerator.isValid(cardId)) {
        throw AuthApiException(context.l10n.kartIdOluturulamadLtfenTekrar);
      }
      await Share.share(
        _shareMessage(context, cardId),
        subject: context.l10n.shareCardSubject,
      );
    } on AuthApiException {
      if (!mounted) return;
      } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _showShareQrDialog() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    String cardId;
    try {
      final synced = await _ensureShareableDraft();
      cardId = synced.cardId?.trim() ?? '';
      if (!CardIdGenerator.isValid(cardId)) {
        throw AuthApiException(context.l10n.kartIdOluturulamadLtfenTekrar);
      }
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _sharing = false);
            return;
    }
    if (!mounted) return;
    setState(() => _sharing = false);
    final payload = CardSharePayload(
      id: cardId,
      n: _draft.displayName?.trim().isEmpty ?? true ? null : _draft.displayName,
      e: _draft.email?.trim().isEmpty ?? true ? null : _draft.email,
      p: _draft.phone?.trim().isEmpty ?? true ? null : _draft.phone,
      c: _draft.company?.trim().isEmpty ?? true ? null : _draft.company,
      t: _draft.title?.trim().isEmpty ?? true ? null : _draft.title,
      w: _draft.website?.trim().isEmpty ?? true ? null : _draft.website,
      l: _draft.linkedin?.trim().isEmpty ?? true ? null : _draft.linkedin,
      s: _draft.skills?.trim().isEmpty ?? true ? null : _draft.skills,
      o: _draft.school?.trim().isEmpty ?? true ? null : _draft.school,
      h: _draft.about?.trim().isEmpty ?? true ? null : _draft.about,
      ph: _draft.photoUrl?.trim().isEmpty ?? true ? null : _draft.photoUrl,
    );
    final jsonStr = jsonEncode(payload.toJson());
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.qrIlePayla),
        content: SizedBox(
          width: 280,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.scanQrToSaveCard,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: jsonStr,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: AppColors.surfaceLight,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  context.l10n.kartIdCardid,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          CustomButton.text(
            label: context.l10n.kapat,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
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
                      _CardIdTile(
                        cardId: _visibleCardId,
                        onCopy: _visibleCardId == null
                            ? null
                            : () => _copyCardId(_visibleCardId!),
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
                      const SizedBox(height: 8),
                      CustomButton.tonal(
                        label: context.l10n.qrIlePayla,
                        icon: Icons.qr_code_2_rounded,
                        onPressed: _sharing ? null : _showShareQrDialog,
                        enabled: !_sharing,
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

class _CardIdTile extends StatelessWidget {
  const _CardIdTile({
    required this.cardId,
    this.onCopy,
  });

  final String? cardId;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasId = cardId != null;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: hasId ? onCopy : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.kartId2,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasId ? cardId! : context.l10n.createdOnShare,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: hasId ? 2 : 0,
                        fontFeatures: hasId
                            ? const [FontFeature.tabularFigures()]
                            : null,
                      ),
                    ),
                    if (!hasId) ...[
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.kartPaylaDediinizdeBenzersizBir,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasId)
                Icon(
                  Icons.copy_all_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
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
