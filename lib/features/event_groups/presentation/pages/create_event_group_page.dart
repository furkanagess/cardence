import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/location/country_location_data_cache.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/new_event_group_name_dialog.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../onboarding/presentation/widgets/onboarding_flow_ui.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/presentation/widgets/saved_card_selectable_list.dart';
import '../helpers/create_event_group_step_meta.dart';
import '../helpers/event_group_location_composer.dart';
import '../helpers/event_group_meta_formatter.dart';
import '../widgets/create_event_group_filled_summary.dart';
import '../widgets/create_event_group_step_header.dart';
import '../widgets/event_group_card_id_invite_field.dart';
import '../widgets/event_group_cover_thumbnail.dart';
import '../widgets/event_group_location_picker_field.dart';
import '../widgets/event_group_photo_picker_field.dart';
import '../widgets/event_group_schedule_picker_section.dart';

/// Yeni etkinlik grubu oluşturma akışının sonucu.
class CreateEventGroupResult {
  const CreateEventGroupResult({
    required this.name,
    required this.location,
    required this.startAt,
    this.endAt,
    this.description,
    this.photoFilePath,
    required this.selectedCardIds,
    required this.invitedCardIds,
  });

  final String name;
  final String location;
  final DateTime startAt;
  final DateTime? endAt;
  final String? description;
  final String? photoFilePath;
  final Set<String> selectedCardIds;
  final List<String> invitedCardIds;
}

enum _CreateEventStep {
  name,
  location,
  schedule,
  details,
  photo,
  cards,
}

/// Her bilgi ayrı adımda: ad · konum · tarih/saat · detay · fotoğraf · kartlar.
class CreateEventGroupPage extends StatefulWidget {
  const CreateEventGroupPage({
    super.key,
    required this.existingNames,
    required this.getSavedCards,
    this.initialPickableCards,
  });

  final List<String> existingNames;
  final GetSavedCards getSavedCards;
  final List<SavedCard>? initialPickableCards;

  static Future<CreateEventGroupResult?> push(
    BuildContext context, {
    required List<String> existingNames,
    required GetSavedCards getSavedCards,
    List<SavedCard>? initialPickableCards,
  }) {
    CountryLocationDataCache.warmUp();
    return Navigator.of(context).push<CreateEventGroupResult>(
      MaterialPageRoute(
        builder: (context) => CreateEventGroupPage(
          existingNames: existingNames,
          getSavedCards: getSavedCards,
          initialPickableCards: initialPickableCards,
        ),
      ),
    );
  }

  @override
  State<CreateEventGroupPage> createState() => _CreateEventGroupPageState();
}

class _CreateEventGroupPageState extends State<CreateEventGroupPage> {
  _CreateEventStep _step = _CreateEventStep.name;
  late final TextEditingController _nameController;
  late final TextEditingController _venueController;
  late final TextEditingController _cardIdController;
  late final TextEditingController _descriptionController;
  String? _locationCountry;
  String? _locationCity;
  String? _nameErrorText;
  String? _locationErrorText;
  String? _scheduleErrorText;
  String? _descriptionErrorText;
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
    _descriptionController = TextEditingController();
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
    _descriptionController.dispose();
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

  bool get _canSkipCurrentStep =>
      _step == _CreateEventStep.details || _step == _CreateEventStep.photo;

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
      case _CreateEventStep.details:
        final description = _descriptionController.text.trim();
        if (description.length > 2000) {
          setState(
            () => _descriptionErrorText = context.l10n.eventDescriptionTooLong,
          );
          return false;
        }
        setState(() => _descriptionErrorText = null);
        return true;
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
    FocusManager.instance.primaryFocus?.unfocus();

    if (_step == _CreateEventStep.photo) {
      await _loadCardsAndAdvance();
      return;
    }

