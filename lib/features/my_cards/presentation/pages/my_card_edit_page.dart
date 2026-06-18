import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
import '../../../../core/widgets/molecules/card_color_customize_section.dart';
import '../../../../core/widgets/molecules/skills_chip_input.dart';
import '../widgets/collapsible_card_preview_panel.dart';
import '../widgets/my_card_preview_helpers.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';

/// Tek bir kartin adini ve bilgilerini duzenleme ekrani.
class MyCardEditPage extends StatefulWidget {
  const MyCardEditPage({
    super.key,
    required this.initialDraft,
    required this.persistOnboardingCard,
    this.isNewCard = false,
    this.onDraftUpdated,
  });

  final OnboardingCardDraft initialDraft;
  final PersistOnboardingCard persistOnboardingCard;
  final bool isNewCard;
  final ValueChanged<OnboardingCardDraft>? onDraftUpdated;

  @override
  State<MyCardEditPage> createState() => _MyCardEditPageState();
}

class _MyCardEditPageState extends State<MyCardEditPage> {
  final _formKey = GlobalKey<FormState>();
  late OnboardingCardDraft _baselineDraft;
  late String _cardId;
  late TextEditingController _cardNameController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;
  late TextEditingController _titleController;
  late TextEditingController _websiteController;
  late TextEditingController _linkedInController;
  late TextEditingController _schoolController;
  late TextEditingController _aboutController;
  String? _skillsValue;
  String? _phoneFullNumber;
  bool _saving = false;

  static Map<String, String> get _labels => MyCardPreviewHelpers.fieldLabels;

  bool get _hasUnsavedChanges => !_buildDraft().contentEquals(_baselineDraft);

