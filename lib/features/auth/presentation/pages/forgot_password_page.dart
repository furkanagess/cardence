import 'package:flutter/material.dart';
import '../../../../core/l10n/api_error_localizer.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/usecases/forgot_password.dart';
import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({
    super.key,
    required this.forgotPassword,
    this.initialEmail,
  });

  final ForgotPassword forgotPassword;
  final String? initialEmail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordBloc(forgotPassword: forgotPassword),
      child: _ForgotPasswordView(initialEmail: initialEmail),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView({this.initialEmail});

  final String? initialEmail;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.failure &&
            state.errorMessage != null) {
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
        appBar: CardenceAppBar(title: context.l10n.ifremiUnuttum),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ForgotPasswordForm(
                    isLoading: state.isLoading,
                    isLinkSentStep: state.isLinkSentStep,
                    pendingEmail: state.pendingEmail,
                    initialEmail: initialEmail,
                    onRequestLink: (email) => context
                        .read<ForgotPasswordBloc>()
                        .add(ForgotPasswordLinkRequested(email: email)),
                    onBackToEmail: () => context
                        .read<ForgotPasswordBloc>()
                        .add(const ForgotPasswordBackToEmail()),
                    onBack: () => Navigator.of(context).pop(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
