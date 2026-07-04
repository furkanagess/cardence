import 'package:flutter/material.dart';

import '../../domain/entities/event_group.dart';
import 'event_group_list_card.dart';

/// Başlıklı yatay etkinlik grubu listesi.
class EventGroupsHorizontalSection extends StatelessWidget {
  const EventGroupsHorizontalSection({
    super.key,
    required this.title,
    required this.groups,
    required this.linkedCardCountFor,
    required this.onGroupTap,
  });

  final String title;
  final List<EventGroup> groups;
  final int Function(EventGroup group) linkedCardCountFor;
  final ValueChanged<EventGroup> onGroupTap;

  static const double cardWidth = 280;
  static const double cardSpacing = 12;

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
            title,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < groups.length; index++) ...[
                if (index > 0) const SizedBox(width: cardSpacing),
                SizedBox(
                  width: cardWidth,
                  child: EventGroupListCard(
                    group: groups[index],
                    linkedCardCount: linkedCardCountFor(groups[index]),
                    onTap: () => onGroupTap(groups[index]),
                    compact: true,
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
