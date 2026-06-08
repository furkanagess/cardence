import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/custom_button.dart';
import '../../domain/entities/event_group.dart';

/// Bir kayıtlı kartın eklenebileceği etkinlik gruplarını seçtirir.
class PickEventGroupsForCardSheet extends StatefulWidget {
  const PickEventGroupsForCardSheet({
    super.key,
    required this.groups,
    required this.cardTitle,
  });

  final List<EventGroup> groups;
  final String cardTitle;

  static Future<Set<String>?> show(
    BuildContext context, {
    required List<EventGroup> groups,
    required String cardTitle,
  }) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => PickEventGroupsForCardSheet(
        groups: groups,
        cardTitle: cardTitle,
      ),
    );
  }

  @override
  State<PickEventGroupsForCardSheet> createState() =>
      _PickEventGroupsForCardSheetState();
}

class _PickEventGroupsForCardSheetState extends State<PickEventGroupsForCardSheet> {
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = {};
  }

  void _toggleSelection(String groupId) {
    setState(() {
      if (_selectedIds.contains(groupId)) {
        _selectedIds.remove(groupId);
      } else {
        _selectedIds.add(groupId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.75;

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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Etkinlik grubu seç',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.cardTitle} kartının eklenebileceği grupları işaretleyin.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.groups.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Text(
                        'Henüz etkinlik grubu yok. Etkinlik grupları sekmesinden yeni grup oluşturabilirsiniz.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: widget.groups.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final group = widget.groups[index];
                        final selected = _selectedIds.contains(group.id);
                        return CheckboxListTile(
                          value: selected,
                          onChanged: (value) {
                            if (value == null) return;
                            _toggleSelection(group.id);
                          },
                          title: Text(group.name),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: CustomButton(
                label: _selectedIds.isEmpty
                    ? 'Gruplara ekle'
                    : '${_selectedIds.length} gruba ekle',
                onPressed: widget.groups.isEmpty || _selectedIds.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(_selectedIds),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
