import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/new_event_group_name_dialog.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/presentation/widgets/saved_card_selectable_list.dart';
import 'event_group_cover_thumbnail.dart';
import 'event_group_photo_picker_field.dart';
import 'event_group_schedule_picker_section.dart';
import 'event_group_card_id_invite_field.dart';
import 'event_group_location_picker_field.dart';
import '../helpers/event_group_location_composer.dart';
import '../../../../core/location/country_location_data_cache.dart';
import '../helpers/event_group_meta_formatter.dart';

/// Yeni etkinlik grubu oluşturma akışının sonucu.
class CreateEventGroupResult {
  const CreateEventGroupResult({
    required this.name,
    required this.location,
    required this.startAt,
    this.endAt,
    this.photoFilePath,
    required this.selectedCardIds,
    required this.invitedCardIds,
  });

  final String name;
  final String location;
  final DateTime startAt;
  final DateTime? endAt;
  final String? photoFilePath;
  final Set<String> selectedCardIds;
  final List<String> invitedCardIds;
}

enum _CreateEventStep {
  name,
  location,
  schedule,
  photo,
  cards,
}

/// Her bilgi ayrı adımda: ad · konum · tarih/saat · fotoğraf · kartlar.
class CreateEventGroupSheet extends StatefulWidget {
  const CreateEventGroupSheet({
    super.key,
    required this.existingNames,
    required this.getSavedCards,
    this.initialPickableCards,
  });

  final List<String> existingNames;
  final GetSavedCards getSavedCards;
  final List<SavedCard>? initialPickableCards;

  static Future<CreateEventGroupResult?> show(
    BuildContext context, {
    required List<String> existingNames,
    required GetSavedCards getSavedCards,
    List<SavedCard>? initialPickableCards,
  }) {
    CountryLocationDataCache.warmUp();
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
        initialPickableCards: initialPickableCards,
      ),
    );
  }

  @override
  State<CreateEventGroupSheet> createState() => _CreateEventGroupSheetState();
}

