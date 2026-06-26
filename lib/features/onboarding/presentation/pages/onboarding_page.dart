import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../../domain/usecases/resolve_onboarding_initial_draft.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../onboarding_draft_helper.dart';
import '../onboarding_step_titles.dart';
import '../widgets/onboarding_flow_ui.dart';
import '../widgets/onboarding_step_name.dart';
import '../widgets/onboarding_step_optional.dart';
import '../widgets/onboarding_step_photo.dart';
import '../widgets/onboarding_step_preview.dart';
import '../widgets/onboarding_step_professional.dart';

/// İlk açılışta adım adım kart oluşturma ile gösterilen onboarding ekranı.
class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({
    super.key,
    required this.completeOnboarding,
    required this.resolveInitialDraft,
    required this.persistOnboardingCard,
    required this.uploadProfilePhoto,
    required this.onFinish,
  });

  final Future<void> Function() completeOnboarding;
  final ResolveOnboardingInitialDraft resolveInitialDraft;
  final PersistOnboardingCard persistOnboardingCard;
  final UploadProfilePhoto uploadProfilePhoto;
  final VoidCallback onFinish;

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  late final Future<OnboardingCardDraft> _initialDraftFuture;

  @override
  void initState() {
    super.initState();
    _initialDraftFuture = widget.resolveInitialDraft();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OnboardingCardDraft>(
      future: _initialDraftFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CardenceScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocProvider(
          create: (_) => OnboardingCubit(
            completeOnboarding: widget.completeOnboarding,
            persistOnboardingCard: widget.persistOnboardingCard,
            initialDraft: snapshot.data,
          ),
          child: _OnboardingContent(
            onFinish: widget.onFinish,
            uploadProfilePhoto: widget.uploadProfilePhoto,
          ),
        );
      },
    );
  }
}

class _OnboardingContent extends StatefulWidget {
  const _OnboardingContent({
    required this.onFinish,
    required this.uploadProfilePhoto,
  });

  final VoidCallback onFinish;
  final UploadProfilePhoto uploadProfilePhoto;

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
              resizeToAvoidBottomInset: false,
              appBar: CardenceAppBar(
                title: OnboardingStepTitles.forIndex(context.l10n, flowState.currentPageIndex),
                leading: flowState.isFirstPage
                    ? null
                    : CardenceAppBar.flowBackButton(
                        context: context,
                        onPressed: () => _goToPage(
                          context,
                          flowState.currentPageIndex - 1,
                        ),
                      ),
                automaticallyImplyLeading: false,
                actions: OnboardingStepTitles.showsOptionalBadge(
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
                      child: BlocBuilder<OnboardingCubit, OnboardingState>(
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
                              return _buildStep(context, state, index);
                            },
                          );
                        },
                      ),
                    ),
                    _OnboardingBottomActions(
                      pageController: _pageController,
                      onFinish: widget.onFinish,
                      onGoToPage: (index) => _goToPage(context, index),
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
        return OnboardingStepName(
          draft: state.draft,
          stepIndex: stepIndex,
          stepCount: stepCount,
          onChanged: (d) => context.read<OnboardingCubit>().updateDraft(d),
        );
      case 1:
        return OnboardingStepProfessional(
          draft: state.draft,
          stepIndex: stepIndex,
          stepCount: stepCount,
          onChanged: (d) => context.read<OnboardingCubit>().updateDraft(d),
        );
      case 2:
        return OnboardingStepPhoto(
          draft: state.draft,
          stepIndex: stepIndex,
          stepCount: stepCount,
          uploadProfilePhoto: widget.uploadProfilePhoto,
          onChanged: (d) => context.read<OnboardingCubit>().updateDraft(d),
        );
      case 3:
        return OnboardingStepOptional(
          draft: state.draft,
          stepIndex: stepIndex,
          stepCount: stepCount,
          onChanged: (d) => context.read<OnboardingCubit>().updateDraft(d),
        );
      case 4:
        return OnboardingStepPreview(
          draft: OnboardingDraftHelper.forPreview(state.draft),
          stepIndex: stepIndex,
          stepCount: stepCount,
          onChanged: (d) => context.read<OnboardingCubit>().updateDraft(d),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _goToPage(BuildContext context, int index) async {
    FocusManager.instance.primaryFocus?.unfocus();
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
    required this.onGoToPage,
  });

  final PageController pageController;
  final VoidCallback onFinish;
  final Future<void> Function(int index) onGoToPage;

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
          a.draft != b.draft,
      builder: (context, state) {
        final isLastPage = state.isLastPage;
        final isSaving = state.isSaving;

        final primaryLabel = isLastPage
            ? AppL10n.createMyCard(context.l10n)
            : AppL10n.continueWithArrow(context.l10n);

        return OnboardingBottomBar(
          stepCount: OnboardingState.stepCount,
          currentIndex: state.currentPageIndex,
          primaryLabel: primaryLabel,
          isLoading: isSaving,
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
              final completed =
                  await context.read<OnboardingCubit>().finishOnboarding();
              if (context.mounted && completed) onFinish();
              return;
            }

            final error = state.validationErrorForCurrentStep(context.l10n);
            if (error != null) {
              _showValidationSnackBar(context, error);
              return;
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
