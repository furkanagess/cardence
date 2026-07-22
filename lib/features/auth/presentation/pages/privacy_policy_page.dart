import 'package:flutter/material.dart';

import '../../../../core/l10n/api_error_localizer.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
import '../../../../core/widgets/molecules/cardence_error_dialog.dart';
import '../widgets/privacy_policy_delete_account_bar.dart';
import 'legal_document_page.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({
    super.key,
    this.onDeleteAccount,
  });

  /// Ayarlardan açıldığında verilir; kayıt ekranından açıldığında null.
  final Future<void> Function()? onDeleteAccount;

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool _busy = false;

  Future<void> _confirmAndDeleteAccount() async {
    final onDeleteAccount = widget.onDeleteAccount;
    if (_busy || onDeleteAccount == null) return;

    final confirmed = await CardenceConfirmDialog.show(
      context,
      title: context.l10n.deleteAccountTitle,
      message: context.l10n.deleteAccountConfirmMessage,
      confirmLabel: context.l10n.deleteAccountConfirmAction,
      icon: Icons.delete_forever_rounded,
      confirmIsDestructive: true,
    );
    if (!mounted || confirmed != true) return;

    setState(() => _busy = true);
    try {
      await onDeleteAccount();
    } on AuthApiException catch (e) {
      if (!mounted) return;
      await CardenceErrorDialog.show(
        context,
        title: context.l10n.operationFailed,
        message: ApiErrorLocalizer.localize(context.l10n, e.message),
      );
    } catch (_) {
      if (!mounted) return;
      await CardenceErrorDialog.show(
        context,
        title: context.l10n.operationFailed,
        message: context.l10n.deleteAccountFailed,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showDelete = widget.onDeleteAccount != null;

    return LegalDocumentPage(
      title: l10n.privacyPolicyTitle,
      sections: [
        LegalSection(
          title: l10n.privacySection1Title,
          body: l10n.privacySection1Body,
        ),
        LegalSection(
          title: l10n.privacySection2Title,
          body: l10n.privacySection2Body,
        ),
        LegalSection(
          title: l10n.privacySection3Title,
          body: l10n.privacySection3Body,
        ),
        LegalSection(
          title: l10n.privacySection4Title,
          body: l10n.privacySection4Body,
        ),
        LegalSection(
          title: l10n.privacySection5Title,
          body: l10n.privacySection5Body,
        ),
        LegalSection(
          title: l10n.privacySection6Title,
          body: l10n.privacySection6Body,
        ),
        LegalSection(
          title: l10n.privacySection7Title,
          body: l10n.privacySection7Body,
        ),
      ],
      bottomBar: showDelete
          ? PrivacyPolicyDeleteAccountBar(
              isLoading: _busy,
              onDeleteAccount: _confirmAndDeleteAccount,
            )
          : null,
    );
  }
}
