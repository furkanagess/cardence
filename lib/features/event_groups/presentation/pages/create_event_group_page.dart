import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/location/country_location_data_cache.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/new_event_group_name_dialog.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../onboarding/presentation/widgets/onboarding_flow_ui.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/presentation/widgets/add_card_flow_status_views.dart';
import '../../../saved_cards/presentation/widgets/saved_card_list_tile.dart';
import '../helpers/create_event_group_submit_result.dart';
import '../helpers/create_event_group_step_meta.dart';
import '../helpers/event_group_location_composer.dart';
import '../widgets/create_event_group_step_header.dart';
import '../widgets/event_group_card_id_invite_field.dart';
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

enum _SubmitPhase { idle, submitting, success, failure }

/// Her bilgi ayrı adımda: ad · konum · tarih/saat · detay · fotoğraf · kartlar.
class CreateEventGroupPage extends StatefulWidget {
  const CreateEventGroupPage({
    super.key,
    required this.existingNames,
    required this.getSavedCards,
    required this.onSubmit,
    this.initialPickableCards,
  });

  final List<String> existingNames;
  final GetSavedCards getSavedCards;
  final Future<CreateEventGroupSubmitResult> Function(CreateEventGroupResult)
      onSubmit;
  final List<SavedCard>? initialPickableCards;

  static const Duration statusDisplayDuration = Duration(milliseconds: 2400);

