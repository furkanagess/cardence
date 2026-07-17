import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../data/datasources/camera_permission_datasource.dart';
import '../../data/datasources/physical_card_ocr_datasource.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../cubit/scan_physical_card_cubit.dart';
import '../cubit/scan_physical_card_state.dart';
import '../widgets/add_card_ui_helpers.dart';
import '../widgets/scan_physical_card_views.dart';
import 'add_manual_card_page.dart';

/// Fiziksel kartvizit: ön yüz (zorunlu) + arka yüz (opsiyonel) → OCR → düzenleme.
class ScanPhysicalCardPage extends StatelessWidget {
  const ScanPhysicalCardPage({
    super.key,
    this.addSavedCard,
    this.returnDraftOnly = false,
  }) : assert(
          returnDraftOnly || addSavedCard != null,
          'Wallet akışı için addSavedCard gerekli',
        );

  final AddSavedCard? addSavedCard;
  final bool returnDraftOnly;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanPhysicalCardCubit(
        ocrDataSource: PhysicalCardOcrDataSource(),
        cameraPermissionDataSource: CameraPermissionDataSource(),
      )..initialize(),
      child: _ScanPhysicalCardView(
        addSavedCard: addSavedCard,
        returnDraftOnly: returnDraftOnly,
      ),
    );
  }
}

class _ScanPhysicalCardView extends StatefulWidget {
  const _ScanPhysicalCardView({
    required this.returnDraftOnly,
    this.addSavedCard,
  });

  final AddSavedCard? addSavedCard;
  final bool returnDraftOnly;

  @override
  State<_ScanPhysicalCardView> createState() => _ScanPhysicalCardViewState();
}

class _ScanPhysicalCardViewState extends State<_ScanPhysicalCardView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<ScanPhysicalCardCubit>().syncCameraPermissionStatus();
    }
  }

  Future<void> _openManualReview(
    BuildContext context,
    ScanPhysicalCardState state,
  ) async {
    final draft = state.completedDraft;
    if (draft == null) return;

    if (widget.returnDraftOnly) {
      Navigator.of(context).pop(draft);
      return;
    }

    final addSavedCard = widget.addSavedCard;
    if (addSavedCard == null) {
      Navigator.of(context).pop(draft);
      return;
    }

    final result = await Navigator.of(context).push<AddSavedCardResult>(
      MaterialPageRoute(
        builder: (_) => AddManualCardPage(
          addSavedCard: addSavedCard,
          initialDraft: draft,
        ),
      ),
    );
    if (!context.mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<ScanPhysicalCardCubit, ScanPhysicalCardState>(
      listenWhen: (previous, current) =>
          (previous.completedDraft == null && current.completedDraft != null) ||
          (previous.errorMessage != current.errorMessage &&
              current.errorMessage != null),
      listener: (context, state) {
        final error = state.errorMessage;
        if (error != null && error.isNotEmpty) {
          final cubit = context.read<ScanPhysicalCardCubit>();
          final openSettings = state.cameraPermission ==
              ScanCameraPermissionStatus.permanentlyDenied;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(error),
                action: openSettings
                    ? SnackBarAction(
                        label: l10n.scanCardOpenPermissions,
                        onPressed: cubit.openCameraSettings,
                      )
                    : null,
              ),
            );
        }
        if (state.completedDraft != null) {
          _openManualReview(context, state);
        }
      },
      builder: (context, state) {
        final cubit = context.read<ScanPhysicalCardCubit>();
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return PopScope(
          canPop: !state.isProcessing,
          child: CardenceScaffold(
            appBar: CardenceAppBar(title: l10n.kartvizitFotorafla),
            resizeToAvoidBottomInset: true,
            body: state.needsPermission
                ? ScanPhysicalCardPermissionBody(
                    status: state.cameraPermission,
                    onRequest: () => cubit.syncCameraPermissionStatus(
                      requestIfNeeded: true,
                    ),
                    onOpenSettings: cubit.openCameraSettings,
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AddCardPhotoCaptureZone(
                                label: l10n.nYz,
                                hint: l10n.scanCardCaptureFrontHint,
                                required: true,
                                imagePath: state.frontImagePath,
                                enabled: state.canCapture,
                                onTap: () => cubit.captureFront(
                                  cropTitle: l10n.scanCardCropTitle,
                                ),
                              ),
                              const SizedBox(height: 20),
                              AddCardPhotoCaptureZone(
                                label: l10n.arkaYz,
                                hint: l10n.scanCardCaptureBackHint,
                                required: false,
                                imagePath: state.backImagePath,
                                enabled: state.canCapture,
                                onTap: () => cubit.captureBack(
                                  cropTitle: l10n.scanCardCropTitle,
                                ),
                              ),
                              if (state.isProcessing) ...[
                                const Spacer(),
                                const Center(child: CircularProgressIndicator()),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.bilgilerOkunuyor,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ],
                          ),
                        ),
                      ),
                      AddCardStickyAction(
                        label: l10n.bilgileriOku,
                        icon: Icons.document_scanner_outlined,
                        enabled: state.canReadInfo,
                        isLoading: state.isProcessing,
                        onPressed: state.canReadInfo ? cubit.finishScan : null,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
