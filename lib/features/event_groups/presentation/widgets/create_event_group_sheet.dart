import 'package:flutter/material.dart';

import '../../../../core/widgets/molecules/new_event_group_name_dialog.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/presentation/saved_cards_catalog.dart';
import '../../../saved_cards/presentation/widgets/saved_card_selectable_list.dart';

/// Yeni etkinlik grubu oluşturma akışının sonucu.
class CreateEventGroupResult {
  const CreateEventGroupResult({
    required this.name,
    required this.selectedCardIds,
  });

  final String name;
  final Set<String> selectedCardIds;
}

/// 1. adım: grup adı · 2. adım: Kaydedilen Kartlar listesi görünümünde seçim.
class CreateEventGroupSheet extends StatefulWidget {
  const CreateEventGroupSheet({
    super.key,
    required this.existingNames,
    required this.getSavedCards,
  });

  final List<String> existingNames;
  final GetSavedCards getSavedCards;

  static Future<CreateEventGroupResult?> show(
    BuildContext context, {
    required List<String> existingNames,
    required GetSavedCards getSavedCards,
  }) {
    return showModalBottomSheet<CreateEventGroupResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => CreateEventGroupSheet(
        existingNames: existingNames,
        getSavedCards: getSavedCards,
      ),
    );
  }

  @override
  State<CreateEventGroupSheet> createState() => _CreateEventGroupSheetState();
}

class _CreateEventGroupSheetState extends State<CreateEventGroupSheet> {
  static const _stepName = 0;
  static const _stepPickCards = 1;

  int _step = _stepName;
  late final TextEditingController _nameController;
  String? _nameErrorText;
  late final Set<String> _selectedCardIds;
  List<SavedCard> _pickableCards = [];
  bool _loadingCards = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(_clearNameErrorOnEdit);
    _selectedCardIds = {};
  }

  void _clearNameErrorOnEdit() {
    if (_nameErrorText == null) return;
    setState(() => _nameErrorText = null);
  }

  @override
  void dispose() {
    _nameController.removeListener(_clearNameErrorOnEdit);
    _nameController.dispose();
    super.dispose();
  }

  String get _groupName => _nameController.text.trim();

  Future<void> _goToPickCards() async {
    final name = _groupName;
    if (name.isEmpty) {
      setState(() => _nameErrorText = 'Etkinlik adı boş olamaz');
      return;
    }
    if (NewEventGroupNameDialog.isDuplicateName(name, widget.existingNames)) {
      setState(() => _nameErrorText = 'Bu isimde bir etkinlik grubu zaten var');
      return;
    }

    setState(() {
      _step = _stepPickCards;
      _loadingCards = true;
    });

    final persisted = await widget.getSavedCards();
    if (!mounted) return;
    setState(() {
      _pickableCards = SavedCardsCatalog.displayCards(persisted);
      _loadingCards = false;
    });
  }

  void _goBackToName() {
    setState(() => _step = _stepName);
  }

  void _submit() {
    Navigator.of(context).pop(
      CreateEventGroupResult(
        name: _groupName,
        selectedCardIds: Set<String>.from(_selectedCardIds),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _step == _stepName
                        ? 'Yeni etkinlik grubu'
                        : 'Kaydedilen kartlardan seç',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adım ${_step + 1}/2',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (_step == _stepName) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Etkinlik adı',
                    hintText: 'Örn. Web Summit 2026',
                    errorText: _nameErrorText,
                  ),
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _goToPickCards(),
                ),
              ),
              const Spacer(),
            ] else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  '"$_groupName" grubuna eklenecek kayıtlı kartları seçin.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: _loadingCards
                    ? const Center(child: CircularProgressIndicator())
                    : SavedCardSelectableList(
                        cards: _pickableCards,
                        selectedIds: _selectedCardIds,
                        onToggle: _toggleCard,
                      ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  if (_step == _stepPickCards)
                    TextButton(
                      onPressed: _loadingCards ? null : _goBackToName,
                      child: const Text('Geri'),
                    ),
                  if (_step == _stepPickCards) const SizedBox(width: 8),
                  Expanded(
                    child: _step == _stepName
                        ? FilledButton(
                            onPressed: _goToPickCards,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('İleri'),
                          )
                        : FilledButton(
                            onPressed: _loadingCards ? null : _submit,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: Text(
                              _selectedCardIds.isEmpty
                                  ? 'Grubu oluştur'
                                  : '${_selectedCardIds.length} kartla oluştur',
                            ),
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
