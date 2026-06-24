import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/birthday_format.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/birthday_picker_field.dart';
import '../../../../core/widgets/molecules/new_event_group_name_dialog.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/presentation/saved_cards_catalog.dart';
import '../../../saved_cards/presentation/widgets/saved_card_selectable_list.dart';
import 'event_group_cover_thumbnail.dart';
import 'event_group_photo_picker_field.dart';
import '../helpers/event_group_meta_formatter.dart';

/// Yeni etkinlik grubu oluşturma akışının sonucu.
class CreateEventGroupResult {
  const CreateEventGroupResult({
    required this.name,
    this.location,
    this.eventDate,
    this.photoFilePath,
    required this.selectedCardIds,
  });

  final String name;
  final String? location;
  final DateTime? eventDate;
  final String? photoFilePath;
  final Set<String> selectedCardIds;
}

/// 1. adım: grup adı · 2. adım: Kaydedilen Kartlar listesi görünümünde seçim.
class CreateEventGroupSheet extends StatefulWidget {
  const CreateEventGroupSheet({
    super.key,
    required this.existingNames,
    required this.getSavedCards,
  });

  final List<String> existingNames;
  final GetSavedCards getSavedCards;

  static Future<CreateEventGroupResult?> show(
    BuildContext context, {
    required List<String> existingNames,
    required GetSavedCards getSavedCards,
  }) {
    return showModalBottomSheet<CreateEventGroupResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CreateEventGroupSheet(
        existingNames: existingNames,
        getSavedCards: getSavedCards,
      ),
    );
  }

  @override
  State<CreateEventGroupSheet> createState() => _CreateEventGroupSheetState();
}

class _CreateEventGroupSheetState extends State<CreateEventGroupSheet> {
  static const _stepName = 0;
  static const _stepPickCards = 1;

