import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_connect_animation.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/login_with_phone.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/reset_password.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../widgets/login_email_form.dart';
import '../widgets/login_method_selector.dart';
import '../widgets/login_phone_form.dart';
import '../widgets/register_form.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    required this.loginWithEmail,
    required this.loginWithPhone,
    required this.registerUser,
    required this.forgotPassword,
    required this.resetPassword,
    required this.onLoginSuccess,
  });

  final LoginWithEmail loginWithEmail;
  final LoginWithPhone loginWithPhone;
  final RegisterUser registerUser;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final VoidCallback onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(
        loginWithEmail: loginWithEmail,
        loginWithPhone: loginWithPhone,
        registerUser: registerUser,
      ),
      child: _AuthView(
        forgotPassword: forgotPassword,
        resetPassword: resetPassword,
        onAuthSuccess: onLoginSuccess,
      ),
    );
  }
}

class _AuthView extends StatefulWidget {
  const _AuthView({
    required this.forgotPassword,
    required this.resetPassword,
    required this.onAuthSuccess,
  });

  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final VoidCallback onAuthSuccess;

  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  late final Animation<double> _introFade;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _introFade = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _introController.forward();
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  void _switchMode(BuildContext context, AuthScreenMode mode) {
    context.read<LoginBloc>().add(AuthScreenModeChanged(mode));
  }

  void _openForgotPassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ForgotPasswordPage(
          forgotPassword: widget.forgotPassword,
          resetPassword: widget.resetPassword,
          onResetSuccess: widget.onAuthSuccess,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          widget.onAuthSuccess();
        }
        if (state.status == LoginStatus.failure && state.errorMessage != null) {
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
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final keyboardVisible =
                  MediaQuery.viewInsetsOf(context).bottom > 0;
              final logoSize = keyboardVisible
                  ? 72.0
                  : math
                      .min(
                        constraints.maxWidth * 0.58,
                        constraints.maxHeight * 0.26,
                      )
                      .clamp(140.0, 200.0);

              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    final isRegister = state.isRegisterMode;

                    if (isRegister) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              0,
                              keyboardVisible ? 4 : 12,
                              0,
                              keyboardVisible ? 8 : 16,
                            ),
                            child: Text(
                              'Hesap oluşturun',
                              textAlign: TextAlign.center,
                              style: (keyboardVisible
                                      ? textTheme.titleSmall
                                      : textTheme.titleMedium)
                                  ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: keyboardVisible
                                ? SingleChildScrollView(
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: RegisterForm(
                                      isLoading: state.isLoading,
                                      onSubmit: ({
                                        required displayName,
                                        required email,
                                        required password,
                                        phone,
                                      }) =>
                                          context.read<LoginBloc>().add(
                                                RegisterSubmitted(
                                                  displayName: displayName,
                                                  email: email,
                                                  password: password,
                                                  phone: phone,
                                                ),
                                              ),
                                    ),
                                  )
                                : RegisterForm(
                                    isLoading: state.isLoading,
                                    onSubmit: ({
                                      required displayName,
                                      required email,
                                      required password,
                                      phone,
                                    }) =>
                                        context.read<LoginBloc>().add(
                                              RegisterSubmitted(
                                                displayName: displayName,
                                                email: email,
                                                password: password,
                                                phone: phone,
                                              ),
                                            ),
                                  ),
                          ),
                          _AuthModeLink(
                            isRegister: true,
                            onTap: () =>
                                _switchMode(context, AuthScreenMode.login),
                          ),
                          if (kDebugMode)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'API: ${ApiConfig.baseUrl}',
                                textAlign: TextAlign.center,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FadeTransition(
                          opacity: _introFade,
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                height: logoSize + (keyboardVisible ? 0 : 8),
                                child: Center(
                                  child: CardenceConnectAnimation(
                                    size: logoSize,
                                  ),
                                ),
                              ),
                              if (!keyboardVisible) ...[
                                const SizedBox(height: 8),
                                Text(
                                  AppConstants.appName,
                                  textAlign: TextAlign.center,
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                              SizedBox(height: keyboardVisible ? 8 : 4),
                              Text(
                                'Hesabınıza giriş yapın',
                                textAlign: TextAlign.center,
                                style: (keyboardVisible
                                        ? textTheme.titleSmall
                                        : textTheme.titleMedium)
                                    ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: keyboardVisible ? 12 : 16),
                        Expanded(
                          child: _LoginFormContent(
                            state: state,
                            expandToFill: !keyboardVisible,
                            onForgotPassword: () =>
                                _openForgotPassword(context),
                          ),
                        ),
                        _AuthModeLink(
                          isRegister: false,
                          onTap: () =>
                              _switchMode(context, AuthScreenMode.register),
                        ),
                        if (kDebugMode)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'API: ${ApiConfig.baseUrl}',
                              textAlign: TextAlign.center,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthModeLink extends StatelessWidget {
  const _AuthModeLink({
    required this.isRegister,
    required this.onTap,
  });

  final bool isRegister;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text.rich(
          TextSpan(
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            children: [
              TextSpan(
                text: isRegister
                    ? 'Zaten hesabınız var mı? '
                    : 'Henüz hesabınız yok mu? ',
              ),
              TextSpan(
                text: isRegister ? 'Giriş yapın' : 'Kayıt olun',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _LoginFormContent extends StatefulWidget {
  const _LoginFormContent({
    required this.state,
    required this.onForgotPassword,
    this.expandToFill = false,
  });

  final LoginState state;
  final VoidCallback onForgotPassword;
  final bool expandToFill;

  @override
  State<_LoginFormContent> createState() => _LoginFormContentState();
}

class _LoginFormContentState extends State<_LoginFormContent> {
  final _emailFormKey = GlobalKey<LoginEmailFormState>();
  final _phoneFormKey = GlobalKey<LoginPhoneFormState>();

  LoginState get state => widget.state;

  void _submit() {
    if (state.method == LoginMethod.email) {
      _emailFormKey.currentState?.submit();
      return;
    }
    _phoneFormKey.currentState?.submit();
  }

  Widget _buildFields() {
    if (state.method == LoginMethod.email) {
      return LoginEmailForm(
        key: _emailFormKey,
        isLoading: state.isLoading,
        showSubmitButton: false,
        onForgotPassword: widget.onForgotPassword,
        onSubmit: ({required email, required password}) =>
            context.read<LoginBloc>().add(
                  LoginEmailSubmitted(email: email, password: password),
                ),
      );
    }

    return LoginPhoneForm(
      key: _phoneFormKey,
      isLoading: state.isLoading,
      showSubmitButton: false,
      onSubmit: ({required phone, required password}) =>
          context.read<LoginBloc>().add(
                LoginPhoneSubmitted(phone: phone, password: password),
              ),
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      label: 'Giriş yap',
      height: 48,
      isLoading: state.isLoading,
      onPressed: _submit,
      labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = _buildFields();
    final submitButton = _buildSubmitButton();

    if (widget.expandToFill) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginMethodSelector(
            selected: state.method,
            onChanged: (method) =>
                context.read<LoginBloc>().add(LoginMethodChanged(method)),
          ),
          const SizedBox(height: 14),
          fields,
          const Spacer(),
          const SizedBox(height: 8),
          submitButton,
        ],
      );
    }

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginMethodSelector(
            selected: state.method,
            onChanged: (method) =>
                context.read<LoginBloc>().add(LoginMethodChanged(method)),
          ),
          const SizedBox(height: 14),
          fields,
          const SizedBox(height: 8),
          submitButton,
        ],
      ),
    );
  }
}
