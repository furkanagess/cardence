import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../data/datasources/camera_permission_datasource.dart';
import '../../data/datasources/physical_card_ocr_datasource.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../cubit/scan_physical_card_cubit.dart';
import '../cubit/scan_physical_card_state.dart';
import '../widgets/add_card_ui_helpers.dart';
import '../widgets/camera_permission_dialog.dart';
import 'add_manual_card_page.dart';

/// Fiziksel kartvizitin ön yüzünü (zorunlu) ve arka yüzünü (opsiyonel) çekerek
/// dijital kart oluşturma.
class ScanPhysicalCardPage extends StatelessWidget {
  const ScanPhysicalCardPage({
    super.key,
    required this.addSavedCard,
  });

  final AddSavedCard addSavedCard;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanPhysicalCardCubit(
        ocrDataSource: PhysicalCardOcrDataSource(),
        cameraPermissionDataSource: CameraPermissionDataSource(),
      ),
      child: _ScanPhysicalCardView(addSavedCard: addSavedCard),
    );
  }
}

class _ScanPhysicalCardView extends StatefulWidget {
  const _ScanPhysicalCardView({required this.addSavedCard});

  final AddSavedCard addSavedCard;

  @override
  State<_ScanPhysicalCardView> createState() => _ScanPhysicalCardViewState();
}

class _ScanPhysicalCardViewState extends State<_ScanPhysicalCardView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ScanPhysicalCardCubit>().syncCameraPermissionStatus();
    });
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

  Future<void> _captureWithPermission(
    ScanPhysicalCardState state,
    Future<void> Function() capture,
  ) async {
    if (!state.canCapture) return;

    if (state.cameraPermission != ScanCameraPermissionStatus.granted &&
        state.cameraPermission !=
            ScanCameraPermissionStatus.permanentlyDenied) {
      final confirmed = await showCameraPermissionDialog(context);
      if (!confirmed || !mounted) return;
    }

    await capture();
  }

  Future<void> _openManualReview(
    BuildContext context,
    ScanPhysicalCardState state,
  ) async {
    final draft = state.completedDraft;
    if (draft == null) return;

    final result = await Navigator.of(context).push<AddSavedCardResult>(
      MaterialPageRoute(
        builder: (_) => AddManualCardPage(
          addSavedCard: widget.addSavedCard,
          initialDraft: draft,
        ),
      ),
    );
    if (!context.mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanPhysicalCardCubit, ScanPhysicalCardState>(
      listenWhen: (previous, current) =>
          (previous.completedDraft == null &&
              current.completedDraft != null) ||
          (previous.errorMessage != current.errorMessage &&
              current.errorMessage != null),
      listener: (context, state) {
        if (state.completedDraft != null) {
          _openManualReview(context, state);
          return;
        }
        final message = state.errorMessage;
        if (message == null) return;

        final cubit = context.read<ScanPhysicalCardCubit>();
        final openSettings = state.cameraPermission ==
            ScanCameraPermissionStatus.permanentlyDenied;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              action: openSettings
                  ? SnackBarAction(
                      label: 'Ayarlar',
                      onPressed: cubit.openCameraSettings,
                    )
                  : null,
            ),
          );
      },
      builder: (context, state) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;
        final cubit = context.read<ScanPhysicalCardCubit>();
        final isProcessing = state.step == ScanPhysicalCardStep.processing;

        return CardenceScaffold(
          appBar: const CardenceAppBar(title: 'Kartvizit fotoğrafla'),
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AddCardPhotoCaptureZone(
                        label: 'Ön yüz',
                        hint: 'Ön yüzü çekin',
                        required: true,
                        imagePath: state.frontImagePath,
                        enabled: state.canCapture,
                        onTap: () => _captureWithPermission(
                          state,
                          cubit.captureFront,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AddCardPhotoCaptureZone(
                        label: 'Arka yüz',
                        hint: 'Arka yüzü ekleyin (varsa)',
                        required: false,
                        imagePath: state.backImagePath,
                        enabled: state.canCapture,
                        onTap: () => _captureWithPermission(
                          state,
                          cubit.captureBack,
                        ),
                      ),
                      if (isProcessing) ...[
                        const Spacer(),
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 12),
                        Text(
                          'Bilgiler okunuyor…',
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
                label: 'Bilgileri oku',
                icon: Icons.document_scanner_outlined,
                enabled: state.canReadInfo,
                isLoading: isProcessing,
                onPressed: state.canReadInfo ? cubit.finishScan : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
