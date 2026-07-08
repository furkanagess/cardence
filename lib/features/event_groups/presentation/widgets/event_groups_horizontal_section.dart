import 'package:flutter/material.dart';

import '../../domain/entities/event_group.dart';
import 'event_group_list_card.dart';

/// Başlıklı dikey etkinlik grubu listesi.
class EventGroupsSection extends StatelessWidget {
  const EventGroupsSection({
    super.key,
    required this.title,
    required this.groups,
    required this.linkedCardCountFor,
    required this.onGroupTap,
    this.uppercaseTitle = false,
  });

  final String title;
  final List<EventGroup> groups;
  final int Function(EventGroup group) linkedCardCountFor;
  final ValueChanged<EventGroup> onGroupTap;
  final bool uppercaseTitle;

  static const double cardSpacing = 10;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            uppercaseTitle ? title.toUpperCase() : title,
            style: (uppercaseTitle
                    ? textTheme.labelLarge
                    : textTheme.titleSmall)
                ?.copyWith(
              color: uppercaseTitle
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface,
              fontWeight: uppercaseTitle ? FontWeight.w700 : FontWeight.w800,
              letterSpacing: uppercaseTitle ? 0.8 : -0.2,
            ),
          ),
        ),
        for (var index = 0; index < groups.length; index++) ...[
          if (index > 0) const SizedBox(height: cardSpacing),
          EventGroupListCard(
            group: groups[index],
            linkedCardCount: linkedCardCountFor(groups[index]),
            onTap: () => onGroupTap(groups[index]),
          ),
        ],
      ],
    );
  }
}