import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../data/datasources/camera_permission_datasource.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../cubit/scan_card_qr_cubit.dart';
import '../cubit/scan_card_qr_state.dart';
import '../helpers/add_card_by_id_messages.dart';
import '../widgets/add_card_flow_status_views.dart';
import '../widgets/scan_card_qr_views.dart';
import 'add_card_by_id_page.dart';

/// QR okutarak cüzdana kart ekleme; altta Kart ID ile ekleme seçeneği.
class ScanCardQrPage extends StatelessWidget {
  const ScanCardQrPage({
    super.key,
    required this.addSavedCard,
  });

  final AddSavedCard addSavedCard;

  static const Duration _statusDisplayDuration = Duration(milliseconds: 2400);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanCardQrCubit(
        addSavedCard: addSavedCard,
        cameraPermissionDataSource: CameraPermissionDataSource(),
      )..initialize(),
      child: _ScanCardQrView(addSavedCard: addSavedCard),
    );
  }
}

class _ScanCardQrView extends StatefulWidget {
  const _ScanCardQrView({required this.addSavedCard});

  final AddSavedCard addSavedCard;

  @override
  State<_ScanCardQrView> createState() => _ScanCardQrViewState();
}

class _ScanCardQrViewState extends State<_ScanCardQrView>
    with WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  bool _openingCardId = false;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
      autoStart: false,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final cubit = context.read<ScanCardQrCubit>();
    if (state == AppLifecycleState.resumed) {
      cubit.syncCameraPermissionStatus();
    }
  }

  Future<void> _syncScanner(ScanCardQrState state) async {
    try {
      if (state.canScan) {
        if (!_scannerController.value.isRunning) {
          await _scannerController.start();
        }
        return;
      }
      if (_scannerController.value.isRunning) {
        await _scannerController.stop();
      }
    } catch (_) {
      // Kamera geçiş hataları sessizce yutulur.
    }
  }

  Future<void> _handleCompletedStatus(ScanCardQrState state) async {
    final result = state.result;
    if (result == null || _completing) return;
    _completing = true;

    await Future<void>.delayed(ScanCardQrPage._statusDisplayDuration);
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  Future<void> _openAddByCardId() async {
    if (_openingCardId) return;
    _openingCardId = true;
    try {
      if (_scannerController.value.isRunning) {
        await _scannerController.stop();
      }
      if (!mounted) return;
      final result = await Navigator.of(context).push<AddSavedCardResult>(
        MaterialPageRoute(
          builder: (_) => AddCardByIdPage(addSavedCard: widget.addSavedCard),
        ),
      );
      if (!mounted) return;
      if (result != null) {
        Navigator.of(context).pop(result);
        return;
      }
      await context.read<ScanCardQrCubit>().syncCameraPermissionStatus();
    } finally {
      _openingCardId = false;
    }
  }

  String? _feedbackMessage(ScanCardQrState state) {
    final l10n = context.l10n;
    if (state.scanHintError == 'invalid') {
      return l10n.scanCardQrInvalid;
    }
    final result = state.result;
    if (result == null) return null;
    return addCardByIdFormError(l10n, result);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanCardQrCubit, ScanCardQrState>(
      listenWhen: (previous, current) =>
          previous.phase != current.phase ||
          previous.cameraPermission != current.cameraPermission ||
          previous.canScan != current.canScan,
      listener: (context, state) {
        _syncScanner(state);
        if (state.isSuccess ||
            (state.isFailure && state.result != null)) {
          _handleCompletedStatus(state);
        }
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final cubit = context.read<ScanCardQrCubit>();
        final colorScheme = Theme.of(context).colorScheme;
        final failureResult = state.result;
        final failureMessages = failureResult == null
            ? (
                title: l10n.kartCzdanaEklenemedi,
                message: l10n.invalidCardId,
              )
            : addCardByIdFailureMessages(l10n, failureResult);
        final feedback = _feedbackMessage(state);

        return PopScope(
          canPop: state.isScanning || state.phase == ScanCardQrPhase.permission,
          child: CardenceScaffold(
            appBar: CardenceAppBar(title: l10n.scanCardQrTitle),
            body: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: switch (state.phase) {
                      ScanCardQrPhase.submitting => AddCardFlowSendingView(
                          key: const ValueKey('qr-sending'),
                          message: l10n.addCardByIdSending,
                        ),
                      ScanCardQrPhase.success => AddCardFlowSuccessView(
                          key: const ValueKey('qr-success'),
                          title: l10n.kartCzdannzaEklendi,
                          message:
                              '${l10n.kartId2}: ${state.scannedCardId ?? ''}',
                        ),
                      ScanCardQrPhase.failure => AddCardFlowFailureView(
                          key: const ValueKey('qr-failure'),
                          title: failureMessages.title,
                          message: failureMessages.message,
                        ),
                      ScanCardQrPhase.permission => ScanCardQrPermissionBody(
                          key: const ValueKey('qr-permission'),
                          status: state.cameraPermission,
                          onRequest: () => cubit.syncCameraPermissionStatus(
                            requestIfNeeded: true,
                          ),
                          onOpenSettings: cubit.openSettings,
                        ),
                      ScanCardQrPhase.scanning => ScanCardQrScannerBody(
                          key: const ValueKey('qr-scanning'),
                          controller: _scannerController,
                          feedback: feedback,
                          onDetect: (raw) => cubit.onRawQrDetected(raw),
                        ),
                    },
                  ),
                ),
                if (state.isScanning ||
                    state.phase == ScanCardQrPhase.permission)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.scanCardQrHint,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),
                          const SizedBox(height: 14),
                          CustomButton(
                            label: l10n.kartIdIleEkle,
                            icon: Icons.badge_outlined,
                            variant: CustomButtonVariant.outlined,
                            onPressed: _openAddByCardId,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
