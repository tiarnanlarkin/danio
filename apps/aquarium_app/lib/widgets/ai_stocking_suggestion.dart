import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import '../theme/app_theme.dart';

/// AI-powered stocking suggestion bottom sheet.
///
/// Takes tank context (size, current fish, water type) and asks
/// OpenAI for compatible fish suggestions. No other aquarium app
/// offers AI stocking advice integrated into a calculator.
class AiStockingSuggestionSheet extends StatefulWidget {
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
  State<AiStockingSuggestionSheet> createState() =>
      _AiStockingSuggestionSheetState();
}

class _AiStockingSuggestionSheetState
    extends State<AiStockingSuggestionSheet> {
  String? _suggestion;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSuggestion();
  }

  Future<void> _fetchSuggestion() async {
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

      final service = OpenAIService();
      final result = await service.chatCompletion(
        messages: [
          const ChatMessage(
            role: 'system',
            content: 'You are Danio, a friendly aquarium expert. '
                'Give practical, specific fish stocking advice. '
                'Use emoji sparingly. Be concise but helpful.',
          ),
          ChatMessage(role: 'user', content: prompt),
        ],
      );

      if (mounted) {
        setState(() {
          _suggestion = result.text;
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
      padding: EdgeInsets.all(AppSpacing.lg2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
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
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: AppSpacing.md),
                        Text('Analyzing your tank...'),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off,
                              size: 48,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(_error!, style: AppTypography.bodyMedium),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton(
                              onPressed: _fetchSuggestion,
                              child: const Text('Try Again'),
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
