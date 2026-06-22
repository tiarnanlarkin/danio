import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

const double kOnboardingMaxContentWidth = 720;

class OnboardingContentFrame extends StatelessWidget {
  const OnboardingContentFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    this.alignment = Alignment.center,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: kOnboardingMaxContentWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}
