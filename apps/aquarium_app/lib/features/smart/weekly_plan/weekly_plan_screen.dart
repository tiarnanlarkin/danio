import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../providers/tank_provider.dart';
import '../../../services/openai_service.dart';
import '../../../theme/app_theme.dart';
import '../models/smart_models.dart';
import '../smart_providers.dart';

/// Screen that generates and displays a personalised weekly maintenance plan.
class WeeklyPlanScreen extends ConsumerStatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  ConsumerState<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends ConsumerState<WeeklyPlanScreen> {
  bool _loading = false;
  String? _error;

  static const _dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    // Generate if no cached plan.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plan = ref.read(weeklyPlanProvider);
      if (plan == null) _generate();
    });
  }

  Future<void> _generate() async {
    final openai = ref.read(openAIServiceProvider);
    if (!openai.isConfigured) {
      setState(() => _error = 'AI features require an OpenAI API key.\n'
          'This feature is coming soon! Stay tuned for updates.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Gather tank data.
      final tanks = await ref.read(tanksProvider.future);
      if (tanks.isEmpty) {
        setState(() {
          _error = 'Add a tank first to generate a weekly plan.';
          _loading = false;
        });
        return;
      }

      // Gather livestock for each tank for context-aware planning.
      final tankDetails = <String>[];
      for (final t in tanks) {
        final livestock = await ref.read(livestockProvider(t.id).future);
        final fishList = livestock.isNotEmpty
            ? livestock.map((l) => '${l.commonName} x${l.count}').join(', ')
            : 'no livestock added yet';
        tankDetails.add(
          '${t.name} (${t.volumeLitres}L, ${t.type.name}, '
          'created ${t.createdAt.toIso8601String().substring(0, 10)}, '
          'fish: $fishList)',
        );
      }
      final tankSummaries = tankDetails.join('; ');

      final prompt =
          'Based on these aquariums: $tankSummaries. '
          'Generate a practical 7-day maintenance plan tailored to these '
          'specific tanks and their inhabitants. Consider: water change '
          'frequency for the tank size and bioload, species-specific feeding '
          'schedules, filter maintenance, plant care if applicable, and water '
          'testing schedule. '
          'Return ONLY valid JSON: '
          '{"days": [{"day": "Mon", "tasks": [{"task": "description", '
          '"duration_mins": 5, "priority": "normal"}]}]}. '
          'Include all 7 days Mon-Sun.';

      final result = await openai.chatCompletion(
        messages: [
          const ChatMessage(
            role: 'system',
            content: 'You are Danio AI, an expert aquarium maintenance planner '
                'with deep knowledge of freshwater and marine fishkeeping. '
                'Create practical, tailored maintenance schedules based on the '
                'specific tanks, species, and bioload provided. Consider tank '
                'maturity, stocking density, and species-specific needs. '
                'Prioritise water quality - ammonia/nitrite should always be 0. '
                'Always return valid JSON only, no markdown or explanation.',
          ),
          ChatMessage(role: 'user', content: prompt),
        ],
        maxTokens: 1024,
      );

      // Parse JSON response.
      var text = result.text.trim();
      if (text.startsWith('```')) {
        text = text.replaceAll(RegExp(r'^```\w*\n?'), '').replaceAll('```', '');
      }

      final json = jsonDecode(text) as Map<String, dynamic>;
      final plan = WeeklyPlan.fromJson({
        ...json,
        'generated_at': DateTime.now().toIso8601String(),
      });

      ref.read(weeklyPlanProvider.notifier).save(plan);
      ref.read(aiHistoryProvider.notifier).add(
        type: 'weekly_plan',
        summary: 'Generated weekly maintenance plan',
      );
    } on OpenAIException catch (e) {
      setState(() => _error = 'AI error: ${e.message}');
    } catch (e) {
      setState(() => _error = 'Couldn\'t generate your plan. Try again in a moment.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = ref.watch(weeklyPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Plan'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _generate,
            tooltip: 'Regenerate',
          ),
        ],
      ),
      body: _loading
          ? _buildLoading()
          : _error != null
              ? _buildError(theme)
              : plan != null
                  ? _buildPlan(theme, plan)
                  : _buildEmpty(theme),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text('Generating your weekly plan...'),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _generate,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 48, color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No plan yet -- tap generate to get started!',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: _generate,
            child: const Text('Generate Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlan(ThemeData theme, WeeklyPlan plan) {
    // Sort days in correct order.
    final sortedDays = List<PlanDay>.from(plan.days)
      ..sort((a, b) {
        final ai = _dayOrder.indexOf(a.day);
        final bi = _dayOrder.indexOf(b.day);
        return ai.compareTo(bi);
      });

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: sortedDays.length + 1, // +1 for footer
      itemBuilder: (context, index) {
        if (index == sortedDays.length) {
          return _buildFooter(theme, plan);
        }

        final day = sortedDays[index];
        return _DayCard(day: day, index: index);
      },
    );
  }

  Widget _buildFooter(ThemeData theme, WeeklyPlan plan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Text(
            'Generated ${_formatDate(plan.generatedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.refresh),
              label: const Text('Regenerate Plan'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _DayCard extends StatelessWidget {
  final PlanDay day;
  final int index;

  const _DayCard({required this.day, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.md2Radius,
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            day.day,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          _fullDayName(day.day),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${day.tasks.length} task${day.tasks.length == 1 ? "" : "s"} · '
          '${day.tasks.fold<int>(0, (sum, t) => sum + t.durationMins)} min',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        initiallyExpanded: index == 0,
        children: day.tasks.map((task) {
          return ListTile(
            leading: _priorityIcon(task.priority),
            title: Text(task.task, style: theme.textTheme.bodyMedium),
            trailing: Text(
              '${task.durationMins}m',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            dense: true,
          );
        }).toList(),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.05);
  }

  Widget _priorityIcon(String priority) {
    final (icon, color) = switch (priority.toLowerCase()) {
      'high' => (Icons.arrow_upward, AppColors.error),
      'low' => (Icons.arrow_downward, AppColors.textSecondary),
      _ => (Icons.remove, AppColors.primary),
    };
    return Icon(icon, size: 16, color: color);
  }

  String _fullDayName(String abbr) {
    return switch (abbr) {
      'Mon' => 'Monday',
      'Tue' => 'Tuesday',
      'Wed' => 'Wednesday',
      'Thu' => 'Thursday',
      'Fri' => 'Friday',
      'Sat' => 'Saturday',
      'Sun' => 'Sunday',
      _ => abbr,
    };
  }
}
