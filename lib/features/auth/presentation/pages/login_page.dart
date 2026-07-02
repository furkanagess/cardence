import 'dart:math' as math;
import '../../../../core/l10n/l10n_extensions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/api_error_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/cardence_error_dialog.dart';
import '../../../../core/widgets/organisms/cardence_connect_animation.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/get_last_login_credentials.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/login_with_linkedin.dart';
import '../../domain/usecases/login_with_phone.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/reset_password.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../widgets/login_accent_color_picker.dart';
import '../widgets/login_email_form.dart';
import '../widgets/login_method_selector.dart';
import '../widgets/login_phone_form.dart';
import '../oauth/linkedin_auth_flow.dart';
import '../widgets/login_social_section.dart';
import '../widgets/register_form.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    required this.loginWithEmail,
    required this.loginWithPhone,
    required this.loginWithLinkedIn,
    required this.registerUser,
    required this.getLastLoginCredentials,
    required this.forgotPassword,
    required this.resetPassword,
    required this.selectedAccentColorId,
    required this.onAccentColorSelected,
    required this.onLoginSuccess,
  });

  final LoginWithEmail loginWithEmail;
  final LoginWithPhone loginWithPhone;
  final LoginWithLinkedIn loginWithLinkedIn;
  final RegisterUser registerUser;
  final GetLastLoginCredentials getLastLoginCredentials;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final String selectedAccentColorId;
  final ValueChanged<String> onAccentColorSelected;
  final void Function({bool fromRegistration}) onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(
        loginWithEmail: loginWithEmail,
        loginWithPhone: loginWithPhone,
        loginWithLinkedIn: loginWithLinkedIn,
        registerUser: registerUser,
        getLastLoginCredentials: getLastLoginCredentials,
      )..add(const LoginStarted()),
      child: _AuthView(
        forgotPassword: forgotPassword,
        resetPassword: resetPassword,
        selectedAccentColorId: selectedAccentColorId,
        onAccentColorSelected: onAccentColorSelected,
        onAuthSuccess: onLoginSuccess,
      ),
    );
  }
}

