import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/custom_button.dart';

class SavedCardsNoteEditorSheet {
  SavedCardsNoteEditorSheet._();

  static Future<String?> show(
    BuildContext context, {
    required String initialNote,
  }) {
    var draftNote = initialNote;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Kisi notu',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: draftNote,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 240,
                      onChanged: (value) =>
                          setModalState(() => draftNote = value),
                      decoration: const InputDecoration(
                        hintText: 'Bu kisi hakkinda not yazin',
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      label: 'Kaydet',
                      onPressed: () =>
                          Navigator.of(context).pop(draftNote.trim()),
                      fullWidth: false,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
