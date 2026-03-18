import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/species_database.dart';
import '../../theme/app_theme.dart';

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

  // Warm cream
  static const _warmCream = Color(0xFFFFF8F0);
  // Decorative amber for non-text usage
  static const _amber = Color(0xFFF5A623);

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
    _traySlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _trayController,
      curve: Curves.easeOutBack,
    ));

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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
      backgroundColor: _warmCream,
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
                        hintText: 'Search 2,000+ species...',
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
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _amber,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
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
      separatorBuilder: (_, __) => const SizedBox(height: 8),
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
        color: Colors.white,
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
                ? const Color(0xFFF5A623).withAlpha(26) // 10%
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFF5A623)
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Fish emoji placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5A623).withAlpha(26),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🐠', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 6),
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
                const Icon(Icons.check_circle, color: Color(0xFFF5A623), size: 16),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF5A623).withAlpha(26)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFF5A623)
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Fish emoji
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5A623).withAlpha(26),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🐠', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
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
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: Color(0xFFF5A623), size: 20),
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
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: ElevatedButton(
        onPressed: widget.onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5A623),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: Text(
          'This is my fish →',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
