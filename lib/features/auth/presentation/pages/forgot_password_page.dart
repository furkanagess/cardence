import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/reset_password.dart';
import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({
    super.key,
    required this.forgotPassword,
    required this.resetPassword,
    required this.onResetSuccess,
  });

  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final VoidCallback onResetSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordBloc(
        forgotPassword: forgotPassword,
        resetPassword: resetPassword,
      ),
      child: _ForgotPasswordView(onResetSuccess: onResetSuccess),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView({required this.onResetSuccess});

  final VoidCallback onResetSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.success) {
          Navigator.of(context).pop();
          onResetSuccess();
        }
        if (state.status == ForgotPasswordStatus.otpSent) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Sıfırlama kodu gönderildi.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
        if (state.status == ForgotPasswordStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: CardenceScaffold(
        resizeToAvoidBottomInset: true,
        appBar: const CardenceAppBar(title: 'Şifremi unuttum'),
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
                    isOtpStep: state.isOtpStep,
                    pendingEmail: state.pendingEmail,
                    onRequestOtp: (email) => context
                        .read<ForgotPasswordBloc>()
                        .add(ForgotPasswordOtpRequested(email: email)),
                    onResetPassword: ({
                      required email,
                      required otpCode,
                      required newPassword,
                    }) =>
                        context.read<ForgotPasswordBloc>().add(
                              ForgotPasswordResetSubmitted(
                                email: email,
                                otpCode: otpCode,
                                newPassword: newPassword,
                              ),
                            ),
                    onBack: () {
                      if (state.isOtpStep) {
                        context.read<ForgotPasswordBloc>().add(
                              const ForgotPasswordBackToEmail(),
                            );
                        return;
                      }
                      Navigator.of(context).pop();
                    },
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
