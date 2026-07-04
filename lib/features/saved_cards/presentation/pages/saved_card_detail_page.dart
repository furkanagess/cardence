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
import '../helpers/saved_card_field_l10n.dart';
import '../widgets/saved_card_profile_header.dart';
import '../widgets/saved_card_profile_action_bar.dart';
import '../widgets/saved_card_profile_section.dart';
import '../widgets/saved_card_add_field_sheet.dart';
import '../widgets/saved_cards_saved_card_preview.dart';

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
  late SavedCard _card;
  List<EventGroup> _eventGroups = [];
  bool _loadingGroups = true;

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

  List<EventGroup> get _availableGroupsForCard => _eventGroups
      .where((g) => !_card.linkedEventGroupIds.contains(g.id))
      .toList();

  Future<void> _openAddToEventGroupsSheet() async {
    final available = _availableGroupsForCard;
    if (available.isEmpty) {
      if (!mounted) return;
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

    try {
      await deleteSavedCard(_card.cardId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on AuthApiException {
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
    }
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
      label: SavedCardFieldL10n.label(context.l10n, def.key),
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
      return;
    }
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
      }

  Future<void> _launchWebsiteField() async {
    final website = _card.website?.trim();
    if (website == null || website.isEmpty) return;
    await _launchWebsite(
      website,
      contactType: 'website',
    );
  }

  Future<void> _showMoreMenu() async {
    final colorScheme = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  Icons.copy_all_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: Text(context.l10n.kartId2),
                subtitle: Text(_card.cardId),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _copyToClipboard(context.l10n.kartId2, _card.cardId);
                },
              ),
              if (_canDeleteCard)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                  title: Text(
                    context.l10n.kartSil,
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDeleteCard();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final hasLinkedIn = _has(_card.linkedin);
    final hasEmail = _has(_card.email);
    final hasPhone = _has(_card.phone);
    final about = _card.about?.trim();
    final school = _card.school?.trim();
    final locationText = savedCardProfileLocationText(_card);
    final metaText = savedCardProfileMetaText(context, _card);

    return CardenceScaffold(
      backgroundColor: AppColors.profileDetailBackground,
      showWatermark: false,
      appBar: CardenceAppBar(
        titleWidget: const SizedBox.shrink(),
        backgroundColor: AppColors.pureBlack,
        foregroundColor: AppColors.textPrimaryDark,
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          SavedCardProfileHeader(
            card: _card,
            displayName: _displayName,
            locationText: locationText,
            metaText: metaText,
            onWebsiteTap: _has(_card.website) ? _launchWebsiteField : null,
            onLinkedInTap: hasLinkedIn ? _launchLinkedIn : null,
          ),
          SavedCardProfileActionBar(
            hasEmail: hasEmail,
            hasPhone: hasPhone,
            hasLinkedIn: hasLinkedIn,
            onEmail: hasEmail ? _launchEmail : null,
            onPhone: hasPhone ? _launchPhone : null,
            onLinkedIn: hasLinkedIn ? _launchLinkedIn : null,
            onMore: _showMoreMenu,
          ),
          SavedCardProfileSection(
            title: context.l10n.kartGrnm2,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AspectRatio(
                  aspectRatio: FlippablePersonCard.cardAspectRatio,
                  child: SavedCardsSavedCardPreview(
                    card: _card,
                    heroTag: widget.heroTag,
                  ),
                ),
              ),
            ),
          ),
          if (about != null && about.isNotEmpty)
            SavedCardProfileSection(
              title: context.l10n.hakknda,
              actionLabel: SavedCardFieldCatalog.byKey(SavedCardFieldKey.about)!
                      .isEditable(_card)
                  ? context.l10n.dzenle
                  : null,
              onAction: SavedCardFieldCatalog.byKey(SavedCardFieldKey.about)!
                      .isEditable(_card)
                  ? () => _openEditField(
                        SavedCardFieldCatalog.byKey(SavedCardFieldKey.about)!,
                      )
                  : null,
              child: Text(
                about,
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: AppColors.textPrimaryDark.withValues(alpha: 0.92),
                ),
              ),
            ),
          SavedCardProfileSection(
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
                          const Divider(
                            height: 1,
                            color: AppColors.profileDetailBorder,
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
          if (_skills.isNotEmpty)
            SavedCardProfileSection(
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
          if (school != null && school.isNotEmpty)
            SavedCardProfileSection(
              title: context.l10n.okul,
              actionLabel: SavedCardFieldCatalog.byKey(SavedCardFieldKey.school)!
                      .isEditable(_card)
                  ? context.l10n.dzenle
                  : null,
              onAction: SavedCardFieldCatalog.byKey(SavedCardFieldKey.school)!
                      .isEditable(_card)
                  ? () => _openEditField(
                        SavedCardFieldCatalog.byKey(SavedCardFieldKey.school)!,
                      )
                  : null,
              child: Text(
                school,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
          SavedCardProfileSection(
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
          SavedCardProfileSection(
            title: context.l10n.notlar,
            child: _NotesContainer(
              note: _card.note,
              onAddOrEdit: _openNoteEditor,
            ),
          ),
          ColoredBox(
            color: AppColors.pureBlack,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Center(
                child: Text(
                  _savedAtDescription(_card.savedAt),
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
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

class _GroupedInfoCard extends StatelessWidget {
  const _GroupedInfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.profileDetailSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.profileDetailBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
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
                decoration: const BoxDecoration(
                  color: AppColors.profileDetailSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  field.icon,
                  size: 18,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.label,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      field.value,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: AppColors.textPrimaryDark,
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
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.textSecondaryDark,
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
                    color: AppColors.textSecondaryDark,
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
    final textTheme = Theme.of(context).textTheme;
    final trimmed = note?.trim();
    final hasNote = trimmed != null && trimmed.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.profileDetailSurfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.profileDetailBorder),
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
                      color: AppColors.textPrimaryDark.withValues(alpha: 0.9),
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
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final group in groups)
          ActionChip(
            label: Text(group.name),
            onPressed: canOpenDetail ? () => onGroupTap(group) : null,
            backgroundColor: AppColors.profileDetailSurfaceElevated,
            labelStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDark,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.profileDetailBorder),
            ),
          ),
        if (canAddMore)
          ActionChip(
            avatar: Icon(
              Icons.add_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            label: Text(
              context.l10n.grubaEkle,
              style: TextStyle(color: AppColors.primary),
            ),
            onPressed: onAdd,
            backgroundColor: AppColors.primaryContainerDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.35),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.profileDetailSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.profileDetailBorder),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _SkeletonBar(),
            SizedBox(height: 12),
            _SkeletonBar(widthFactor: 0.72),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    this.widthFactor = 1,
  });

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 14,
        decoration: BoxDecoration(
          color: AppColors.profileDetailSurface,
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
    return _GroupedInfoCard(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppColors.textSecondaryDark.withValues(alpha: 0.65),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
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
