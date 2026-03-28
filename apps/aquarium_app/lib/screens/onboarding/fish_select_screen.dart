import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/species_database.dart';
import '../../data/species_sprites.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';

/// Screen 6 — Fish Selection
///
/// The user picks their first fish species. This selection triggers the
/// personalised aha-moment reveal on the next screen.
class FishSelectScreen extends StatefulWidget {
  /// 'active', 'planning', or 'cycling'
  final String tankStatus;

  /// Called when the user confirms their fish selection.
  final ValueChanged<SpeciesInfo> onFishSelected;

  const FishSelectScreen({
    super.key,
    required this.tankStatus,
    required this.onFishSelected,
  });

  @override
  State<FishSelectScreen> createState() => _FishSelectScreenState();
}

class _FishSelectScreenState extends State<FishSelectScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  List<SpeciesInfo> _searchResults = [];
  SpeciesInfo? _selectedFish;
  bool _isSearching = false;

  // Bottom tray animation
  late final AnimationController _trayController;
  late final CurvedAnimation _trayCurve;
  late final Animation<Offset> _traySlide;

  // Popular starter fish common names — looked up from SpeciesDatabase
  static const _popularNames = [
    'Neon Tetra',
    'Betta',
    'Guppy',
    'Corydoras',
    'Platy',
    'Molly',
    'Cherry Barb',
    'Zebra Danio',
    'Angelfish',
    'Dwarf Gourami',
    'Bristlenose Pleco',
    'Cherry Shrimp',
  ];

  late final List<SpeciesInfo> _popularFish;

  // Onboarding colours consolidated into AppColors

  @override
  void initState() {
    super.initState();

    // Resolve popular fish from DB
    _popularFish = _popularNames
        .map((n) => SpeciesDatabase.lookup(n))
        .whereType<SpeciesInfo>()
        .toList();

    // Tray animation — spring-style via a fast curve
    _trayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _trayCurve = CurvedAnimation(
      parent: _trayController,
      curve: Curves.easeOutBack,
    );
    _traySlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(_trayCurve);

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _trayCurve.dispose();
    _trayController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _searchResults = SpeciesDatabase.search(query);
      }
    });
  }

  void _selectFish(SpeciesInfo fish) {
    HapticFeedback.selectionClick();
    setState(() => _selectedFish = fish);

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _trayController.value = 1.0;
    } else {
      _trayController.forward(from: 0);
    }
  }

  void _confirmSelection() {
    if (_selectedFish == null) return;
    HapticFeedback.mediumImpact();
    widget.onFishSelected(_selectedFish!);
  }

  String get _headerText {
    switch (widget.tankStatus) {
      case 'active':
        return 'What fish do you have right now?';
      case 'planning':
        return 'What fish are you thinking of getting?';
      default:
        return 'What fish are you keeping?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.onboardingWarmCream,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs,
                  ),
                  child: Semantics(
                    header: true,
                    child: Text(
                      _headerText,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    'Search or pick from popular choices below.',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Semantics(
                    label: 'Search species',
                    textField: true,
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: GoogleFonts.nunito(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search 125+ species...',
                        hintStyle: GoogleFonts.nunito(
                          fontSize: 15,
                          color: AppColors.textHint,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textHint,
                        ),
                        suffixIcon: _isSearching
                            ? IconButton(
                                tooltip: 'Clear search',
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md2),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md2),
                          borderSide: const BorderSide(
                            color: AppColors.onboardingAmber,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm4,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Content — grid or list
                Expanded(
                  child: AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    child: _isSearching
                        ? _buildSearchResults()
                        : _buildPopularGrid(),
                  ),
                ),

                // Spacer for bottom tray
                if (_selectedFish != null) const SizedBox(height: 100),
              ],
            ),

            // Bottom tray
            if (_selectedFish != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: _traySlide,
                  child: _buildBottomTray(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Popular grid ────────────────────────────────────────────────

  Widget _buildPopularGrid() {
    return Padding(
      key: const ValueKey('grid'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular starter fish',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: _popularFish.length,
              itemBuilder: (context, index) {
                final fish = _popularFish[index];
                final isSelected = _selectedFish == fish;
                return _PopularTile(
                  fish: fish,
                  isSelected: isSelected,
                  onTap: () => _selectFish(fish),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search results list ─────────────────────────────────────────

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        key: const ValueKey('empty'),
        child: Text(
          'No species found. Try another name.',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      key: const ValueKey('list'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final fish = _searchResults[index];
        final isSelected = _selectedFish == fish;
        return _SearchResultCard(
          fish: fish,
          isSelected: isSelected,
          onTap: () => _selectFish(fish),
        );
      },
    );
  }

  // ─── Bottom tray ─────────────────────────────────────────────────

  Widget _buildBottomTray() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackAlpha10,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Fish name
          Expanded(
            child: Text(
              _selectedFish!.commonName,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // CTA with pulse
          Semantics(
            button: true,
            label: 'Confirm ${_selectedFish!.commonName} as your fish',
            child: _PulsingButton(
              animate: !reduceMotion,
              onTap: _confirmSelection,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════════════════════════════

/// Displays a fish sprite image when available, falling back to an emoji.
class _FishSpriteImage extends StatelessWidget {
  final String commonName;
  final double size;

  const _FishSpriteImage({
    required this.commonName,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final thumbPath = SpeciesSprites.thumbFor(commonName);
    if (thumbPath != null) {
      return ClipOval(
        child: Image.asset(
          thumbPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          semanticLabel: commonName,
          cacheWidth: (size * 2).toInt(),
          cacheHeight: (size * 2).toInt(),
          errorBuilder: (_, __, ___) => _fallbackEmoji,
        ),
      );
    }
    return _fallbackEmoji;
  }

  Widget get _fallbackEmoji => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.onboardingAmber.withAlpha(26),
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text('🐠', style: TextStyle(fontSize: size * 0.5)),
  );
}

/// A single popular-fish tile in the 3-column grid.
class _PopularTile extends StatelessWidget {
  final SpeciesInfo fish;
  final bool isSelected;
  final VoidCallback onTap;

  const _PopularTile({
    required this.fish,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${fish.commonName}, ${fish.scientificName}',
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.onboardingAmber.withAlpha(26) // 10%
                : AppColors.onPrimary,
            borderRadius: BorderRadius.circular(AppRadius.md2),
            border: Border.all(
              color: isSelected
                  ? AppColors.onboardingAmber
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Fish sprite or fallback emoji
              _FishSpriteImage(
                commonName: fish.commonName,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.xs2),
              // Common name
              Text(
                fish.commonName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              // Scientific name
              Text(
                fish.scientificName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSecondary,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.onboardingAmber, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single search result card.
class _SearchResultCard extends StatelessWidget {
  final SpeciesInfo fish;
  final bool isSelected;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.fish,
    required this.isSelected,
    required this.onTap,
  });

  Color get _difficultyColor {
    switch (fish.careLevel.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${fish.commonName}, ${fish.scientificName}, ${fish.careLevel} difficulty',
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm4, vertical: AppSpacing.sm2),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.onboardingAmber.withAlpha(26)
                : AppColors.onPrimary,
            borderRadius: BorderRadius.circular(AppRadius.md2),
            border: Border.all(
              color: isSelected
                  ? AppColors.onboardingAmber
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Fish sprite or fallback emoji
              _FishSpriteImage(
                commonName: fish.commonName,
                size: 36,
              ),
              const SizedBox(width: AppSpacing.sm2),
              // Names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fish.commonName,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      fish.scientificName,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Difficulty dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _difficultyColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.check_circle, color: AppColors.onboardingAmber, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Amber CTA button with a subtle pulse animation.
class _PulsingButton extends StatefulWidget {
  final bool animate;
  final VoidCallback onTap;

  const _PulsingButton({required this.animate, required this.onTap});

  @override
  State<_PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<_PulsingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _scaleCurve;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.02).animate(_scaleCurve);

    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(_PulsingButton old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _scaleCurve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: AppButton(
        label: 'This is my fish →',
        onPressed: widget.onTap,
        variant: AppButtonVariant.primary,
      ),
    );
  }
}
