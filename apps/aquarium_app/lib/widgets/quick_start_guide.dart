/// Quick Start Guide overlay - Shows contextual tips for new users
/// Appears after onboarding to guide first actions in the app
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class QuickStartGuide extends StatefulWidget {
  final Widget child;

  const QuickStartGuide({super.key, required this.child});

  @override
  State<QuickStartGuide> createState() => _QuickStartGuideState();
}

class _QuickStartGuideState extends State<QuickStartGuide> {
  OverlayEntry? _overlayEntry;
  int _currentStep = 0;
  bool _isGuideActive = false;

  final List<_GuideStep> _steps = [
    _GuideStep(
      title: 'Welcome to Your Tank! 🐠',
      description:
          'This is your home screen. Here you can see your tank health and quick actions.',
      targetKey: 'tank_card',
      position: _GuidePosition.bottom,
    ),
    _GuideStep(
      title: 'Log Water Parameters 💧',
      description:
          'Tap the + button to log water tests. Regular testing keeps your fish healthy!',
      targetKey: 'add_log_button',
      position: _GuidePosition.left,
    ),
    _GuideStep(
      title: 'Complete Tasks ✅',
      description:
          'Check your maintenance tasks here. Complete them to earn XP and keep your tank thriving!',
      targetKey: 'tasks_section',
      position: _GuidePosition.top,
    ),
    _GuideStep(
      title: 'Learn & Grow 📚',
      description:
          'Visit the Learning tab to complete lessons and unlock new features. You\'re all set!',
      targetKey: 'learning_tab',
      position: _GuidePosition.top,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkShouldShowGuide();
  }

  Future<void> _checkShouldShowGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenGuide = prefs.getBool('quick_start_guide_seen') ?? false;

    if (!hasSeenGuide && mounted) {
      // Delay to let UI settle
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showGuide();
      });
    }
  }

  void _showGuide() {
    setState(() {
      _isGuideActive = true;
      _currentStep = 0;
    });
    _showOverlay();
  }

  void _showOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    final step = _steps[_currentStep];

    return OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: GestureDetector(
          onTap: _nextStep,
          child: Stack(
            children: [
              // Dimmed background
              Positioned.fill(child: Container(color: Colors.black54)),

              // Guide tooltip
              _buildGuideTooltip(step),

              // Skip button
              Positioned(
                top: 50,
                right: 16,
                child: TextButton.icon(
                  onPressed: _dismissGuide,
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text(
                    'Skip Tutorial',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black38,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideTooltip(_GuideStep step) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 100,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (context, value, child) => Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(opacity: value, child: child),
        ),
        child: Card(
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
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentStep == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentStep == index
                            ? AppColors.accent
                            : Colors.grey[300],
                        borderRadius: AppRadius.xsRadius,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Title
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Description
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of ${_steps.length}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: _previousStep,
                            child: const Text('Back'),
                          ),
                        const SizedBox(width: AppSpacing.sm),
                        FilledButton.icon(
                          onPressed: _nextStep,
                          icon: Icon(
                            _currentStep == _steps.length - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                          ),
                          label: Text(
                            _currentStep == _steps.length - 1
                                ? 'Got it!'
                                : 'Next',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _showOverlay();
    } else {
      _dismissGuide();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _showOverlay();
    }
  }

  void _dismissGuide() async {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isGuideActive = false);

    // Mark as seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quick_start_guide_seen', true);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _GuideStep {
  final String title;
  final String description;
  final String targetKey;
  final _GuidePosition position;

  _GuideStep({
    required this.title,
    required this.description,
    required this.targetKey,
    required this.position,
  });
}

enum _GuidePosition { top, bottom, left, right }

/// Widget to mark guide targets
class GuideTarget extends StatelessWidget {
  final String targetKey;
  final Widget child;

  const GuideTarget({super.key, required this.targetKey, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Standalone Quick Start Tips Card (for home screen)
class QuickStartTipsCard extends StatelessWidget {
  const QuickStartTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.mediumRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: AppRadius.smallRadius,
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Quick Start Guide',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTipItem(
                icon: Icons.water_drop,
                text: 'Log your first water test to track trends',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildTipItem(
                icon: Icons.task_alt,
                text: 'Complete daily tasks to earn XP',
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildTipItem(
                icon: Icons.school,
                text: 'Start a learning path to unlock features',
                color: Colors.orange,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showFullGuide(context),
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: const Text('Show Tutorial'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: () => _dismissCard(context),
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Dismiss',
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  void _showFullGuide(BuildContext context) {
    // This would trigger the overlay guide
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tutorial overlay feature - integrate with QuickStartGuide widget',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _dismissCard(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quick_start_tips_card_dismissed', true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can always access help from Settings'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
