import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/new_event_group_name_dialog.dart';
import '../../domain/entities/event_group.dart';
import 'event_group_photo_picker_field.dart';
import 'event_group_schedule_picker_section.dart';

class EditEventGroupResult {
  const EditEventGroupResult({
    required this.name,
    required this.location,
    required this.startAt,
    this.endAt,
    this.photoFilePath,
    this.clearPhoto = false,
  });

  final String name;
  final String location;
  final DateTime startAt;
  final DateTime? endAt;
  final String? photoFilePath;
  final bool clearPhoto;
}

class EditEventGroupSheet extends StatefulWidget {
  const EditEventGroupSheet({
    super.key,
    required this.group,
    required this.existingNames,
  });

  final EventGroup group;
  final List<String> existingNames;

  static Future<EditEventGroupResult?> show(
    BuildContext context, {
    required EventGroup group,
    required List<String> existingNames,
  }) {
    return showModalBottomSheet<EditEventGroupResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => EditEventGroupSheet(
        group: group,
        existingNames: existingNames,
      ),
    );
  }

  @override
  State<EditEventGroupSheet> createState() => _EditEventGroupSheetState();
}

class _EditEventGroupSheetState extends State<EditEventGroupSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  String? _nameErrorText;
  String? _locationErrorText;
  String? _scheduleErrorText;
  late DateTime? _startDate;
  late TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  String? _photoFilePath;
  bool _clearPhoto = false;
  String? _initialPhotoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _locationController =
        TextEditingController(text: widget.group.location ?? '');
    _initialPhotoUrl = widget.group.photoUrl;
    final startLocal = widget.group.startAt.toLocal();
    _startDate = DateTime(startLocal.year, startLocal.month, startLocal.day);
    _startTime = TimeOfDay(hour: startLocal.hour, minute: startLocal.minute);
    final endAt = widget.group.endAt;
    if (endAt != null) {
      final endLocal = endAt.toLocal();
      _endDate = DateTime(endLocal.year, endLocal.month, endLocal.day);
      _endTime = TimeOfDay(hour: endLocal.hour, minute: endLocal.minute);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  DateTime? get _startAt => _combineDateAndTime(_startDate, _startTime);

  DateTime? get _endAt => _combineDateAndTime(_endDate, _endTime);

  DateTime? _combineDateAndTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<DateTime?> _pickDate({required DateTime initialDate}) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
  }

  Future<TimeOfDay?> _pickTime({required TimeOfDay initialTime}) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final startAt = _startAt;
    final endAt = _endAt;

    if (name.isEmpty) {
      setState(() => _nameErrorText = context.l10n.eventGroupNameRequired);
      return;
    }
    if (name != widget.group.name &&
        NewEventGroupNameDialog.isDuplicateName(name, widget.existingNames)) {
      setState(() => _nameErrorText = context.l10n.eventGroupNameDuplicate);
      return;
    }
    if (location.isEmpty) {
      setState(() => _locationErrorText = context.l10n.eventLocationRequired);
      return;
    }
    if (startAt == null) {
      setState(() => _scheduleErrorText = context.l10n.eventStartRequired);
      return;
    }
    if ((_endDate == null) != (_endTime == null)) {
      setState(
          () => _scheduleErrorText = context.l10n.eventEndRequiresDateAndTime);
      return;
    }
    if (endAt != null && endAt.isBefore(startAt)) {
      setState(() => _scheduleErrorText = context.l10n.eventEndBeforeStart);
      return;
    }

    Navigator.of(context).pop(
      EditEventGroupResult(
        name: name,
        location: location,
        startAt: startAt,
        endAt: endAt,
        photoFilePath: _photoFilePath,
        clearPhoto: _clearPhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                context.l10n.eventEditTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          labelText: context.l10n.etkinlikAd,
                          errorText: _nameErrorText,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _locationController,
                          labelText: context.l10n.konum,
                          errorText: _locationErrorText,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        EventGroupSchedulePickerSection(
                          startDate: _startDate,
                          startTime: _startTime,
                          endDate: _endDate,
                          endTime: _endTime,
                          errorText: _scheduleErrorText,
                          onPickStartDate: () async {
                            final picked = await _pickDate(
                              initialDate: _startDate ?? DateTime.now(),
                            );
                            if (picked == null) return;
                            setState(() {
                              _startDate = picked;
                              _scheduleErrorText = null;
                            });
                          },
                          onPickStartTime: () async {
                            final picked = await _pickTime(
                              initialTime: _startTime ?? TimeOfDay.now(),
                            );
                            if (picked == null) return;
                            setState(() {
                              _startTime = picked;
                              _scheduleErrorText = null;
                            });
                          },
                          onPickEndDate: () async {
                            final picked = await _pickDate(
                              initialDate:
                                  _endDate ?? _startDate ?? DateTime.now(),
                            );
                            if (picked == null) return;
                            setState(() {
                              _endDate = picked;
                              _scheduleErrorText = null;
                            });
                          },
                          onPickEndTime: () async {
                            final picked = await _pickTime(
                              initialTime:
                                  _endTime ?? _startTime ?? TimeOfDay.now(),
                            );
                            if (picked == null) return;
                            setState(() {
                              _endTime = picked;
                              _scheduleErrorText = null;
                            });
                          },
                          onClearEnd: () {
                            setState(() {
                              _endDate = null;
                              _endTime = null;
                              _scheduleErrorText = null;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        EventGroupPhotoPickerField(
                          value: _photoFilePath,
                          previewUrl:
                              _clearPhoto ? null : _initialPhotoUrl,
                          onChanged: (path) {
                            setState(() {
                              _photoFilePath = path;
                              _clearPhoto = path == null &&
                                  (_initialPhotoUrl?.trim().isNotEmpty ?? false);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: CustomButton(
                  label: context.l10n.kaydet,
                  onPressed: _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
