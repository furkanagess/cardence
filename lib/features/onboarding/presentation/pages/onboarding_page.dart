import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/l10n/locale_preference_material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../../auth/domain/usecases/upload_profile_photo.dart';
import '../../../saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../../domain/usecases/resolve_onboarding_initial_draft.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../onboarding_draft_helper.dart';
import '../widgets/onboarding_flow_ui.dart';
import '../widgets/onboarding_step_header.dart';
import '../widgets/onboarding_step_name.dart';
import '../widgets/onboarding_step_optional.dart';
import '../widgets/onboarding_step_photo.dart';
import '../widgets/onboarding_step_preview.dart';
import '../widgets/onboarding_step_professional.dart';
import '../../../my_cards/presentation/helpers/card_effect_premium_helper.dart';
import 'card_created_share_page.dart';

/// İlk açılışta veya ek kart oluştururken adım adım kart onboarding ekranı.
class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({
    super.key,
    this.completeOnboarding,
    this.resolveInitialDraft,
    this.initialDraft,
    required this.persistOnboardingCard,
    required this.uploadProfilePhoto,
    required this.upgradeWalletPlan,
    required this.onFinish,
  }) : assert(
          initialDraft != null || resolveInitialDraft != null,
          'initialDraft veya resolveInitialDraft gerekli',
        );

  final Future<void> Function()? completeOnboarding;
  final ResolveOnboardingInitialDraft? resolveInitialDraft;
  final OnboardingCardDraft? initialDraft;
  final PersistOnboardingCard persistOnboardingCard;
  final UploadProfilePhoto uploadProfilePhoto;
  final UpgradeWalletPlan upgradeWalletPlan;
  final ValueChanged<OnboardingCardDraft> onFinish;

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  late final Future<OnboardingCardDraft> _initialDraftFuture;

  @override
  void initState() {
    super.initState();
    final seedDraft = widget.initialDraft;
    _initialDraftFuture = seedDraft != null
        ? Future.value(seedDraft)
        : widget.resolveInitialDraft!();
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
            upgradeWalletPlan: widget.upgradeWalletPlan,
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
    required this.upgradeWalletPlan,
  });

  final ValueChanged<OnboardingCardDraft> onFinish;
  final UploadProfilePhoto uploadProfilePhoto;
  final UpgradeWalletPlan upgradeWalletPlan;

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
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (previous, current) =>
          previous.currentPageIndex != current.currentPageIndex,
      builder: (context, flowState) {
        return PopScope(
          canPop: flowState.isFirstPage,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop || flowState.isFirstPage) return;
            _goToPage(context, flowState.currentPageIndex - 1);
          },
          child: BlocListener<OnboardingCubit, OnboardingState>(
            listenWhen: (previous, current) =>
                previous.currentPageIndex != current.currentPageIndex,
            listener: (context, state) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _syncPageController(state.currentPageIndex);
              });
            },
            child: CardenceScaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    OnboardingStepHeader(
                      currentIndex: flowState.currentPageIndex,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: OnboardingState.stepCount,
                        itemBuilder: (context, index) {
                          return _OnboardingStepPage(
                            index: index,
                            uploadProfilePhoto: widget.uploadProfilePhoto,
                            upgradeWalletPlan: widget.upgradeWalletPlan,
                          );
                        },
                      ),
                    ),
                    _OnboardingKeyboardAwareBottom(
                      child: _OnboardingBottomActions(
                        onFinish: widget.onFinish,
                        upgradeWalletPlan: widget.upgradeWalletPlan,
                        onGoToPage: (index) => _goToPage(context, index),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _syncPageController(int index) {
    if (!_pageController.hasClients) return;
    final current = _pageController.page?.round();
    if (current == index) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPage(BuildContext context, int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<OnboardingCubit>().setPage(index);
  }
}

class _OnboardingKeyboardAwareBottom extends StatelessWidget {
  const _OnboardingKeyboardAwareBottom({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: child,
    );
  }
}

class _OnboardingStepPage extends StatelessWidget {
  const _OnboardingStepPage({
    required this.index,
    required this.uploadProfilePhoto,
    required this.upgradeWalletPlan,
  });

  final int index;
  final UploadProfilePhoto uploadProfilePhoto;
  final UpgradeWalletPlan upgradeWalletPlan;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (previous, current) {
        if (previous.draft == current.draft) return false;
        return previous.currentPageIndex == index ||
            current.currentPageIndex == index;
      },
      builder: (context, state) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildOnboardingStep(
            context: context,
            state: state,
            index: index,
            uploadProfilePhoto: uploadProfilePhoto,
            upgradeWalletPlan: upgradeWalletPlan,
          ),
        );
      },
    );
  }
}