  static Future<CreateEventGroupPageOutcome?> push(
    BuildContext context, {
    required List<String> existingNames,
    required GetSavedCards getSavedCards,
    required Future<CreateEventGroupSubmitResult> Function(
      CreateEventGroupResult,
    )
        onSubmit,
    List<SavedCard>? initialPickableCards,
  }) {
    CountryLocationDataCache.warmUp();
    return Navigator.of(context).push<CreateEventGroupPageOutcome>(
      MaterialPageRoute(
        builder: (context) => CreateEventGroupPage(
          existingNames: existingNames,
          getSavedCards: getSavedCards,
          onSubmit: onSubmit,
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
  _SubmitPhase _submitPhase = _SubmitPhase.idle;
  String? _failureTitle;
  String? _failureMessage;
  bool _paywallRequiredAfterDismiss = false;
  String? _successTitle;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _venueController = TextEditingController();
    _cardIdController = TextEditingController();
    _descriptionController = TextEditingController();
    _nameController.addListener(_onNameFieldChanged);
    _descriptionController.addListener(_onDescriptionFieldChanged);
    _selectedCardIds = {};
    _invitedCardIds = {};
    final initialCards = widget.initialPickableCards;
    if (initialCards != null && initialCards.isNotEmpty) {
      _pickableCards = List<SavedCard>.from(initialCards);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameFieldChanged);
    _descriptionController.removeListener(_onDescriptionFieldChanged);
    _nameController.dispose();
    _venueController.dispose();
    _cardIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _groupName => _nameController.text.trim();

  void _onNameFieldChanged() {
    setState(() {
      if (_nameErrorText != null) _nameErrorText = null;
    });
  }

  void _onDescriptionFieldChanged() {
    setState(() {
      if (_descriptionErrorText != null) _descriptionErrorText = null;
    });
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

  DateTime? get _startAt => _combineDateAndTime(_startDate, _startTime);

  DateTime? get _endAt => _combineDateAndTime(_endDate, _endTime);

  bool get _canSkipCurrentStep =>
      _step == _CreateEventStep.details || _step == _CreateEventStep.photo;

  bool get _isCurrentStepReady {
    switch (_step) {
      case _CreateEventStep.name:
        final name = _groupName;
        return name.isNotEmpty &&
            !NewEventGroupNameDialog.isDuplicateName(
              name,
              widget.existingNames,
            );
      case _CreateEventStep.location:
        return EventGroupLocationComposer.isRegionComplete(
          _locationCountry,
          _locationCity,
        );
      case _CreateEventStep.schedule:
        return _isScheduleStepReady;
      case _CreateEventStep.details:
        return _descriptionController.text.trim().length <= 2000;
      case _CreateEventStep.photo:
      case _CreateEventStep.cards:
        return true;
    }
  }

  bool get _isScheduleStepReady {
    final startAt = _startAt;
    if (startAt == null) return false;

    final hasEndDate = _endDate != null;
    final hasEndTime = _endTime != null;
    if (!hasEndDate && !hasEndTime) return true;
    if (hasEndDate != hasEndTime) return false;

    final endAt = _endAt;
    if (endAt == null) return false;
    return !endAt.isBefore(startAt);
  }

  bool get _isPrimaryActionEnabled => !_loadingCards && _isCurrentStepReady;

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

  Future<void> _submit() async {
    final location = _composedLocation.trim();
    final startAt = _startAt;
    if (location.isEmpty || startAt == null) {
      setState(() => _step = _CreateEventStep.name);
      return;
    }
    if (_submitPhase == _SubmitPhase.submitting) return;

    final draft = CreateEventGroupResult(
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
    );

    setState(() {
      _submitPhase = _SubmitPhase.submitting;
      _failureTitle = null;
      _failureMessage = null;
    });

    final outcome = await widget.onSubmit(draft);
    if (!mounted) return;

    switch (outcome) {
      case CreateEventGroupSubmitSuccess(
          :final successTitle,
          :final successMessage,
        ):
        setState(() {
          _submitPhase = _SubmitPhase.success;
          _successTitle = successTitle;
          _successMessage = successMessage;
        });
        await Future<void>.delayed(CreateEventGroupPage.statusDisplayDuration);
        if (!mounted) return;
        Navigator.of(context).pop(CreateEventGroupPageOutcome.created);
      case CreateEventGroupSubmitPaywallRequired():
        setState(() {
          _submitPhase = _SubmitPhase.failure;
          _failureTitle = context.l10n.eventGroupCreateFailed;
          _failureMessage = context.l10n.groupLimitReached;
          _paywallRequiredAfterDismiss = true;
        });
      case CreateEventGroupSubmitFailure(:final title, :final message):
        setState(() {
          _submitPhase = _SubmitPhase.failure;
          _failureTitle = title;
          _failureMessage = message;
        });
    }
  }

  void _dismissFailure() {
    if (_paywallRequiredAfterDismiss) {
      _paywallRequiredAfterDismiss = false;
      Navigator.of(context).pop(CreateEventGroupPageOutcome.paywallRequired);
      return;
    }
    setState(() {
      _submitPhase = _SubmitPhase.idle;
      _failureTitle = null;
      _failureMessage = null;
    });
  }

  void _handleAppBarBack() {
    if (_submitPhase == _SubmitPhase.failure) {
      _dismissFailure();
      return;
    }
    if (_submitPhase != _SubmitPhase.idle) return;

    if (_step == _CreateEventStep.name) {
      Navigator.of(context).maybePop();
      return;
    }
    _goBack();
  }

  bool get _isSubmittingFlow =>
      _submitPhase == _SubmitPhase.submitting ||
      _submitPhase == _SubmitPhase.success;

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
    final isForm = _submitPhase == _SubmitPhase.idle;
    final isFailure = _submitPhase == _SubmitPhase.failure;
    final l10n = context.l10n;

    return PopScope(
      canPop: isForm && isFirstStep,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isFailure) {
          _dismissFailure();
          return;
        }
        if (!isForm || isFirstStep) return;
        _goBack();
      },
      child: CardenceScaffold(
        resizeToAvoidBottomInset: false,
        appBar: CardenceAppBar(
          title: l10n.etkinlikOlutur,
          leading: CardenceAppBar.flowBackButton(
            context: context,
            onPressed: _isSubmittingFlow ? null : _handleAppBarBack,
          ),
          automaticallyImplyLeading: false,
          actions: isForm &&
                  CreateEventGroupStepMeta.showsOptionalBadge(_step.index)
              ? const [
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Center(child: OnboardingOptionalBadge()),
                  ),
                ]
              : null,
        ),
        body: SafeArea(
          bottom: false,
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isForm)
                CreateEventGroupStepProgress(currentIndex: _step.index),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: switch (_submitPhase) {
                    _SubmitPhase.submitting => AddCardFlowSendingView(
                        key: const ValueKey('create-event-sending'),
                        message: l10n.eventGroupCreating,
                      ),
                    _SubmitPhase.success => AddCardFlowSuccessView(
                        key: const ValueKey('create-event-success'),
                        title: _successTitle ?? l10n.eventGroupCreatedSuccess,
                        message: _successMessage ??
                            l10n.eventGroupCreatedMessage(_groupName),
                      ),
                    _SubmitPhase.failure => AddCardFlowFailureView(
                        key: const ValueKey('create-event-failure'),
                        title: _failureTitle ?? l10n.eventGroupCreateFailed,
                        message: _failureMessage ?? l10n.operationFailed,
                      ),
                    _SubmitPhase.idle => IndexedStack(
                        key: const ValueKey('create-event-form'),
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
                  },
                ),
              ),
              if (isForm)
                _CreateEventGroupKeyboardAwareBottom(
                  child: CardenceFlowBottomBarRegion(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_canSkipCurrentStep)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: CustomButton.text(
                                label: l10n.eventSkip,
                                onPressed:
                                    _loadingCards ? null : _skipCurrentStep,
                              ),
                            ),
                          ),
                        OnboardingBottomBar(
                          embedded: true,
                          stepCount: CreateEventGroupStepMeta.stepCount,
                          currentIndex: _step.index,
                          showStepIndicator: false,
                          backLabel: l10n.geri,
                          onBackPressed:
                              isFirstStep || _loadingCards ? null : _goBack,
                          primaryLabel: isCardsStep
                              ? (selectedCount == 0
                                  ? l10n.createGroup
                                  : l10n.createGroupWithCards(
                                      selectedCount,
                                    ))
                              : l10n.devam,
                          onPrimaryPressed: _isPrimaryActionEnabled
                              ? (isCardsStep ? _submit : _goToNext)
                              : null,
                          isLoading: _loadingCards,
                          enabled: _isPrimaryActionEnabled,
                        ),
                      ],
                    ),
                  ),
                )
              else if (isFailure)
                CardenceFlowBottomBarRegion(
                  child: CustomButton(
                    label: _paywallRequiredAfterDismiss
                        ? l10n.tamam
                        : l10n.retry,
                    onPressed: _dismissFailure,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return _CreateEventScrollableStep(
      stepIndex: _CreateEventStep.name.index,
      compactHeader: true,
      child: _CreateEventNameStep(
        nameController: _nameController,
        nameErrorText: _nameErrorText,
        onContinue: _goToNext,
      ),
    );
  }

  Widget _buildLocationStep() {
    return _CreateEventScrollableStep(
      stepIndex: _CreateEventStep.location.index,
      child: _CreateEventLocationStep(
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
        onMapLocationResolved: ({country, city, venue}) => setState(() {
          if (country != null) _locationCountry = country;
          if (city != null) _locationCity = city;
          if (venue != null && venue.trim().isNotEmpty) {
            _venueController.text = venue.trim();
          }
          _clearLocationErrorOnEdit();
        }),
      ),
    );
  }

  Widget _buildScheduleStep() {
    return _CreateEventScheduleStep(
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
  }

  Widget _buildDetailsStep() {
    return _CreateEventScrollableStep(
      stepIndex: _CreateEventStep.details.index,
      child: _CreateEventDetailsStep(
        descriptionController: _descriptionController,
        descriptionErrorText: _descriptionErrorText,
      ),
    );
  }

  Widget _buildPhotoStep() {
    return _CreateEventScrollableStep(
      stepIndex: _CreateEventStep.photo.index,
      child: _CreateEventPhotoStep(
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

class _CreateEventScrollableStep extends StatelessWidget {
  const _CreateEventScrollableStep({
    required this.stepIndex,
    required this.child,
    this.compactHeader = false,
    this.scrollController,
  });

  final int stepIndex;
  final Widget child;
  final bool compactHeader;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final bottomInset = OnboardingBottomBar.contentBottomInset(
      context,
      showStepIndicator: false,
    );

    return SingleChildScrollView(
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CreateEventGroupStepTitleHeader(
            currentIndex: stepIndex,
            compact: compactHeader,
          ),
          child,
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: CustomTextField(
        controller: nameController,
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
    required this.country,
    required this.city,
    required this.venueController,
    required this.locationErrorText,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.onVenueChanged,
    this.onMapLocationResolved,
  });

  final String? country;
  final String? city;
  final TextEditingController venueController;
  final String? locationErrorText;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onCityChanged;
  final VoidCallback onVenueChanged;
  final void Function({
    String? country,
    String? city,
    String? venue,
  })? onMapLocationResolved;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: EventGroupLocationPickerField(
        country: country,
        city: city,
        venueController: venueController,
        errorText: locationErrorText,
        onCountryChanged: onCountryChanged,
        onCityChanged: onCityChanged,
        onVenueChanged: onVenueChanged,
        onMapLocationResolved: onMapLocationResolved,
        showComposedPreview: false,
      ),
    );
  }
}

class _CreateEventScheduleStep extends StatefulWidget {
  const _CreateEventScheduleStep({
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
  State<_CreateEventScheduleStep> createState() =>
      _CreateEventScheduleStepState();
}

class _CreateEventScheduleStepState extends State<_CreateEventScheduleStep> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _endSectionKey = GlobalKey();
  late bool _endSectionVisible;
  bool _wasEndSectionVisible = false;

  @override
  void initState() {
    super.initState();
    _endSectionVisible = _hasEndValues(widget);
    _wasEndSectionVisible = _endSectionVisible;
  }

  bool _hasEndValues(_CreateEventScheduleStep step) {
    return step.endDate != null || step.endTime != null;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CreateEventScheduleStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasEndValues(widget)) {
      _endSectionVisible = true;
    }
    final wasVisible = _wasEndSectionVisible;
    final isVisible = _endSectionVisible;
    _wasEndSectionVisible = isVisible;
    if (!wasVisible && isVisible) {
      _scrollToEndSection();
    }
  }

  void _revealEndSection() {
    setState(() => _endSectionVisible = true);
    _scrollToEndSection();
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
    return _CreateEventScrollableStep(
      stepIndex: _CreateEventStep.schedule.index,
      scrollController: _scrollController,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: EventGroupSchedulePickerSection(
          style: EventGroupSchedulePickerStyle.createFlow,
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
          showEndSection: _endSectionVisible,
          onRevealEnd: _revealEndSection,
          endSectionKey: _endSectionKey,
        ),
      ),
    );
  }
}

class _CreateEventDetailsStep extends StatelessWidget {
  const _CreateEventDetailsStep({
    required this.descriptionController,
    required this.descriptionErrorText,
  });

  final TextEditingController descriptionController;
  final String? descriptionErrorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: CustomTextField(
        controller: descriptionController,
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
    required this.photoFilePath,
    required this.onPhotoChanged,
  });

  final String? photoFilePath;
  final ValueChanged<String?> onPhotoChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: EventGroupPhotoPickerField(
        value: photoFilePath,
        onChanged: onPhotoChanged,
        style: EventGroupPhotoPickerStyle.createFlow,
      ),
    );
  }
}

