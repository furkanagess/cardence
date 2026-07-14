import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
import '../../../../core/widgets/molecules/card_appearance_customize_section.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../../core/widgets/molecules/birthday_picker_field.dart';
import '../../../../core/widgets/molecules/comma_separated_chip_input.dart';
import '../../../../core/widgets/molecules/country_city_picker_field.dart';
import '../../../../core/widgets/molecules/skills_chip_input.dart';
import '../widgets/collapsible_card_preview_panel.dart';
import '../widgets/my_card_preview_helpers.dart';
import '../helpers/card_effect_premium_helper.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../onboarding/presentation/pages/card_created_share_page.dart';
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
  late TextEditingController _addressController;
  late TextEditingController _departmentController;
  late TextEditingController _twitterController;
  late TextEditingController _instagramController;
  String? _skillsValue;
  String? _countryValue;
  String? _cityValue;
  String? _attendedEventsValue;
  String? _birthdayValue;
  String? _phoneFullNumber;
  bool _saving = false;

  Map<String, String> _labels(BuildContext context) =>
      MyCardPreviewHelpers.fieldLabels(context.l10n);

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
    _addressController = TextEditingController(text: d.address ?? '');
    _departmentController = TextEditingController(text: d.department ?? '');
    _twitterController = TextEditingController(text: d.twitter ?? '');
    _instagramController = TextEditingController(text: d.instagram ?? '');
    _skillsValue = d.skills;
    _countryValue = d.country;
    _cityValue = d.city;
    _attendedEventsValue = d.attendedEvents;
    _birthdayValue = d.birthday;
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
    _addressController.dispose();
    _departmentController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
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
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      city: (_cityValue ?? '').trim().isEmpty ? null : _cityValue!.trim(),
      country:
          (_countryValue ?? '').trim().isEmpty ? null : _countryValue!.trim(),
      department: _departmentController.text.trim().isEmpty
          ? null
          : _departmentController.text.trim(),
      attendedEvents: (_attendedEventsValue ?? '').trim().isEmpty
          ? null
          : _attendedEventsValue!.trim(),
      twitter: _twitterController.text.trim().isEmpty
          ? null
          : _twitterController.text.trim(),
      instagram: _instagramController.text.trim().isEmpty
          ? null
          : _instagramController.text.trim(),
      birthday:
          (_birthdayValue ?? '').trim().isEmpty ? null : _birthdayValue!.trim(),
    );
  }

  Future<void> _save({bool popAfter = true}) async {
    if (_saving) return;
    if (_cardNameController.text.trim().isEmpty) {
            return;
    }
    setState(() => _saving = true);
    final originalDraft = _buildDraft();
    var draft = originalDraft;
    try {
      final resolved = await prepareCardDraftForPersist(context, draft);
      if (!mounted) return;
      if (resolved == null) {
        setState(() => _saving = false);
        return;
      }
      draft = resolved;
      if (resolved.cardEffect != originalDraft.cardEffect) {
        setState(() => _baselineDraft = resolved);
      }
      final updated = await widget.persistOnboardingCard(draft);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _baselineDraft = updated;
      });
      widget.onDraftUpdated?.call(updated);
      if (popAfter) {
        if (widget.isNewCard) {
          await CardCreatedSharePage.open(context, draft: updated);
          if (!mounted) return;
        }
        Navigator.of(context).pop(updated);
      }
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
          } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
          }
  }

  Future<bool> _confirmDiscardChanges() {
    return CardenceConfirmDialog.show(
      context,
      title: context.l10n.kaydedilmemiDeiiklikler,
      message:
          context.l10n.yaptnzDeiikliklerKaydedilmedikmakIstediinize,
      confirmLabel: context.l10n.k,
      cancelLabel: context.l10n.iptal,
      icon: Icons.warning_amber_rounded,
      confirmIsDestructive: true,
    ).then((value) => value == true);
  }

  void _showColorCustomizeBottomSheet() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            final draft = _buildDraft();
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.88,
              minChildSize: 0.45,
              maxChildSize: 0.92,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    16 + MediaQuery.paddingOf(sheetContext).bottom,
                  ),
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
                      context.l10n.kartRenkleri,
                      style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.changesReflectInPreview,
                      style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 16),
                    CardAppearanceCustomizeSection(
                      backgroundColor: draft.backgroundColor,
                      accentColor: draft.accentColor,
                      cardEffect: draft.cardEffect,
                      compact: true,
                      lastUsedPaletteBackgroundColor:
                          draft.lastUsedPaletteBackgroundColor,
                      previewBuilder: (bg, accent, effect) => AspectRatio(
                        aspectRatio: FlippablePersonCard.cardAspectRatio,
                        child: MyCardPreviewHelpers.flippableCardWithColors(
                          draft: draft,
                          l10n: context.l10n,
                          backgroundColor: bg,
                          accentColor: accent,
                          cardEffect: effect,
                        ),
                      ),
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
                      onEffectChanged: (effect) {
                        setState(() {
                          _baselineDraft =
                              _baselineDraft.copyWith(cardEffect: effect);
                        });
                        sheetSetState(() {});
                      },
                      onLastUsedPaletteBackgroundChanged: (hex) {
                        setState(() {
                          _baselineDraft = _baselineDraft.copyWith(
                            backgroundColor: hex,
                            lastUsedPaletteBackgroundColor: hex,
                          );
                        });
                        sheetSetState(() {});
                      },
                      showSaveButton: true,
                      onSave: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                );
              },
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
        title: widget.isNewCard ? context.l10n.newCard : context.l10n.editCard,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CollapsibleCardPreviewPanel(
              draft: previewDraft,
              emptyMessage: context.l10n.bilgiGirildikeKarttaGrnr,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _buildFormSection(
                    title: context.l10n.kartAd,
                    subtitle:
                        context.l10n.sadeceSizinGrdnzEtiketKart,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    children: [
                      TextFormField(
                        controller: _cardNameController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: context.l10n.rnKartmKonferans2025,
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
                    title: context.l10n.kartBilgileri,
                    subtitle:
                        context.l10n.kartYzndeGrnecekIletiimVe,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    children: [
                      _buildField(
                        (_labels(context))['displayName']!,
                        _nameController,
                        colorScheme,
                      ),
                      _buildField(
                        (_labels(context))['email']!,
                        _emailController,
                        colorScheme,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildPhoneField(colorScheme),
                      _buildField(
                        (_labels(context))['company']!,
                        _companyController,
                        colorScheme,
                      ),
                      _buildField(
                        (_labels(context))['title']!,
                        _titleController,
                        colorScheme,
                      ),
                      _buildField(
                        (_labels(context))['website']!,
                        _websiteController,
                        colorScheme,
                        keyboardType: TextInputType.url,
                      ),
                      _buildField(
                        (_labels(context))['linkedin']!,
                        _linkedInController,
                        colorScheme,
                        keyboardType: TextInputType.url,
                      ),
                      SkillsChipInput(
                        label: (_labels(context))['skills']!,
                        value: _skillsValue,
                        onChanged: (s) => setState(() => _skillsValue = s),
                      ),
                      _buildField(
                        (_labels(context))['school']!,
                        _schoolController,
                        colorScheme,
                      ),
                      _buildField(
                        (_labels(context))['about']!,
                        _aboutController,
                        colorScheme,
                        maxLength: 200,
                        minLines: 3,
                        maxLines: 6,
                      ),
                    ],
                  ),
                  _buildFormSection(
                    title: context.l10n.ekBilgiler,
                    subtitle:
                        context.l10n.adresSosyalMedyaVeEtkinlik,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    children: [
                      _buildField(
                        (_labels(context))['address']!,
                        _addressController,
                        colorScheme,
                        minLines: 2,
                        maxLines: 4,
                      ),
                      CountryCityPickerField(
                        countryLabel: (_labels(context))['country']!,
                        stateLabel: context.l10n.provinceLabel,
                        districtLabel: context.l10n.districtLabel,
                        country: _countryValue,
                        city: _cityValue,
                        onCountryChanged: (value) =>
                            setState(() => _countryValue = value),
                        onCityChanged: (value) =>
                            setState(() => _cityValue = value),
                      ),
                      _buildField(
                        (_labels(context))['department']!,
                        _departmentController,
                        colorScheme,
                      ),
                      CommaSeparatedChipInput(
                        label: (_labels(context))['attendedEvents']!,
                        value: _attendedEventsValue,
                        hintText: context.l10n.etkinlikEklernWebSummit,
                        prefixIcon: Icons.event_outlined,
                        chipIcon: Icons.event_outlined,
                        canAddItem: (text) => text.trim().length >= 2,
                        onChanged: (value) =>
                            setState(() => _attendedEventsValue = value),
                      ),
                      _buildField(
                        (_labels(context))['twitter']!,
                        _twitterController,
                        colorScheme,
                        keyboardType: TextInputType.url,
                      ),
                      _buildField(
                        (_labels(context))['instagram']!,
                        _instagramController,
                        colorScheme,
                        keyboardType: TextInputType.url,
                      ),
                      BirthdayPickerField(
                        label: (_labels(context))['birthday']!,
                        value: _birthdayValue,
                        onChanged: (value) =>
                            setState(() => _birthdayValue = value),
                      ),
                    ],
                  ),
                  _buildFormSection(
                    title: context.l10n.tasarm,
                    subtitle: context.l10n.kartVeMetinRenginiDzenleyin,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    children: [
                      CustomButton(
                        label: context.l10n.renkleriDzenle,
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
                    label: context.l10n.kaydet,
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
    String? hintText,
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
          hintText: hintText,
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
          labelText: (_labels(context))['phone'],
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
