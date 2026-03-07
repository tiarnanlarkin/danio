import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/openai_service.dart';
import '../../../theme/app_theme.dart';
import '../smart_providers.dart';

/// Common fish health symptoms for quick-select chips.
const _commonSymptoms = [
  'Lethargy',
  'White spots',
  'Fin damage',
  'Bloating',
  'Gasping at surface',
  'Colour loss',
  'Not eating',
  'Unusual swimming',
  'Red gills',
  'Death',
];

/// Conversational wizard for diagnosing fish health problems.
class SymptomTriageScreen extends ConsumerStatefulWidget {
  const SymptomTriageScreen({super.key});

  @override
  ConsumerState<SymptomTriageScreen> createState() =>
      _SymptomTriageScreenState();
}

class _SymptomTriageScreenState extends ConsumerState<SymptomTriageScreen> {
  int _step = 0; // 0=symptoms, 1=params, 2=diagnosis
  final _selectedSymptoms = <String>{};
  final _freeTextController = TextEditingController();

  // Water params entry
  final _phController = TextEditingController();
  final _ammoniaController = TextEditingController();
  final _nitriteController = TextEditingController();
  final _nitrateController = TextEditingController();
  final _tempController = TextEditingController();

  // Diagnosis state
  String _diagnosis = '';
  bool _streaming = false;
  String? _error;

  @override
  void dispose() {
    _freeTextController.dispose();
    _phController.dispose();
    _ammoniaController.dispose();
    _nitriteController.dispose();
    _nitrateController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0) {
      if (_selectedSymptoms.isEmpty && _freeTextController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one symptom')),
        );
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      setState(() => _step = 2);
      _runDiagnosis();
    }
  }

  Future<void> _runDiagnosis() async {
    final openai = ref.read(openAIServiceProvider);
    if (!openai.isConfigured) {
      setState(() => _error = 'AI features require an OpenAI API key.\n'
          'This feature is coming soon! Stay tuned for updates.');
      return;
    }

    final symptoms = [
      ..._selectedSymptoms,
      if (_freeTextController.text.trim().isNotEmpty)
        _freeTextController.text.trim(),
    ].join(', ');

    final params = StringBuffer();
    if (_phController.text.isNotEmpty) params.write('pH: ${_phController.text}, ');
    if (_ammoniaController.text.isNotEmpty) {
      params.write('Ammonia: ${_ammoniaController.text} ppm, ');
    }
    if (_nitriteController.text.isNotEmpty) {
      params.write('Nitrite: ${_nitriteController.text} ppm, ');
    }
    if (_nitrateController.text.isNotEmpty) {
      params.write('Nitrate: ${_nitrateController.text} ppm, ');
    }
    if (_tempController.text.isNotEmpty) {
      params.write('Temp: ${_tempController.text}°C, ');
    }

    final prompt =
        'You are an expert aquarist. A fishkeeper reports these symptoms: $symptoms. '
        '${params.isNotEmpty ? "Water parameters: $params. " : ""}'
        'Provide: likely cause (ranked), urgency (low/medium/high/critical), '
        'immediate actions, when to see a vet. Be concise and practical.';

    setState(() {
      _streaming = true;
      _diagnosis = '';
      _error = null;
    });

    try {
      final stream = openai.chatCompletionStream(
        messages: [
          const ChatMessage(
            role: 'system',
            content: 'You are Danio AI, an expert aquatic veterinarian and fish '
                'health specialist with 20+ years of experience diagnosing '
                'freshwater and marine fish diseases. You think systematically: '
                'consider the most likely diagnoses first, rule out common causes, '
                'and always factor in water chemistry. '
                'Format your response with these sections:\n'
                '## 🔍 Most Likely Diagnosis\n'
                '## ⚠️ Urgency Level\n'
                '## 🩺 Immediate Actions\n'
                '## 💊 Treatment Options\n'
                '## 🔬 If It Doesn\'t Improve\n'
                'Be concise and practical - this is for hobbyists, not academics. '
                'Always mention if a water change should be done first.',
          ),
          ChatMessage(role: 'user', content: prompt),
        ],
      );

      await for (final chunk in stream) {
        if (!mounted) return;
        setState(() => _diagnosis += chunk);
      }

      // Record in AI history.
      ref.read(aiHistoryProvider.notifier).add(
        type: 'symptom_triage',
        summary: 'Triage: $symptoms',
      );
    } on OpenAIException catch (e) {
      if (!mounted) return;
      setState(() => _error = 'AI error: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Give it another go!');
    } finally {
      if (mounted) setState(() => _streaming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Triage'),
        centerTitle: true,
      ),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _step < 2 ? _nextStep : null,
        onStepCancel: _step > 0 && !_streaming
            ? () => setState(() => _step--)
            : null,
        controlsBuilder: (context, details) {
          if (_step == 2) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(_step == 1 ? 'Get Diagnosis' : 'Next'),
                ),
                if (_step > 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // Step 1: Symptoms
          Step(
            title: const Text('What\'s wrong?'),
            subtitle: _step > 0
                ? Text(_selectedSymptoms.join(', '))
                : null,
            isActive: _step >= 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: _buildSymptomsStep(theme),
          ),

          // Step 2: Water parameters
          Step(
            title: const Text('Water Parameters'),
            subtitle: const Text('Optional - improves accuracy'),
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
            content: _buildParamsStep(theme),
          ),

          // Step 3: Diagnosis
          Step(
            title: const Text('Diagnosis'),
            isActive: _step >= 2,
            state: _step == 2 ? StepState.indexed : StepState.indexed,
            content: _buildDiagnosisStep(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: _commonSymptoms.map((symptom) {
            final selected = _selectedSymptoms.contains(symptom);
            return FilterChip(
              label: Text(symptom),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedSymptoms.add(symptom);
                  } else {
                    _selectedSymptoms.remove(symptom);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _freeTextController,
          decoration: const InputDecoration(
            labelText: 'Other symptoms or details',
            hintText: 'Describe what you see...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildParamsStep(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _phController,
                decoration: const InputDecoration(
                  labelText: 'pH',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _tempController,
                decoration: const InputDecoration(
                  labelText: 'Temp (°C)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ammoniaController,
                decoration: const InputDecoration(
                  labelText: 'Ammonia (ppm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _nitriteController,
                decoration: const InputDecoration(
                  labelText: 'Nitrite (ppm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _nitrateController,
          decoration: const InputDecoration(
            labelText: 'Nitrate (ppm)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildDiagnosisStep(ThemeData theme) {
    if (_error != null) {
      return Card(
        color: AppColors.error.withValues(alpha: 0.1),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  setState(() {
                    _step = 1;
                    _error = null;
                  });
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_streaming || _diagnosis.isEmpty)
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _diagnosis.isEmpty ? 'Analysing symptoms...' : 'Thinking...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ).animate().fadeIn(),

        if (_diagnosis.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          SelectableText(
            _diagnosis,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],

        if (!_streaming && _diagnosis.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Save to journal - pop with the diagnosis text.
                    Navigator.of(context).pop(_diagnosis);
                  },
                  icon: const Icon(Icons.book),
                  label: const Text('Save to Journal'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _step = 0;
                      _diagnosis = '';
                      _selectedSymptoms.clear();
                      _freeTextController.clear();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Triage'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
