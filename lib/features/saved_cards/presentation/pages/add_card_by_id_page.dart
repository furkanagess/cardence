import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../cubit/add_card_by_id_cubit.dart';
import '../cubit/add_card_by_id_state.dart';
import '../helpers/add_card_by_id_messages.dart';
import '../widgets/add_card_flow_status_views.dart';
import '../widgets/add_card_ui_helpers.dart';

/// Kart ID ile cüzdana kart ekleme.
class AddCardByIdPage extends StatelessWidget {
  const AddCardByIdPage({
    super.key,
    required this.addSavedCard,
  });

  final AddSavedCard addSavedCard;

  static const Duration _statusDisplayDuration = Duration(milliseconds: 2400);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddCardByIdCubit(addSavedCard: addSavedCard),
      child: const _AddCardByIdView(),
    );
  }
}

class _AddCardByIdView extends StatefulWidget {
  const _AddCardByIdView();

  @override
  State<_AddCardByIdView> createState() => _AddCardByIdViewState();
}

class _AddCardByIdViewState extends State<_AddCardByIdView> {
  final _formKey = GlobalKey<FormState>();
  final _cardIdController = TextEditingController();

  @override
  void dispose() {
    _cardIdController.dispose();
    super.dispose();
  }

  String? _validateCardId(String? value) {
    final id = value?.trim() ?? '';
    if (id.isEmpty) return context.l10n.kartIdGirin;
    if (!CardIdGenerator.isValid(id)) {
      return context.l10n.kartIdTam6Haneli;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AddCardByIdCubit>().submit(_cardIdController.text);
  }

  Future<void> _handleCompletedStatus(AddCardByIdState state) async {
    final result = state.result;
    if (result == null) return;

    await Future<void>.delayed(AddCardByIdPage._statusDisplayDuration);
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCardByIdCubit, AddCardByIdState>(
      listenWhen: (previous, current) =>
          current.isSuccess ||
          (current.isFailure && current.result != null),
      listener: (context, state) => _handleCompletedStatus(state),
      child: BlocBuilder<AddCardByIdCubit, AddCardByIdState>(
        builder: (context, state) {
          final l10n = context.l10n;
          final formError = addCardByIdFormError(l10n, state.result);
          final failureResult = state.result;
          final failureMessages = failureResult == null
              ? (
                  title: l10n.kartCzdanaEklenemedi,
                  message: l10n.invalidCardId,
                )
              : addCardByIdFailureMessages(l10n, failureResult);

          return PopScope(
            canPop: state.isForm,
            child: CardenceScaffold(
              appBar: CardenceAppBar(title: l10n.kartIdIleEkle),
              resizeToAvoidBottomInset: true,
              body: Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: switch (state.phase) {
                        AddCardByIdPhase.submitting => AddCardFlowSendingView(
                            message: l10n.addCardByIdSending,
                          ),
                        AddCardByIdPhase.success => AddCardFlowSuccessView(
                            title: l10n.kartCzdannzaEklendi,
                            message:
                                '${l10n.kartId2}: ${_cardIdController.text.trim()}',
                          ),
                        AddCardByIdPhase.failure => AddCardFlowFailureView(
                            title: failureMessages.title,
                            message: failureMessages.message,
                          ),
                        AddCardByIdPhase.form => _AddCardByIdForm(
                            key: const ValueKey('add-card-by-id-form'),
                            formKey: _formKey,
                            cardIdController: _cardIdController,
                            formError: formError,
                            validateCardId: _validateCardId,
                            onFieldChanged: () =>
                                context.read<AddCardByIdCubit>().clearFormError(),
                            onSubmit: _submit,
                          ),
                      },
                    ),
                  ),
                  if (state.isForm)
                    AddCardStickyAction(
                      label: l10n.kartEkle2,
                      icon: Icons.add_card_rounded,
                      onPressed: _submit,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AddCardByIdForm extends StatelessWidget {
  const _AddCardByIdForm({
    super.key,
    required this.formKey,
    required this.cardIdController,
    required this.formError,
    required this.validateCardId,
    required this.onFieldChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController cardIdController;
  final String? formError;
  final String? Function(String?) validateCardId;
  final VoidCallback onFieldChanged;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.badge_outlined,
                size: 36,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.paylalanKartKimliiniGirinBilgiler,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            context.l10n.kartId,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: cardIdController,
            validator: validateCardId,
            keyboardType: TextInputType.number,
            maxLength: CardIdGenerator.length,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(CardIdGenerator.length),
            ],
            decoration: CustomTextField.themedDecoration(
              context,
              hintText: '000000',
              errorText: formError,
              prefixIcon: const Icon(Icons.perm_identity_outlined),
              maxLength: CardIdGenerator.length,
            ),
            textInputAction: TextInputAction.done,
            autocorrect: false,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
            onChanged: (_) => onFieldChanged(),
            onFieldSubmitted: (_) async {
              final formState = formKey.currentState;
              if (formState == null || !formState.validate()) return;
              await onSubmit();
            },
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.sadeceSaysalKarakterlerKabulEdilir,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          AddCardTipCard.security(
            title: context.l10n.gvenliPaylam,
            text: AppL10n.cardenceDataSecurityMessage(context.l10n),
          ),
        ],
      ),
    );
  }
}