    if (_step.index < _CreateEventStep.cards.index) {
      setState(() => _step = _CreateEventStep.values[_step.index + 1]);
    }
  }

  Future<void> _skipCurrentStep() async {
    if (_step == _CreateEventStep.details) {
      setState(() {
        _descriptionController.clear();
        _descriptionErrorText = null;
        _step = _CreateEventStep.photo;
      });
      return;
    }
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
    FocusManager.instance.primaryFocus?.unfocus();
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
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
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

  void _addInvitedCardId(String cardId) {
    setState(() => _invitedCardIds.add(cardId));
  }

  void _removeInvitedCardId(String cardId) {
    setState(() => _invitedCardIds.remove(cardId));
  }

  Future<void> _pickStartDate() async {
    final picked = await _pickDate(
      initialDate: _startDate ?? DateTime.now(),
      helpText: context.l10n.eventScheduleDateField,
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      _scheduleErrorText = null;
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await _pickTime(
      initialTime: _startTime ?? TimeOfDay.now(),
      helpText: context.l10n.eventScheduleTimeField,
    );
    if (picked == null) return;
    setState(() {
      _startTime = picked;
      _scheduleErrorText = null;
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await _pickDate(
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      helpText: context.l10n.eventEndOptional,
    );
    if (picked == null) return;
    setState(() {
      _endDate = picked;
      _scheduleErrorText = null;
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await _pickTime(
      initialTime: _endTime ?? _startTime ?? TimeOfDay.now(),
      helpText: context.l10n.eventEndOptional,
    );
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

  Future<DateTime?> _pickDate({
    required DateTime initialDate,
    required String helpText,
  }) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      helpText: helpText,
      cancelText: context.l10n.iptal,
      confirmText: context.l10n.tamam,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<TimeOfDay?> _pickTime({
    required TimeOfDay initialTime,
    required String helpText,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
      cancelText: context.l10n.iptal,
      confirmText: context.l10n.tamam,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
  }

  DateTime? _combineDateAndTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    final isFirstStep = _step == _CreateEventStep.name;
    final isCardsStep = _step == _CreateEventStep.cards;
    final selectedCount =
        _selectedCardIds.length + _invitedCardIds.length;

    return PopScope(
      canPop: isFirstStep,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || isFirstStep) return;
        _goBack();
      },
      child: CardenceScaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CreateEventGroupStepHeader(currentIndex: _step.index),
              Expanded(
                child: IndexedStack(
                  index: _step.index,
                  sizing: StackFit.expand,
                  children: [
                    _buildNameStep(),
                    _buildLocationStep(),
                    _buildScheduleStep(),
                    _buildDetailsStep(),
                    _buildPhotoStep(),
                    _buildCardsStep(),
                  ],
                ),
              ),
              _CreateEventGroupKeyboardAwareBottom(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_canSkipCurrentStep)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: CustomButton.text(
                            label: context.l10n.eventSkip,
                            onPressed:
                                _loadingCards ? null : _skipCurrentStep,
                          ),
                        ),
                      ),
                    OnboardingBottomBar(
                      stepCount: CreateEventGroupStepMeta.stepCount,
                      currentIndex: _step.index,
                      showStepIndicator: false,
                      backLabel: context.l10n.geri,
                      onBackPressed:
                          isFirstStep || _loadingCards ? null : _goBack,
                      primaryLabel: isCardsStep
                          ? (selectedCount == 0
                              ? context.l10n.createGroup
                              : context.l10n.createGroupWithCards(
                                  selectedCount,
                                ))
                          : context.l10n.devam,
                      onPrimaryPressed:
                          _loadingCards ? null : (isCardsStep ? _submit : _goToNext),
                      isLoading: _loadingCards,
                      enabled: !_loadingCards,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilledSummaryHeader() {
    return CreateEventGroupFilledSummary(
      name: _groupName,
      location: _locationSummary,
      startAt: _startAt,
      endAt: _endAt,
      photoFilePath: _photoFilePath,
    );
  }

  Widget _buildNameStep() {
    return _CreateEventStepLayer(
      child: _CreateEventNameStep(
        nameController: _nameController,
        nameErrorText: _nameErrorText,
        onContinue: _goToNext,
      ),
    );
  }

  Widget _buildLocationStep() {
    return _CreateEventStepLayer(
      child: _CreateEventLocationStep(
        summaryHeader: _buildFilledSummaryHeader(),
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
      ),
    );
  }

  Widget _buildScheduleStep() {
    return _CreateEventStepLayer(
      child: _CreateEventScheduleStep(
        summaryHeader: _buildFilledSummaryHeader(),
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
      ),
    );
  }

  Widget _buildDetailsStep() {
    return _CreateEventStepLayer(
      child: _CreateEventDetailsStep(
        summaryHeader: _buildFilledSummaryHeader(),
        descriptionController: _descriptionController,
        descriptionErrorText: _descriptionErrorText,
      ),
    );
  }

  Widget _buildPhotoStep() {
    return _CreateEventStepLayer(
      child: _CreateEventPhotoStep(
        summaryHeader: _buildFilledSummaryHeader(),
        photoFilePath: _photoFilePath,
        onPhotoChanged: (value) => setState(() => _photoFilePath = value),
      ),
    );
  }

  Widget _buildCardsStep() {
    final startAt = _startAt;
    if (startAt == null) {
      return const SizedBox.shrink();
    }

    return _CreateEventGroupPickCardsStep(
      groupName: _groupName,
      location: _locationSummary,
      startAt: startAt,
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

class _CreateEventStepLayer extends StatelessWidget {
  const _CreateEventStepLayer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      widthFactor: 1,
      heightFactor: 1,
      child: child,
    );
  }
}

class _CreateEventGroupKeyboardAwareBottom extends StatelessWidget {
  const _CreateEventGroupKeyboardAwareBottom({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: child,
    );
  }
}

class _CreateEventStepCard extends StatelessWidget {
  const _CreateEventStepCard({
    required this.child,
    this.scrollController,
    this.header,
  });

  final Widget child;
  final ScrollController? scrollController;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) header!,
          Align(
            alignment: Alignment.topCenter,
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
          ),
        ],
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
    required this.summaryHeader,
    required this.country,
    required this.city,
    required this.venueController,
    required this.locationErrorText,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.onVenueChanged,
  });

  final Widget summaryHeader;
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
      header: summaryHeader,
      child: EventGroupLocationPickerField(
        country: country,
        city: city,
        venueController: venueController,
        errorText: locationErrorText,
        onCountryChanged: onCountryChanged,
        onCityChanged: onCityChanged,
        onVenueChanged: onVenueChanged,
        showComposedPreview: false,
      ),
    );
  }
}