class _CreateEventGroupPickCardsStep extends StatelessWidget {
  const _CreateEventGroupPickCardsStep({
    super.key,
    required this.cardIdController,
    required this.loadingCards,
    required this.pickableCards,
    required this.selectedCardIds,
    required this.invitedCardIds,
    required this.onToggleCard,
    required this.onAddInvitedCardId,
    required this.onRemoveInvitedCardId,
  });

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
    final bottomInset = OnboardingBottomBar.contentBottomInset(
      context,
      showStepIndicator: false,
    );

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: CreateEventGroupStepTitleHeader(
            currentIndex: _CreateEventStep.cards.index,
          ),
        ),
        if (!loadingCards)
          SliverToBoxAdapter(
            child: Padding(
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
                        : context.l10n.cardsSelectedCount(
                            selectedCardIds.length,
                          ),
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
          ),
        if (loadingCards)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (pickableCards.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Text(
                context.l10n.eventCreateNoSavedCards,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final card = pickableCards[index];
                  return SavedCardListTile(
                    card: card,
                    selectable: true,
                    selected: selectedCardIds.contains(card.cardId),
                    onTap: () => onToggleCard(card.cardId),
                  );
                },
                childCount: pickableCards.length,
              ),
            ),
          ),
        SliverPadding(padding: EdgeInsets.only(bottom: bottomInset)),
      ],
    );
  }
}
