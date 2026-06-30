import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/helpers/saved_card_field_catalog.dart';
import '../helpers/saved_card_field_l10n.dart';

/// Kayıtlı kart detayında alan seçme ve düzenleme bottom sheet'i.
class SavedCardAddFieldSheet {
  SavedCardAddFieldSheet._();

  /// Eklenebilir alanları listeler; seçilen alan için düzenleme sheet'i açar.
  static Future<SavedCardFieldKey?> pickFieldToAdd(
    BuildContext context, {
    required SavedCard card,
  }) {
    final options = SavedCardFieldCatalog.addableFields(card);
    if (options.isEmpty) return Future.value(null);

    return showModalBottomSheet<SavedCardFieldKey>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.bilgiEkle,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.kartaEklemekIstediinizAlanSein,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final def = options[index];
                      return ListTile(
                        leading: Icon(
                          SavedCardFieldIcons.iconFor(def.iconName),
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          SavedCardFieldL10n.label(context.l10n, def.key),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          SavedCardFieldL10n.hint(context.l10n, def.key),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(def.key),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Seçilen alanın değerini düzenler; kaydedilen metni döner (null = iptal).
  static Future<String?> editFieldValue(
    BuildContext context, {
    required SavedCardFieldDefinition definition,
    String? initialValue,
  }) {
    var draft = initialValue ?? '';

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final maxLines = definition.multiline ? 6 : 1;

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      SavedCardFieldL10n.label(context.l10n, definition.key),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: draft,
                      minLines: definition.multiline ? 3 : 1,
                      maxLines: maxLines,
                      maxLength: definition.multiline ? 1000 : 320,
                      autofocus: true,
                      onChanged: (value) =>
                          setModalState(() => draft = value),
                      decoration: InputDecoration(
                        hintText: SavedCardFieldL10n.hint(
                          context.l10n,
                          definition.key,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: context.l10n.kaydet,
                      onPressed: () =>
                          Navigator.of(context).pop(draft.trim()),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (initialValue != null &&
                        initialValue.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      CustomButton.text(
                        label: context.l10n.alanKaldr,
                        onPressed: () => Navigator.of(context).pop(''),
                        fullWidth: true,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ],
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

/// Katalog [iconName] → Material ikon eşlemesi.
class SavedCardFieldIcons {
  SavedCardFieldIcons._();

  static IconData iconFor(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person_outline_rounded;
      case 'email':
        return Icons.mail_outline_rounded;
      case 'phone':
        return Icons.phone_outlined;
      case 'apartment':
        return Icons.apartment_rounded;
      case 'work':
        return Icons.work_outline_rounded;
      case 'language':
        return Icons.language_rounded;
      case 'link':
        return Icons.link_rounded;
      case 'location':
        return Icons.location_on_outlined;
      case 'location_city':
        return Icons.location_city_outlined;
      case 'public':
        return Icons.public_rounded;
      case 'groups':
        return Icons.groups_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'info':
        return Icons.info_outline_rounded;
      case 'star':
        return Icons.star_outline_rounded;
      case 'event':
        return Icons.event_outlined;
      case 'alternate_email':
        return Icons.alternate_email_rounded;
      case 'camera':
        return Icons.camera_alt_outlined;
      case 'cake':
        return Icons.cake_outlined;
      default:
        return Icons.article_outlined;
    }
  }
}
