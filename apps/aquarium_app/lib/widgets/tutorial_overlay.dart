/// First-launch tutorial overlay with coach marks
/// Shows new users key features of the app
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';

/// Tutorial step configuration
class TutorialStep {
  final String title;
  final String description;
  final GlobalKey targetKey;
  final Alignment targetAlignment;
  final Alignment tooltipAlignment;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.targetKey,
    this.targetAlignment = Alignment.center,
    this.tooltipAlignment = Alignment.bottomCenter,
  });
}

/// Tutorial overlay widget that highlights UI elements with explanations
class TutorialOverlay extends ConsumerStatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  @override
  ConsumerState<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends ConsumerState<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _completeTutorial();
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  Future<void> _completeTutorial() async {
    // Mark tutorial as seen in user profile
    final profile = ref.read(userProfileProvider).value;
    if (profile != null) {
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(hasSeenTutorial: true);
    }

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];

    // Get target widget position
    RenderBox? renderBox;
    Offset? targetPosition;
    Size? targetSize;

    try {
      renderBox =
          step.targetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        targetPosition = renderBox.localToGlobal(Offset.zero);
        targetSize = renderBox.size;
      }
    } catch (e) {
      // Target not found, show centered tooltip
    }

    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: _nextStep, // Tap anywhere to continue
        child: Stack(
          children: [
            // Highlight circle around target (if found)
            if (targetPosition != null && targetSize != null)
              Positioned(
                left: targetPosition.dx - 8,
                top: targetPosition.dy - 8,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: targetSize.width + 16,
                    height: targetSize.height + 16,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      borderRadius: AppRadius.mediumRadius,
                      boxShadow: [
                        BoxShadow(
                          color: AppOverlays.white30,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Cutout for target (make it visible)
            if (targetPosition != null && targetSize != null)
              Positioned(
                left: targetPosition.dx,
                top: targetPosition.dy,
                child: IgnorePointer(
                  child: Container(
                    width: targetSize.width,
                    height: targetSize.height,
                    color: Colors.transparent,
                  ),
                ),
              ),

            // Tooltip
            _buildTooltip(step, targetPosition, targetSize),

            // Navigation controls
            Positioned(left: 0, right: 0, bottom: 40, child: _buildControls()),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip(
    TutorialStep step,
    Offset? targetPosition,
    Size? targetSize,
  ) {
    // Calculate tooltip position
    double? top;
    double? bottom;
    double left = 16;
    double right = 16;

    if (targetPosition != null && targetSize != null) {
      final screenHeight = MediaQuery.of(context).size.height;
      final targetBottom = targetPosition.dy + targetSize.height;

      // Position tooltip below target if there's room, otherwise above
      if (targetBottom + 200 < screenHeight) {
        top = targetBottom + 20;
      } else {
        bottom = screenHeight - targetPosition.dy + 20;
      }
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mediumRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppOverlays.accent10,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Text(
                        'Tip ${_currentStep + 1}/${widget.steps.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Description
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Skip button
            TextButton(
              onPressed: _skipTutorial,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Skip Tutorial'),
            ),

            // Progress dots
            Row(
              children: List.generate(
                widget.steps.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentStep
                        ? Colors.white
                        : AppOverlays.white30,
                  ),
                ),
              ),
            ),

            // Next/Done button
            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.largeRadius,
                ),
              ),
              child: Text(
                _currentStep == widget.steps.length - 1 ? 'Got it!' : 'Next',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show tutorial overlay
void showTutorialOverlay(
  BuildContext context, {
  required List<TutorialStep> steps,
  required VoidCallback onComplete,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) => TutorialOverlay(
      steps: steps,
      onComplete: () {
        Navigator.of(context).pop();
        onComplete();
      },
    ),
  );
}
