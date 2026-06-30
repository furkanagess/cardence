import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.eventStart,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: EventGroupSchedulePickerButton(
                label: _formatDate(startDate) ?? context.l10n.tarihSein,
                icon: Icons.calendar_today_rounded,
                onPressed: onPickStartDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: EventGroupSchedulePickerButton(
                label: _formatTime(startTime) ?? context.l10n.eventPickTime,
                icon: Icons.schedule_rounded,
                onPressed: onPickStartTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.eventEndOptional,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (endDate != null || endTime != null)
              CustomButton.text(
                label: context.l10n.temizle,
                onPressed: onClearEnd,
                height: 32,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: EventGroupSchedulePickerButton(
                label: _formatDate(endDate) ?? context.l10n.tarihSein,
                icon: Icons.event_available_rounded,
                onPressed: onPickEndDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: EventGroupSchedulePickerButton(
                label: _formatTime(endTime) ?? context.l10n.eventPickTime,
                icon: Icons.more_time_rounded,
                onPressed: onPickEndTime,
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  static String? _formatDate(DateTime? value) {
    if (value == null) return null;
    return '${value.day.toString().padLeft(2, '0')}.'
        '${value.month.toString().padLeft(2, '0')}.${value.year}';
  }

  static String? _formatTime(TimeOfDay? value) {
    if (value == null) return null;
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }
}

class EventGroupSchedulePickerButton extends StatelessWidget {
  const EventGroupSchedulePickerButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
