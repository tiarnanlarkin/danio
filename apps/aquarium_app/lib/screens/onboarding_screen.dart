import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/onboarding_service.dart';
import '../theme/app_theme.dart';
import '../models/user_profile.dart';
import '../models/tank.dart';
import '../providers/user_profile_provider.dart';
import 'onboarding/profile_creation_screen.dart';
import 'onboarding/experience_assessment_screen.dart';
import 'tab_navigator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.water_drop_rounded,
      title: 'Why Danio?',
      description:
          'The smartest way to keep fish happy and healthy.\n\n\u{1F393} Learn fishkeeping the fun way \u2014 lessons, quizzes, streaks\n\u{1F916} AI that identifies fish and diagnoses problems\n\u{1F3C6} 55+ achievements \u2014 from First Fish to Master Aquarist',
      gradientColors: [AppColors.primaryDark, AppColors.primary],
    ),
    _OnboardingPage(
      icon: Icons.set_meal_rounded,
      title: 'Manage Your Collection',
      description:
          'Add fish, plants, and equipment. Set maintenance schedules and get reminders when things need attention.',
      gradientColors: [DanioColors.coralAccent, DanioColors.topaz],
    ),
    _OnboardingPage(
      icon: Icons.auto_graph_rounded,
      title: 'Watch Your Tanks Thrive',
      description:
          'Smart tasks keep your tanks healthy. Complete tasks, view history, and watch your parameters over time.',
      gradientColors: [DanioColors.tealWater, DanioColors.tealWater.withValues(alpha: 0.7)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: AppCurves.standardDecelerate),
    );
    
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: AppCurves.standardDecelerate));
    
    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    HapticFeedback.selectionClick();
    _contentController.reset();
    _contentController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            // Static gradient background (animated caused ANR)
            AnimatedContainer(
              duration: AppDurations.long2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    page.gradientColors[0],
                    page.gradientColors[1],
                    page.gradientColors[0].withAlpha(204),
                  ],
                ),
              ),
            ),
            
            // Static decorative orbs (no animation to prevent ANR)
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.whiteAlpha15,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.whiteAlpha10,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar with skip and quick start
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Quick Start - prominent button
                        TextButton.icon(
                          onPressed: _quickStart,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.whiteAlpha15,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          icon: const Icon(Icons.flash_on, size: AppIconSizes.sm),
                          label: const Text('Quick Start'),
                        ),
                        // Skip - goes to profile creation
                        TextButton(
                          onPressed: _completeOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.whiteAlpha80,
                          ),
                          child: const Text('Skip Intro'),
                        ),
                      ],
                    ),
                  ),
                  
                  // Page content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        return _buildPageContent(_pages[index]);
                      },
                    ),
                  ),
                  
                  // Bottom section with dots and button
                  _buildBottomSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(_OnboardingPage page) {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glass icon container
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.whiteAlpha15,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: AppColors.whiteAlpha30,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      page.icon,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Title
              Text(
                page.title,
                style: AppTypography.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                page.description,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.whiteAlpha85,
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

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          // Premium pill dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: AppDurations.long1,
                    curve: AppCurves.standard,
                  );
                },
                child: AnimatedContainer(
                  duration: AppDurations.medium4,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 32 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : AppColors.whiteAlpha40,
                    borderRadius: AppRadius.xsRadius,
                    boxShadow: _currentPage == index
                        ? [
                            BoxShadow(
                              color: AppColors.whiteAlpha50,
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Navigation buttons
          Row(
            children: [
              // Back button
              if (_currentPage > 0)
                Expanded(
                  child: _GlassButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _pageController.previousPage(
                        duration: AppDurations.long1,
                        curve: AppCurves.standard,
                      );
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),
              
              const SizedBox(width: 16),
              
              // Next / Get Started
              Expanded(
                flex: 2,
                child: _PrimaryButton(
                  onTap: _currentPage == _pages.length - 1
                      ? _completeOnboarding
                      : () {
                          HapticFeedback.lightImpact();
                          _pageController.nextPage(
                            duration: AppDurations.long1,
                            curve: AppCurves.standard,
                          );
                        },
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final service = await OnboardingService.getInstance();
    await service.completeOnboarding();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ExperienceAssessmentScreen()),
      );
    }
  }

  /// Quick Start - Create default profile and skip all onboarding
  Future<void> _quickStart() async {
    try {
      HapticFeedback.mediumImpact();
      
      // Create default beginner profile
      await ref.read(userProfileProvider.notifier).createProfile(
        name: 'Aquarist', // Default name
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive, UserGoal.beautifulDisplay],
      );

      // Mark onboarding as complete
      final service = await OnboardingService.getInstance();
      await service.completeOnboarding();

      if (mounted) {
        // Go straight to main app
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TabNavigator()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quick start failed: $e')),
        );
      }
    }
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
  });
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GlassButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mediumRadius,
        child: ClipRRect(
          borderRadius: AppRadius.mediumRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.whiteAlpha15,
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(
                  color: AppColors.whiteAlpha25,
                ),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _PrimaryButton({required this.onTap, required this.child});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.short,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.mediumRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackAlpha15,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.whiteAlpha80,
                    blurRadius: 1,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Center(
                child: DefaultTextStyle(
                  style: const TextStyle(color: AppColors.primary),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
