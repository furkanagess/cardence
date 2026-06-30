import 'package:flutter/material.dart';
import '../../../../core/l10n/api_error_localizer.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/usecases/submit_support_request.dart';
import '../cubit/support_cubit.dart';
import '../cubit/support_state.dart';
import '../widgets/support_topic_selector.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({
    super.key,
    required this.submitSupportRequest,
    this.initialEmail,
  });

  final SubmitSupportRequest submitSupportRequest;
  final String? initialEmail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupportCubit(
        submitSupportRequest: submitSupportRequest,
        initialEmail: initialEmail,
      ),
      child: const _SupportView(),
    );
  }
}

class _SupportView extends StatefulWidget {
  const _SupportView();

  @override
  State<_SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<_SupportView> {
  late final TextEditingController _emailController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    final initialEmail = context.read<SupportCubit>().state.email;
    _emailController = TextEditingController(text: initialEmail);
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupportCubit, SupportState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SupportStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(context.l10n.destekTalebinizAlndEnKsa),
                behavior: SnackBarBehavior.floating,
              ),
            );
          Navigator.of(context).pop();
        }
        if (state.status == SupportStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  ApiErrorLocalizer.localize(context.l10n, state.errorMessage!),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: CardenceScaffold(
        resizeToAvoidBottomInset: true,
        appBar: CardenceAppBar(title: context.l10n.destek),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: BlocBuilder<SupportCubit, SupportState>(
              builder: (context, state) {
                final cubit = context.read<SupportCubit>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              controller: _emailController,
                              labelText: context.l10n.ePosta,
                              hintText: context.l10n.ornekMailCom,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onChanged: cubit.setEmail,
                            ),
                            const SizedBox(height: 16),
                            SupportTopicSelector(
                              selected: state.topic,
                              onChanged: cubit.setTopic,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _messageController,
                              labelText: context.l10n.mesajnz,
                              hintText: context.l10n.sorununuzuVeyaTalebiniziKsacaAklayn,
                              minLines: 5,
                              maxLines: 8,
                              maxLength: 2000,
                              textInputAction: TextInputAction.newline,
                              onChanged: cubit.setMessage,
                              helperText: context.l10n.enAz10Karakter,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: context.l10n.talebiGnder,
                      icon: Icons.send_rounded,
                      isLoading: state.isSubmitting,
                      enabled: state.canSubmit,
                      onPressed: () => cubit.submit(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
