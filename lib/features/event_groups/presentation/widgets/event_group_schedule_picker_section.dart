import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/location_picker_field_row.dart';
import '../helpers/event_group_meta_formatter.dart';

enum EventGroupSchedulePickerStyle {
  standard,
  createFlow,
}

String? formatEventGroupDate(DateTime? value) {
  if (value == null) return null;
  return '${value.day.toString().padLeft(2, '0')}.'
      '${value.month.toString().padLeft(2, '0')}.${value.year}';
}

String? formatEventGroupDisplayDate(BuildContext context, DateTime? value) {
  if (value == null) return null;
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat('d MMM yyyy', locale).format(value);
}

String? formatEventGroupTime(TimeOfDay? value) {
  if (value == null) return null;
  return '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

DateTime? combineEventGroupSchedule(DateTime? date, TimeOfDay? time) {
  if (date == null || time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

class EventGroupScheduleFieldTile extends StatelessWidget {
  const EventGroupScheduleFieldTile({
    super.key,
    required this.fieldLabel,
    required this.valueLabel,
    required this.placeholder,
    required this.icon,
    required this.isSet,
    required this.onPressed,
  });

  final String fieldLabel;
  final String valueLabel;
  final String placeholder;
  final IconData icon;
  final bool isSet;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isSet
        ? colorScheme.primary.withValues(alpha: isDark ? 0.55 : 0.35)
        : (isDark
            ? AppColors.outlineDark.withValues(alpha: 0.45)
            : AppColors.outlineVariant.withValues(alpha: 0.85));
    final backgroundColor = isSet
        ? colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.06)
        : colorScheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.35 : 0.55,
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: (isSet ? colorScheme.primary : colorScheme.onSurfaceVariant)
                        .withValues(alpha: isDark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      icon,
                      size: 18,
                      color: isSet ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fieldLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isSet ? valueLabel : placeholder,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isSet
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          fontWeight: isSet ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSet ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                  size: 20,
                  color: isSet ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddEndScheduleButton extends StatelessWidget {
  const _AddEndScheduleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(
          Icons.add_circle_outline_rounded,
          size: 20,
          color: colorScheme.primary,
        ),
        label: Text(
          context.l10n.eventAddEnd,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CreateFlowScheduleFields extends StatelessWidget {
  const _CreateFlowScheduleFields({
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.showEndSection,
    required this.onPickStartDate,
    required this.onPickStartTime,
    required this.onPickEndDate,
    required this.onPickEndTime,
    required this.onRevealEnd,
    required this.onClearEnd,
    this.endSectionKey,
  });

  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final bool showEndSection;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndDate;
  final VoidCallback onPickEndTime;
  final VoidCallback onRevealEnd;
  final VoidCallback onClearEnd;
  final GlobalKey? endSectionKey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final hasEndValues = endDate != null || endTime != null;

    return Column(
      key: endSectionKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LocationPickerFieldRow(
          label: l10n.eventStartDateLabel.toUpperCase(),
          leadingIcon: Icons.calendar_today_outlined,
          leadingIconColor: colorScheme.primary,
          value: formatEventGroupDisplayDate(context, startDate),
          placeholder: l10n.tarihSein,
          onTap: onPickStartDate,
        ),
        const SizedBox(height: 16),
        LocationPickerFieldRow(
          label: l10n.eventStartTimeLabel.toUpperCase(),
          leadingIcon: Icons.schedule_rounded,
          leadingIconColor: colorScheme.primary,
          value: formatEventGroupTime(startTime),
          placeholder: l10n.eventPickTime,
          onTap: onPickStartTime,
        ),
        if (!showEndSection) ...[
          const SizedBox(height: 16),
          _AddEndScheduleButton(onPressed: onRevealEnd),
        ],
        if (showEndSection) ...[
          const SizedBox(height: 20),
          LocationPickerFieldRow(
            label: l10n.eventEndDateLabel.toUpperCase(),
            leadingIcon: Icons.event_outlined,
            leadingIconColor: colorScheme.primary,
            value: formatEventGroupDisplayDate(context, endDate),
            placeholder: l10n.tarihSein,
            onTap: onPickEndDate,
          ),
          const SizedBox(height: 16),
          LocationPickerFieldRow(
            label: l10n.eventEndTimeLabel.toUpperCase(),
            leadingIcon: Icons.more_time_rounded,
            leadingIconColor: colorScheme.primary,
            value: formatEventGroupTime(endTime),
            placeholder: l10n.eventPickTime,
            onTap: onPickEndTime,
          ),
          if (hasEndValues) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton.text(
                label: l10n.temizle,
                onPressed: onClearEnd,
                height: 32,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _ScheduleSummaryBanner extends StatelessWidget {
  const _ScheduleSummaryBanner({
    required this.title,
    required this.summary,
  });

  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
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

class _ScheduleHintBanner extends StatelessWidget {
  const _ScheduleHintBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.45 : 0.65,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.outlineDark.withValues(alpha: 0.35)
              : AppColors.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleSectionHeader extends StatelessWidget {
  const _ScheduleSectionHeader({
    required this.title,
    required this.badgeLabel,
    required this.required,
  });

  final String title;
  final String badgeLabel;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final badgeColor = required ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: badgeColor.withValues(alpha: 0.28),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              badgeLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EventGroupStartScheduleSection extends StatelessWidget {
  const EventGroupStartScheduleSection({
    super.key,
    required this.startDate,
    required this.startTime,
    required this.onPickStartDate,
    required this.onPickStartTime,
  });

  final DateTime? startDate;
  final TimeOfDay? startTime;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickStartTime;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScheduleSectionHeader(
          title: l10n.eventStart,
          badgeLabel: l10n.eventScheduleRequired,
          required: true,
        ),
        const SizedBox(height: 8),
        _ScheduleHintBanner(message: l10n.eventScheduleStartHelper),
        const SizedBox(height: 12),
        EventGroupScheduleFieldTile(
          fieldLabel: l10n.eventScheduleDateField,
          valueLabel: formatEventGroupDate(startDate) ?? '',
          placeholder: l10n.tarihSein,
          icon: Icons.calendar_month_outlined,
          isSet: startDate != null,
          onPressed: onPickStartDate,
        ),
        const SizedBox(height: 10),
        EventGroupScheduleFieldTile(
          fieldLabel: l10n.eventScheduleTimeField,
          valueLabel: formatEventGroupTime(startTime) ?? '',
          placeholder: l10n.eventPickTime,
          icon: Icons.schedule_rounded,
          isSet: startTime != null,
          onPressed: onPickStartTime,
        ),
      ],
    );
  }
}

class EventGroupEndScheduleSection extends StatelessWidget {
  const EventGroupEndScheduleSection({
    super.key,
    required this.endDate,
    required this.endTime,
    required this.onPickEndDate,
    required this.onPickEndTime,
    required this.onClearEnd,
  });

  final DateTime? endDate;
  final TimeOfDay? endTime;
  final VoidCallback onPickEndDate;
  final VoidCallback onPickEndTime;
  final VoidCallback onClearEnd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasEndValues = endDate != null || endTime != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScheduleSectionHeader(
          title: l10n.eventEndOptional,
          badgeLabel: l10n.opsiyonel,
          required: false,
        ),
        const SizedBox(height: 8),
        _ScheduleHintBanner(message: l10n.eventScheduleEndHelper),
        const SizedBox(height: 12),
        EventGroupScheduleFieldTile(
          fieldLabel: l10n.eventScheduleDateField,
          valueLabel: formatEventGroupDate(endDate) ?? '',
          placeholder: l10n.tarihSein,
          icon: Icons.event_outlined,
          isSet: endDate != null,
          onPressed: onPickEndDate,
        ),
        const SizedBox(height: 10),
        EventGroupScheduleFieldTile(
          fieldLabel: l10n.eventScheduleTimeField,
          valueLabel: formatEventGroupTime(endTime) ?? '',
          placeholder: l10n.eventPickTime,
          icon: Icons.more_time_rounded,
          isSet: endTime != null,
          onPressed: onPickEndTime,
        ),
        if (hasEndValues) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton.text(
              label: l10n.temizle,
              onPressed: onClearEnd,
              height: 32,
            ),
          ),
        ],
      ],
    );
  }
}

class EventGroupSchedulePickerSection extends StatelessWidget {
  const EventGroupSchedulePickerSection({
    super.key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.errorText,
    required this.onPickStartDate,
    required this.onPickStartTime,
    required this.onPickEndDate,
    required this.onPickEndTime,
    required this.onClearEnd,
    this.style = EventGroupSchedulePickerStyle.standard,
    this.showInlineSummary = true,
    this.endSectionKey,
    this.revealEndWhenStartComplete = false,
    this.showEndSection = true,
    this.onRevealEnd,
  });

  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final String? errorText;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndDate;
  final VoidCallback onPickEndTime;
  final VoidCallback onClearEnd;
  final EventGroupSchedulePickerStyle style;
  final bool showInlineSummary;
  final GlobalKey? endSectionKey;
  final bool revealEndWhenStartComplete;
  final bool showEndSection;
  final VoidCallback? onRevealEnd;

  bool _shouldShowEndSection() {
    if (style == EventGroupSchedulePickerStyle.createFlow) {
      return showEndSection;
    }
    if (!revealEndWhenStartComplete) return true;
    if (endDate != null || endTime != null) return true;
    return startDate != null && startTime != null;
  }

  String? _buildSummary(BuildContext context) {
    final startAt = combineEventGroupSchedule(startDate, startTime);
    if (startAt == null) return null;

    final endAt = combineEventGroupSchedule(endDate, endTime);
    if (endAt == null) {
      return EventGroupMetaFormatter.formatDate(startAt);
    }
    return EventGroupMetaFormatter.formatRange(startAt, endAt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final error = errorText;
    final summary = _buildSummary(context);
    final hasEnd = endDate != null && endTime != null;
    final showEnd = _shouldShowEndSection();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (style == EventGroupSchedulePickerStyle.createFlow)
          _CreateFlowScheduleFields(
            startDate: startDate,
            startTime: startTime,
            endDate: endDate,
            endTime: endTime,
            showEndSection: showEnd,
            onPickStartDate: onPickStartDate,
            onPickStartTime: onPickStartTime,
            onPickEndDate: onPickEndDate,
            onPickEndTime: onPickEndTime,
            onRevealEnd: onRevealEnd ?? () {},
            onClearEnd: onClearEnd,
            endSectionKey: endSectionKey,
          )
        else ...[
          if (showInlineSummary && summary != null) ...[
            _ScheduleSummaryBanner(
              title: hasEnd
                  ? l10n.eventSchedulePlannedRange
                  : l10n.eventSchedulePlannedStart,
              summary: summary,
            ),
            const SizedBox(height: 16),
          ],
          EventGroupStartScheduleSection(
            startDate: startDate,
            startTime: startTime,
            onPickStartDate: onPickStartDate,
            onPickStartTime: onPickStartTime,
          ),
          if (showEnd) ...[
            const SizedBox(height: 20),
            EventGroupEndScheduleSection(
              key: endSectionKey,
              endDate: endDate,
              endTime: endTime,
              onPickEndDate: onPickEndDate,
              onPickEndTime: onPickEndTime,
              onClearEnd: onClearEnd,
            ),
          ],
        ],
        if (error != null) ...[
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.35),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
