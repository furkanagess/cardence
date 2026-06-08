import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../business_cards/domain/usecases/save_business_card.dart';
import '../../domain/usecases/save_onboarding_draft_card.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../onboarding_draft_helper.dart';
import '../widgets/onboarding_flow_ui.dart';
import '../widgets/onboarding_step_contact.dart';
import '../widgets/onboarding_step_name.dart';
import '../widgets/onboarding_step_optional.dart';
import '../widgets/onboarding_step_preview.dart';
import '../widgets/onboarding_step_professional.dart';
import '../widgets/onboarding_step_welcome.dart';

/// İlk açılışta adım adım kart oluşturma ile gösterilen onboarding ekranı.
class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({
    super.key,
    required this.completeOnboarding,
    required this.saveOnboardingDraftCard,
    required this.saveBusinessCard,
    required this.onFinish,
  });

  final Future<void> Function() completeOnboarding;
  final SaveOnboardingDraftCard saveOnboardingDraftCard;
  final SaveBusinessCard saveBusinessCard;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(
        completeOnboarding: completeOnboarding,
        saveOnboardingDraftCard: saveOnboardingDraftCard,
        saveBusinessCard: saveBusinessCard,
      ),
      child: _OnboardingContent(onFinish: onFinish),
    );
  }
}

class _OnboardingContent extends StatefulWidget {
  const _OnboardingContent({required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<_OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<_OnboardingContent> {
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (prev, curr) =>
          curr.errorMessage != null && prev.errorMessage != curr.errorMessage,
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
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (a, b) => a.currentPageIndex != b.currentPageIndex,
      builder: (context, flowState) {
        return PopScope(
          canPop: flowState.isFirstPage,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop || flowState.isFirstPage) return;
            _goToPage(context, flowState.currentPageIndex - 1);
          },
          child: CardenceScaffold(
            body: SafeArea(
              bottom: false,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BlocBuilder<OnboardingCubit, OnboardingState>(
                    buildWhen: (a, b) =>
                        a.draft != b.draft ||
                        a.currentPageIndex != b.currentPageIndex,
                    builder: (context, state) {
                      return PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (i) =>
                            context.read<OnboardingCubit>().setPage(i),
                        itemCount: OnboardingState.stepCount,
                        itemBuilder: (context, index) {
                          final isWelcome = index == 0;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: OnboardingBottomBar.contentBottomInset(
                                context,
                                showStepIndicator: !isWelcome,
                              ),
                            ),
                            child: _buildStep(context, state, index),
                          );
                        },
                      );
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _OnboardingBottomActions(
                      pageController: _pageController,
                      onFinish: widget.onFinish,
                    ),
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
    OnboardingState state,
    int index,
  ) {
    final stepIndex = index + 1;
    final stepCount = OnboardingState.stepCount;

    switch (index) {
      case 0:
        return const OnboardingStepWelcome();
      case 1:
        return OnboardingStepName(
          draft: state.draft,
          stepIndex: stepIndex,
          stepCount: stepCount,
          onChanged: (d) => context.read<OnboardingCubit>().updateDraft(d),
        );
      case 2:
        return OnboardingStepProfessional(
          draft: state.draft,
          stepIndex: stepIndex,
          stepCount: stepCount,
          onChanged: (d) => context.read<OnboardingCubit>().updateDraft(d),
        );
      case 3:
        return OnboardingStepContact(
          draft: state.draft,
          stepIndex: stepIndex,
          stepCount: stepCount,
          onChanged: (d) => context.read<OnboardingCubit>().updateDraft(d),
        );
      case 4:
        return OnboardingStepOptional(
          draft: state.draft,
          stepIndex: stepIndex,
          stepCount: stepCount,
          onChanged: (d) => context.read<OnboardingCubit>().updateDraft(d),
        );
      case 5:
        return OnboardingStepPreview(
          draft: OnboardingDraftHelper.forPreview(state.draft),
          stepIndex: stepIndex,
          stepCount: stepCount,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _goToPage(BuildContext context, int index) async {
    context.read<OnboardingCubit>().setPage(index);
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

}

class _OnboardingBottomActions extends StatelessWidget {
  const _OnboardingBottomActions({
    required this.pageController,
    required this.onFinish,
  });

  final PageController pageController;
  final VoidCallback onFinish;

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
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (a, b) =>
          a.currentPageIndex != b.currentPageIndex ||
          a.isLastPage != b.isLastPage ||
          a.isSaving != b.isSaving ||
          a.canFinish != b.canFinish ||
          a.canProceedCurrentStep != b.canProceedCurrentStep ||
          a.draft != b.draft,
      builder: (context, state) {
        final isLastPage = state.isLastPage;
        final isSaving = state.isSaving;
        final isWelcome = state.isFirstPage;
        final isFormStep = !isWelcome;

        final primaryLabel = isLastPage
            ? 'Kartımı oluştur'
            : isWelcome
                ? 'Başla'
                : 'Devam';

        return OnboardingBottomBar(
          stepCount: OnboardingState.stepCount,
          currentIndex: state.currentPageIndex,
          primaryLabel: primaryLabel,
          isLoading: isSaving,
          enabled: state.canProceedCurrentStep,
          showStepIndicator: isFormStep,
          onPrimaryPressed: () async {
            if (isLastPage) {
              if (!state.canFinish) {
                _showValidationSnackBar(
                  context,
                  'Lütfen zorunlu alanları doldurun.',
                );
                return;
              }
              final completed =
                  await context.read<OnboardingCubit>().finishOnboarding();
              if (context.mounted && completed) onFinish();
              return;
            }

            if (!isWelcome) {
              final error = state.validationErrorForCurrentStep;
              if (error != null) {
                _showValidationSnackBar(context, error);
                return;
              }
            }

            context.read<OnboardingCubit>().nextPage();
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
