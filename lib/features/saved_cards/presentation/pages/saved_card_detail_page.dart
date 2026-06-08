import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../event_groups/domain/entities/event_group.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../event_groups/domain/usecases/save_event_groups.dart';
import '../../../event_groups/presentation/pages/event_group_detail_page.dart';
import '../../../event_groups/presentation/widgets/pick_event_groups_for_card_sheet.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/usecases/delete_saved_card.dart';
import '../../domain/usecases/get_saved_cards.dart';
import '../../domain/usecases/save_saved_card.dart';

/// Kaydedilen bir kisinin tam detay ekrani: onizleme, hizli aksiyonlar, tum alanlar.
class SavedCardDetailPage extends StatefulWidget {
  const SavedCardDetailPage({
    super.key,
    required this.card,
    required this.onSave,
    required this.getEventGroups,
    this.getSavedCards,
    this.saveEventGroups,
    this.saveSavedCard,
    this.deleteSavedCard,
    this.heroTag,
  });

  final SavedCard card;
  final Future<void> Function(SavedCard updated) onSave;
  final GetEventGroups getEventGroups;
  final GetSavedCards? getSavedCards;
  final SaveEventGroups? saveEventGroups;
  final SaveSavedCard? saveSavedCard;
  final DeleteSavedCard? deleteSavedCard;
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
      widget.saveEventGroups != null &&
      widget.saveSavedCard != null &&
      widget.deleteSavedCard != null;

  bool get _canAddToMoreGroups =>
      !_loadingGroups && _availableGroupsForCard.isNotEmpty;

  bool get _isDemoCard => _card.cardId.startsWith('dummy-');

