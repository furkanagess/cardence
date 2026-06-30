import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../core/utils/skills_format.dart';
import '../../../../core/widgets/molecules/skills_chip_display.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../event_groups/domain/entities/event_group.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../event_groups/domain/usecases/delete_event_group.dart';
import '../../../event_groups/domain/usecases/update_event_group.dart';
import '../../../event_groups/domain/usecases/invite_event_group_cards_by_card_id.dart';
import '../../domain/usecases/link_saved_cards_to_event_group.dart';
import '../../../event_groups/presentation/pages/event_group_detail_page.dart';
import '../../../event_groups/presentation/widgets/pick_event_groups_for_card_sheet.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/usecases/delete_saved_card.dart';
import '../../domain/usecases/get_saved_cards.dart';
import '../../domain/usecases/save_saved_card.dart';
import '../../domain/usecases/track_saved_card_contact_click.dart';
import '../../domain/helpers/saved_card_field_catalog.dart';
import '../../domain/extensions/saved_card_preview_colors.dart';
import '../helpers/saved_card_flip_back_entries.dart';
import '../widgets/saved_card_add_field_sheet.dart';

/// Kaydedilen bir kisinin tam detay ekrani: onizleme, hizli aksiyonlar, tum alanlar.
class SavedCardDetailPage extends StatefulWidget {
  const SavedCardDetailPage({
    super.key,
    required this.card,
    required this.onSave,
    required this.getEventGroups,
    this.getSavedCards,
    this.updateEventGroup,
    this.inviteEventGroupCardsByCardId,
    this.deleteEventGroup,
    this.linkSavedCardsToEventGroup,
    this.saveSavedCard,
    this.deleteSavedCard,
    this.trackSavedCardContactClick,
    this.heroTag,
  });

  final SavedCard card;
  final Future<void> Function(SavedCard updated) onSave;
  final GetEventGroups getEventGroups;
  final GetSavedCards? getSavedCards;
  final UpdateEventGroup? updateEventGroup;
  final InviteEventGroupCardsByCardId? inviteEventGroupCardsByCardId;
  final DeleteEventGroup? deleteEventGroup;
  final LinkSavedCardsToEventGroup? linkSavedCardsToEventGroup;
  final SaveSavedCard? saveSavedCard;
  final DeleteSavedCard? deleteSavedCard;
  final TrackSavedCardContactClick? trackSavedCardContactClick;
  final String? heroTag;

  @override
  State<SavedCardDetailPage> createState() => _SavedCardDetailPageState();
}

class _SavedCardDetailPageState extends State<SavedCardDetailPage> {
  static const double _deleteBarContentHeight = 48;
  static const double _deleteBarVerticalPadding = 16;

