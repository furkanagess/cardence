import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
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
import 'scan_physical_card_page.dart';

/// QR okutarak cüzdana kart ekleme; altta Kart ID ve fotoğraf ile ekleme.
class ScanCardQrPage extends StatelessWidget {
  const ScanCardQrPage({
    super.key,
    required this.addSavedCard,
    this.canAddManualSavedCard = true,
    this.onRequestPaywall,
  });

  final AddSavedCard addSavedCard;
  final bool canAddManualSavedCard;
  final Future<void> Function()? onRequestPaywall;

  static const Duration _statusDisplayDuration = Duration(milliseconds: 2400);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanCardQrCubit(
        addSavedCard: addSavedCard,
        cameraPermissionDataSource: CameraPermissionDataSource(),
      )..initialize(),
      child: _ScanCardQrView(
        addSavedCard: addSavedCard,
        canAddManualSavedCard: canAddManualSavedCard,
        onRequestPaywall: onRequestPaywall,
      ),
    );
  }
}

class _ScanCardQrView extends StatefulWidget {
  const _ScanCardQrView({
    required this.addSavedCard,
    required this.canAddManualSavedCard,
    this.onRequestPaywall,
  });

  final AddSavedCard addSavedCard;
  final bool canAddManualSavedCard;
  final Future<void> Function()? onRequestPaywall;

  @override
  State<_ScanCardQrView> createState() => _ScanCardQrViewState();
}

class _ScanCardQrViewState extends State<_ScanCardQrView>
    with WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  bool _secondaryFlowActive = false;
  bool _completing = false;

  /// Alt ekran açıkken MobileScanner ağaca hiç girmez (dispose sonrası kullanım yok).
  bool get _showScannerPreview => !_secondaryFlowActive;

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
    if (!mounted || _secondaryFlowActive) return;

    final cubit = context.read<ScanCardQrCubit>();
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _stopScannerQuietly();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      cubit.syncCameraPermissionStatus().then((_) {
        if (!mounted || _secondaryFlowActive) return;
        _syncScanner(context.read<ScanCardQrCubit>().state);
      });
    }
  }

  Future<void> _stopScannerQuietly() async {
    try {
      if (_scannerController.value.isRunning) {
        await _scannerController.stop();
      }
    } on MobileScannerException {
      // Zaten durmuş / dispose edilmiş olabilir.
    } catch (_) {}
  }

  Future<void> _syncScanner(ScanCardQrState state) async {
    if (_secondaryFlowActive || !_showScannerPreview) return;
    try {
      if (state.canScan) {
        if (_scannerController.value.isRunning) return;
        await Future<void>.delayed(const Duration(milliseconds: 150));
        if (!mounted || _secondaryFlowActive) return;
        if (!context.read<ScanCardQrCubit>().state.canScan) return;
        await _scannerController.start();
        return;
      }
      if (_scannerController.value.isRunning) {
        await _scannerController.stop();
      }
    } on MobileScannerException {
      // Geçiş hataları yutulur.
    } catch (_) {}
  }

  Future<void> _handleCompletedStatus(ScanCardQrState state) async {
    final result = state.result;
    if (result == null || _completing) return;
    _completing = true;

    await Future<void>.delayed(ScanCardQrPage._statusDisplayDuration);
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  Future<void> _openSecondaryFlow(
    Future<AddSavedCardResult?> Function() open,
  ) async {
    if (_secondaryFlowActive) return;

    // Önce preview'ı ağaçtan çıkar, sonra kamerayı durdur.
    setState(() => _secondaryFlowActive = true);
    await _stopScannerQuietly();
    // Widget unmount + kamera serbest kalsın.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    var shouldRestartScanner = true;
    try {
      final result = await open();
      if (!mounted) {
        shouldRestartScanner = false;
        return;
      }
      if (result != null) {
        shouldRestartScanner = false;
        Navigator.of(context).pop(result);
        return;
      }
    } finally {
      if (mounted) {
        setState(() => _secondaryFlowActive = false);
      }
    }

    if (!mounted || !shouldRestartScanner) return;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted || _secondaryFlowActive) return;
    await context.read<ScanCardQrCubit>().syncCameraPermissionStatus();
    if (!mounted || _secondaryFlowActive) return;
    await _syncScanner(context.read<ScanCardQrCubit>().state);
  }

  Future<void> _openAddByCardId() {
    return _openSecondaryFlow(
      () => Navigator.of(context).push<AddSavedCardResult>(
        MaterialPageRoute(
          builder: (_) => AddCardByIdPage(addSavedCard: widget.addSavedCard),
        ),
      ),
    );
  }

  Future<void> _openPhysicalScan() async {
    if (!widget.canAddManualSavedCard) {
      await widget.onRequestPaywall?.call();
      return;
    }
    return _openSecondaryFlow(
      () => Navigator.of(context).push<AddSavedCardResult>(
        MaterialPageRoute(
          builder: (_) =>
              ScanPhysicalCardPage(addSavedCard: widget.addSavedCard),
        ),
      ),
    );
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

  Widget _buildScannerArea(ScanCardQrState state, String? feedback) {
    if (!_showScannerPreview) {
      return const ColoredBox(
        color: AppColors.pureBlack,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ScanCardQrScannerBody(
      key: const ValueKey('qr-scanning'),
      controller: _scannerController,
      feedback: feedback,
      onDetect: (raw) => context.read<ScanCardQrCubit>().onRawQrDetected(raw),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanCardQrCubit, ScanCardQrState>(
      listenWhen: (previous, current) =>
          previous.phase != current.phase ||
          previous.cameraPermission != current.cameraPermission ||
          previous.canScan != current.canScan,
      listener: (context, state) {
        if (!_secondaryFlowActive) {
          _syncScanner(state);
        }
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
                      ScanCardQrPhase.scanning => KeyedSubtree(
                          key: const ValueKey('qr-scanning-area'),
                          child: _buildScannerArea(state, feedback),
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
                            onPressed:
                                _secondaryFlowActive ? null : _openAddByCardId,
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            label: l10n.kartvizitFotorafla,
                            icon: widget.canAddManualSavedCard
                                ? Icons.photo_camera_outlined
                                : Icons.workspace_premium_outlined,
                            variant: CustomButtonVariant.outlined,
                            onPressed: _secondaryFlowActive
                                ? null
                                : _openPhysicalScan,
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
