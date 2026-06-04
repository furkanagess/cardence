import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/usecases/save_onboarding_draft_card.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_step_contact.dart';
import '../widgets/onboarding_step_name.dart';
import '../widgets/onboarding_step_preview.dart';
import '../widgets/onboarding_step_professional.dart';
import '../widgets/onboarding_step_social.dart';
import '../widgets/onboarding_step_visible_fields.dart';
import '../widgets/onboarding_step_welcome.dart';

/// İlk açılışta adım adım kart oluşturma ile gösterilen onboarding ekranı.
class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({
    super.key,
    required this.completeOnboarding,
    required this.saveOnboardingDraftCard,
    required this.onFinish,
  });

  final CompleteOnboarding completeOnboarding;
  final SaveOnboardingDraftCard saveOnboardingDraftCard;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(
        completeOnboarding: completeOnboarding,
        saveOnboardingDraftCard: saveOnboardingDraftCard,
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
    final colorScheme = Theme.of(context).colorScheme;
    return CardenceScaffold(
      backgroundColor: colorScheme.surface,
      appBar: CardenceAppBar(
        variant: CardenceAppBarVariant.flow,
        leading: BlocBuilder<OnboardingCubit, OnboardingState>(
          buildWhen: (a, b) => a.currentPageIndex != b.currentPageIndex,
          builder: (context, state) {
            return AnimatedOpacity(
              opacity: state.isFirstPage ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: CardenceAppBar.flowBackButton(
                onPressed: state.isFirstPage
                    ? null
                    : () => _goToPage(context, state.currentPageIndex - 1),
              ),
            );
          },
        ),
        actions: [
          CardenceAppBar.flowTextAction(
            label: 'Atla',
            onPressed: () => _skipOnboarding(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
                buildWhen: (a, b) => a.currentPageIndex != b.currentPageIndex,
                builder: (context, state) {
                  return PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) =>
                        context.read<OnboardingCubit>().setPage(i),
                    itemCount: state.stepCount,
                    itemBuilder: (context, index) {
                      return BlocBuilder<OnboardingCubit, OnboardingState>(
                        buildWhen: (a, b) =>
                            a.draft != b.draft ||
                            a.currentPageIndex != b.currentPageIndex,
                        builder: (ctx, s) => _buildStep(ctx, s, index),
                      );
                    },
                  );
                },
              ),
            ),
            _PageIndicatorAndButtons(
              pageController: _pageController,
              onFinish: widget.onFinish,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    OnboardingState state,
    int index,
  ) {
    switch (index) {
      case 0:
        return const OnboardingStepWelcome();
      case 1:
        return OnboardingStepName(
          draft: state.draft,
          onChanged: (d) =>
              context.read<OnboardingCubit>().updateDraft(d),
        );
      case 2:
        return OnboardingStepContact(
          draft: state.draft,
          onChanged: (d) =>
              context.read<OnboardingCubit>().updateDraft(d),
        );
      case 3:
        return OnboardingStepProfessional(
          draft: state.draft,
          onChanged: (d) =>
              context.read<OnboardingCubit>().updateDraft(d),
        );
      case 4:
        return OnboardingStepSocial(
          draft: state.draft,
          onChanged: (d) =>
              context.read<OnboardingCubit>().updateDraft(d),
        );
      case 5:
        return OnboardingStepVisibleFields(
          draft: state.draft,
          onChanged: (d) =>
              context.read<OnboardingCubit>().updateDraft(d),
        );
      case 6:
        return OnboardingStepPreview(draft: state.draft);
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

  Future<void> _skipOnboarding(BuildContext context) async {
    await context.read<OnboardingCubit>().skipOnboarding();
    if (context.mounted) widget.onFinish();
  }
}

class _PageIndicatorAndButtons extends StatelessWidget {
  const _PageIndicatorAndButtons({
    required this.pageController,
    required this.onFinish,
  });

  final PageController pageController;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<OnboardingCubit, OnboardingState>(
            buildWhen: (a, b) => a.currentPageIndex != b.currentPageIndex,
            builder: (context, state) {
              final stepCount = state.stepCount;
              final index = state.currentPageIndex;
              final primary = Theme.of(context).colorScheme.primary;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  stepCount,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == i
                          ? primary
                          : primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          BlocBuilder<OnboardingCubit, OnboardingState>(
            buildWhen: (a, b) =>
                a.currentPageIndex != b.currentPageIndex ||
                a.isLastPage != b.isLastPage ||
                a.isSaving != b.isSaving,
            builder: (context, state) {
              final isLastPage = state.isLastPage;
              final isSaving = state.isSaving;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (isLastPage) {
                            await context
                                .read<OnboardingCubit>()
                                .finishOnboarding();
                            if (context.mounted) onFinish();
                          } else {
                            final draft = state.draft;
                            final onNameStep = state.currentPageIndex == 1;
                            if (onNameStep &&
                                (draft.displayName == null ||
                                    draft.displayName!.trim().isEmpty)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Ad zorunludur')),
                              );
                              return;
                            }
                            context.read<OnboardingCubit>().nextPage();
                            await pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isLastPage ? 'Kartımı oluştur' : 'İleri',
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
