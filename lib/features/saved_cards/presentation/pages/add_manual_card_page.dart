import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../data/datasources/physical_card_image_store.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/manual_saved_card_draft.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../cubit/add_manual_card_cubit.dart';
import '../cubit/add_manual_card_state.dart';

/// Elle girilen bilgilerle başkasının kartını cüzdana ekleme.
class AddManualCardPage extends StatefulWidget {
  const AddManualCardPage({
    super.key,
    required this.addSavedCard,
    this.initialDraft,
  });

  final AddSavedCard addSavedCard;
  final ManualSavedCardDraft? initialDraft;

  @override
  State<AddManualCardPage> createState() => _AddManualCardPageState();
}

class _AddManualCardPageState extends State<AddManualCardPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyController;
  late final TextEditingController _titleController;
  late final TextEditingController _websiteController;
  late final TextEditingController _linkedInController;
  late final TextEditingController _aboutController;
  String? _phoneFullNumber;
  late final String _initialCountryCode;
  late final String _initialPhoneNational;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDraft;
    _nameController = TextEditingController(text: d?.displayName ?? '');
    _emailController = TextEditingController(text: d?.email ?? '');
    _companyController = TextEditingController(text: d?.company ?? '');
    _titleController = TextEditingController(text: d?.title ?? '');
    _websiteController = TextEditingController(text: d?.website ?? '');
    _linkedInController = TextEditingController(text: d?.linkedin ?? '');
    _aboutController = TextEditingController(text: d?.about ?? '');
    _phoneFullNumber = d?.phone;
    _initialCountryCode = _countryCodeFromPhone(d?.phone);
    _initialPhoneNational = _nationalFromPhone(d?.phone);
  }

  static String _countryCodeFromPhone(String? full) {
    if (full == null || full.isEmpty) return 'TR';
    final digits = full.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90')) return 'TR';
    if (digits.startsWith('1')) return 'US';
    if (digits.startsWith('44')) return 'GB';
    if (digits.startsWith('49')) return 'DE';
    if (digits.startsWith('33')) return 'FR';
    return 'TR';
  }

  static String _nationalFromPhone(String? full) {
    if (full == null || full.isEmpty) return '';
    final digits = full.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90') && digits.length > 2) {
      return digits.substring(2);
    }
    if (digits.startsWith('1') && digits.length > 1) {
      return digits.substring(1);
    }
    if (digits.startsWith('44') && digits.length > 2) {
      return digits.substring(2);
    }
    if (digits.startsWith('49') && digits.length > 2) {
      return digits.substring(2);
    }
    if (digits.startsWith('33') && digits.length > 2) {
      return digits.substring(2);
    }
    return digits;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _titleController.dispose();
    _websiteController.dispose();
    _linkedInController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  ManualSavedCardDraft _buildDraft(AddManualCardState state) {
    final base = widget.initialDraft ?? state.draft;
    return ManualSavedCardDraft(
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneFullNumber?.trim(),
      company: _companyController.text.trim(),
      title: _titleController.text.trim(),
      website: _websiteController.text.trim(),
      linkedin: _linkedInController.text.trim(),
      about: _aboutController.text.trim(),
      frontImagePath: base.frontImagePath,
      backImagePath: base.backImagePath,
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AddManualCardCubit>();
    cubit.updateDraft(_buildDraft(cubit.state));
    final result = await cubit.submit();
    if (!context.mounted || result == null) return;

    switch (result) {
      case AddSavedCardSuccess():
        Navigator.of(context).pop(result);
      case AddSavedCardDuplicate():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu kart zaten cüzdanınızda.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case AddSavedCardLimitReached():
        Navigator.of(context).pop(result);
      case AddSavedCardInvalidPayload(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasPhotos = widget.initialDraft?.frontImagePath != null;

    return BlocProvider(
      create: (_) => AddManualCardCubit(
        addSavedCard: widget.addSavedCard,
        imageStore: PhysicalCardImageStore(),
        initialDraft: widget.initialDraft,
      ),
      child: BlocListener<AddManualCardCubit, AddManualCardState>(
        listenWhen: (a, b) => a.errorMessage != b.errorMessage,
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(message), behavior: SnackBarBehavior.floating),
          );
        },
        child: CardenceScaffold(
          appBar: const CardenceAppBar(title: 'Manuel kart ekle'),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Text(
                  hasPhotos
                      ? 'Fotoğraftan okunan bilgileri kontrol edin, gerekirse düzenleyin.'
                      : 'Karşınızdaki kişinin kartvizit bilgilerini girin.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                if (hasPhotos) ...[
                  const SizedBox(height: 16),
                  _PhotoPreviewRow(
                    frontPath: widget.initialDraft!.frontImagePath!,
                    backPath: widget.initialDraft!.backImagePath,
                  ),
                ],
                const SizedBox(height: 20),
                _buildField('Ad Soyad', _nameController, required: true),
                _buildField(
                  'E-posta',
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: IntlPhoneField(
                    initialCountryCode: _initialCountryCode,
                    initialValue: _initialPhoneNational,
                    keyboardType: TextInputType.phone,
                    disableLengthCheck: true,
                    decoration: InputDecoration(
                      labelText: 'Telefon',
                      counterText: '',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (phone) {
                      _phoneFullNumber =
                          phone.number.isEmpty ? null : phone.completeNumber;
                    },
                  ),
                ),
                _buildField('Şirket', _companyController),
                _buildField('Ünvan', _titleController),
                _buildField(
                  'Web sitesi',
                  _websiteController,
                  keyboardType: TextInputType.url,
                ),
                _buildField(
                  'LinkedIn',
                  _linkedInController,
                  keyboardType: TextInputType.url,
                ),
                _buildField(
                  'Not',
                  _aboutController,
                  minLines: 3,
                  maxLines: 6,
                ),
                const SizedBox(height: 8),
                BlocBuilder<AddManualCardCubit, AddManualCardState>(
                  builder: (context, state) {
                    return CustomButton(
                      label: 'Cüzdana ekle',
                      onPressed: () => _submit(context),
                      isLoading: state.isSubmitting,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        validator: required
            ? (value) {
                if ((value ?? '').trim().isEmpty) {
                  return '$label zorunludur';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _PhotoPreviewRow extends StatelessWidget {
  const _PhotoPreviewRow({
    required this.frontPath,
    this.backPath,
  });

  final String frontPath;
  final String? backPath;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _PhotoThumb(label: 'Ön yüz', path: frontPath)),
        const SizedBox(width: 12),
        Expanded(
          child: backPath != null
              ? _PhotoThumb(label: 'Arka yüz', path: backPath!)
              : _PhotoPlaceholder(label: 'Arka yüz yok'),
        ),
      ],
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.label, required this.path});

  final String label;
  final String path;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1.6,
            child: Image.file(File(path), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 1.6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image_not_supported_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