class _AuthView extends StatefulWidget {
  const _AuthView({
    required this.forgotPassword,
    required this.resetPassword,
    required this.selectedAccentColorId,
    required this.onAccentColorSelected,
    required this.onAuthSuccess,
  });

  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final String selectedAccentColorId;
  final ValueChanged<String> onAccentColorSelected;
  final void Function({bool fromRegistration}) onAuthSuccess;

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
    final initialEmail = context.read<LoginBloc>().state.lastEmail;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ForgotPasswordPage(
          forgotPassword: widget.forgotPassword,
          initialEmail: initialEmail,
        ),
      ),
    );
  }

  Future<void> _handleLinkedInLogin(BuildContext context) async {
    try {
      final code = await requestLinkedInAuthorizationCode(context);
      if (!context.mounted) {
        return;
      }
      if (code == null || code.isEmpty) {
        return;
      }

      context.read<LoginBloc>().add(
            LoginLinkedInSubmitted(authorizationCode: code),
          );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
          }
  }

  void _showRegisterErrorDialog(BuildContext context, String message) {
    FocusScope.of(context).unfocus();
    final l10n = context.l10n;
    CardenceErrorDialog.show(
      context,
      title: l10n.operationFailed,
      message: ApiErrorLocalizer.localize(l10n, message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) {
        if (curr.status == LoginStatus.success &&
            prev.status != LoginStatus.success) {
          return true;
        }
        return curr.isRegisterMode &&
            prev.status == LoginStatus.loading &&
            curr.status == LoginStatus.failure;
      },
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          widget.onAuthSuccess(fromRegistration: state.isRegisterMode);
          return;
        }

        final errorMessage = state.errorMessage;
        if (errorMessage == null || errorMessage.isEmpty) return;
        _showRegisterErrorDialog(context, errorMessage);
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return CardenceScaffold(
            resizeToAvoidBottomInset: state.isRegisterMode,
            appBar: state.isRegisterMode
                ? CardenceAppBar(
                    title: context.l10n.kaytOl,
                    leading: CardenceAppBar.backButton(
                      context: context,
                      onPressed: () =>
                          _switchMode(context, AuthScreenMode.login),
                    ),
                  )
                : null,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
                  final keyboardVisible = bottomInset > 0;
                  final logoSize = keyboardVisible
                      ? 72.0
                      : math
                          .min(
                            constraints.maxWidth * 0.58,
                            constraints.maxHeight * 0.26,
                          )
                          .clamp(112.0, 132.0);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                    child: state.isRegisterMode
                        ? _RegisterScreenContent(
                            state: state,
                            keyboardVisible: keyboardVisible,
                            bottomInset: bottomInset,
                          )
                        : _LoginScreenContent(
                            state: state,
                            keyboardVisible: keyboardVisible,
                            bottomInset: bottomInset,
                            logoSize: logoSize,
                            introFade: _introFade,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            onForgotPassword: () =>
                                _openForgotPassword(context),
                            onLinkedInPressed: () => _handleLinkedInLogin(context),
                            onRegisterTap: () =>
                                _switchMode(context, AuthScreenMode.register),
                            selectedAccentColorId: widget.selectedAccentColorId,
                            onAccentColorSelected: widget.onAccentColorSelected,
                          ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RegisterScreenContent extends StatelessWidget {
  const _RegisterScreenContent({
    required this.state,
    required this.keyboardVisible,
    required this.bottomInset,
  });

  final LoginState state;
  final bool keyboardVisible;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final registerForm = RegisterForm(
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
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              top: keyboardVisible ? 0 : 6,
              bottom: bottomInset + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!keyboardVisible) ...[
                  Text(
                    "Cardence'a Katılın",
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.profesyonelKimliiniziYnetmekIinYeni,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                registerForm,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginScreenContent extends StatelessWidget {
  const _LoginScreenContent({
    required this.state,
    required this.keyboardVisible,
    required this.bottomInset,
    required this.logoSize,
    required this.introFade,
    required this.colorScheme,
    required this.textTheme,
    required this.onForgotPassword,
    required this.onLinkedInPressed,
    required this.onRegisterTap,
    required this.selectedAccentColorId,
    required this.onAccentColorSelected,
  });

  final LoginState state;
  final bool keyboardVisible;
  final double bottomInset;
  final double logoSize;
  final Animation<double> introFade;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onForgotPassword;
  final VoidCallback onLinkedInPressed;
  final VoidCallback onRegisterTap;
  final String selectedAccentColorId;
  final ValueChanged<String> onAccentColorSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeTransition(
          opacity: introFade,
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
                context.l10n.hesabnzaGiriYapn,
                textAlign: TextAlign.center,
                style: (keyboardVisible
                        ? textTheme.titleSmall
                        : textTheme.bodyLarge)
                    ?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
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
            bottomInset: bottomInset,
            onForgotPassword: onForgotPassword,
            onLinkedInPressed: onLinkedInPressed,
            selectedAccentColorId: selectedAccentColorId,
            onAccentColorSelected: onAccentColorSelected,
          ),
        ),
        if (!keyboardVisible) ...[
          _AuthModeLink(
            isRegister: false,
            onTap: onRegisterTap,
          ),
        ],
      ],
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
                    : 'Hesabınız yok mu? ',
              ),
              TextSpan(
                text: isRegister ? context.l10n.giriYap : context.l10n.signUp,
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
    required this.onLinkedInPressed,
    required this.selectedAccentColorId,
    required this.onAccentColorSelected,
    this.expandToFill = false,
    this.bottomInset = 0,
  });

  final LoginState state;
  final VoidCallback onForgotPassword;
  final VoidCallback onLinkedInPressed;
  final String selectedAccentColorId;
  final ValueChanged<String> onAccentColorSelected;
  final bool expandToFill;
  final double bottomInset;

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
        initialEmail: state.lastEmail,
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
      initialPhone: state.lastPhone,
      showSubmitButton: false,
      onSubmit: ({required phone, required password}) =>
          context.read<LoginBloc>().add(
                LoginPhoneSubmitted(phone: phone, password: password),
              ),
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      label: context.l10n.giriYap,
      height: 48,
      isLoading: state.isLoading,
      onPressed: _submit,
      labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildSocialSection() {
    return LoginSocialSection(
      isLoading: state.isLoading,
      onLinkedInPressed: state.isLoading ? null : widget.onLinkedInPressed,
    );
  }

  Widget _buildAccentPicker() {
    return LoginAccentColorPicker(
      selectedId: widget.selectedAccentColorId,
      onSelected: widget.onAccentColorSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = _buildFields();
    final submitButton = _buildSubmitButton();
    final accentPicker = _buildAccentPicker();
    final socialSection = _buildSocialSection();

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
          const SizedBox(height: 14),
          accentPicker,
          const SizedBox(height: 12),
          socialSection,
        ],
      );
    }

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: widget.bottomInset + 16),
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
          const SizedBox(height: 14),
          accentPicker,
          const SizedBox(height: 12),
          socialSection,
        ],
      ),
    );
  }
}
