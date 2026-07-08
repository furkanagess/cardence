import 'dart:math' as math;
import '../../../../core/l10n/l10n_extensions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/api_error_localizer.dart';
import '../../../../core/theme/splash_theme.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/cardence_error_dialog.dart';
import '../../../../core/widgets/organisms/cardence_logo_merge_animation.dart';
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
import '../widgets/login_email_form.dart';
import '../widgets/login_phone_form.dart';
import '../oauth/linkedin_auth_flow.dart';
import '../widgets/login_social_section.dart';
import '../widgets/register_form.dart';
import '../../../onboarding/presentation/widgets/onboarding_flow_ui.dart';
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
    required this.onLoginSuccess,
  });

  final LoginWithEmail loginWithEmail;
  final LoginWithPhone loginWithPhone;
  final LoginWithLinkedIn loginWithLinkedIn;
  final RegisterUser registerUser;
  final GetLastLoginCredentials getLastLoginCredentials;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
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
  final void Function({bool fromRegistration}) onAuthSuccess;

  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView>
    with SingleTickerProviderStateMixin {
  bool _authSuccessHandled = false;
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

  void _showAuthErrorDialog(BuildContext context, String message) {
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
        if (curr.status == LoginStatus.loading &&
            prev.status != LoginStatus.loading) {
          return true;
        }
        if (curr.status == LoginStatus.success &&
            prev.status != LoginStatus.success) {
          return true;
        }
        return prev.status == LoginStatus.loading &&
            curr.status == LoginStatus.failure;
      },
      listener: (context, state) {
        if (state.status == LoginStatus.loading) {
          _authSuccessHandled = false;
          return;
        }

        if (state.status == LoginStatus.success) {
          if (_authSuccessHandled) return;
          _authSuccessHandled = true;
          final fromRegistration = state.isRegisterMode;
          // Frame sonrasında çağır: parent setState ile listener yarışmasın.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            widget.onAuthSuccess(fromRegistration: fromRegistration);
          });
          return;
        }

        final errorMessage = state.errorMessage;
        if (errorMessage == null || errorMessage.isEmpty) return;
        _showAuthErrorDialog(context, errorMessage);
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
            body: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                math.max(MediaQuery.paddingOf(context).top - 12, 0),
                24,
                MediaQuery.paddingOf(context).bottom,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
                  final keyboardVisible = bottomInset > 0;
                  final logoSize = keyboardVisible
                      ? 84.0
                      : math
                          .min(
                            constraints.maxWidth * 0.64,
                            constraints.maxHeight * 0.32,
                          )
                          .clamp(148.0, 196.0);

                  return state.isRegisterMode
                      ? _RegisterScreenContent(
                          state: state,
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
                          onLinkedInPressed: () =>
                              _handleLinkedInLogin(context),
                          onRegisterTap: () =>
                              _switchMode(context, AuthScreenMode.register),
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

class _RegisterScreenContent extends StatefulWidget {
  const _RegisterScreenContent({
    required this.state,
    required this.bottomInset,
  });

  final LoginState state;
  final double bottomInset;

  @override
  State<_RegisterScreenContent> createState() => _RegisterScreenContentState();
}

class _RegisterScreenContentState extends State<_RegisterScreenContent> {
  final _registerFormKey = GlobalKey<RegisterFormState>();
  bool _canSubmit = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final bottomBarInset = OnboardingBottomBar.contentBottomInset(
      context,
      showStepIndicator: false,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.authJoinCardenceTitle,
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
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              bottom: widget.bottomInset + bottomBarInset,
            ),
            child: RegisterForm(
              key: _registerFormKey,
              isLoading: widget.state.isLoading,
              showSubmitButton: false,
              onCanSubmitChanged: (canSubmit) {
                if (_canSubmit == canSubmit) return;
                setState(() => _canSubmit = canSubmit);
              },
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
        ),
        CardenceFlowBottomBarRegion(
          child: CustomButton(
            label: context.l10n.kaytOl,
            height: 48,
            isLoading: widget.state.isLoading,
            onPressed: _canSubmit
                ? () => _registerFormKey.currentState?.submit()
                : null,
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
                  child: CardenceLogoMergeAnimation(
                    size: logoSize,
                    repeat: true,
                    logoAssetPath: SplashTheme.logoAsset(
                      Theme.of(context).brightness,
                    ),
                  ),
                ),
              ),
              if (!keyboardVisible) ...[
                const SizedBox(height: 6),
                Text(
                  context.l10n.loginWelcomeTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: keyboardVisible ? 8 : 10),
        Expanded(
          child: _LoginFormContent(
            state: state,
            expandToFill: !keyboardVisible,
            bottomInset: bottomInset,
            onForgotPassword: onForgotPassword,
            onLinkedInPressed: onLinkedInPressed,
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
                    ? context.l10n.authAlreadyHaveAccountPrompt
                    : context.l10n.authNoAccountPrompt,
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
    this.expandToFill = false,
    this.bottomInset = 0,
  });

  final LoginState state;
  final VoidCallback onForgotPassword;
  final VoidCallback onLinkedInPressed;
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
    final signInLabelColor = Theme.of(context).scaffoldBackgroundColor;

    return CustomButton(
      label: context.l10n.giriYap,
      height: 48,
      isLoading: state.isLoading,
      onPressed: _submit,
      labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: signInLabelColor,
          ),
      style: FilledButton.styleFrom(
        foregroundColor: signInLabelColor,
      ),
    );
  }

  Widget _buildSocialSection() {
    return LoginSocialSection(
      isLoading: state.isLoading,
      onLinkedInPressed: state.isLoading ? null : widget.onLinkedInPressed,
    );
  }

  Widget _buildMethodSwitchButton() {
    final isEmail = state.method == LoginMethod.email;
    return CustomButton.outlined(
      label: isEmail ? context.l10n.loginWithPhone : context.l10n.loginWithEmail,
      icon: isEmail ? Icons.phone_android_rounded : Icons.mail_outline_rounded,
      height: 48,
      isLoading: state.isLoading,
      onPressed: state.isLoading
          ? null
          : () => context.read<LoginBloc>().add(
                LoginMethodChanged(
                  isEmail ? LoginMethod.phone : LoginMethod.email,
                ),
              ),
      labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = _buildFields();
    final submitButton = _buildSubmitButton();
    final methodSwitchButton = _buildMethodSwitchButton();
    final socialSection = _buildSocialSection();

    if (widget.expandToFill) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          fields,
          const Spacer(),
          const SizedBox(height: 8),
          submitButton,
          const SizedBox(height: 10),
          methodSwitchButton,
          const SizedBox(height: 14),
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
          fields,
          const SizedBox(height: 8),
          submitButton,
          const SizedBox(height: 10),
          methodSwitchButton,
          const SizedBox(height: 14),
          socialSection,
        ],
      ),
    );
  }
}
