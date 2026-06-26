import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';

import '../../../event_groups/domain/entities/event_group.dart';
import '../../domain/entities/graph_scope.dart';

class NetworkGraphScopeBar extends StatelessWidget {
  const NetworkGraphScopeBar({
    super.key,
    required this.scope,
    required this.eventGroups,
    this.selectedEventGroupId,
    this.onPersonalSelected,
    this.onEventSelected,
  });

  final GraphScope scope;
  final List<EventGroup> eventGroups;
  final String? selectedEventGroupId;
  final VoidCallback? onPersonalSelected;
  final ValueChanged<EventGroup>? onEventSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.viewScope,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(context.l10n.personalNetwork),
              selected: scope == GraphScope.personal,
              onSelected: scope == GraphScope.personal ? null : (_) => onPersonalSelected?.call(),
            ),
            if (eventGroups.isNotEmpty)
              ChoiceChip(
                label: Text(context.l10n.eventNetwork),
                selected: scope == GraphScope.event,
                onSelected: scope == GraphScope.event
                    ? null
                    : (_) {
                        final group = _resolveEventGroup();
                        if (group != null) onEventSelected?.call(group);
                      },
              ),
          ],
        ),
        if (scope == GraphScope.event && eventGroups.isNotEmpty) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey(selectedEventGroupId),
            initialValue: selectedEventGroupId ?? eventGroups.first.id,
            decoration: InputDecoration(
              labelText: context.l10n.etkinlikGrubu2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: eventGroups
                .map(
                  (group) => DropdownMenuItem<String>(
                    value: group.id,
                    child: Text(group.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (groupId) {
              if (groupId == null) return;
              final group = eventGroups.firstWhere((g) => g.id == groupId);
              onEventSelected?.call(group);
            },
          ),
        ],
        if (scope == GraphScope.event && eventGroups.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              context.l10n.createEventGroupFirstForNetwork,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
      ],
    );
  }

  EventGroup? _resolveEventGroup() {
    if (eventGroups.isEmpty) return null;
    if (selectedEventGroupId == null) return eventGroups.first;
    return eventGroups.firstWhere(
      (group) => group.id == selectedEventGroupId,
      orElse: () => eventGroups.first,
    );
  }
}
