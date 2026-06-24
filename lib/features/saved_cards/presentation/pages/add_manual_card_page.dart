import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../onboarding/presentation/widgets/onboarding_flow_ui.dart';
import '../../data/datasources/physical_card_image_store.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/manual_saved_card_draft.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../add_manual_card_step_titles.dart';
import '../cubit/add_manual_card_cubit.dart';
import '../cubit/add_manual_card_state.dart';
import '../widgets/add_manual_card_steps/add_manual_card_step_name.dart';
import '../widgets/add_manual_card_steps/add_manual_card_step_optional.dart';
import '../widgets/add_manual_card_steps/add_manual_card_step_preview.dart';
import '../widgets/add_manual_card_steps/add_manual_card_step_professional.dart';

/// Elle girilen bilgilerle başkasının kartını cüzdana ekleme (adım adım).
class AddManualCardPage extends StatefulWidget {
  const AddManualCardPage({
    super.key,
    required this.addSavedCard,
    this.initialDraft,
  });

  final AddSavedCard addSavedCard;
  final ManualSavedCardDraft? initialDraft;

  @override
  State<AddManualCardPage> createState() => _AddManualCardPageState();
}

class _AddManualCardPageState extends State<AddManualCardPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(BuildContext context, int index) async {
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<AddManualCardCubit>().setPage(index);
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final cubit = context.read<AddManualCardCubit>();
    final result = await cubit.submit();
    if (!context.mounted || result == null) return;

    switch (result) {
      case AddSavedCardSuccess():
        Navigator.of(context).pop(result);
      case AddSavedCardDuplicate():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.buKartZatenCzdannzda),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case AddSavedCardLimitReached():
      case AddSavedCardPremiumRequired():
        Navigator.of(context).pop(result);
      case AddSavedCardInvalidPayload(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddManualCardCubit(
        addSavedCard: widget.addSavedCard,
        imageStore: PhysicalCardImageStore(),
        initialDraft: widget.initialDraft,
      ),
      child: _AddManualCardContent(
        pageController: _pageController,
        onGoToPage: (index) => _goToPage(context, index),
        onSubmit: () => _handleSubmit(context),
      ),
    );
  }
}

class _AddManualCardContent extends StatelessWidget {
  const _AddManualCardContent({
    required this.pageController,
    required this.onGoToPage,
    required this.onSubmit,
  });

  final PageController pageController;
  final Future<void> Function(int index) onGoToPage;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddManualCardCubit, AddManualCardState>(
      listenWhen: (a, b) => a.errorMessage != b.errorMessage,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      child: BlocBuilder<AddManualCardCubit, AddManualCardState>(
        buildWhen: (a, b) => a.currentPageIndex != b.currentPageIndex,
        builder: (context, flowState) {
          return PopScope(
            canPop: flowState.isFirstPage,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop || flowState.isFirstPage) return;
              onGoToPage(flowState.currentPageIndex - 1);
            },
            child: CardenceScaffold(
              resizeToAvoidBottomInset: false,
              appBar: CardenceAppBar(
                title: AddManualCardStepTitles.forIndex(context.l10n, 
                  flowState.currentPageIndex,
                ),
                leading: CardenceAppBar.flowBackButton(
                  context: context,
                  onPressed: () {
                    if (flowState.isFirstPage) {
                      Navigator.of(context).maybePop();
                      return;
                    }
                    onGoToPage(flowState.currentPageIndex - 1);
                  },
                ),
                automaticallyImplyLeading: false,
                actions: AddManualCardStepTitles.showsOptionalBadge(
                  flowState.currentPageIndex,
                )
                    ? const [
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Center(child: OnboardingOptionalBadge()),
                        ),
                      ]
                    : null,
              ),
              body: SafeArea(
                bottom: false,
                top: false,
                child: Column(
                  children: [
                    Expanded(
                      child: BlocBuilder<AddManualCardCubit, AddManualCardState>(
                        buildWhen: (a, b) =>
                            a.draft != b.draft ||
                            a.currentPageIndex != b.currentPageIndex,
                        builder: (context, state) {
                          return PageView.builder(
                            controller: pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            onPageChanged: (i) =>
                                context.read<AddManualCardCubit>().setPage(i),
                            itemCount: AddManualCardState.stepCount,
                            itemBuilder: (context, index) =>
                                _buildStep(context, state, index),
                          );
                        },
                      ),
                    ),
                    _AddManualCardBottomActions(
                      pageController: pageController,
                      onGoToPage: onGoToPage,
                      onSubmit: onSubmit,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    AddManualCardState state,
    int index,
  ) {
    final cubit = context.read<AddManualCardCubit>();
    final onChanged = cubit.updateDraft;

    switch (index) {
      case 0:
        return AddManualCardStepName(
          draft: state.draft,
          onChanged: onChanged,
        );
      case 1:
        return AddManualCardStepProfessional(
          draft: state.draft,
          onChanged: onChanged,
        );
      case 2:
        return AddManualCardStepOptional(
          draft: state.draft,
          onChanged: onChanged,
        );
      case 3:
        return AddManualCardStepPreview(
          draft: state.draft,
          onChanged: onChanged,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _AddManualCardBottomActions extends StatelessWidget {
  const _AddManualCardBottomActions({
    required this.pageController,
    required this.onGoToPage,
    required this.onSubmit,
  });

  final PageController pageController;
  final Future<void> Function(int index) onGoToPage;
  final Future<void> Function() onSubmit;

  void _showValidationSnackBar(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: colorScheme.onError,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddManualCardCubit, AddManualCardState>(
      buildWhen: (a, b) =>
          a.currentPageIndex != b.currentPageIndex ||
          a.isLastPage != b.isLastPage ||
          a.isSubmitting != b.isSubmitting ||
          a.draft != b.draft,
      builder: (context, state) {
        final isLastPage = state.isLastPage;
        final primaryLabel = isLastPage ? 'Kartı kaydet' : 'Devam →';

        return OnboardingBottomBar(
          stepCount: AddManualCardState.stepCount,
          currentIndex: state.currentPageIndex,
          primaryLabel: primaryLabel,
          isLoading: state.isSubmitting,
          enabled: state.canProceedCurrentStep(context.l10n),
          onStepSelected:
              state.isFirstPage ? null : (index) => onGoToPage(index),
          onPrimaryPressed: () async {
            if (isLastPage) {
              if (!state.canFinish(context.l10n)) {
                _showValidationSnackBar(
                  context,
                  context.l10n.ltfenZorunluAlanlarDoldurun,
                );
                return;
              }
              await onSubmit();
              return;
            }

            final error = state.validationErrorForCurrentStep(context.l10n);
            if (error != null) {
              _showValidationSnackBar(context, error);
              return;
            }

            context.read<AddManualCardCubit>().nextPage();
            await pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      },
    );
  }
}
