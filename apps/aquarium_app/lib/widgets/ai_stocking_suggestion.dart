import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_button.dart';

import '../services/api_rate_limiter.dart';
import '../services/openai_service.dart';
import '../theme/app_theme.dart';
import '../widgets/core/bubble_loader.dart';
import '../widgets/offline_indicator.dart';

/// AI-powered stocking suggestion bottom sheet.
///
/// Takes tank context (size, current fish, water type) and asks
/// OpenAI for compatible fish suggestions. No other aquarium app
/// offers AI stocking advice integrated into a calculator.
class AiStockingSuggestionSheet extends ConsumerStatefulWidget {
  final double tankLitres;
  final List<String> currentFish;
  final double stockingPercent;
  final String waterType;

  const AiStockingSuggestionSheet({
    super.key,
    required this.tankLitres,
    required this.currentFish,
    required this.stockingPercent,
    this.waterType = 'freshwater',
  });

  static void show(
    BuildContext context, {
    required double tankLitres,
    required List<String> currentFish,
    required double stockingPercent,
    String waterType = 'freshwater',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: AiStockingSuggestionSheet(
            tankLitres: tankLitres,
            currentFish: currentFish,
            stockingPercent: stockingPercent,
            waterType: waterType,
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<AiStockingSuggestionSheet> createState() =>
      _AiStockingSuggestionSheetState();
}

class _AiStockingSuggestionSheetState
    extends ConsumerState<AiStockingSuggestionSheet> {
  String? _suggestion;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSuggestion();
  }

  Future<void> _fetchSuggestion() async {
    final openai = ref.read(openAIServiceProvider);
    if (!openai.isConfigured) {
      setState(
        () => _error =
            'AI stocking suggestions aren\'t available yet — we\'re working on bringing them to you! 🐟',
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
    if (!rateLimiter.canRequest(AIFeature.stockingSuggestion)) {
      setState(() => _error = OpenAIUserMessages.rateLimited);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final fishList = widget.currentFish.isEmpty
          ? 'none yet'
          : widget.currentFish.join(', ');

      final remainingPercent = (100 - widget.stockingPercent).clamp(0, 100);

      final prompt =
          'I have a ${widget.tankLitres.toStringAsFixed(0)} litre ${widget.waterType} aquarium. '
          'Current fish: $fishList. '
          'Stocking level: ${widget.stockingPercent.toStringAsFixed(0)}% '
          '(~${remainingPercent.toStringAsFixed(0)}% capacity remaining).\n\n'
          'Suggest 3-5 compatible fish species I could add. For each:\n'
          '- Common name and scientific name\n'
          '- Why it works with my current setup\n'
          '- Recommended quantity\n'
          '- Care difficulty (beginner/intermediate/advanced)\n\n'
          'Consider compatibility, water parameters, swimming levels, '
          'and bioload. Be specific and practical. If the tank is nearly full, '
          'suggest smaller species or say no more fish.';

      final result = await openai.chatCompletion(
        messages: [
          const ChatMessage(
            role: 'system',
            content:
                'You are Danio, a friendly aquarium expert. '
                'Give practical, specific fish stocking advice. '
                'Use emoji sparingly. Be concise but helpful.',
          ),
          ChatMessage(role: 'user', content: prompt),
        ],
      );

      rateLimiter.recordRequest(AIFeature.stockingSuggestion);

      if (mounted) {
        setState(() {
          _suggestion = result.text;
          _loading = false;
        });
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _error = OpenAIUserMessages.timeout;
          _loading = false;
        });
      }
    } on OpenAIException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not get AI suggestion. Check your connection.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AI Stocking Suggestions',
                style: AppTypography.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${widget.tankLitres.toStringAsFixed(0)}L ${widget.waterType} '
            '| ${widget.stockingPercent.toStringAsFixed(0)}% stocked',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          // Content
          Expanded(
            child: _loading
                ? Center(
                    child: BubbleLoader.small(
                      color: AppColors.accent,
                    ),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 48,
                          color: context.textHint,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(_error!, style: AppTypography.bodyMedium),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          onPressed: _fetchSuggestion,
                          label: 'Try Again',
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Text(
                      _suggestion ?? '',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