  @override
  void initState() {
    super.initState();
    final d = widget.initialDraft;
    _baselineDraft = d;
    _cardId = CardIdGenerator.isValid(d.cardId) ? d.cardId!.trim() : CardIdGenerator.generateBusinessCandidate();
    _cardNameController =
        TextEditingController(text: d.cardName ?? d.listTitle);
    _nameController = TextEditingController(text: d.displayName ?? '');
    _emailController = TextEditingController(text: d.email ?? '');
    _companyController = TextEditingController(text: d.company ?? '');
    _titleController = TextEditingController(text: d.title ?? '');
    _websiteController = TextEditingController(text: d.website ?? '');
    _linkedInController = TextEditingController(text: d.linkedin ?? '');
    _schoolController = TextEditingController(text: d.school ?? '');
    _aboutController = TextEditingController(text: d.about ?? '');
    _skillsValue = d.skills;
    _phoneFullNumber = d.phone;
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _titleController.dispose();
    _websiteController.dispose();
    _linkedInController.dispose();
    _schoolController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  OnboardingCardDraft _buildDraft() {
    final base = _baselineDraft;
    return base.copyWith(
      cardId: _cardId,
      cardName: _cardNameController.text.trim().isEmpty
          ? null
          : _cardNameController.text.trim(),
      displayName: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: (_phoneFullNumber ?? '').trim().isEmpty
          ? null
          : _phoneFullNumber!.trim(),
      company: _companyController.text.trim().isEmpty
          ? null
          : _companyController.text.trim(),
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      linkedin: _linkedInController.text.trim().isEmpty
          ? null
          : _linkedInController.text.trim(),
      skills: (_skillsValue ?? '').trim().isEmpty ? null : _skillsValue!.trim(),
      school: _schoolController.text.trim().isEmpty
          ? null
          : _schoolController.text.trim(),
      about: _aboutController.text.trim().isEmpty
          ? null
          : _aboutController.text.trim(),
    );
  }

  Future<void> _save({bool popAfter = true}) async {
    if (_saving) return;
    if (_cardNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kart adı zorunludur'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final draft = _buildDraft();
    try {
      final updated = await widget.persistOnboardingCard(draft);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _baselineDraft = updated;
      });
      widget.onDraftUpdated?.call(updated);
      if (popAfter) {
        Navigator.of(context).pop(updated);
      }
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kart kaydedilemedi. Lütfen tekrar deneyin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _confirmDiscardChanges() {
    return CardenceConfirmDialog.show(
      context,
      title: 'Kaydedilmemiş değişiklikler',
      message:
          'Yaptığınız değişiklikler kaydedilmedi. Çıkmak istediğinize emin misiniz?',
      confirmLabel: 'Çık',
      cancelLabel: 'İptal',
      icon: Icons.warning_amber_rounded,
      confirmIsDestructive: true,
    ).then((value) => value == true);
  }

  void _showColorCustomizeBottomSheet() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            final draft = _buildDraft();
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20 + MediaQuery.paddingOf(sheetContext).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.outline.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Kart renkleri',
                    style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Değişiklikler önizlemeye anında yansır; kaydetmek için Kaydet\'e basın.',
                    style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 20),
                  CardColorCustomizeSection(
                    backgroundColor: draft.backgroundColor,
                    accentColor: draft.accentColor,
                    lastUsedPaletteBackgroundColor:
                        draft.lastUsedPaletteBackgroundColor,
                    onBackgroundColorChanged: (hex) {
                      setState(() {
                        _baselineDraft = hex == null
                            ? _baselineDraft.copyWith(clearBackgroundColor: true)
                            : _baselineDraft.copyWith(backgroundColor: hex);
                      });
                      sheetSetState(() {});
                    },
                    onAccentColorChanged: (hex) {
                      setState(() {
                        _baselineDraft = hex == null
                            ? _baselineDraft.copyWith(clearAccentColor: true)
                            : _baselineDraft.copyWith(accentColor: hex);
                      });
                      sheetSetState(() {});
                    },
                    onLastUsedPaletteBackgroundChanged: (hex) {
                      setState(() {
                        _baselineDraft = _baselineDraft.copyWith(
                          lastUsedPaletteBackgroundColor: hex,
                        );
                      });
                      sheetSetState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String _countryCodeFromFullPhone(String? full) {
    if (full == null || full.isEmpty) return 'TR';
    final digits = full.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90') && digits.length >= 12) return 'TR';
    if (digits.startsWith('1') && digits.length >= 11) return 'US';
    if (digits.startsWith('44')) return 'GB';
    if (digits.startsWith('49')) return 'DE';
    if (digits.startsWith('33')) return 'FR';
    return 'TR';
  }

  static String _nationalNumberFromFullPhone(String? full) {
    if (full == null || full.isEmpty) return '';
    final digits = full.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90') && digits.length > 2) {
      return digits.substring(2);
    }
    if (digits.startsWith('1') && digits.length > 1) return digits.substring(1);
    if (digits.startsWith('44') && digits.length > 2)
      return digits.substring(2);
    if (digits.startsWith('49') && digits.length > 2)
      return digits.substring(2);
    if (digits.startsWith('33') && digits.length > 2)
      return digits.substring(2);
    return digits;
  }

  Widget _buildFormSection({
    required String title,
    required String? subtitle,
    required List<Widget> children,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final previewDraft = _buildDraft();

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_hasUnsavedChanges) return;
        final shouldLeave = await _confirmDiscardChanges();
        if (!mounted || !shouldLeave) return;
        Navigator.of(context).pop();
      },
      child: CardenceScaffold(
      appBar: CardenceAppBar(
        variant: CardenceAppBarVariant.editor,
        title: widget.isNewCard ? 'Yeni kart' : 'Kartı düzenle',
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CollapsibleCardPreviewPanel(
              draft: previewDraft,
              emptyMessage: 'Bilgi girildikçe kartta görünür',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _buildFormSection(
                    title: 'Kart adı',
                    subtitle:
                        'Sadece sizin gördüğünüz etiket; kart yüzündeki isim “Ad Soyad” alanıdır.',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    children: [
                      TextFormField(
                        controller: _cardNameController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Örn. İş kartım, Konferans 2025',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                  _buildFormSection(
                    title: 'Kart bilgileri',
                    subtitle:
                        'Kart yüzünde görünecek iletişim ve profil alanları.',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    children: [
                      _buildField(
                        _labels['displayName']!,
                        _nameController,
                        colorScheme,
                      ),
                      _buildField(
                        _labels['email']!,
                        _emailController,
                        colorScheme,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildPhoneField(colorScheme),
                      _buildField(
                        _labels['company']!,
                        _companyController,
                        colorScheme,
                      ),
                      _buildField(
                        _labels['title']!,
                        _titleController,
                        colorScheme,
                      ),
                      _buildField(
                        _labels['website']!,
                        _websiteController,
                        colorScheme,
                        keyboardType: TextInputType.url,
                      ),
                      _buildField(
                        _labels['linkedin']!,
                        _linkedInController,
                        colorScheme,
                        keyboardType: TextInputType.url,
                      ),
                      SkillsChipInput(
                        label: _labels['skills']!,
                        value: _skillsValue,
                        onChanged: (s) => setState(() => _skillsValue = s),
                      ),
                      _buildField(
                        _labels['school']!,
                        _schoolController,
                        colorScheme,
                      ),
                      _buildField(
                        _labels['about']!,
                        _aboutController,
                        colorScheme,
                        maxLength: 200,
                        minLines: 3,
                        maxLines: 6,
                      ),
                    ],
                  ),
                  _buildFormSection(
                    title: 'Tasarım',
                    subtitle: 'Kart ve metin rengini düzenleyin.',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    children: [
                      CustomButton(
                        label: 'Renkleri düzenle',
                        icon: Icons.palette_outlined,
                        onPressed: _showColorCustomizeBottomSheet,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                  CustomButton(
                    label: 'Kaydet',
                    onPressed: _save,
                    isLoading: _saving,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    ColorScheme colorScheme, {
    TextInputType? keyboardType,
    int? maxLength,
    int? minLines,
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          counterText: '',
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildPhoneField(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: IntlPhoneField(
        key: ValueKey<String?>(_phoneFullNumber),
        initialCountryCode: _countryCodeFromFullPhone(_phoneFullNumber),
        initialValue: _nationalNumberFromFullPhone(_phoneFullNumber),
        showCountryFlag: true,
        disableLengthCheck: true,
        decoration: InputDecoration(
          labelText: _labels['phone'],
          counterText: '',
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (phone) =>
            setState(() => _phoneFullNumber = phone.completeNumber),
      ),
    );
  }
}
