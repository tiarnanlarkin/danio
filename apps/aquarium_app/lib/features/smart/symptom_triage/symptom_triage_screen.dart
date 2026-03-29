import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/log_entry.dart';
import '../../../providers/storage_provider.dart';
import '../../../providers/tank_provider.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../services/api_rate_limiter.dart';
import '../../../services/openai_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/core/app_button.dart';
import '../../../widgets/core/app_dialog.dart';
import '../../../widgets/core/bubble_loader.dart';
import '../../../widgets/danio_snack_bar.dart';
import '../../../widgets/offline_indicator.dart';
import '../smart_providers.dart';
import '../../../utils/logger.dart';

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

  /// Key for persisting the OpenAI data disclosure acceptance.
  static const _openaiDisclosureKey = 'openai_disclosure_accepted';

  /// Shows a one-time disclosure about OpenAI data handling for Symptom Triage.
  /// Returns `true` if the user accepts, `false` if they cancel.
  Future<bool> _ensureOpenAIDisclosure() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (prefs.getBool(_openaiDisclosureKey) == true) return true;

    if (!mounted) return false;
    final accepted = await showAppConfirmDialog(
      context: context,
      title: 'OpenAI Data Disclosure',
      message:
          'Text you enter and water parameters are sent to OpenAI servers in '
          'the US, retained up to 30 days per OpenAI\'s data retention policy. '
          'OpenAI does not use API data to train their models.',
      confirmLabel: 'I Understand',
      cancelLabel: 'Cancel',
      barrierDismissible: false,
    );

    if (accepted == true) {
      await prefs.setBool(_openaiDisclosureKey, true);
      return true;
    }
    return false;
  }

  void _nextStep() {
    if (_step == 0) {
      if (_selectedSymptoms.isEmpty &&
          _freeTextController.text.trim().isEmpty) {
        DanioSnackBar.show(context, 'Select at least one symptom');
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      _advanceToDiagnosis();
    }
  }

  Future<void> _advanceToDiagnosis() async {
    final accepted = await _ensureOpenAIDisclosure();
    if (!accepted || !mounted) return;
    setState(() => _step = 2);
    _runDiagnosis();
  }

  Future<void> _runDiagnosis() async {
    final openai = ref.read(openAIServiceProvider);
    if (!openai.isConfigured) {
      setState(
        () => _error =
            'Symptom Triage isn\'t available yet — we\'re working on bringing it to you! 🩺',
      );
      return;
    }

    // Offline check.
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      setState(() => _error = OpenAIUserMessages.offline);
      return;
    }

    // Rate limit check.
    final rateLimiter = ref.read(apiRateLimiterProvider);
    if (!rateLimiter.canRequest(AIFeature.symptomTriage)) {
      setState(() => _error = OpenAIUserMessages.rateLimited);
      return;
    }

    final symptoms = [
      ..._selectedSymptoms,
      if (_freeTextController.text.trim().isNotEmpty)
        _freeTextController.text.trim(),
    ].join(', ');

    final params = StringBuffer();
    if (_phController.text.isNotEmpty) {
      params.write('pH: ${_phController.text}, ');
    }
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
            content:
                'You are Danio AI, an expert aquatic veterinarian and fish '
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

      // Record rate limit & AI history.
      rateLimiter.recordRequest(AIFeature.symptomTriage);
      ref
          .read(aiHistoryProvider.notifier)
          .add(type: 'symptom_triage', summary: 'Triage: $symptoms');
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _error = OpenAIUserMessages.timeout);
    } on OpenAIException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e, st) {
      logError('SymptomTriageScreen: triage failed: $e', stackTrace: st, tag: 'SymptomTriageScreen');
      if (!mounted) return;
      setState(() => _error = 'We hit a snag. Try again in a moment.');
    } finally {
      if (mounted) setState(() => _streaming = false);
    }
  }

  Future<void> _saveToJournal() async {
    final diagnosisText = _stripMarkdown(_diagnosis);
    if (diagnosisText.isEmpty) return;

    // Get first available tank to attach the journal entry.
    final tanksAsync = await ref.read(tanksProvider.future);
    if (tanksAsync.isEmpty) {
      if (!mounted) return;
      DanioSnackBar.warning(context, 'No tanks found — add a tank first.');
      return;
    }
    final tankId = tanksAsync.first.id;

    final now = DateTime.now();
    final entry = LogEntry(
      id: now.millisecondsSinceEpoch.toString(),
      tankId: tankId,
      type: LogType.observation,
      timestamp: now,
      createdAt: now,
      notes: '🩺 Symptom Triage Result\n\n$diagnosisText',
    );

    try {
      final storage = ref.read(storageServiceProvider);
      await storage.saveLog(entry);
      if (!mounted) return;
      DanioSnackBar.show(context, 'Diagnosis saved to journal ✅');
      Navigator.of(context).pop();
    } catch (e, st) {
      logError('SymptomTriageScreen: saveToJournal failed: $e', stackTrace: st, tag: 'SymptomTriageScreen');
      if (!mounted) return;
      DanioSnackBar.warning(context, 'Could not save to journal. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Triage'), centerTitle: true),
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
                AppButton(
                  label: _step == 1 ? 'Get Diagnosis' : 'Next',
                  onPressed: details.onStepContinue,
                  variant: AppButtonVariant.primary,
                ),
                if (_step > 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: 'Back',
                    onPressed: details.onStepCancel,
                    variant: AppButtonVariant.text,
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
            subtitle: _step > 0 ? Text(_selectedSymptoms.join(', ')) : null,
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
          inputFormatters: [LengthLimitingTextInputFormatter(500)],
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
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
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
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
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
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
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
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
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
          inputFormatters: [LengthLimitingTextInputFormatter(500)],
        ),
      ],
    );
  }

  /// Strip common markdown syntax so AI responses render as plain text.
  String _stripMarkdown(String text) {
    return text
        // Remove ATX headings (# Heading)
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
        // Remove bold/italic markers (**, *, __, _)
        .replaceAll(RegExp(r'\*{1,3}|_{1,3}'), '')
        // Remove inline code backticks
        .replaceAll(RegExp(r'`+'), '')
        // Remove horizontal rules
        .replaceAll(RegExp(r'^[-*_]{3,}\s*$', multiLine: true), '')
        // Remove blockquote markers
        .replaceAll(RegExp(r'^>\s+', multiLine: true), '')
        // Convert unordered list markers to bullet
        .replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '• ')
        .trim();
  }

  Widget _buildDiagnosisStep(ThemeData theme) {
    if (_error != null) {
      return Card(
        color: AppColors.errorAlpha10,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Try Again',
                onPressed: () {
                  setState(() {
                    _step = 1;
                    _error = null;
                  });
                },
                variant: AppButtonVariant.text,
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
                child: BubbleLoader.small(),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _diagnosis.isEmpty ? 'Analysing symptoms...' : 'Thinking...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ).animate().fadeIn(),

        if (_diagnosis.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          SelectableText(
            _stripMarkdown(_diagnosis),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],

        if (!_streaming && _diagnosis.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          // AI disclosure notice
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 12, color: context.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'AI-generated diagnosis · Not a substitute for veterinary advice',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Save to Journal',
                  onPressed: () => _saveToJournal(),
                  leadingIcon: Icons.book,
                  variant: AppButtonVariant.secondary,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'New Triage',
                  onPressed: () {
                    setState(() {
                      _step = 0;
                      _diagnosis = '';
                      _selectedSymptoms.clear();
                      _freeTextController.clear();
                    });
                  },
                  leadingIcon: Icons.refresh,
                  variant: AppButtonVariant.primary,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
