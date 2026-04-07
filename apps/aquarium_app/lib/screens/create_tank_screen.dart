import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/inventory_provider.dart';
import '../services/achievement_service.dart';
import '../services/xp_animation_service.dart';
import '../services/celebration_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/haptic_feedback.dart';
import '../utils/accessibility_utils.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/app_dialog.dart';
import 'create_tank_screen/setup_mode.dart';
import 'create_tank_screen/widgets/basic_info_page.dart';
import 'create_tank_screen/widgets/size_page.dart';
import 'create_tank_screen/widgets/water_type_page.dart';
import '../utils/logger.dart';

class CreateTankScreen extends ConsumerStatefulWidget {
  /// Controls whether the screen shows the guided 3-page wizard or the
  /// expert single-form flow. Defaults to [SetupMode.guided] so existing
  /// entry points (tank log board, "add tank" buttons) stay unchanged.
  final SetupMode mode;

  const CreateTankScreen({
    super.key,
    this.mode = SetupMode.guided,
  });

  @override
  ConsumerState<CreateTankScreen> createState() => _CreateTankScreenState();
}

class _CreateTankScreenState extends ConsumerState<CreateTankScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Controller for the expert-mode volume field. Lives here (rather than
  // inside the expert form method) so size preset chips can update it.
  final _expertVolumeController = TextEditingController();

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

  bool get _isExpert => widget.mode == SetupMode.expert;

  @override
  void dispose() {
    _pageController.dispose();
    _expertVolumeController.dispose();
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
        final shouldPop = await showAppDestructiveDialog(
          context: context,
          title: 'Discard new tank?',
          message: 'You have unsaved changes. Are you sure you want to go back?',
          destructiveLabel: 'Discard',
        );
        if (shouldPop == true && context.mounted) {
          Navigator.maybePop(context);
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isExpert ? 'Quick setup' : 'New Tank'),
            leading: Semantics(
              label: A11yLabels.closeButton('new tank form'),
              button: true,
              child: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close and discard new tank',
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
            ),
          ),
          body: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: _isExpert ? _buildExpertForm() : _buildGuidedForm(),
            ),
          ),
        ),
      ),
    );
  }

  // ── Guided form (3-page wizard — unchanged structure) ────────────────────

  Widget _buildGuidedForm() {
    return Column(
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
              BasicInfoPage(
                name: _name,
                type: _type,
                onNameChanged: (v) => setState(() => _name = v),
                onTypeChanged: (v) => setState(() => _type = v),
              ),
              SizePage(
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
              WaterTypePage(
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

        // Navigation buttons
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
        ),
      ],
    );
  }

  // ── Expert form (single screen: name + volume + water type) ──────────────

  Widget _buildExpertForm() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Just the essentials',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Edit anything else later in tank settings.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Name
                FocusTraversalOrder(
                  order: const NumericFocusOrder(1.0),
                  child: Semantics(
                    label:
                        A11yLabels.textField('Tank name', required: true),
                    textField: true,
                    child: TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(
                        labelText: 'Tank name',
                        hintText: 'e.g., Betta Palace',
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) => setState(() => _name = v),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter a tank name'
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Volume
                FocusTraversalOrder(
                  order: const NumericFocusOrder(2.0),
                  child: Semantics(
                    label: A11yLabels.textField(
                      'Volume in litres',
                      required: true,
                    ),
                    textField: true,
                    child: TextFormField(
                      controller: _expertVolumeController,
                      decoration: const InputDecoration(
                        labelText: 'Volume',
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
                        setState(() => _volumeLitres = value ?? 0);
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter a volume';
                        }
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
                const SizedBox(height: AppSpacing.sm),

                // Size presets — shared idea with the guided SizePage so
                // expert users get the same quick-pick shortcuts.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [20, 60, 120, 200, 300].map((litres) {
                    return Semantics(
                      label: A11yLabels.button('Set volume to ${litres}L'),
                      button: true,
                      child: ActionChip(
                        label: Text('${litres}L'),
                        onPressed: () {
                          setState(() {
                            _volumeLitres = litres.toDouble();
                            _expertVolumeController.text = litres.toString();
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Water type toggle
                Semantics(
                  header: true,
                  child: Text(
                    'Water type',
                    style: AppTypography.titleMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(3.0),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'tropical',
                        label: Text('Tropical'),
                        icon: Icon(Icons.thermostat),
                      ),
                      ButtonSegment(
                        value: 'coldwater',
                        label: Text('Coldwater'),
                        icon: Icon(Icons.ac_unit),
                      ),
                    ],
                    selected: {_waterType},
                    onSelectionChanged: (selection) {
                      final v = selection.first;
                      setState(() {
                        _waterType = v;
                        _targets = v == 'tropical'
                            ? WaterTargets.freshwaterTropical()
                            : WaterTargets.freshwaterColdwater();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Create button pinned to the bottom — matches guided form affordance
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: 'Create Tank',
              onPressed: _canCreateExpert() && !_isCreating ? _createTank : null,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
              size: AppButtonSize.large,
              isLoading: _isCreating,
              leadingIcon: Icons.add,
              semanticsLabel: A11yLabels.button(
                'Create tank',
                _name.isNotEmpty ? _name : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _canCreateExpert() =>
      _name.trim().isNotEmpty && _volumeLitres >= 1;

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
      if (!_formKey.currentState!.validate()) return;
      try {
        FocusManager.instance.primaryFocus?.unfocus();
      } catch (e) {
        appLog('CreateTankScreen: unfocus failed: $e', tag: 'CreateTankScreen');
      }
      AppHaptics.light(enabled: ref.read(settingsProvider).hapticFeedbackEnabled);
      _pageController.nextPage(
        duration: AppDurations.medium4,
        curve: AppCurves.standard,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      FocusManager.instance.primaryFocus?.unfocus();
      AppHaptics.light(enabled: ref.read(settingsProvider).hapticFeedbackEnabled);
      _pageController.previousPage(
        duration: AppDurations.medium4,
        curve: AppCurves.standard,
      );
    }
  }

  Future<void> _createTank() async {
    if (!_canProceed()) return;
    if (!_formKey.currentState!.validate()) return;

    AppHaptics.medium(enabled: ref.read(settingsProvider).hapticFeedbackEnabled);
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

      if (mounted) {
        ref.showXpAnimation(effectiveXp);
      }

      // Check for achievements after tank creation
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        try {
          final achievementChecker = ref.read(achievementCheckerProvider);
          final stats = AchievementStats(
            totalXp: profile.totalXp,
            currentStreak: profile.currentStreak,
            hasCompletedPlacementTest: profile.hasCompletedPlacementTest,
            lessonsCompleted: profile.completedLessons.length,
          );
          await achievementChecker.checkAllAchievements(stats: stats);
        } catch (e, st) {
          logError('CreateTankScreen: achievement check failed: $e', stackTrace: st, tag: 'CreateTankScreen');
        }
      }

      if (mounted) {
        AppHaptics.success(enabled: ref.read(settingsProvider).hapticFeedbackEnabled);
        final nav = Navigator.of(context);
        final tankName = _name.trim();
        AppFeedback.showSuccess(
          context,
          '$tankName created! +${XpRewards.createTank} XP',
          duration: const Duration(seconds: 2),
        );
        nav.pop();

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
          ref
              .read(celebrationProvider.notifier)
              .achievement(
                'Multi-Tank Aquarist! \u{1F30A}',
                subtitle:
                    'You now have multiple tanks to manage!',
              );
        }
      }
    } catch (e, st) {
      logError('CreateTankScreen: tank creation failed: $e', stackTrace: st, tag: 'CreateTankScreen');
      if (mounted) {
        AppHaptics.error(enabled: ref.read(settingsProvider).hapticFeedbackEnabled);
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