  late SavedCard _card;
  List<EventGroup> _eventGroups = [];
  bool _loadingGroups = true;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _card = widget.card;
    _loadEventGroups();
  }

  Future<void> _loadEventGroups() async {
    final groups = await widget.getEventGroups();
    if (!mounted) return;
    setState(() {
      _eventGroups = groups;
      _loadingGroups = false;
    });
  }

  List<EventGroup> get _linkedGroups => _eventGroups
      .where((g) => _card.linkedEventGroupIds.contains(g.id))
      .toList();

  bool get _hasLinkedGroups => _linkedGroups.isNotEmpty;

  bool get _canOpenGroupDetail =>
      widget.getSavedCards != null &&
      widget.updateEventGroup != null &&
      widget.inviteEventGroupCardsByCardId != null &&
      widget.deleteEventGroup != null &&
      widget.linkSavedCardsToEventGroup != null &&
      widget.saveSavedCard != null &&
      widget.deleteSavedCard != null;

  bool get _canAddToMoreGroups =>
      !_loadingGroups && _availableGroupsForCard.isNotEmpty;

  bool get _isDemoCard => _card.cardId.startsWith('dummy-');

  bool get _canDeleteCard => widget.deleteSavedCard != null && !_isDemoCard;

  double _deleteBarInset(BuildContext context) {
    if (!_canDeleteCard) return 0;
    return MediaQuery.paddingOf(context).bottom +
        _deleteBarVerticalPadding +
        _deleteBarContentHeight +
        _deleteBarVerticalPadding;
  }

  List<EventGroup> get _availableGroupsForCard => _eventGroups
      .where((g) => !_card.linkedEventGroupIds.contains(g.id))
      .toList();

  Future<void> _openAddToEventGroupsSheet() async {
    final available = _availableGroupsForCard;
    if (available.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _eventGroups.isEmpty
                ? context.l10n.henzEtkinlikGrubuYok
                : AppL10n.cardAlreadyInAllGroups(context.l10n),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedIds = await PickEventGroupsForCardSheet.show(
      context,
      groups: available,
      cardTitle: _displayName,
    );
    if (!mounted || selectedIds == null || selectedIds.isEmpty) return;

    final ids = List<String>.from(_card.linkedEventGroupIds);
    for (final groupId in selectedIds) {
      if (!ids.contains(groupId)) ids.add(groupId);
    }
    await _persistCard(_card.copyWith(linkedEventGroupIds: ids));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppL10n.addedToGroupsMessage(context.l10n, selectedIds.length)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openEventGroupDetail(EventGroup group) async {
    if (!_canOpenGroupDetail) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => EventGroupDetailPage(
          group: group,
          getEventGroups: widget.getEventGroups,
          updateEventGroup: widget.updateEventGroup!,
          inviteEventGroupCardsByCardId:
              widget.inviteEventGroupCardsByCardId!,
          deleteEventGroup: widget.deleteEventGroup!,
          linkSavedCardsToEventGroup: widget.linkSavedCardsToEventGroup!,
          getSavedCards: widget.getSavedCards!,
          saveSavedCard: widget.saveSavedCard!,
          deleteSavedCard: widget.deleteSavedCard!,
        ),
      ),
    );
    if (!mounted) return;
    await Future.wait([_loadEventGroups(), _refreshCardFromStorage()]);
  }

  Future<void> _confirmDeleteCard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.kartSil),
        content: Text(
          AppL10n.deleteCardConfirmQuestion(context.l10n, _displayName),
        ),
        actions: [
          CustomButton.text(
            label: context.l10n.iptal,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CustomButton(
            label: context.l10n.sil,
            onPressed: () => Navigator.of(context).pop(true),
            fullWidth: false,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _deleteCard();
  }

  Future<void> _deleteCard() async {
    final deleteSavedCard = widget.deleteSavedCard;
    if (deleteSavedCard == null) return;

    setState(() => _deleting = true);
    try {
      await deleteSavedCard(_card.cardId);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppL10n.cardDeletedFromWalletMessage(context.l10n, _displayName)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.kartSilinemediLtfenTekrarDeneyin),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildStickyDeleteBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          _deleteBarVerticalPadding,
        ),
        child: Material(
          color: Colors.transparent,
          child: CustomButton(
            label: context.l10n.kartCzdandanSil,
            icon: Icons.delete_outline_rounded,
            onPressed: _deleting ? null : _confirmDeleteCard,
            isLoading: _deleting,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 8,
              shadowColor: AppColors.error.withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshCardFromStorage() async {
    final getSavedCards = widget.getSavedCards;
    if (getSavedCards == null) return;
    final cards = await getSavedCards();
    if (!mounted) return;
    for (final card in cards) {
      if (card.cardId == _card.cardId) {
        setState(() => _card = card);
        return;
      }
    }
  }

  Future<void> _persistCard(SavedCard updated) async {
    await widget.onSave(updated);
    if (!mounted) return;
    setState(() => _card = updated);
  }

  String get _displayName {
    final name = _card.displayName?.trim();
    if (name == null || name.isEmpty) {
      return '${AppL10n.kart(context.l10n)} ${_card.cardId}';
    }
    return name;
  }

  bool get _canAddFields =>
      !_isDemoCard && SavedCardFieldCatalog.addableFields(_card).isNotEmpty;

  List<SavedCardFieldDefinition> get _infoFields {
    return SavedCardFieldCatalog.filledFields(_card)
        .where((def) => def.key != SavedCardFieldKey.skills)
        .toList();
  }

  Future<void> _openAddFieldFlow() async {
    final key = await SavedCardAddFieldSheet.pickFieldToAdd(
      context,
      card: _card,
    );
    if (!mounted || key == null) return;
    final def = SavedCardFieldCatalog.byKey(key);
    if (def == null) return;
    await _openEditField(def);
  }

  Future<void> _openEditField(SavedCardFieldDefinition def) async {
    if (!def.isEditable(_card)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.buAlanCardenceKartndaDzenlenemez),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final value = await SavedCardAddFieldSheet.editFieldValue(
      context,
      definition: def,
      initialValue: def.readValue(_card),
    );
    if (!mounted || value == null) return;

    final updated = def.writeValue(_card, value);
    await _persistCard(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppL10n.fieldSaved(context.l10n, def.label)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  _ContactFieldData _contactDataFor(SavedCardFieldDefinition def) {
    final value = def.readValue(_card)!.trim();
    VoidCallback? onTap;
    var trailing = _ContactTrailingAction.copy;

    if (def.isLink) {
      trailing = _ContactTrailingAction.openLink;
      onTap = () => _launchWebsite(value, contactType: _contactTypeFor(def));
    } else if (def.key == SavedCardFieldKey.email) {
      onTap = _launchEmail;
    } else if (def.key == SavedCardFieldKey.phone) {
      onTap = _launchPhone;
    }

    return _ContactFieldData(
      label: def.label,
      value: value,
      icon: SavedCardFieldIcons.iconFor(def.iconName),
      trailing: trailing,
      onTap: onTap,
      onEdit: def.isEditable(_card) ? () => _openEditField(def) : null,
    );
  }

  List<_ContactFieldData> get _contactFields {
    return _infoFields.map(_contactDataFor).toList();
  }

  List<String> get _skills => SkillsFormat.parse(_card.skills);

  List<String> get _visibleContactFields {
    final keys = <String>[];
    if (_has(_card.email)) keys.add('email');
    if (_has(_card.phone)) keys.add('phone');
    if (_has(_card.linkedin)) keys.add('linkedin');
    if (_has(_card.website)) keys.add('website');
    return keys;
  }

  List<({String label, String value})> get _previewBackEntries =>
      savedCardFlipBackEntries(_card, context.l10n);

  bool _has(String? value) => value != null && value.trim().isNotEmpty;

  String _formatSavedAt(int? ms) {
    if (ms == null) return context.l10n.bilinmiyor;
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    const months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _savedAtDescription(int? ms) {
    if (ms == null) return context.l10n.kaydedildiTarihBilinmiyor;
    return AppL10n.savedAtLabel(context.l10n, _formatSavedAt(ms));
  }

  Future<void> _copyToClipboard(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppL10n.copiedToClipboardMessage(context.l10n, label)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchLinkedIn() async {
    final linkedin = _card.linkedin?.trim();
    if (linkedin == null || linkedin.isEmpty) return;
    await _launchWebsite(
      linkedin,
      contactType: 'linkedin',
      errorMessage: context.l10n.linkedinAlamad,
    );
  }

  Future<void> _launchEmail() async {
    final email = _card.email?.trim();
    if (email == null || email.isEmpty) return;
    unawaited(_trackContactClick('email'));
    await ContactLauncher.launchEmail(context, email);
  }

  Future<void> _launchPhone() async {
    final phone = _card.phone?.trim();
    if (phone == null || phone.isEmpty) return;
    unawaited(_trackContactClick('phone'));
    await ContactLauncher.launchPhone(context, phone);
  }

  Future<void> _launchWebsite(
    String url, {
    String contactType = 'website',
    String? errorMessage,
  }) async {
    unawaited(_trackContactClick(contactType));
    var normalized = url.trim();
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      final defaultErrorMsg = AppL10n.couldNotOpenLink(context.l10n);
      _showLaunchError(errorMessage ?? defaultErrorMsg);
    }
  }

  void _showLaunchError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _contactTypeFor(SavedCardFieldDefinition def) {
    return switch (def.key) {
      SavedCardFieldKey.linkedin => 'linkedin',
      SavedCardFieldKey.website => 'website',
      _ => 'website',
    };
  }

  Future<void> _trackContactClick(String contactType) async {
    final tracker = widget.trackSavedCardContactClick;
    if (tracker == null) return;

    try {
      await tracker(cardId: _card.cardId, contactType: contactType);
    } catch (_) {
      // Telemetry should never block the user's contact action.
    }
  }

  Future<void> _openNoteEditor() async {
    var draftNote = _card.note ?? '';
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.kiiNotu,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.toplantProjeVeyaHatrlatmaNotu,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: draftNote,
                      minLines: 4,
                      maxLines: 8,
                      maxLength: 500,
                      onChanged: (value) =>
                          setModalState(() => draftNote = value),
                      decoration: InputDecoration(
                        hintText: context.l10n.notunuzuBurayaYazn,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: context.l10n.kaydet,
                      onPressed: () =>
                          Navigator.of(context).pop(draftNote.trim()),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (!mounted || note == null) return;
    final updated = _card.copyWith(
      note: note.isEmpty ? null : note,
      clearNote: note.isEmpty,
    );
    await _persistCard(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.notKaydedildi),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final hasLinkedIn = _has(_card.linkedin);
    final hasEmail = _has(_card.email);
    final hasPhone = _has(_card.phone);
    final showQuickActions = hasLinkedIn || hasEmail || hasPhone;
    final companyName = _card.company?.trim();

    final cardPreview = FlippablePersonCard(
      title: _displayName,
      titleSecondary: companyName,
      jobTitle: _card.title?.trim(),
      photoUrl: _card.photoUrl,
      accentColor: _card.previewAccentColor,
      backgroundColor: _card.previewBackgroundColor,
      frontEntries: const [],
      backEntries: _previewBackEntries,
      emptyMessage: context.l10n.kartBilgisiYok,
      cardId: _card.cardId,
      onBackEmptyActionTap:
          savedCardShouldOfferFlipBackNote(_card) ? _openNoteEditor : null,
      backEmptyActionLabel: context.l10n.notEkle,
      onBackEditTap: _openNoteEditor,
      contactEmail: _card.email,
      contactPhone: _card.phone,
      contactWebsite: _card.website,
      contactLinkedin: _card.linkedin,
      visibleContactFields: _visibleContactFields,
      showPremiumBadge: _card.isOwnerPremium,
    );

    final preview = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: cardPreview,
      ),
    );

    final bottomInset = _deleteBarInset(context);

    return CardenceScaffold(
      appBar: CardenceAppBar(
        title: _displayName,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 32 + bottomInset),
            children: [
              if (widget.heroTag != null)
                Hero(
                  tag: widget.heroTag!,
                  child: Material(
                    color: Colors.transparent,
                    child: preview,
                  ),
                )
              else
                preview,
              if (showQuickActions) ...[
                const SizedBox(height: 20),
                _CircularQuickActionsRow(
                  hasLinkedIn: hasLinkedIn,
                  hasEmail: hasEmail,
                  hasPhone: hasPhone,
                  onLinkedIn: _launchLinkedIn,
                  onEmail: _launchEmail,
                  onPhone: _launchPhone,
                ),
              ],
              const SizedBox(height: 24),
              _DetailSection(
                title: context.l10n.bilgiler,
                actionLabel: _canAddFields ? context.l10n.bilgiEkle : null,
                onAction: _canAddFields ? _openAddFieldFlow : null,
                child: _contactFields.isEmpty
                    ? _EmptyStateCard(
                        icon: Icons.contact_page_outlined,
                        message: _canAddFields
                            ? AppL10n.noExtraInfoYet(context.l10n)
                            : AppL10n.noExtraInfoInThisCard(context.l10n),
                        actionLabel:
                            _canAddFields ? context.l10n.bilgiEkle : null,
                        onAction: _canAddFields ? _openAddFieldFlow : null,
                      )
                    : _GroupedInfoCard(
                        children: [
                          for (var i = 0; i < _contactFields.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            _ContactFieldRow(
                              field: _contactFields[i],
                              onCopy: () => _copyToClipboard(
                                _contactFields[i].label,
                                _contactFields[i].value,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              if (_skills.isNotEmpty) ...[
                const SizedBox(height: 24),
                _DetailSection(
                  title: context.l10n.yetenekler,
                  actionLabel:
                      SavedCardFieldCatalog.byKey(SavedCardFieldKey.skills)!
                              .isEditable(_card)
                          ? context.l10n.dzenle
                          : null,
                  onAction:
                      SavedCardFieldCatalog.byKey(SavedCardFieldKey.skills)!
                              .isEditable(_card)
                          ? () => _openEditField(
                                SavedCardFieldCatalog.byKey(
                                    SavedCardFieldKey.skills)!,
                              )
                          : null,
                  child: SkillsChipDisplay(
                    skills: _skills,
                    onSkillTap: (skill) => _copyToClipboard(
                      AppL10n.nodeTypeSkill(context.l10n),
                      skill,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _DetailSection(
                title: context.l10n.katldEtkinlikler,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _loadingGroups
                      ? const _EventGroupsLoadingSkeleton(
                          key: ValueKey('event_groups_loading'),
                        )
                      : _EventGroupsChipRow(
                          key: ValueKey(
                            'event_groups_chips_${_linkedGroups.length}',
                          ),
                          groups: _linkedGroups,
                          canOpenDetail: _canOpenGroupDetail,
                          canAddMore: _canAddToMoreGroups || !_hasLinkedGroups,
                          onGroupTap: _openEventGroupDetail,
                          onAdd: _openAddToEventGroupsSheet,
                        ),
                ),
              ),
              const SizedBox(height: 24),
              _DetailSection(
                title: context.l10n.notlar,
                child: _NotesContainer(
                  note: _card.note,
                  onAddOrEdit: _openNoteEditor,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _savedAtDescription(_card.savedAt),
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          if (_canDeleteCard)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildStickyDeleteBar(context),
            ),
        ],
      ),
    );
  }
}

class _ContactFieldData {
  const _ContactFieldData({
    required this.label,
    required this.value,
    required this.icon,
    this.trailing = _ContactTrailingAction.copy,
    this.onTap,
    this.onEdit,
  });

  final String label;
  final String value;
  final IconData icon;
  final _ContactTrailingAction trailing;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
}

enum _ContactTrailingAction { copy, openLink }

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null)
                CustomButton.text(
                  label: actionLabel!,
                  onPressed: onAction,
                  height: 0,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _GroupedInfoCard extends StatelessWidget {
  const _GroupedInfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}

class _CircularQuickActionsRow extends StatelessWidget {
  const _CircularQuickActionsRow({
    required this.hasLinkedIn,
    required this.hasEmail,
    required this.hasPhone,
    required this.onLinkedIn,
    required this.onEmail,
    required this.onPhone,
  });

  final bool hasLinkedIn;
  final bool hasEmail;
  final bool hasPhone;
  final VoidCallback onLinkedIn;
  final VoidCallback onEmail;
  final VoidCallback onPhone;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    void addButton(Widget button) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 20));
      buttons.add(button);
    }

    if (hasLinkedIn) {
      addButton(
        _CircularQuickActionButton(
          icon: Icons.link_rounded,
          onTap: onLinkedIn,
        ),
      );
    }
    if (hasEmail) {
      addButton(
        _CircularQuickActionButton(
          icon: Icons.mail_outline_rounded,
          onTap: onEmail,
        ),
      );
    }
    if (hasPhone) {
      addButton(
        _CircularQuickActionButton(
          icon: Icons.phone_outlined,
          onTap: onPhone,
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons,
    );
  }
}

class _CircularQuickActionButton extends StatelessWidget {
  const _CircularQuickActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Icon(
            icon,
            size: 24,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ContactFieldRow extends StatelessWidget {
  const _ContactFieldRow({
    required this.field,
    required this.onCopy,
  });

  final _ContactFieldData field;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canOpen = field.onTap != null;
    final canEdit = field.onEdit != null;
    final trailingIcon = field.trailing == _ContactTrailingAction.openLink
        ? Icons.open_in_new_rounded
        : Icons.copy_all_rounded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canEdit ? field.onEdit : field.onTap,
        onLongPress: canEdit ? field.onEdit : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  field.icon,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.label,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      field.value,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (canEdit)
                IconButton(
                  tooltip: context.l10n.dzenle,
                  visualDensity: VisualDensity.compact,
                  onPressed: field.onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              if (canOpen || !canEdit)
                IconButton(
                  tooltip: canOpen ? AppL10n.open(context.l10n) : context.l10n.kopyala,
                  visualDensity: VisualDensity.compact,
                  onPressed: canOpen ? field.onTap : onCopy,
                  icon: Icon(
                    trailingIcon,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotesContainer extends StatelessWidget {
  const _NotesContainer({
    required this.note,
    required this.onAddOrEdit,
  });

  final String? note;
  final VoidCallback onAddOrEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final trimmed = note?.trim();
    final hasNote = trimmed != null && trimmed.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasNote ? onAddOrEdit : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: hasNote
                ? Text(
                    '"$trimmed"',
                    style: textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface.withValues(alpha: 0.88),
                    ),
                  )
                : Center(
                    child: CustomButton.tonal(
                      label: context.l10n.notEkle,
                      icon: Icons.add_rounded,
                      onPressed: onAddOrEdit,
                      fullWidth: false,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _EventGroupsChipRow extends StatelessWidget {
  const _EventGroupsChipRow({
    super.key,
    required this.groups,
    required this.canOpenDetail,
    required this.canAddMore,
    required this.onGroupTap,
    required this.onAdd,
  });

  final List<EventGroup> groups;
  final bool canOpenDetail;
  final bool canAddMore;
  final void Function(EventGroup group) onGroupTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final group in groups)
          ActionChip(
            label: Text(group.name),
            onPressed: canOpenDetail ? () => onGroupTap(group) : null,
            backgroundColor: colorScheme.surfaceContainerHighest,
            labelStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        if (canAddMore)
          ActionChip(
            avatar: Icon(
              Icons.add_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
            label: Text(
              context.l10n.grubaEkle,
              style: TextStyle(color: colorScheme.primary),
            ),
            onPressed: onAdd,
            backgroundColor:
                colorScheme.primaryContainer.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
          ),
      ],
    );
  }
}

class _EventGroupsLoadingSkeleton extends StatelessWidget {
  const _EventGroupsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SkeletonBar(colorScheme: colorScheme),
            const SizedBox(height: 12),
            _SkeletonBar(colorScheme: colorScheme, widthFactor: 0.72),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.colorScheme,
    this.widthFactor = 1,
  });

  final ColorScheme colorScheme;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 14,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _GroupedInfoCard(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 14),
                CustomButton.tonal(
                  label: actionLabel!,
                  icon: Icons.add_rounded,
                  onPressed: onAction,
                  fullWidth: false,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
