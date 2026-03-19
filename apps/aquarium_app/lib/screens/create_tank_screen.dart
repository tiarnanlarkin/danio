import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/achievement_provider.dart';
import '../services/achievement_service.dart';
import '../services/xp_animation_service.dart';
import '../services/celebration_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/haptic_feedback.dart';
import '../utils/accessibility_utils.dart';
import '../widgets/core/app_button.dart';

class CreateTankScreen extends ConsumerStatefulWidget {
  const CreateTankScreen({super.key});

  @override
  ConsumerState<CreateTankScreen> createState() => _CreateTankScreenState();
}

class _CreateTankScreenState extends ConsumerState<CreateTankScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  int _currentPage = 0;
  bool _isCreating = false;

  // Form values
  String _name = '';
  TankType _type = TankType.freshwater;
  double _volumeLitres = 0;
  double? _lengthCm;
  double? _widthCm;
  double? _heightCm;
  DateTime _startDate = DateTime.now();
  String _waterType = 'tropical'; // 'tropical' or 'coldwater'
  WaterTargets _targets = WaterTargets.freshwaterTropical();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _hasUnsavedData =>
      _name.isNotEmpty || _volumeLitres > 0 || _currentPage > 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedData || _isCreating,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard new tank?'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to go back?',
            ),
            actions: [
              TextButton(
                onPressed: () { if (Navigator.canPop(ctx)) Navigator.pop(ctx, false); },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () { if (Navigator.canPop(ctx)) Navigator.pop(ctx, true); },
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        if (shouldPop == true && context.mounted) {
          Navigator.maybePop(context);
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('New Tank'),
            leading: Semantics(
              label: A11yLabels.closeButton('new tank form'),
              button: true,
              child: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close and discard new tank',
                onPressed: () {
                  if (_hasUnsavedData) {
                    // Let PopScope handle confirmation
                    Navigator.maybePop(context);
                  } else {
                    Navigator.maybePop(context);
                  }
                },
              ),
            ),
          ),
          body: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Progress indicator
                  Semantics(
                    label: A11yLabels.progress(
                      _currentPage + 1,
                      3,
                      'Tank creation',
                    ),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 3,
                      backgroundColor: context.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),

                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) =>
                          setState(() => _currentPage = page),
                      children: [
                        _BasicInfoPage(
                          name: _name,
                          type: _type,
                          onNameChanged: (v) => setState(() => _name = v),
                          onTypeChanged: (v) => setState(() => _type = v),
                        ),
                        _SizePage(
                          volumeLitres: _volumeLitres,
                          lengthCm: _lengthCm,
                          widthCm: _widthCm,
                          heightCm: _heightCm,
                          onVolumeChanged: (v) =>
                              setState(() => _volumeLitres = v),
                          onLengthChanged: (v) => setState(() => _lengthCm = v),
                          onWidthChanged: (v) => setState(() => _widthCm = v),
                          onHeightChanged: (v) => setState(() => _heightCm = v),
                        ),
                        _WaterTypePage(
                          waterType: _waterType,
                          startDate: _startDate,
                          onWaterTypeChanged: (v) {
                            setState(() {
                              _waterType = v;
                              _targets = v == 'tropical'
                                  ? WaterTargets.freshwaterTropical()
                                  : WaterTargets.freshwaterColdwater();
                            });
                          },
                          onStartDateChanged: (v) =>
                              setState(() => _startDate = v),
                        ),
                      ],
                    ),
                  ),

                  // Navigation buttons — SafeArea ensures buttons stay above gesture nav zone.
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          if (_currentPage > 0)
                            AppButton(
                              label: 'Back',
                              onPressed: _previousPage,
                              variant: AppButtonVariant.secondary,
                              semanticsLabel: A11yLabels.button(
                                'Go back to previous step',
                              ),
                            ),
                          const Spacer(),
                          if (_currentPage < 2)
                            AppButton(
                              label: 'Next',
                              onPressed: _canProceed() ? _nextPage : null,
                              variant: AppButtonVariant.primary,
                              trailingIcon: Icons.arrow_forward,
                              semanticsLabel: A11yLabels.button(
                                'Continue to next step',
                              ),
                            )
                          else
                            AppButton(
                              label: 'Create Tank',
                              onPressed: _canProceed() && !_isCreating
                                  ? _createTank
                                  : null,
                              variant: AppButtonVariant.primary,
                              isLoading: _isCreating,
                              leadingIcon: Icons.add,
                              semanticsLabel: A11yLabels.button(
                                'Create tank',
                                _name.isNotEmpty ? _name : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ), // SafeArea
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _name.trim().isNotEmpty;
      case 1:
        return _volumeLitres >= 1;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      // Validate current page fields before proceeding
      if (!_formKey.currentState!.validate()) return;
      try {
        FocusManager.instance.primaryFocus?.unfocus();
      } catch (_) {
        // unfocus errors are non-critical; ignore silently
      }
      AppHaptics.light();
      _pageController.nextPage(
        duration: AppDurations.medium4,
        curve: AppCurves.standard,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      FocusManager.instance.primaryFocus?.unfocus();
      AppHaptics.light();
      _pageController.previousPage(
        duration: AppDurations.medium4,
        curve: AppCurves.standard,
      );
    }
  }

  Future<void> _createTank() async {
    if (!_canProceed()) return;
    if (!_formKey.currentState!.validate()) return;

    AppHaptics.medium();
    setState(() => _isCreating = true);

    try {
      final actions = ref.read(tankActionsProvider);
      await actions.createTank(
        name: _name.trim(),
        type: _type,
        volumeLitres: _volumeLitres,
        lengthCm: _lengthCm,
        widthCm: _widthCm,
        heightCm: _heightCm,
        startDate: _startDate,
        targets: _targets,
      );

      // Award XP for creating a new tank (with boost if active)
      final isBoostActive = ref.read(xpBoostActiveProvider);
      final effectiveXp = isBoostActive
          ? XpRewards.createTank * 2
          : XpRewards.createTank;
      await ref
          .read(userProfileProvider.notifier)
          .recordActivity(
            xp: XpRewards.createTank,
            xpBoostActive: isBoostActive,
          );

      // Show XP animation
      if (mounted) {
        ref.showXpAnimation(effectiveXp);
      }

      // Check for achievements after tank creation
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        try {
          final achievementChecker = ref.read(achievementCheckerProvider);

          // Build stats for achievement checking
          final stats = AchievementStats(
            totalXp: profile.totalXp,
            currentStreak: profile.currentStreak,
            hasCompletedPlacementTest: profile.hasCompletedPlacementTest,
            lessonsCompleted: profile.completedLessons.length,
          );

          await achievementChecker.checkAllAchievements(stats: stats);
        } catch (e) {
          // Don't fail the tank creation if achievement check fails
          debugPrint('Achievement check failed: $e');
        }
      }

      if (mounted) {
        AppHaptics.success();
        // Capture navigator and messenger BEFORE pop() disposes the context.
        final nav = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        final tankName = _name.trim();
        nav.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('$tankName created! +${XpRewards.createTank} XP'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.md2Radius),
            margin: const EdgeInsets.all(AppSpacing.md),
          ),
        );

        // Celebrate first tank creation!
        final tanks = ref.read(tanksProvider).value ?? [];
        if (tanks.length <= 1) {
          ref
              .read(celebrationProvider.notifier)
              .milestone(
                'Your First Tank! 🎉',
                subtitle:
                    'Welcome to the hobby - your aquarium adventure has officially begun!',
              );
        } else if (tanks.length == 2) {
          // Plant Danio Pro seed for multi-tank users
          ref
              .read(celebrationProvider.notifier)
              .achievement(
                'Multi-Tank Aquarist! \u{1F30A}',
                subtitle:
                    'Danio Pro will unlock advanced multi-tank features — stay tuned!',
              );
        }
      }
    } catch (e) {
      if (mounted) {
        AppHaptics.error();
        AppFeedback.showError(
          context,
          'Couldn\'t create your tank right now. Give it another go!',
          onRetry: _createTank,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}

// --- Page 1: Basic Info ---
class _BasicInfoPage extends StatelessWidget {
  final String name;
  final TankType type;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<TankType> onTypeChanged;

  const _BasicInfoPage({
    required this.name,
    required this.type,
    required this.onNameChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text('Name your tank', style: AppTypography.headlineMedium),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Give it a memorable name, like "Living Room Tank" or "Betta Palace".',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          FocusTraversalOrder(
            order: const NumericFocusOrder(1.0),
            child: Semantics(
              label: A11yLabels.textField('Tank name', required: true),
              textField: true,
              child: TextFormField(
                initialValue: name,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Tank name',
                  hintText: 'e.g., Living Room Tank',
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: onNameChanged,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a tank name'
                    : null,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Semantics(
            header: true,
            child: Text('Tank type', style: AppTypography.headlineSmall),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Freshwater is the most common choice for beginners.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          FocusTraversalOrder(
            order: const NumericFocusOrder(2.0),
            child: _TypeSelector(selected: type, onChanged: onTypeChanged),
          ),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final TankType selected;
  final ValueChanged<TankType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeCard(
            icon: Icons.water_drop,
            title: 'Freshwater',
            subtitle: 'Tropical, coldwater, planted',
            isSelected: selected == TankType.freshwater,
            onTap: () => onChanged(TankType.freshwater),
          ),
        ),
        const SizedBox(width: AppSpacing.sm2),
        Expanded(
          child: _TypeCard(
            icon: Icons.waves,
            title: 'Marine',
            subtitle: 'Arriving soon',
            isSelected: selected == TankType.marine,
            isDisabled: true,
            onTap: () {
              // Show message when user taps disabled Marine option
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.waves, color: Colors.white),
                      SizedBox(width: AppSpacing.sm2),
                      Expanded(
                        child: Text(
                          'Marine tanks are on the way — stay tuned! 🐠🦀🐙',
                        ),
                      ),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: A11yLabels.selectableItem(title, isSelected),
      hint: isDisabled ? 'Arriving soon' : subtitle,
      button: true,
      enabled: !isDisabled,
      selected: isSelected,
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1,
        child: InkWell(
          // Allow tap even when disabled to show feedback message
          onTap: onTap,
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppOverlays.primary10
                  : context.surfaceVariant,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    icon,
                    size: 32,
                    color: isSelected
                        ? AppColors.primary
                        : context.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ExcludeSemantics(
                  child: Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : context.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ExcludeSemantics(
                  child: Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDisabled ? context.textHint : null,
                      fontStyle: isDisabled ? FontStyle.italic : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Page 2: Size ---
class _SizePage extends StatefulWidget {
  final double volumeLitres;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double?> onLengthChanged;
  final ValueChanged<double?> onWidthChanged;
  final ValueChanged<double?> onHeightChanged;

  const _SizePage({
    required this.volumeLitres,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    required this.onVolumeChanged,
    required this.onLengthChanged,
    required this.onWidthChanged,
    required this.onHeightChanged,
  });

  @override
  State<_SizePage> createState() => _SizePageState();
}

class _SizePageState extends State<_SizePage> {
  late TextEditingController _volumeController;
  bool _disposed = false;

  /// Format volume without trailing ".0" for whole numbers.
  static String _formatVolume(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void initState() {
    super.initState();
    _volumeController = TextEditingController(
      text: widget.volumeLitres > 0 ? _formatVolume(widget.volumeLitres) : '',
    );
  }

  @override
  void didUpdateWidget(_SizePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_disposed) return;
    // Update text field when volume changes externally (e.g., from presets)
    try {
      final currentText = _volumeController.text;
      final newText = widget.volumeLitres > 0
          ? _formatVolume(widget.volumeLitres)
          : '';
      if (currentText != newText &&
          double.tryParse(currentText) != widget.volumeLitres) {
        _volumeController.text = newText;
      }
    } catch (_) {
      // didUpdateWidget controller sync errors are non-critical; ignore silently
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _volumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text('Tank size', style: AppTypography.headlineMedium),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter the volume, or we can calculate it from dimensions.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Volume input
          FocusTraversalOrder(
            order: const NumericFocusOrder(1.0),
            child: Semantics(
              label: A11yLabels.textField('Volume in litres', required: true),
              textField: true,
              child: TextFormField(
                controller: _volumeController,
                decoration: const InputDecoration(
                  labelText: 'Volume (litres)',
                  hintText: 'e.g., 120',
                  suffixText: 'L',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                onChanged: (v) {
                  final value = double.tryParse(v);
                  if (value != null) widget.onVolumeChanged(value);
                },
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter a volume';
                  final n = double.tryParse(v);
                  if (n == null || n < 1) {
                    return 'Minimum tank volume is 1 litre';
                  }
                  if (n > 10000) return 'Maximum 10,000 litres';
                  return null;
                },
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Semantics(
            header: true,
            child: Text(
              'Dimensions (optional)',
              style: AppTypography.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Useful for stocking recommendations.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(2.0),
                  child: Semantics(
                    label: A11yLabels.textField('Length in centimeters'),
                    textField: true,
                    child: TextFormField(
                      initialValue: widget.lengthCm?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Length',
                        suffixText: 'cm',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      onChanged: (v) =>
                          widget.onLengthChanged(double.tryParse(v)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(3.0),
                  child: Semantics(
                    label: A11yLabels.textField('Width in centimeters'),
                    textField: true,
                    child: TextFormField(
                      initialValue: widget.widthCm?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Width',
                        suffixText: 'cm',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      onChanged: (v) =>
                          widget.onWidthChanged(double.tryParse(v)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(4.0),
                  child: Semantics(
                    label: A11yLabels.textField('Height in centimeters'),
                    textField: true,
                    child: TextFormField(
                      initialValue: widget.heightCm?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Height',
                        suffixText: 'cm',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      onChanged: (v) =>
                          widget.onHeightChanged(double.tryParse(v)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Quick size presets
          const SizedBox(height: AppSpacing.lg),
          Text('Quick presets', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SizePreset(
                label: '20L',
                onTap: () => widget.onVolumeChanged(20),
              ),
              _SizePreset(
                label: '60L',
                onTap: () => widget.onVolumeChanged(60),
              ),
              _SizePreset(
                label: '120L',
                onTap: () => widget.onVolumeChanged(120),
              ),
              _SizePreset(
                label: '200L',
                onTap: () => widget.onVolumeChanged(200),
              ),
              _SizePreset(
                label: '300L',
                onTap: () => widget.onVolumeChanged(300),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SizePreset extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SizePreset({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: A11yLabels.button('Set volume to $label'),
      button: true,
      child: ActionChip(label: Text(label), onPressed: onTap),
    );
  }
}

// --- Page 3: Water Type ---
class _WaterTypePage extends StatelessWidget {
  final String waterType;
  final DateTime startDate;
  final ValueChanged<String> onWaterTypeChanged;
  final ValueChanged<DateTime> onStartDateChanged;

  const _WaterTypePage({
    required this.waterType,
    required this.startDate,
    required this.onWaterTypeChanged,
    required this.onStartDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text('Water type', style: AppTypography.headlineMedium),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This sets default temperature and parameter targets.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          FocusTraversalOrder(
            order: const NumericFocusOrder(1.0),
            child: _WaterTypeSelector(
              selected: waterType,
              onChanged: onWaterTypeChanged,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Semantics(
            header: true,
            child: Text(
              'When did you set up this tank?',
              style: AppTypography.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Helps track cycling progress and maintenance history.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          FocusTraversalOrder(
            order: const NumericFocusOrder(2.0),
            child: Semantics(
              label: A11yLabels.button(
                'Select start date',
                'Currently ${startDate.day}/${startDate.month}/${startDate.year}',
              ),
              button: true,
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    onStartDateChanged(picked);
                  }
                },
                borderRadius: AppRadius.mediumRadius,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Row(
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          Icons.calendar_today,
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm2),
                      ExcludeSemantics(
                        child: Text(
                          '${startDate.day}/${startDate.month}/${startDate.year}',
                          style: AppTypography.bodyLarge,
                        ),
                      ),
                      const Spacer(),
                      ExcludeSemantics(
                        child: Icon(
                          Icons.edit,
                          color: context.textHint,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          FocusTraversalOrder(
            order: const NumericFocusOrder(3.0),
            child: Semantics(
              label: A11yLabels.button('Set start date to today'),
              button: true,
              child: TextButton(
                onPressed: () => onStartDateChanged(DateTime.now()),
                child: const Text('Set to today'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _WaterTypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _WaterTypeOption(
          icon: '🌴',
          title: 'Tropical',
          subtitle: '24-28°C • Most community fish',
          isSelected: selected == 'tropical',
          onTap: () => onChanged('tropical'),
        ),
        const SizedBox(height: AppSpacing.sm2),
        _WaterTypeOption(
          icon: '❄️',
          title: 'Coldwater',
          subtitle: '15-22°C • Goldfish, minnows',
          isSelected: selected == 'coldwater',
          onTap: () => onChanged('coldwater'),
        ),
      ],
    );
  }
}

class _WaterTypeOption extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _WaterTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: A11yLabels.selectableItem(title, isSelected),
      hint: subtitle,
      button: true,
      selected: isSelected,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mediumRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? AppOverlays.primary10 : context.surfaceVariant,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Text(
                  icon,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Text(
                        title,
                        style: AppTypography.labelLarge.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : context.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    ExcludeSemantics(
                      child: Text(subtitle, style: AppTypography.bodySmall),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const ExcludeSemantics(
                  child: Icon(Icons.check_circle, color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
