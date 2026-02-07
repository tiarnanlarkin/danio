import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Tank'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
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
                    onVolumeChanged: (v) => setState(() => _volumeLitres = v),
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
                    onStartDateChanged: (v) => setState(() => _startDate = v),
                  ),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  if (_currentPage < 2)
                    ElevatedButton(
                      onPressed: _canProceed() ? _nextPage : null,
                      child: const Text('Next'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _canProceed() && !_isCreating ? _createTank : null,
                      child: _isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Create Tank'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _name.trim().isNotEmpty;
      case 1:
        return _volumeLitres > 0;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createTank() async {
    if (!_canProceed()) return;

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

      if (mounted) {
        Navigator.of(context).pop();
        AppFeedback.showSuccess(context, '${_name.trim()} created!');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Failed to create tank: $e');
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name your tank', style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Give it a memorable name, like "Living Room Tank" or "Betta Palace".',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            initialValue: name,
            decoration: const InputDecoration(
              labelText: 'Tank name',
              hintText: 'e.g., Living Room Tank',
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: onNameChanged,
          ),
          
          const SizedBox(height: 32),
          
          Text('Tank type', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Freshwater is the most common choice for beginners.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          _TypeSelector(
            selected: type,
            onChanged: onTypeChanged,
          ),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final TankType selected;
  final ValueChanged<TankType> onChanged;

  const _TypeSelector({
    required this.selected,
    required this.onChanged,
  });

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
        const SizedBox(width: 12),
        Expanded(
          child: _TypeCard(
            icon: Icons.waves,
            title: 'Marine',
            subtitle: 'Coming soon',
            isSelected: selected == TankType.marine,
            isDisabled: true,
            onTap: null,
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
    return Opacity(
      opacity: isDisabled ? 0.5 : 1,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Page 2: Size ---
class _SizePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tank size', style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Enter the volume, or we can calculate it from dimensions.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // Volume input
          TextFormField(
            initialValue: volumeLitres > 0 ? volumeLitres.toString() : '',
            decoration: const InputDecoration(
              labelText: 'Volume (litres)',
              hintText: 'e.g., 120',
              suffixText: 'L',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            onChanged: (v) {
              final value = double.tryParse(v);
              if (value != null) onVolumeChanged(value);
            },
          ),
          
          const SizedBox(height: 24),
          
          Text('Dimensions (optional)', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Useful for stocking recommendations.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: lengthCm?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Length',
                    suffixText: 'cm',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  onChanged: (v) => onLengthChanged(double.tryParse(v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: widthCm?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Width',
                    suffixText: 'cm',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  onChanged: (v) => onWidthChanged(double.tryParse(v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: heightCm?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    suffixText: 'cm',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  onChanged: (v) => onHeightChanged(double.tryParse(v)),
                ),
              ),
            ],
          ),
          
          // Quick size presets
          const SizedBox(height: 24),
          Text('Quick presets', style: AppTypography.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SizePreset(label: '20L', onTap: () => onVolumeChanged(20)),
              _SizePreset(label: '60L', onTap: () => onVolumeChanged(60)),
              _SizePreset(label: '120L', onTap: () => onVolumeChanged(120)),
              _SizePreset(label: '200L', onTap: () => onVolumeChanged(200)),
              _SizePreset(label: '300L', onTap: () => onVolumeChanged(300)),
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
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Water type', style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'This sets default temperature and parameter targets.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          _WaterTypeSelector(
            selected: waterType,
            onChanged: onWaterTypeChanged,
          ),
          
          const SizedBox(height: 32),
          
          Text('When did you set up this tank?', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Helps track cycling progress and maintenance history.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          InkWell(
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
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    '${startDate.day}/${startDate.month}/${startDate.year}',
                    style: AppTypography.bodyLarge,
                  ),
                  const Spacer(),
                  const Icon(Icons.edit, color: AppColors.textHint, size: 18),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          TextButton(
            onPressed: () => onStartDateChanged(DateTime.now()),
            child: const Text('Set to today'),
          ),
        ],
      ),
    );
  }
}

class _WaterTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _WaterTypeSelector({
    required this.selected,
    required this.onChanged,
  });

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
        const SizedBox(height: 12),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
