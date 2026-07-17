import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
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
    context.read<AddManualCardCubit>().setPage(index);
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final cubit = context.read<AddManualCardCubit>();
    final result = await cubit.submit();
    if (!context.mounted || result == null) return;

    switch (result) {
      case AddSavedCardSuccess():
        Navigator.of(context).pop(result);
      case AddSavedCardDuplicate():
      case AddSavedCardOwnCard():
      case AddSavedCardLimitReached():
      case AddSavedCardPremiumRequired():
        Navigator.of(context).pop(result);
      case AddSavedCardInvalidPayload():
        break;
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
      child: BlocListener<AddManualCardCubit, AddManualCardState>(
        listenWhen: (previous, current) =>
            previous.currentPageIndex != current.currentPageIndex,
        listener: (context, state) => _syncPageController(state.currentPageIndex),
        child: _AddManualCardContent(
          pageController: _pageController,
          onGoToPage: (index) => _goToPage(context, index),
          onSubmit: () => _handleSubmit(context),
        ),
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
  final void Function(int index) onGoToPage;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddManualCardCubit, AddManualCardState>(
      buildWhen: (a, b) => a.currentPageIndex != b.currentPageIndex,
      builder: (context, flowState) {
        return PopScope(
          canPop: flowState.isFirstPage,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop || flowState.isFirstPage) return;
            onGoToPage(flowState.currentPageIndex - 1);
          },
          child: CardenceScaffold(
            resizeToAvoidBottomInset: true,
            appBar: CardenceAppBar(
              title: AddManualCardStepTitles.forIndex(
                context.l10n,
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
                    child: PageView.builder(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: AddManualCardState.stepCount,
                      itemBuilder: (context, index) {
                        return _AddManualCardStepPage(index: index);
                      },
                    ),
                  ),
                  _AddManualCardBottomActions(
                    onGoToPage: onGoToPage,
                    onSubmit: onSubmit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddManualCardStepPage extends StatelessWidget {
  const _AddManualCardStepPage({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddManualCardCubit, AddManualCardState>(
      buildWhen: (previous, current) {
        if (previous.draft == current.draft) return false;
        return previous.currentPageIndex == index ||
            current.currentPageIndex == index;
      },
      builder: (context, state) {
        final cubit = context.read<AddManualCardCubit>();
        final onChanged = cubit.updateDraft;

        final step = switch (index) {
          0 => AddManualCardStepName(
              draft: state.draft,
              onChanged: onChanged,
            ),
          1 => AddManualCardStepProfessional(
              draft: state.draft,
              onChanged: onChanged,
            ),
          2 => AddManualCardStepOptional(
              draft: state.draft,
              onChanged: onChanged,
            ),
          3 => AddManualCardStepPreview(
              draft: state.draft,
              onChanged: onChanged,
            ),
          _ => const SizedBox.shrink(),
        };

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom + 8,
          ),
          child: step,
        );
      },
    );
  }
}

class _AddManualCardBottomActions extends StatelessWidget {
  const _AddManualCardBottomActions({
    required this.onGoToPage,
    required this.onSubmit,
  });

  final void Function(int index) onGoToPage;
  final Future<void> Function() onSubmit;

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
        final primaryLabel = isLastPage
            ? AppL10n.saveCard(context.l10n)
            : AppL10n.continueWithArrow(context.l10n);

        return OnboardingBottomBar(
          stepCount: AddManualCardState.stepCount,
          currentIndex: state.currentPageIndex,
          primaryLabel: primaryLabel,
          isLoading: state.isSubmitting,
          enabled: state.canProceedCurrentStep(context.l10n),
          showStepIndicator: false,
          onStepSelected:
              state.isFirstPage ? null : (index) => onGoToPage(index),
          onPrimaryPressed: () async {
            if (isLastPage) {
              if (!state.canFinish(context.l10n)) {
                return;
              }
              await onSubmit();
              return;
            }

            final error = state.validationErrorForCurrentStep(context.l10n);
            if (error != null) {
              return;
            }

            context.read<AddManualCardCubit>().nextPage();
          },
        );
      },
    );
  }
}