class _CreateEventGroupSheetState extends State<CreateEventGroupSheet> {
  _CreateEventStep _step = _CreateEventStep.name;
  late final TextEditingController _nameController;
  late final TextEditingController _venueController;
  late final TextEditingController _cardIdController;
  String? _locationCountry;
  String? _locationCity;
  String? _nameErrorText;
  String? _locationErrorText;
  String? _scheduleErrorText;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  String? _photoFilePath;
  late final Set<String> _selectedCardIds;
  late final Set<String> _invitedCardIds;
  List<SavedCard> _pickableCards = [];
  bool _loadingCards = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _venueController = TextEditingController();
    _cardIdController = TextEditingController();
    _nameController.addListener(_clearNameErrorOnEdit);
    _selectedCardIds = {};
    _invitedCardIds = {};
    final initialCards = widget.initialPickableCards;
    if (initialCards != null && initialCards.isNotEmpty) {
      _pickableCards = List<SavedCard>.from(initialCards);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_clearNameErrorOnEdit);
    _nameController.dispose();
    _venueController.dispose();
    _cardIdController.dispose();
    super.dispose();
  }

  String get _groupName => _nameController.text.trim();

  void _clearNameErrorOnEdit() {
    if (_nameErrorText == null) return;
    setState(() => _nameErrorText = null);
  }

  void _clearLocationErrorOnEdit() {
    if (_locationErrorText == null) return;
    setState(() => _locationErrorText = null);
  }

  String get _composedLocation => EventGroupLocationComposer.compose(
        venue: _venueController.text,
        country: _locationCountry,
        city: _locationCity,
      );

  String? get _locationSummary {
    final location = _composedLocation.trim();
    return location.isEmpty ? null : location;
  }

  DateTime? get _startAt => _combineDateAndTime(_startDate, _startTime);

  DateTime? get _endAt => _combineDateAndTime(_endDate, _endTime);

  bool get _canSkipCurrentStep => _step == _CreateEventStep.photo;

  bool _validateCurrentStep() {
    switch (_step) {
      case _CreateEventStep.name:
        final name = _groupName;
        if (name.isEmpty) {
          setState(() => _nameErrorText = context.l10n.eventGroupNameRequired);
          return false;
        }
        if (NewEventGroupNameDialog.isDuplicateName(name, widget.existingNames)) {
          setState(() => _nameErrorText = context.l10n.eventGroupNameDuplicate);
          return false;
        }
        return true;
      case _CreateEventStep.location:
        if (!EventGroupLocationComposer.isRegionComplete(
          _locationCountry,
          _locationCity,
        )) {
          setState(
            () => _locationErrorText = context.l10n.eventLocationRegionRequired,
          );
          return false;
        }
        return true;
      case _CreateEventStep.schedule:
        if (_startAt == null) {
          setState(() => _scheduleErrorText = context.l10n.eventStartRequired);
          return false;
        }
        return _validateEndStep();
      case _CreateEventStep.photo:
      case _CreateEventStep.cards:
        return true;
    }
  }

  bool _validateEndStep() {
    final startAt = _startAt;
    final endAt = _endAt;
    final hasEndDate = _endDate != null;
    final hasEndTime = _endTime != null;

    if (!hasEndDate && !hasEndTime) {
      setState(() => _scheduleErrorText = null);
      return true;
    }
    if (hasEndDate != hasEndTime) {
      setState(
          () => _scheduleErrorText = context.l10n.eventEndRequiresDateAndTime);
      return false;
    }
    if (startAt != null && endAt != null && endAt.isBefore(startAt)) {
      setState(() => _scheduleErrorText = context.l10n.eventEndBeforeStart);
      return false;
    }
    setState(() => _scheduleErrorText = null);
    return true;
  }

  Future<void> _goToNext() async {
    if (!_validateCurrentStep()) return;

    if (_step == _CreateEventStep.photo) {
      await _loadCardsAndAdvance();
      return;
    }

    if (_step.index < _CreateEventStep.cards.index) {
      setState(() => _step = _CreateEventStep.values[_step.index + 1]);
    }
  }

  Future<void> _skipCurrentStep() async {
    if (_step == _CreateEventStep.photo) {
      setState(() {
        _photoFilePath = null;
        _step = _CreateEventStep.cards;
      });
      await _loadCardsIfNeeded();
    }
  }

  void _goBack() {
    if (_step.index == 0) return;
    setState(() => _step = _CreateEventStep.values[_step.index - 1]);
  }

  Future<void> _loadCardsAndAdvance() async {
    setState(() {
      _step = _CreateEventStep.cards;
      _loadingCards = true;
    });
    await _loadCardsIfNeeded();
  }

  Future<void> _loadCardsIfNeeded() async {
    if (_pickableCards.isNotEmpty) {
      if (mounted) setState(() => _loadingCards = false);
      return;
    }
    final persisted = await widget.getSavedCards();
    if (!mounted) return;
    setState(() {
      _pickableCards = persisted;
      _loadingCards = false;
    });
  }

  void _submit() {
    final location = _composedLocation.trim();
    final startAt = _startAt;
    if (location.isEmpty || startAt == null) {
      setState(() => _step = _CreateEventStep.name);
      return;
    }
    Navigator.of(context).pop(
      CreateEventGroupResult(
        name: _groupName,
        location: location,
        startAt: startAt,
        endAt: _endAt,
        photoFilePath: _photoFilePath,
        selectedCardIds: Set<String>.from(_selectedCardIds),
        invitedCardIds: _invitedCardIds.toList(),
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

  void _addInvitedCardId() {
    final cardId = _cardIdController.text.trim();
    if (cardId.isEmpty) return;
    setState(() {
      _invitedCardIds.add(cardId);
      _cardIdController.clear();
    });
  }

  void _removeInvitedCardId(String cardId) {
    setState(() => _invitedCardIds.remove(cardId));
  }

  Future<void> _pickStartDate() async {
    final picked = await _pickDate(initialDate: _startDate ?? DateTime.now());
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      _scheduleErrorText = null;
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await _pickTime(initialTime: _startTime ?? TimeOfDay.now());
    if (picked == null) return;
    setState(() {
      _startTime = picked;
      _scheduleErrorText = null;
    });
  }

  Future<void> _pickEndDate() async {
    final picked =
        await _pickDate(initialDate: _endDate ?? _startDate ?? DateTime.now());
    if (picked == null) return;
    setState(() {
      _endDate = picked;
      _scheduleErrorText = null;
    });
  }

  Future<void> _pickEndTime() async {
    final picked =
        await _pickTime(initialTime: _endTime ?? _startTime ?? TimeOfDay.now());
    if (picked == null) return;
    setState(() {
      _endTime = picked;
      _scheduleErrorText = null;
    });
  }

  void _clearEnd() {
    setState(() {
      _endDate = null;
      _endTime = null;
      _scheduleErrorText = null;
    });
  }

  Future<DateTime?> _pickDate({required DateTime initialDate}) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
  }

  Future<TimeOfDay?> _pickTime({required TimeOfDay initialTime}) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  DateTime? _combineDateAndTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
                duration: const Duration(milliseconds: 150),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _buildStepContent(),
              ),
            ),
            _CreateEventGroupSheetFooter(
              step: _step,
              loadingCards: _loadingCards,
              selectedCount: _selectedCardIds.length + _invitedCardIds.length,
              canSkip: _canSkipCurrentStep,
              onBack: _goBack,
              onSkip: _skipCurrentStep,
              onContinue: _goToNext,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case _CreateEventStep.name:
        return _CreateEventNameStep(
          key: const ValueKey('name'),
          nameController: _nameController,
          nameErrorText: _nameErrorText,
          onContinue: _goToNext,
        );
      case _CreateEventStep.location:
        return _CreateEventLocationStep(
          key: const ValueKey('location'),
          country: _locationCountry,
          city: _locationCity,
          venueController: _venueController,
          locationErrorText: _locationErrorText,
          onCountryChanged: (value) => setState(() {
            _locationCountry = value;
            _clearLocationErrorOnEdit();
          }),
          onCityChanged: (value) => setState(() {
            _locationCity = value;
            _clearLocationErrorOnEdit();
          }),
          onVenueChanged: _clearLocationErrorOnEdit,
        );
      case _CreateEventStep.schedule:
        return _CreateEventScheduleStep(
          key: const ValueKey('schedule'),
          startDate: _startDate,
          startTime: _startTime,
          endDate: _endDate,
          endTime: _endTime,
          scheduleErrorText: _scheduleErrorText,
          onPickStartDate: _pickStartDate,
          onPickStartTime: _pickStartTime,
          onPickEndDate: _pickEndDate,
          onPickEndTime: _pickEndTime,
          onClearEnd: _clearEnd,
        );
      case _CreateEventStep.photo:
        return _CreateEventPhotoStep(
          key: const ValueKey('photo'),
          photoFilePath: _photoFilePath,
          onPhotoChanged: (value) => setState(() => _photoFilePath = value),
        );
      case _CreateEventStep.cards:
        return _CreateEventGroupPickCardsStep(
          key: const ValueKey('cards'),
          groupName: _groupName,
          location: _locationSummary,
          startAt: _startAt!,
          endAt: _endAt,
          photoFilePath: _photoFilePath,
          cardIdController: _cardIdController,
          loadingCards: _loadingCards,
          pickableCards: _pickableCards,
          selectedCardIds: _selectedCardIds,
          invitedCardIds: _invitedCardIds,
          onToggleCard: _toggleCard,
          onAddInvitedCardId: _addInvitedCardId,
          onRemoveInvitedCardId: _removeInvitedCardId,
        );
    }
  }
}

