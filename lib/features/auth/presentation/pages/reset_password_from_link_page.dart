import 'package:flutter/material.dart';
import '../../../../core/l10n/api_error_localizer.dart';
import '../../../../core/l10n/app_error_keys.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/usecases/reset_password.dart';
import '../helpers/auth_form_validation.dart';
import '../widgets/auth_password_field.dart';

class ResetPasswordFromLinkPage extends StatefulWidget {
  const ResetPasswordFromLinkPage({
    super.key,
    required this.resetPassword,
    required this.resetToken,
    this.email,
    required this.onResetSuccess,
  });

  final ResetPassword resetPassword;
  final String resetToken;
  final String? email;
  final VoidCallback onResetSuccess;

  @override
  State<ResetPasswordFromLinkPage> createState() =>
      _ResetPasswordFromLinkPageState();
}

class _ResetPasswordFromLinkPageState extends State<ResetPasswordFromLinkPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    String? passwordError;
    String? confirmError;

    passwordError = AuthFormValidation.passwordError(context.l10n, password);
    if (password != confirm) {
      confirmError = context.l10n.sifrelerEslesmiyor;
    }

    setState(() {
      _passwordError = passwordError;
      _confirmError = confirmError;
      _generalError = null;
    });

    if (passwordError != null || confirmError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.resetPassword(
        email: widget.email,
        resetToken: widget.resetToken,
        newPassword: password,
      );
      if (!mounted) return;
      widget.onResetSuccess();
      Navigator.of(context).pop();
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _generalError = ApiErrorLocalizer.localize(context.l10n, e.message);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _generalError = ApiErrorLocalizer.localize(
          context.l10n,
          AppErrorKeys.connectionError,
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CardenceScaffold(
      appBar: CardenceAppBar(title: context.l10n.yeniifre),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.sifreSifirlamaLinkAcildi,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.email!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AuthPasswordField(
                  controller: _passwordController,
                  label: context.l10n.yeniifre,
                  errorText: _passwordError,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                ),
                const SizedBox(height: 8),
                AuthPasswordField(
                  controller: _confirmController,
                  label: context.l10n.yeniifreTekrar,
                  hintText: context.l10n.ifreniziTekrarGirin,
                  errorText: _confirmError,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  onChanged: (_) {
                    if (_confirmError != null) {
                      setState(() => _confirmError = null);
                    }
                  },
                ),
                if (_generalError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _generalError!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                CustomButton(
                  label: context.l10n.ifreyiGncelle,
                  height: 48,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
