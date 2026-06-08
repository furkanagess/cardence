import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/organisms/cardence_connect_animation.dart';

class OnboardingStepWelcome extends StatefulWidget {
  const OnboardingStepWelcome({super.key});

  @override
  State<OnboardingStepWelcome> createState() => _OnboardingStepWelcomeState();
}

class _OnboardingStepWelcomeState extends State<OnboardingStepWelcome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textController;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textFade = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    );
    Future<void>.delayed(const Duration(milliseconds: 480), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final animationSize = math.min(
            constraints.maxWidth,
            constraints.maxHeight * 0.72,
          ).clamp(200.0, 300.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CardenceConnectAnimation(size: animationSize),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(_textFade),
                  child: Column(
                    children: [
                      Text(
                        AppConstants.appName,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.appTagline,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kartınızı oluşturun, paylaşın ve ağınızı genişletin.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