class _CreateEventScheduleStep extends StatefulWidget {
  const _CreateEventScheduleStep({
    required this.summaryHeader,
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

  final Widget summaryHeader;
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
  State<_CreateEventScheduleStep> createState() =>
      _CreateEventScheduleStepState();
}

class _CreateEventScheduleStepState extends State<_CreateEventScheduleStep> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _endSectionKey = GlobalKey();
  bool _wasEndSectionVisible = false;

  @override
  void initState() {
    super.initState();
    _wasEndSectionVisible = _isEndSectionVisible(widget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isEndSectionVisible(_CreateEventScheduleStep step) {
    if (step.endDate != null || step.endTime != null) return true;
    return step.startDate != null && step.startTime != null;
  }

  @override
  void didUpdateWidget(covariant _CreateEventScheduleStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasVisible = _wasEndSectionVisible;
    final isVisible = _isEndSectionVisible(widget);
    _wasEndSectionVisible = isVisible;
    if (!wasVisible && isVisible) {
      _scrollToEndSection();
    }
  }

  void _scrollToEndSection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final targetContext = _endSectionKey.currentContext;
        if (targetContext == null) return;
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0.02,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CreateEventStepCard(
      scrollController: _scrollController,
      header: widget.summaryHeader,
      child: EventGroupSchedulePickerSection(
        startDate: widget.startDate,
        startTime: widget.startTime,
        endDate: widget.endDate,
        endTime: widget.endTime,
        errorText: widget.scheduleErrorText,
        onPickStartDate: widget.onPickStartDate,
        onPickStartTime: widget.onPickStartTime,
        onPickEndDate: widget.onPickEndDate,
        onPickEndTime: widget.onPickEndTime,
        onClearEnd: widget.onClearEnd,
        showInlineSummary: false,
        revealEndWhenStartComplete: true,
        endSectionKey: _endSectionKey,
      ),
    );
  }
}

class _CreateEventDetailsStep extends StatelessWidget {
  const _CreateEventDetailsStep({
    required this.summaryHeader,
    required this.descriptionController,
    required this.descriptionErrorText,
  });

  final Widget summaryHeader;
  final TextEditingController descriptionController;
  final String? descriptionErrorText;

  @override
  Widget build(BuildContext context) {
    return _CreateEventStepCard(
      header: summaryHeader,
      child: CustomTextField(
        controller: descriptionController,
        labelText: context.l10n.eventDescription,
        hintText: context.l10n.eventDescriptionHint,
        errorText: descriptionErrorText,
        minLines: 4,
        maxLines: 8,
        maxLength: 2000,
        textInputAction: TextInputAction.newline,
      ),
    );
  }
}

class _CreateEventPhotoStep extends StatelessWidget {
  const _CreateEventPhotoStep({
    required this.summaryHeader,
    required this.photoFilePath,
    required this.onPhotoChanged,
  });

  final Widget summaryHeader;
  final String? photoFilePath;
  final ValueChanged<String?> onPhotoChanged;

  @override
  Widget build(BuildContext context) {
    return _CreateEventStepCard(
      header: summaryHeader,
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
  final void Function(String cardId) onAddInvitedCardId;
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