  int _step = _stepName;
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  String? _nameErrorText;
  String? _eventDateValue;
  String? _photoFilePath;
  late final Set<String> _selectedCardIds;
  List<SavedCard> _pickableCards = [];
  bool _loadingCards = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _nameController.addListener(_clearNameErrorOnEdit);
    _selectedCardIds = {};
  }

  void _clearNameErrorOnEdit() {
    if (_nameErrorText == null) return;
    setState(() => _nameErrorText = null);
  }

  @override
  void dispose() {
    _nameController.removeListener(_clearNameErrorOnEdit);
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String get _groupName => _nameController.text.trim();

  String? get _locationSummary {
    final location = _locationController.text.trim();
    return location.isEmpty ? null : location;
  }

  DateTime? get _parsedEventDate =>
      _eventDateValue == null ? null : BirthdayFormat.tryParse(_eventDateValue);

  Future<void> _goToPickCards() async {
    final name = _groupName;
    if (name.isEmpty) {
      setState(() => _nameErrorText = 'Etkinlik adı boş olamaz');
      return;
    }
    if (NewEventGroupNameDialog.isDuplicateName(name, widget.existingNames)) {
      setState(() => _nameErrorText = 'Bu isimde bir etkinlik grubu zaten var');
      return;
    }

    setState(() {
      _step = _stepPickCards;
      _loadingCards = true;
    });

    final persisted = await widget.getSavedCards();
    if (!mounted) return;
    setState(() {
      _pickableCards = SavedCardsCatalog.displayCards(persisted);
      _loadingCards = false;
    });
  }

  void _goBackToName() {
    setState(() => _step = _stepName);
  }

  void _submit() {
    final location = _locationController.text.trim();
    Navigator.of(context).pop(
      CreateEventGroupResult(
        name: _groupName,
        location: location.isEmpty ? null : location,
        eventDate: _parsedEventDate,
        photoFilePath: _photoFilePath,
        selectedCardIds: Set<String>.from(_selectedCardIds),
      ),
    );
  }

  void _toggleCard(String cardId) {
    setState(() {
      if (_selectedCardIds.contains(cardId)) {
        _selectedCardIds.remove(cardId);
      } else {
        _selectedCardIds.add(cardId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CreateEventGroupSheetHeader(step: _step),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _step == _stepName
                    ? _CreateEventGroupDetailsStep(
                        key: const ValueKey('details'),
                        nameController: _nameController,
                        locationController: _locationController,
                        nameErrorText: _nameErrorText,
                        eventDateValue: _eventDateValue,
                        photoFilePath: _photoFilePath,
                        onEventDateChanged: (value) =>
                            setState(() => _eventDateValue = value),
                        onPhotoChanged: (value) =>
                            setState(() => _photoFilePath = value),
                        onContinue: _goToPickCards,
                      )
                    : _CreateEventGroupPickCardsStep(
                        key: const ValueKey('cards'),
                        groupName: _groupName,
                        location: _locationSummary,
                        eventDate: _parsedEventDate,
                        photoFilePath: _photoFilePath,
                        loadingCards: _loadingCards,
                        pickableCards: _pickableCards,
                        selectedCardIds: _selectedCardIds,
                        onToggleCard: _toggleCard,
                      ),
              ),
            ),
            _CreateEventGroupSheetFooter(
              step: _step,
              loadingCards: _loadingCards,
              selectedCount: _selectedCardIds.length,
              onBack: _goBackToName,
              onContinue: _goToPickCards,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateEventGroupSheetHeader extends StatelessWidget {
  const _CreateEventGroupSheetHeader({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final title = step == 0 ? context.l10n.yeniEtkinlikGrubu : context.l10n.selectCards;
    final subtitle = step == 0
        ? 'Etkinliğin adını, konumunu ve tarihini girin.'
        : 'İsterseniz kart seçmeden de grubu oluşturabilirsiniz.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _StepIndicatorDot(
                label: '1',
                title: context.l10n.bilgiler,
                active: step == 0,
                completed: step > 0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: step > 0
                          ? colorScheme.primary
                          : (isDark
                              ? AppColors.outlineDark.withValues(alpha: 0.45)
                              : AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const SizedBox(height: 2),
                  ),
                ),
              ),
              _StepIndicatorDot(
                label: '2',
                title: context.l10n.kartlar,
                active: step == 1,
                completed: false,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicatorDot extends StatelessWidget {
  const _StepIndicatorDot({
    required this.label,
    required this.title,
    required this.active,
    required this.completed,
  });

  final String label;
  final String title;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool highlighted = active || completed;
    final circleColor = highlighted
        ? colorScheme.primary
        : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant);
    final contentColor = highlighted
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    final titleColor = highlighted
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return SizedBox(
      width: 56,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: completed
                ? Icon(Icons.check_rounded, size: 16, color: contentColor)
                : Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: titleColor,
              fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateEventGroupDetailsStep extends StatelessWidget {
  const _CreateEventGroupDetailsStep({
    super.key,
    required this.nameController,
    required this.locationController,
    required this.nameErrorText,
    required this.eventDateValue,
    required this.photoFilePath,
    required this.onEventDateChanged,
    required this.onPhotoChanged,
    required this.onContinue,
  });

  final TextEditingController nameController;
  final TextEditingController locationController;
  final String? nameErrorText;
  final String? eventDateValue;
  final String? photoFilePath;
  final ValueChanged<String?> onEventDateChanged;
  final ValueChanged<String?> onPhotoChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest.withValues(
                alpha: isDark ? 0.55 : 0.85,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.outlineDark.withValues(alpha: 0.35)
                    : AppColors.outlineVariant.withValues(alpha: 0.75),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: nameController,
                    labelText: context.l10n.etkinlikAd,
                    hintText: context.l10n.rnWebSummit2026,
                    errorText: nameErrorText,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => onContinue(),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: locationController,
                    labelText: context.l10n.konum,
                    hintText: context.l10n.rnstanbulKongreMerkezi,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                      BirthdayPickerField(
                        label: context.l10n.etkinlikTarihi,
                        value: eventDateValue,
                        hintText: context.l10n.tarihSein,
                        onChanged: onEventDateChanged,
                      ),
                      const SizedBox(height: 18),
                      EventGroupPhotoPickerField(
                        value: photoFilePath,
                        onChanged: onPhotoChanged,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateEventGroupPickCardsStep extends StatelessWidget {
  const _CreateEventGroupPickCardsStep({
    super.key,
    required this.groupName,
    required this.location,
    required this.eventDate,
    required this.photoFilePath,
    required this.loadingCards,
    required this.pickableCards,
    required this.selectedCardIds,
    required this.onToggleCard,
  });

  final String groupName;
  final String? location;
  final DateTime? eventDate;
  final String? photoFilePath;
  final bool loadingCards;
  final List<SavedCard> pickableCards;
  final Set<String> selectedCardIds;
  final void Function(String cardId) onToggleCard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = EventGroupMetaFormatter.summary(
      location: location,
      eventDate: eventDate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest.withValues(
                alpha: isDark ? 0.55 : 0.85,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppColors.outlineDark.withValues(alpha: 0.35)
                    : AppColors.outlineVariant.withValues(alpha: 0.75),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  EventGroupCoverThumbnail(
                    localFilePath: photoFilePath,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (meta != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!loadingCards)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              selectedCardIds.isEmpty
                  ? 'Henüz kart seçilmedi'
                  : '${selectedCardIds.length} kart seçildi',
              style: textTheme.labelLarge?.copyWith(
                color: selectedCardIds.isEmpty
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Expanded(
          child: loadingCards
              ? const Center(child: CircularProgressIndicator())
              : SavedCardSelectableList(
                  cards: pickableCards,
                  selectedIds: selectedCardIds,
                  onToggle: onToggleCard,
                ),
        ),
      ],
    );
  }
}

class _CreateEventGroupSheetFooter extends StatelessWidget {
  const _CreateEventGroupSheetFooter({
    required this.step,
    required this.loadingCards,
    required this.selectedCount,
    required this.onBack,
    required this.onContinue,
    required this.onSubmit,
  });

  final int step;
  final bool loadingCards;
  final int selectedCount;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.outlineDark.withValues(alpha: 0.45)
                : AppColors.outlineVariant.withValues(alpha: 0.9),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Row(
            children: [
              if (step == 1) ...[
                TextButton(
                  onPressed: loadingCards ? null : onBack,
                  child: Text(context.l10n.geri),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: step == 0
                    ? CustomButton(
                        label: context.l10n.devam,
                        onPressed: onContinue,
                      )
                    : CustomButton(
                        label: selectedCount == 0
                            ? 'Grubu oluştur'
                            : '$selectedCount kartla oluştur',
                        onPressed: loadingCards ? null : onSubmit,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