  bool get _canDeleteCard =>
      widget.deleteSavedCard != null && !_isDemoCard;

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
                ? 'Henüz etkinlik grubu yok'
                : 'Bu kart zaten tüm gruplarda',
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
        content: Text('${selectedIds.length} gruba eklendi'),
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
          saveEventGroups: widget.saveEventGroups!,
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
        title: const Text('Kartı sil'),
        content: Text(
          '"$_displayName" kartını cüzdanınızdan silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          CustomButton(
            label: 'Sil',
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
          content: Text('$_displayName cüzdandan silindi'),
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
        const SnackBar(
          content: Text('Kart silinemedi. Lütfen tekrar deneyin.'),
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
            label: 'Kartı cüzdandan sil',
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

  Future<void> _confirmUnlinkFromGroup(EventGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gruptan çıkar'),
        content: Text(
          '"${group.name}" grubundan bu kartı kaldırmak istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          CustomButton(
            label: 'Çıkar',
            onPressed: () => Navigator.of(context).pop(true),
            fullWidth: false,
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    final ids = List<String>.from(_card.linkedEventGroupIds)..remove(group.id);
    await _persistCard(_card.copyWith(linkedEventGroupIds: ids));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${group.name}" grubundan çıkarıldı'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _persistCard(SavedCard updated) async {
    await widget.onSave(updated);
    if (!mounted) return;
    setState(() => _card = updated);
  }

  String get _displayName {
    final name = _card.displayName?.trim();
    if (name == null || name.isEmpty) {
      return 'Kart ${_card.cardId.substring(0, 8)}...';
    }
    return name;
  }

  List<_ContactFieldData> get _contactFields {
    return [
      if (_has(_card.title))
        _ContactFieldData(
          label: 'Ünvan',
          value: _card.title!.trim(),
          icon: Icons.badge_outlined,
        ),
      if (_has(_card.company))
        _ContactFieldData(
          label: 'Şirket',
          value: _card.company!.trim(),
          icon: Icons.apartment_rounded,
        ),
      if (_has(_card.email))
        _ContactFieldData(
          label: 'E-posta',
          value: _card.email!.trim(),
          icon: Icons.mail_outline_rounded,
        ),
      if (_has(_card.phone))
        _ContactFieldData(
          label: 'Telefon',
          value: _card.phone!.trim(),
          icon: Icons.phone_outlined,
        ),
      if (_has(_card.website))
        _ContactFieldData(
          label: 'Web sitesi',
          value: _card.website!.trim(),
          icon: Icons.language_rounded,
          onTap: () => _launchWebsite(_card.website!.trim()),
        ),
      if (_has(_card.linkedin))
        _ContactFieldData(
          label: 'LinkedIn',
          value: _card.linkedin!.trim(),
          icon: Icons.link_rounded,
          onTap: () => _launchWebsite(_card.linkedin!.trim()),
        ),
      if (_has(_card.skills))
        _ContactFieldData(
          label: 'Yetenekler',
          value: _card.skills!.trim(),
          icon: Icons.auto_awesome_outlined,
        ),
      if (_has(_card.school))
        _ContactFieldData(
          label: 'Okul',
          value: _card.school!.trim(),
          icon: Icons.school_outlined,
        ),
    ];
  }

  List<({String label, String value})> get _previewFrontEntries {
    return [
      if (_has(_card.title)) (label: 'Ünvan', value: _card.title!.trim()),
      if (_has(_card.email)) (label: 'E-posta', value: _card.email!.trim()),
      if (_has(_card.phone)) (label: 'Telefon', value: _card.phone!.trim()),
    ];
  }

  List<({String label, String value})> get _previewBackEntries {
    if (!_has(_card.about)) return const [];
    return [(label: 'Notlar', value: _card.about!.trim())];
  }

  bool _has(String? value) => value != null && value.trim().isNotEmpty;

  String _formatSavedAt(int? ms) {
    if (ms == null) return 'Bilinmiyor';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _savedAtDescription(int? ms) {
    if (ms == null) {
      return '${AppConstants.appName} ile kaydedildi · tarih bilinmiyor';
    }
    return '${_formatSavedAt(ms)} tarihinde ${AppConstants.appName} ile kaydedildi';
  }

  Future<void> _copyToClipboard(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label panoya kopyalandı'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _isGithubUrl(String url) {
    return url.toLowerCase().contains('github.com');
  }

  _ThirdQuickLinkType get _thirdQuickLinkType {
    if (!_has(_card.website)) return _ThirdQuickLinkType.none;
    if (_isGithubUrl(_card.website!)) return _ThirdQuickLinkType.github;
    return _ThirdQuickLinkType.website;
  }

  Future<void> _launchLinkedIn() async {
    final linkedin = _card.linkedin?.trim();
    if (linkedin == null || linkedin.isEmpty) return;
    await _launchWebsite(linkedin, errorMessage: 'LinkedIn açılamadı');
  }

  Future<void> _launchEmail() async {
    final email = _card.email?.trim();
    if (email == null || email.isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(uri)) {
      if (!mounted) return;
      _showLaunchError('E-posta uygulaması açılamadı');
    }
  }

  Future<void> _launchWebsite(
    String url, {
    String errorMessage = 'Bağlantı açılamadı',
  }) async {
    var normalized = url.trim();
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      _showLaunchError(errorMessage);
    }
  }

  Future<void> _launchThirdLink() async {
    final website = _card.website?.trim();
    if (website == null || website.isEmpty) return;
    final message = _thirdQuickLinkType == _ThirdQuickLinkType.github
        ? 'GitHub açılamadı'
        : 'Web sitesi açılamadı';
    await _launchWebsite(website, errorMessage: message);
  }

  void _showLaunchError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _openNoteEditor() async {
    var draftNote = _card.about ?? '';
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
                      'Kişi notu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toplantı, proje veya hatırlatma notu ekleyin',
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
                        hintText: 'Notunuzu buraya yazın…',
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
                      label: 'Kaydet',
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
      about: note.isEmpty ? null : note,
      clearAbout: note.isEmpty,
    );
    await _persistCard(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not kaydedildi'),
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
    final thirdLinkType = _thirdQuickLinkType;
    final showQuickActions =
        hasLinkedIn || hasEmail || thirdLinkType != _ThirdQuickLinkType.none;
    final companyName = _card.company?.trim();
    final hasNote = _has(_card.about);

    final preview = FlippablePersonCard(
      title: _displayName,
      titleSecondary: companyName,
      frontEntries: _previewFrontEntries,
      backEntries: _previewBackEntries,
      emptyMessage: 'Kart bilgisi yok',
      backEmptyMessage: 'Bu kişi için not bulunmuyor.',
      backEmptyActionLabel: 'Not ekle',
      onBackEmptyActionTap: _openNoteEditor,
      onBackEditTap: hasNote ? _openNoteEditor : null,
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
        padding: EdgeInsets.fromLTRB(16, 12, 16, 32 + bottomInset),
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
          const SizedBox(height: 20),
          if (showQuickActions)
            _QuickActionsRow(
              hasLinkedIn: hasLinkedIn,
              hasEmail: hasEmail,
              thirdLinkType: thirdLinkType,
              onLinkedIn: _launchLinkedIn,
              onEmail: _launchEmail,
              onThirdLink: _launchThirdLink,
            ),
          if (showQuickActions) const SizedBox(height: 20),
          _DetailSection(
            title: 'İletişim bilgileri',
            child: _contactFields.isEmpty
                ? _EmptyStateCard(
                    icon: Icons.contact_page_outlined,
                    message: 'Bu kartta ek iletişim bilgisi yok.',
                  )
                : _GroupedInfoCard(
                    children: [
                      for (var i = 0; i < _contactFields.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            indent: 56,
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
          const SizedBox(height: 20),
          _DetailSection(
            title: 'Etkinlik grupları',
            actionLabel:
                _hasLinkedGroups && _canAddToMoreGroups ? 'Ekle' : null,
            onAction: _hasLinkedGroups && _canAddToMoreGroups
                ? _openAddToEventGroupsSheet
                : null,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _loadingGroups
                  ? const _EventGroupsLoadingSkeleton(
                      key: ValueKey('event_groups_loading'),
                    )
                  : !_hasLinkedGroups
                      ? _DetailEmptyActionCard(
                          key: const ValueKey('event_groups_empty'),
                          icon: Icons.event_note_outlined,
                          message: 'Henüz gruba eklenmedi',
                          buttonLabel: 'Gruba ekle',
                          onPressed: _openAddToEventGroupsSheet,
                        )
                      : _LinkedEventGroupsCard(
                          key: ValueKey(
                            'event_groups_linked_${_linkedGroups.length}',
                          ),
                          groups: _linkedGroups,
                          canOpenDetail: _canOpenGroupDetail,
                          canAddMore: _canAddToMoreGroups,
                          onGroupTap: _openEventGroupDetail,
                          onUnlink: _confirmUnlinkFromGroup,
                          onAddMore: _openAddToEventGroupsSheet,
                        ),
            ),
          ),
          const SizedBox(height: 20),
          _DetailSection(
            title: 'Notlar',
            actionLabel: hasNote ? 'Düzenle' : null,
            onAction: hasNote ? _openNoteEditor : null,
            child: hasNote
                ? _NoteFilledCard(
                    note: _card.about!.trim(),
                    onTap: _openNoteEditor,
                  )
                : _DetailEmptyActionCard(
                    icon: Icons.note_add_outlined,
                    message: 'Henüz not eklenmedi',
                    buttonLabel: 'Not ekle',
                    onPressed: _openNoteEditor,
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
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
}

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
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(actionLabel!),
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

enum _ThirdQuickLinkType { none, github, website }

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.hasLinkedIn,
    required this.hasEmail,
    required this.thirdLinkType,
    required this.onLinkedIn,
    required this.onEmail,
    required this.onThirdLink,
  });

  final bool hasLinkedIn;
  final bool hasEmail;
  final _ThirdQuickLinkType thirdLinkType;
  final VoidCallback onLinkedIn;
  final VoidCallback onEmail;
  final VoidCallback onThirdLink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final actions = <Widget>[];

    void addAction(Widget action) {
      if (actions.isNotEmpty) {
        actions.add(
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        );
      }
      actions.add(action);
    }

    if (hasLinkedIn) {
      addAction(
        _QuickActionButton(
          icon: Icons.business_center_outlined,
          label: 'LinkedIn',
          color: AppColors.primary,
          onTap: onLinkedIn,
        ),
      );
    }
    if (hasEmail) {
      addAction(
        _QuickActionButton(
          icon: Icons.mail_rounded,
          label: 'E-posta',
          color: AppColors.info,
          onTap: onEmail,
        ),
      );
    }
    if (thirdLinkType == _ThirdQuickLinkType.github) {
      addAction(
        _QuickActionButton(
          icon: Icons.code_rounded,
          label: 'GitHub',
          color: AppColors.secondary,
          onTap: onThirdLink,
        ),
      );
    } else if (thirdLinkType == _ThirdQuickLinkType.website) {
      addAction(
        _QuickActionButton(
          icon: Icons.language_rounded,
          label: 'Web sitesi',
          color: AppColors.success,
          onTap: onThirdLink,
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: actions,
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
            ),
          ],
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: field.onTap ?? onCopy,
        onLongPress: field.onTap != null ? onCopy : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  field.icon,
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
                      field.label,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      field.value,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    if (canOpen) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Açmak için dokunun',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Kopyala',
                visualDensity: VisualDensity.compact,
                onPressed: onCopy,
                icon: Icon(
                  Icons.copy_all_rounded,
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

class _NoteFilledCard extends StatelessWidget {
  const _NoteFilledCard({
    required this.note,
    required this.onTap,
  });

  final String note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.35),
                colorScheme.surface,
              ],
            ),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              note,
              style: textTheme.bodyLarge?.copyWith(
                height: 1.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Boş not / etkinlik grubu gibi bölümlerde ortak kesik çizgili kart + tam genişlik CTA.
class _DetailEmptyActionCard extends StatelessWidget {
  const _DetailEmptyActionCard({
    super.key,
    required this.icon,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: colorScheme.outlineVariant,
            radius: 16,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Icon(
                    icon,
                    size: 36,
                    color: colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton.tonal(
                  label: buttonLabel,
                  icon: Icons.add_rounded,
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

class _LinkedEventGroupsCard extends StatelessWidget {
  const _LinkedEventGroupsCard({
    super.key,
    required this.groups,
    required this.canOpenDetail,
    required this.canAddMore,
    required this.onGroupTap,
    required this.onUnlink,
    required this.onAddMore,
  });

  final List<EventGroup> groups;
  final bool canOpenDetail;
  final bool canAddMore;
  final void Function(EventGroup group) onGroupTap;
  final void Function(EventGroup group) onUnlink;
  final VoidCallback onAddMore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                groups.length == 1
                    ? '1 etkinlik grubunda'
                    : '${groups.length} etkinlik grubunda',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            for (var i = 0; i < groups.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: 68,
                  endIndent: 16,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              _LinkedEventGroupTile(
                group: groups[i],
                tappable: canOpenDetail,
                onTap: () => onGroupTap(groups[i]),
                onUnlink: () => onUnlink(groups[i]),
              ),
            ],
            if (canAddMore) ...[
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAddMore,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Başka gruba ekle',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinkedEventGroupTile extends StatelessWidget {
  const _LinkedEventGroupTile({
    required this.group,
    required this.tappable,
    required this.onTap,
    required this.onUnlink,
  });

  final EventGroup group;
  final bool tappable;
  final VoidCallback onTap;
  final VoidCallback onUnlink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tappable ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tappable
                          ? 'Grubu ve kartları görüntüle'
                          : 'Etkinlik grubu',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Gruptan çıkar',
                onPressed: onUnlink,
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                ),
                style: IconButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (tappable)
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

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
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0.0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
