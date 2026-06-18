import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../data/datasources/camera_permission_datasource.dart';
import '../../data/datasources/physical_card_ocr_datasource.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../cubit/scan_physical_card_cubit.dart';
import '../cubit/scan_physical_card_state.dart';
import '../widgets/add_card_ui_helpers.dart';
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

class _ScanPhysicalCardViewState extends State<_ScanPhysicalCardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ScanPhysicalCardCubit>().requestCameraPermission();
    });
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      builder: (context, state) {
        final textTheme = Theme.of(context).textTheme;
        final cubit = context.read<ScanPhysicalCardCubit>();
        final isProcessing = state.step == ScanPhysicalCardStep.processing;
        final permissionGranted =
            state.cameraPermission == ScanCameraPermissionStatus.granted;
        final permissionChecking =
            state.cameraPermission == ScanCameraPermissionStatus.checking;

        return CardenceScaffold(
          appBar: const CardenceAppBar(title: 'Kartvizit fotoğrafla'),
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    if (permissionChecking) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      Text(
                        'Kamera izni isteniyor…',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else if (!permissionGranted) ...[
                      _CameraPermissionBlocked(
                        status: state.cameraPermission,
                        onRetry: cubit.requestCameraPermission,
                        onOpenSettings: cubit.openCameraSettings,
                      ),
                    ] else ...[
                      AddCardPhotoCaptureZone(
                        label: 'Ön yüz',
                        hint: 'Ön yüzü çekin',
                        required: true,
                        imagePath: state.frontImagePath,
                        enabled: state.canCapture,
                        onTap: cubit.captureFront,
                      ),
                      const SizedBox(height: 20),
                      AddCardPhotoCaptureZone(
                        label: 'Arka yüz',
                        hint: 'Arka yüzü ekleyin (varsa)',
                        required: false,
                        imagePath: state.backImagePath,
                        enabled: state.canCapture,
                        onTap: cubit.captureBack,
                      ),
                      const SizedBox(height: 20),
                      const AddCardTipCard.info(
                        text:
                            'Fotoğraf net ve düz olmalı. Tüm bilgiler okunabilir ve ışık yansıması minimum düzeyde olmalıdır.',
                      ),
                      if (isProcessing) ...[
                        const SizedBox(height: 28),
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 12),
                        Text(
                          'Bilgiler okunuyor…',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              if (permissionGranted && !permissionChecking)
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

class _CameraPermissionBlocked extends StatelessWidget {
  const _CameraPermissionBlocked({
    required this.status,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final ScanCameraPermissionStatus status;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final permanentlyDenied =
        status == ScanCameraPermissionStatus.permanentlyDenied;

    return Column(
      children: [
        const Icon(
          Icons.photo_camera_outlined,
          size: 48,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Kamera izni gerekli',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          permanentlyDenied
              ? 'Kartvizit fotoğraflamak için ayarlardan kamera erişimine izin verin.'
              : 'Kartvizit fotoğraflamak için kamera erişimine izin vermeniz gerekiyor.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        if (permanentlyDenied)
          CustomButton(
            label: 'Ayarlara git',
            icon: Icons.settings_outlined,
            onPressed: onOpenSettings,
          )
        else
          CustomButton(
            label: 'İzin ver',
            icon: Icons.check_circle_outline,
            onPressed: onRetry,
          ),
        const SizedBox(height: 10),
        if (permanentlyDenied)
          CustomButton.tonal(
            label: 'Tekrar dene',
            onPressed: onRetry,
          ),
      ],
    );
  }
}
