import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../data/datasources/camera_permission_datasource.dart';
import '../../data/datasources/physical_card_ocr_datasource.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../cubit/scan_physical_card_cubit.dart';
import '../cubit/scan_physical_card_state.dart';
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
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final cubit = context.read<ScanPhysicalCardCubit>();
        final isProcessing = state.step == ScanPhysicalCardStep.processing;
        final permissionGranted =
            state.cameraPermission == ScanCameraPermissionStatus.granted;
        final permissionChecking =
            state.cameraPermission == ScanCameraPermissionStatus.checking;

        return CardenceScaffold(
          appBar: const CardenceAppBar(title: 'Kartvizit fotoğrafla'),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              if (permissionChecking) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamera izni isteniyor…',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else if (!permissionGranted) ...[
                _CameraPermissionBlocked(
                  status: state.cameraPermission,
                  onRetry: cubit.requestCameraPermission,
                  onOpenSettings: cubit.openCameraSettings,
                ),
              ] else ...[
                Text(
                  _stepTitle(state.step),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _stepSubtitle(state.step),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _CaptureProgress(
                  hasFront: state.frontImagePath != null,
                  hasBack: state.backImagePath != null,
                ),
                if (state.frontImagePath != null) ...[
                  const SizedBox(height: 16),
                  _CapturedPreview(
                    label: 'Ön yüz',
                    path: state.frontImagePath!,
                  ),
                ],
                if (state.backImagePath != null) ...[
                  const SizedBox(height: 12),
                  _CapturedPreview(
                    label: 'Arka yüz (opsiyonel)',
                    path: state.backImagePath!,
                  ),
                ],
                const SizedBox(height: 24),
                if (isProcessing)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.step == ScanPhysicalCardStep.front)
                  CustomButton(
                    label: 'Ön yüzü çek',
                    icon: Icons.photo_camera_outlined,
                    onPressed: state.canCapture ? cubit.captureFront : null,
                    isLoading: state.isBusy,
                  )
                else ...[
                  CustomButton(
                    label: 'Devam et',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: state.canCapture ? cubit.finishScan : null,
                    isLoading: state.isBusy,
                  ),
                  const SizedBox(height: 10),
                  CustomButton.tonal(
                    label: state.backImagePath == null
                        ? 'Arka yüzü çek (opsiyonel)'
                        : 'Arka yüzü yeniden çek',
                    icon: Icons.flip_camera_ios_outlined,
                    onPressed: state.canCapture ? cubit.captureBack : null,
                  ),
                  const SizedBox(height: 10),
                  CustomButton.tonal(
                    label: 'Ön yüzü yeniden çek',
                    onPressed: state.canCapture ? cubit.retakeFront : null,
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  String _stepTitle(ScanPhysicalCardStep step) {
    switch (step) {
      case ScanPhysicalCardStep.front:
        return 'Ön yüzü çekin';
      case ScanPhysicalCardStep.back:
        return 'Arka yüz opsiyonel';
      case ScanPhysicalCardStep.processing:
        return 'Bilgiler okunuyor';
    }
  }

  String _stepSubtitle(ScanPhysicalCardStep step) {
    switch (step) {
      case ScanPhysicalCardStep.front:
        return 'Kartviziti düz bir zeminde, iyi ışıkta tutun ve ön yüzünü fotoğraflayın.';
      case ScanPhysicalCardStep.back:
        return 'Arka yüzü çekmek zorunlu değil. Hazırsanız doğrudan devam edebilirsiniz.';
      case ScanPhysicalCardStep.processing:
        return 'Metin tanıma çalışıyor; ardından bilgileri onaylayabilirsiniz.';
    }
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final permanentlyDenied =
        status == ScanCameraPermissionStatus.permanentlyDenied;

    return Column(
      children: [
        Icon(
          Icons.photo_camera_outlined,
          size: 48,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Kamera izni gerekli',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          permanentlyDenied
              ? 'Kartvizit fotoğraflamak için ayarlardan kamera erişimine izin verin.'
              : 'Kartvizit fotoğraflamak için kamera erişimine izin vermeniz gerekiyor.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
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

class _CaptureProgress extends StatelessWidget {
  const _CaptureProgress({
    required this.hasFront,
    required this.hasBack,
  });

  final bool hasFront;
  final bool hasBack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _StepDot(
          label: '1',
          title: 'Ön',
          active: true,
          done: hasFront,
          colorScheme: colorScheme,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: hasFront
                ? colorScheme.primary.withValues(alpha: 0.4)
                : colorScheme.surfaceContainerHighest,
          ),
        ),
        _StepDot(
          label: '2',
          title: 'Arka',
          subtitle: 'Opsiyonel',
          active: hasFront,
          done: hasBack,
          optional: true,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.label,
    required this.title,
    required this.active,
    required this.done,
    required this.colorScheme,
    this.subtitle,
    this.optional = false,
  });

  final String label;
  final String title;
  final String? subtitle;
  final bool active;
  final bool done;
  final bool optional;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final bg = done
        ? colorScheme.primary
        : active
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest;
    final fg = done
        ? colorScheme.onPrimary
        : active
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant;

    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: bg,
          child: done
              ? Icon(Icons.check_rounded, size: 18, color: fg)
              : Text(
                  label,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
        ),
        if (optional && subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
          ),
      ],
    );
  }
}

class _CapturedPreview extends StatelessWidget {
  const _CapturedPreview({required this.label, required this.path});

  final String label;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 1.6,
            child: Image.file(File(path), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}
