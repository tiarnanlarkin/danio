import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/species_database.dart';
import '../../data/species_sprites.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';

/// Screen 10 — Warm App Entry
///
/// Personalised first-launch home screen shown briefly (~2.5s) as a warm
/// transition before the real app loads. Auto-calls [onReady] after 2.5s
/// or on tap anywhere.
class WarmEntryScreen extends StatefulWidget {
  final SpeciesInfo selectedFish;
  final ExperienceLevel experienceLevel;
  final String tankStatus; // 'planning' | 'cycling' | 'active'
  final String? userName;
  final ValueChanged<String>? onNameChanged; // Callback to persist name
  final VoidCallback onReady;

  const WarmEntryScreen({
    super.key,
    required this.selectedFish,
    required this.experienceLevel,
    required this.tankStatus,
    this.userName,
    this.onNameChanged,
    required this.onReady,
  });

  @override
  State<WarmEntryScreen> createState() => _WarmEntryScreenState();
}

class _WarmEntryScreenState extends State<WarmEntryScreen>
    with TickerProviderStateMixin {
  // Onboarding colours consolidated into AppColors

  late final AnimationController _fishCardController;
  late final CurvedAnimation _fishCardOpacityCurve;
  late final Animation<double> _fishCardOpacity;
  late final CurvedAnimation _fishCardSlideCurve;
  late final Animation<Offset> _fishCardSlide;

  late final AnimationController _lessonCardController;
  late final CurvedAnimation _lessonCardOpacityCurve;
  late final Animation<double> _lessonCardOpacity;

  late final AnimationController _xpBarController;
  late final CurvedAnimation _xpFillCurve;
  late final Animation<double> _xpFill;

  late final AnimationController _streakFlickerController;
  late final Animation<double> _streakScale;

  bool _hasCalledReady = false;
  late final TextEditingController _nameController;
  bool _nameSubmitted = false; // Whether name step is done (skip or submit)

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userName ?? '',
    );

    final disableAnimations =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;

    // Fish card: slides up 20px + fades in over 400ms
    _fishCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fishCardOpacityCurve = CurvedAnimation(
      parent: _fishCardController,
      curve: Curves.easeOut,
    );
    _fishCardOpacity = _fishCardOpacityCurve;
    _fishCardSlideCurve = CurvedAnimation(
      parent: _fishCardController,
      curve: Curves.easeOut,
    );
    _fishCardSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(_fishCardSlideCurve);

    // Lesson card: appears 200ms after fish card
    _lessonCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _lessonCardOpacityCurve = CurvedAnimation(
      parent: _lessonCardController,
      curve: Curves.easeOut,
    );
    _lessonCardOpacity = _lessonCardOpacityCurve;

    // XP bar fills 0→10% over 500ms
    _xpBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _xpFillCurve = CurvedAnimation(parent: _xpBarController, curve: Curves.easeOut);
    _xpFill = Tween<double>(begin: 0.0, end: 0.1).animate(_xpFillCurve);

    // Streak flame flicker (scale pulse)
    _streakFlickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _streakScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_streakFlickerController);

    if (!disableAnimations) {
      // Animations are deferred to _submitName() so they start after
      // the user enters/skips their name.
    } else {
      _fishCardController.value = 1.0;
      _lessonCardController.value = 1.0;
      _xpBarController.value = 1.0;
      _streakFlickerController.value = 1.0;
    }
  }

  void _callReady() {
    if (!_hasCalledReady && mounted) {
      _hasCalledReady = true;
      widget.onReady();
    }
  }

  void _submitName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && widget.onNameChanged != null) {
      widget.onNameChanged!(name);
    }
    setState(() => _nameSubmitted = true);
    // Start the warm entry animations now
    _fishCardController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _lessonCardController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _xpBarController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _streakFlickerController.forward();
    });
    // Auto-advance after 2.5 seconds from name submission
    Future.delayed(const Duration(milliseconds: 2500), _callReady);
  }

  @override
  void didUpdateWidget(covariant WarmEntryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userName != widget.userName) {
      _nameController.text = widget.userName ?? '';
    }
  }

  @override
  void dispose() {
    _fishCardOpacityCurve.dispose();
    _fishCardSlideCurve.dispose();
    _fishCardController.dispose();
    _lessonCardOpacityCurve.dispose();
    _lessonCardController.dispose();
    _xpFillCurve.dispose();
    _xpBarController.dispose();
    _streakFlickerController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String get _greeting {
    final name = widget.userName;
    switch (widget.tankStatus) {
      case 'planning':
        return "Let's get your tank ready 🏠";
      case 'cycling':
        return 'Your tank is almost there 🔧';
      case 'active':
      default:
        if (name != null && name.isNotEmpty) {
          return 'Welcome to Danio, $name 🐟';
        }
        return 'Welcome to Danio 🐟';
    }
  }

  String get _lessonTitle {
    if (widget.experienceLevel == ExperienceLevel.expert ||
        widget.experienceLevel == ExperienceLevel.intermediate) {
      return "Up next: Reading your fish's behaviour";
    }
    return 'Up next: Understanding the nitrogen cycle';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingWarmCream,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          _callReady();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Personalised greeting — changes based on name-entry phase
                Semantics(
                  header: true,
                  child: Text(
                    _nameSubmitted ? _greeting : 'Almost there! 🐟',
                    style: GoogleFonts.lora(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Name input (shown before the warm entry cards)
                if (!_nameSubmitted) ...[
                  Text(
                    "What would you like to be called?",
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          label: 'Enter your name',
                          child: TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            autofocus: true,
                            onSubmitted: (_) => _submitName(),
                            decoration: InputDecoration(
                              hintText: 'Your name (optional)',
                              hintStyle: GoogleFonts.nunito(
                                fontSize: 14,
                                color: AppColors.textHint,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _submitName,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.onboardingAmber,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Next →',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _submitName,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                // Fish care card
                SlideTransition(
                  position: _fishCardSlide,
                  child: FadeTransition(
                    opacity: _fishCardOpacity,
                    child: _buildFishCareCard(),
                  ),
                ),
                const SizedBox(height: 16),
                // Lesson card
                FadeTransition(
                  opacity: _lessonCardOpacity,
                  child: _buildLessonCard(),
                ),
                const SizedBox(height: 24),
                // XP progress bar
                _buildXpBar(),
                const SizedBox(height: 16),
                // Streak counter
                _buildStreakCounter(),
                ], // end of _nameSubmitted else branch
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFishCareCard() {
    final fish = widget.selectedFish;
    return Semantics(
      label:
          '${fish.commonName}, care level ${fish.careLevel}, pH ${fish.minPh} to ${fish.maxPh}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildFishSprite(fish),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fish.commonName,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Your fish',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.star_rounded,
                  label: fish.careLevel,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  icon: Icons.water_drop_rounded,
                  label: 'pH ${fish.minPh}–${fish.maxPh}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFishSprite(SpeciesInfo fish) {
    final thumbPath = SpeciesSprites.thumbFor(fish.commonName);
    if (thumbPath != null) {
      return SizedBox(
        width: 48,
        height: 48,
        child: Image.asset(
          thumbPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Text('🐟', style: TextStyle(fontSize: 32)),
        ),
      );
    }
    return const Text('🐟', style: TextStyle(fontSize: 32));
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.onboardingWarmCream,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.onboardingAmber),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard() {
    return Semantics(
      label: _lessonTitle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.onboardingAmber.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.onboardingAmber,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your first lesson',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _lessonTitle,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXpBar() {
    return Semantics(
      label: 'Level 1, 10 XP, progress 10 percent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level 1 · 10 XP',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '10%',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _xpFill,
            builder: (context, _) {
              return Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _xpFill.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.onboardingAmber,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCounter() {
    return Semantics(
      label: 'Day 1 streak',
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _streakScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _streakScale.value,
                child: child,
              );
            },
            child: const Text('🔥', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 10),
          Text(
            'Day 1 streak',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
