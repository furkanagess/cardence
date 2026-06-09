import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
import '../../../../core/widgets/molecules/skills_chip_input.dart';
import '../widgets/collapsible_card_preview_panel.dart';
import '../widgets/my_card_preview_helpers.dart';
import 'card_detail_page.dart';
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
    _cardId = CardIdGenerator.isValid(d.cardId) ? d.cardId!.trim() : CardIdGenerator.generate();
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

  void _applyDraftFromSaved(OnboardingCardDraft draft) {
    setState(() {
      _baselineDraft = draft;
      _cardId = CardIdGenerator.isValid(draft.cardId)
          ? draft.cardId!.trim()
          : _cardId;
      _cardNameController.text = draft.cardName ?? draft.listTitle;
      _nameController.text = draft.displayName ?? '';
      _emailController.text = draft.email ?? '';
      _companyController.text = draft.company ?? '';
      _titleController.text = draft.title ?? '';
      _websiteController.text = draft.website ?? '';
      _linkedInController.text = draft.linkedin ?? '';
      _schoolController.text = draft.school ?? '';
      _aboutController.text = draft.about ?? '';
      _skillsValue = draft.skills;
      _phoneFullNumber = draft.phone;
    });
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

  void _openDesignAndShare(OnboardingCardDraft draft) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CardDetailPage(
          draft: draft,
          persistOnboardingCard: widget.persistOnboardingCard,
          onDraftUpdated: (updated) {
            widget.onDraftUpdated?.call(updated);
            if (!mounted) return;
            _applyDraftFromSaved(updated);
          },
        ),
      ),
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
        actions: [
          CardenceAppBar.textAction(
            label: 'Kaydet',
            onPressed: _save,
            loading: _saving,
          ),
        ],
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
                    title: 'Tasarım ve paylaşım',
                    subtitle: 'Renk, görünür alanlar ve QR paylaşımı.',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    children: [
                      CustomButton(
                        label: 'Tasarım ve paylaşım',
                        icon: Icons.palette_outlined,
                        onPressed: () => _openDesignAndShare(_buildDraft()),
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
        decoration: InputDecoration(
          labelText: _labels['phone'],
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
