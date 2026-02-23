/// Enhanced interactive tutorial walkthrough with animations and demo tank option
/// Final step of onboarding flow before entering the main app
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../models/models.dart';
import '../../providers/tank_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/onboarding_service.dart';
import '../tab_navigator.dart';

class EnhancedTutorialWalkthroughScreen extends ConsumerStatefulWidget {
  const EnhancedTutorialWalkthroughScreen({super.key});

  @override
  ConsumerState<EnhancedTutorialWalkthroughScreen> createState() =>
      _EnhancedTutorialWalkthroughScreenState();
}

class _EnhancedTutorialWalkthroughScreenState
    extends ConsumerState<EnhancedTutorialWalkthroughScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;

  // Tank creation form state
  final _formKey = GlobalKey<FormState>();
  String _tankName = '';
  TankType _tankType = TankType.freshwater;
  double _volumeLitres = 0;
  String _waterType = 'tropical';
  bool _useDemoData = false;

  final List<_TutorialStep> _steps = const [
    _TutorialStep(
      icon: Icons.waves,
      title: 'Welcome to Your Aquarium Journey! 🎉',
      description:
          'You\'ve completed the assessment! Now let\'s set up your first virtual tank to track your real aquarium.',
      emoji: '🐠',
      color: AppColors.primary,
    ),
    _TutorialStep(
      icon: Icons.water_drop,
      title: 'Track Everything in One Place',
      description:
          'Log water parameters, track fish health, set maintenance reminders, and watch your knowledge grow as you learn.',
      emoji: '📊',
      color: AppColors.secondary,
    ),
    _TutorialStep(
      icon: Icons.tips_and_updates,
      title: 'Learn as You Go',
      description:
          'Complete lessons to unlock equipment, earn XP, and discover new species. The app gamifies aquarium keeping!',
      emoji: '⭐',
      color: AppColors.accent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: AppCurves.standardAccelerate),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: AppCurves.standardDecelerate),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: AppDurations.long1,
        curve: AppCurves.standard,
      );
      // Trigger animation for next page
      _animationController.reset();
      _animationController.forward();
    } else {
      // Move to tank creation form
      setState(() => _currentStep = _steps.length);
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0 && _currentStep < _steps.length) {
      _pageController.previousPage(
        duration: AppDurations.long1,
        curve: AppCurves.standard,
      );
    } else if (_currentStep == _steps.length) {
      setState(() => _currentStep = _steps.length - 1);
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _skipTutorial() async {
    // Mark onboarding as complete
    final service = await OnboardingService.getInstance();
    await service.completeOnboarding();
    
    if (!mounted) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TabNavigator()),
      (route) => false,
    );
  }

  Future<void> _createFirstTank() async {
    if (!_formKey.currentState!.validate() && !_useDemoData) return;

    // Trigger confetti celebration
    _confettiController.play();

    try {
      final actions = ref.read(tankActionsProvider);
      final targets = _waterType == 'tropical'
          ? WaterTargets.freshwaterTropical()
          : WaterTargets.freshwaterColdwater();

      // Use demo data if selected
      final tankName = _useDemoData ? 'Demo Community Tank' : _tankName.trim();
      final volume = _useDemoData ? 60.0 : _volumeLitres;

      await actions.createTank(
        name: tankName,
        type: _tankType,
        volumeLitres: volume,
        startDate: DateTime.now(),
        targets: targets,
      );

      if (!mounted) return;

      // Show success with animation
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _SuccessDialog(tankName: tankName),
      );

      if (!mounted) return;

      // Mark onboarding as complete
      final service = await OnboardingService.getInstance();
      await service.completeOnboarding();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TabNavigator()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating tank: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Getting Started'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skipTutorial,
            child: const Text(
              'Skip',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _currentStep < _steps.length
              ? Column(
                  children: [
                    // Progress bar with animation
                    _buildAnimatedProgressBar(),

                    // Tutorial steps
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) =>
                            setState(() => _currentStep = index),
                        itemCount: _steps.length,
                        itemBuilder: (context, index) =>
                            _buildTutorialPage(_steps[index]),
                      ),
                    ),

                    // Navigation
                    _buildNavigation(),
                  ],
                )
              : _buildTankCreationForm(),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.accent,
                Colors.green,
                Colors.orange,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedProgressBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: (_currentStep + 1) / (_steps.length + 1)),
      duration: AppDurations.long2,
      curve: AppCurves.standardDecelerate,
      builder: (context, value, child) => Column(
        children: [
          LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(
              _currentStep < _steps.length
                  ? _steps[_currentStep].color
                  : AppColors.accent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${_currentStep + 1} of ${_steps.length + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${((value) * 100).round()}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialPage(_TutorialStep step) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated emoji with scale effect
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: AppCurves.elastic,
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: Text(
                    step.emoji,
                    style: const TextStyle(fontSize: 100),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Icon with color
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: step.color.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(step.icon, size: 56, color: step.color),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                step.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: step.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              Text(
                step.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTankCreationForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Progress indicator
          _buildAnimatedProgressBar(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: AppCurves.standardDecelerate,
                      builder: (context, value, child) =>
                          Opacity(opacity: value, child: child),
                      child: Column(
                        children: [
                          Text(
                            'Create Your First Tank 🐟',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'This will be your virtual tank to track your real aquarium',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Demo tank option
                    _buildDemoTankCard(),
                    const SizedBox(height: AppSpacing.lg),

                    if (!_useDemoData) ...[
                      // Tank name
                      _buildSectionLabel('Tank Name'),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'e.g., Living Room Tank',
                          prefixIcon: Icon(Icons.label),
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a tank name';
                          }
                          return null;
                        },
                        onChanged: (value) => _tankName = value,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Tank type
                      _buildSectionLabel('Tank Type'),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _TankTypeCard(
                              icon: Icons.water_drop,
                              label: 'Freshwater',
                              isSelected: _tankType == TankType.freshwater,
                              onTap: () => setState(
                                () => _tankType = TankType.freshwater,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TankTypeCard(
                              icon: Icons.waves,
                              label: 'Marine',
                              isSelected: _tankType == TankType.marine,
                              isDisabled: true,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Volume
                      _buildSectionLabel('Tank Size'),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter volume',
                          prefixIcon: Icon(Icons.straighten),
                          suffixText: 'litres',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter tank volume';
                          }
                          final volume = double.tryParse(value);
                          if (volume == null || volume <= 0) {
                            return 'Please enter a valid volume';
                          }
                          return null;
                        },
                        onChanged: (value) =>
                            _volumeLitres = double.tryParse(value) ?? 0,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 8,
                        children: [20, 40, 60, 100, 120, 200].map((volume) {
                          return ActionChip(
                            label: Text('${volume}L'),
                            onPressed: () => setState(
                              () => _volumeLitres = volume.toDouble(),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Water type
                      _buildSectionLabel('Water Type'),
                      const SizedBox(height: AppSpacing.sm),
                      _WaterTypeCard(
                        icon: '🌴',
                        label: 'Tropical',
                        subtitle: '24-28°C',
                        isSelected: _waterType == 'tropical',
                        onTap: () => setState(() => _waterType = 'tropical'),
                      ),
                      const SizedBox(height: 12),
                      _WaterTypeCard(
                        icon: '❄️',
                        label: 'Coldwater',
                        subtitle: '15-22°C',
                        isSelected: _waterType == 'coldwater',
                        onTap: () => setState(() => _waterType = 'coldwater'),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ] else ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildDemoTankPreview(),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // Create button with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.9, end: 1.0),
                      duration: AppDurations.medium4,
                      curve: AppCurves.standardDecelerate,
                      builder: (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: FilledButton.icon(
                        onPressed: _createFirstTank,
                        icon: const Icon(Icons.rocket_launch),
                        label: Text(
                          _useDemoData
                              ? 'Start with Demo Tank!'
                              : 'Create Tank & Start Journey!',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoTankCard() {
    return Card(
      elevation: _useDemoData ? AppElevation.level2 : AppElevation.level1,
      color: _useDemoData ? AppOverlays.accent10 : null,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mediumRadius,
        side: BorderSide(
          color: _useDemoData ? AppColors.accent : Colors.grey.shade300,
          width: _useDemoData ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _useDemoData = !_useDemoData),
        borderRadius: AppRadius.mediumRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                _useDemoData ? Icons.check_circle : Icons.science_outlined,
                color: _useDemoData ? AppColors.accent : Colors.grey,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Try with a Demo Tank?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _useDemoData ? AppColors.accent : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Start with a pre-configured 60L community tank to explore features',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _useDemoData,
                onChanged: (value) => setState(() => _useDemoData = value),
                activeColor: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoTankPreview() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppOverlays.primary10,
            AppOverlays.accent10,
          ],
        ),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.accentAlpha30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Demo Community Tank',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPreviewRow(Icons.straighten, '60 Litres'),
          const SizedBox(height: AppSpacing.sm),
          _buildPreviewRow(Icons.thermostat, 'Tropical (24-28°C)'),
          const SizedBox(height: AppSpacing.sm),
          _buildPreviewRow(Icons.water_drop, 'Freshwater Community'),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.smallRadius,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange,
                  size: AppIconSizes.sm,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Perfect for exploring features before setting up your real tank!',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: AppSpacing.sm),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppOverlays.black5,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _nextStep,
              icon: Icon(
                _currentStep == _steps.length - 1
                    ? Icons.edit
                    : Icons.arrow_forward,
              ),
              label: Text(
                _currentStep == _steps.length - 1 ? 'Create My Tank!' : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialStep {
  final IconData icon;
  final String title;
  final String description;
  final String emoji;
  final Color color;

  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
  });
}

class _TankTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _TankTypeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: AppRadius.mediumRadius,
      child: AnimatedOpacity(
        duration: AppDurations.medium2,
        opacity: isDisabled ? 0.5 : 1.0,
        child: AnimatedContainer(
          duration: AppDurations.medium2,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? AppOverlays.primary10
                : Colors.grey[100],
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.primary : Colors.grey[600],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.grey[800],
                ),
              ),
              if (isDisabled) ...[
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Coming soon',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterTypeCard extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _WaterTypeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mediumRadius,
      child: AnimatedContainer(
        duration: AppDurations.medium2,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppOverlays.accent10
              : Colors.grey[100],
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.accent : Colors.grey[800],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.accent)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  final String tankName;

  const _SuccessDialog({required this.tankName});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.elastic,
    );
    _controller.forward();
    _confettiController.play();

    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.largeRadius,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 80,
                  color: AppColors.accent,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Tank Created!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${widget.tankName} is ready!',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Let\'s start your aquarium journey! 🐠',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.03,
            numberOfParticles: 40,
            gravity: 0.3,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.secondary,
              AppColors.accent,
              Colors.green,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }
}