class _CreateEventGroupSheetHeader extends StatelessWidget {
  const _CreateEventGroupSheetHeader({required this.step});

  final _CreateEventStep step;

  bool get _isCardsStep => step == _CreateEventStep.cards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final title = _isCardsStep
        ? context.l10n.selectCards
        : context.l10n.yeniEtkinlikGrubu;

    final subtitle = _isCardsStep
        ? context.l10n.eventGroupCardsStepSubtitle
        : switch (step) {
            _CreateEventStep.name => context.l10n.eventCreateNameSubtitle,
            _CreateEventStep.location => context.l10n.eventCreateLocationSubtitle,
            _CreateEventStep.schedule => context.l10n.eventCreateScheduleSubtitle,
            _CreateEventStep.photo => context.l10n.eventCreatePhotoSubtitle,
            _CreateEventStep.cards => context.l10n.eventGroupCardsStepSubtitle,
          };

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
                active: !_isCardsStep,
                completed: _isCardsStep,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _isCardsStep
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
                active: _isCardsStep,
                completed: false,
              ),
            ],
          ),
          if (!_isCardsStep) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.eventCreateStepProgress(
                  step.index + 1,
                  _CreateEventStep.cards.index,
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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

    final highlighted = active || completed;
    final circleColor = highlighted
        ? colorScheme.primary
        : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant);
    final contentColor =
        highlighted ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;
    final titleColor =
        highlighted ? colorScheme.primary : colorScheme.onSurfaceVariant;

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

class _CreateEventStepCard extends StatelessWidget {
  const _CreateEventStepCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: DecoratedBox(
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
          child: child,
        ),
      ),
    );
  }
}

class _CreateEventNameStep extends StatelessWidget {
  const _CreateEventNameStep({
    super.key,
    required this.nameController,
    required this.nameErrorText,
    required this.onContinue,
  });

  final TextEditingController nameController;
  final String? nameErrorText;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _CreateEventStepCard(
      child: CustomTextField(
        controller: nameController,
        labelText: context.l10n.etkinlikAd,
        hintText: context.l10n.rnWebSummit2026,
        errorText: nameErrorText,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => onContinue(),
      ),
    );
  }
}

class _CreateEventLocationStep extends StatelessWidget {
  const _CreateEventLocationStep({
    super.key,
    required this.country,
    required this.city,
    required this.venueController,
    required this.locationErrorText,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.onVenueChanged,
  });