Widget _buildOnboardingStep({
  required BuildContext context,
  required OnboardingState state,
  required int index,
  required UploadProfilePhoto uploadProfilePhoto,
  required UpgradeWalletPlan upgradeWalletPlan,
}) {
  final stepIndex = index + 1;
  final stepCount = OnboardingState.stepCount;
  final onChanged = context.read<OnboardingCubit>().updateDraft;

  switch (index) {
    case 0:
      return OnboardingStepName(
        draft: state.draft,
        stepIndex: stepIndex,
        stepCount: stepCount,
        onChanged: context.read<OnboardingCubit>().updateDraftImmediate,
      );
    case 1:
      return OnboardingStepProfessional(
        draft: state.draft,
        stepIndex: stepIndex,
        stepCount: stepCount,
        onChanged: context.read<OnboardingCubit>().updateDraftImmediate,
      );
    case 2:
      return OnboardingStepPhoto(
        draft: state.draft,
        stepIndex: stepIndex,
        stepCount: stepCount,
        uploadProfilePhoto: uploadProfilePhoto,
        onChanged: onChanged,
      );
    case 3:
      return OnboardingStepOptional(
        draft: state.draft,
        stepIndex: stepIndex,
        stepCount: stepCount,
        onChanged: onChanged,
      );
    case 4:
      return OnboardingStepPreview(
        draft: OnboardingDraftHelper.forPreview(state.draft),
        stepIndex: stepIndex,
        stepCount: stepCount,
        upgradeWalletPlan: upgradeWalletPlan,
      );
    default:
      return const SizedBox.shrink();
  }
}

class _OnboardingBottomActions extends StatelessWidget {
  const _OnboardingBottomActions({
    required this.onFinish,
    required this.upgradeWalletPlan,
    required this.onGoToPage,
  });

  final ValueChanged<OnboardingCardDraft> onFinish;
  final UpgradeWalletPlan upgradeWalletPlan;
  final void Function(int index) onGoToPage;

  @override
  Widget build(BuildContext context) {
    return CardEffectPremiumHelper.build(
      builder: (context, isPremium) {
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
                : context.l10n.devam;

            return OnboardingBottomBar(
              stepCount: OnboardingState.stepCount,
              currentIndex: state.currentPageIndex,
              primaryLabel: primaryLabel,
              isLoading: isSaving,
              enabled: state.canProceedCurrentStep(
                context.l10n,
                isPremium: isPremium,
              ),
              showStepIndicator: false,
              onStepSelected:
                  state.isFirstPage ? null : (index) => onGoToPage(index),
              onBackPressed: state.isFirstPage
                  ? null
                  : () => onGoToPage(state.currentPageIndex - 1),
              backLabel: context.l10n.geri,
              onPrimaryPressed: () async {
                if (isLastPage) {
                  if (!state.canFinish(
                    context.l10n,
                    isPremium: isPremium,
                  )) {
                    return;
                  }
                  final cubit = context.read<OnboardingCubit>();
                  final resolved = await prepareCardDraftForPersist(
                    context,
                    cubit.state.draft,
                    onRequestPremium: () => upgradeWalletPlan(
                      preferredLocale: revenueCatPreferredLocaleFrom(
                        Localizations.localeOf(context),
                      ),
                    ),
                  );
                  if (!context.mounted || resolved == null) return;
                  if (resolved.cardEffect != cubit.state.draft.cardEffect) {
                    cubit.updateDraft(resolved);
                  }
                  final synced = await cubit.finishOnboarding();
                  if (!context.mounted || synced == null) return;
                  await CardCreatedSharePage.open(context, draft: synced);
                  if (context.mounted) onFinish(synced);
                  return;
                }

                final error =
                    state.validationErrorForCurrentStep(context.l10n);
                if (error != null) {
                  return;
                }

                FocusManager.instance.primaryFocus?.unfocus();
                context.read<OnboardingCubit>().nextPage();
              },
            );
          },
        );
      },
    );
  }
}