  final String? country;
  final String? city;
  final TextEditingController venueController;
  final String? locationErrorText;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onCityChanged;
  final VoidCallback onVenueChanged;

  @override
  Widget build(BuildContext context) {
    return _CreateEventStepCard(
      child: EventGroupLocationPickerField(
        country: country,
        city: city,
        venueController: venueController,
        errorText: locationErrorText,
        onCountryChanged: onCountryChanged,
        onCityChanged: onCityChanged,
        onVenueChanged: onVenueChanged,
      ),
    );
  }
}

class _CreateEventScheduleStep extends StatelessWidget {
  const _CreateEventScheduleStep({
    super.key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.scheduleErrorText,
    required this.onPickStartDate,
    required this.onPickStartTime,
    required this.onPickEndDate,
    required this.onPickEndTime,
    required this.onClearEnd,
  });

  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final String? scheduleErrorText;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndDate;
  final VoidCallback onPickEndTime;
  final VoidCallback onClearEnd;

  @override
  Widget build(BuildContext context) {
    return _CreateEventStepCard(
      child: EventGroupSchedulePickerSection(
        startDate: startDate,
        startTime: startTime,
        endDate: endDate,
        endTime: endTime,
        errorText: scheduleErrorText,
        onPickStartDate: onPickStartDate,
        onPickStartTime: onPickStartTime,
        onPickEndDate: onPickEndDate,
        onPickEndTime: onPickEndTime,
        onClearEnd: onClearEnd,
      ),
    );
  }
}

class _CreateEventPhotoStep extends StatelessWidget {
  const _CreateEventPhotoStep({
    super.key,
    required this.photoFilePath,
    required this.onPhotoChanged,
  });

  final String? photoFilePath;
  final ValueChanged<String?> onPhotoChanged;

  @override
  Widget build(BuildContext context) {
    return _CreateEventStepCard(
      child: EventGroupPhotoPickerField(
        value: photoFilePath,
        onChanged: onPhotoChanged,
      ),
    );
  }
}

class _CreateEventGroupPickCardsStep extends StatelessWidget {
  const _CreateEventGroupPickCardsStep({
    super.key,
    required this.groupName,
    required this.location,
    required this.startAt,
    required this.endAt,
    required this.photoFilePath,
    required this.cardIdController,
    required this.loadingCards,
    required this.pickableCards,
    required this.selectedCardIds,
    required this.invitedCardIds,
    required this.onToggleCard,
    required this.onAddInvitedCardId,
    required this.onRemoveInvitedCardId,
  });

  final String groupName;
  final String? location;
  final DateTime startAt;
  final DateTime? endAt;
  final String? photoFilePath;
  final TextEditingController cardIdController;
  final bool loadingCards;
  final List<SavedCard> pickableCards;
  final Set<String> selectedCardIds;
  final Set<String> invitedCardIds;
  final void Function(String cardId) onToggleCard;
  final VoidCallback onAddInvitedCardId;
  final ValueChanged<String> onRemoveInvitedCardId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = EventGroupMetaFormatter.summary(
      location: location,
      eventDate: startAt,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EventGroupCardIdInviteField(
                  controller: cardIdController,
                  invitedCardIds: invitedCardIds,
                  onAdd: onAddInvitedCardId,
                  onRemove: onRemoveInvitedCardId,
                ),
                const SizedBox(height: 12),
                Text(
                  selectedCardIds.isEmpty
                      ? context.l10n.noCardsSelectedYet
                      : context.l10n.cardsSelectedCount(selectedCardIds.length),
                  style: textTheme.labelLarge?.copyWith(
                    color: selectedCardIds.isEmpty
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
    required this.canSkip,
    required this.onBack,
    required this.onSkip,
    required this.onContinue,
    required this.onSubmit,
  });

  final _CreateEventStep step;
  final bool loadingCards;
  final int selectedCount;
  final bool canSkip;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onContinue;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCardsStep = step == _CreateEventStep.cards;

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
              if (step.index > 0) ...[
                CustomButton.text(
                  label: context.l10n.geri,
                  onPressed: loadingCards ? null : onBack,
                ),
                const SizedBox(width: 8),
              ],
              if (canSkip) ...[
                CustomButton.text(
                  label: context.l10n.eventSkip,
                  onPressed: loadingCards ? null : onSkip,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: isCardsStep
                    ? CustomButton(
                        label: selectedCount == 0
                            ? context.l10n.createGroup
                            : context.l10n.createGroupWithCards(selectedCount),
                        onPressed: loadingCards ? null : onSubmit,
                      )
                    : CustomButton(
                        label: context.l10n.devam,
                        onPressed: onContinue,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
