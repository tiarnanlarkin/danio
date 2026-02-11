/// Beautiful, animated UI widgets for all exercise types
/// Duolingo-style interactive learning experiences
library;

import 'package:flutter/material.dart';
import '../models/exercises.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

// ==========================================
// EXERCISE WIDGET BUILDER
// ==========================================

/// Main widget that renders any exercise type
class ExerciseWidget extends StatelessWidget {
  final Exercise exercise;
  final Function(dynamic answer) onAnswer;
  final bool isAnswered;
  final bool? isCorrect;
  final dynamic userAnswer;

  const ExerciseWidget({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isAnswered = false,
    this.isCorrect,
    this.userAnswer,
  });

  @override
  Widget build(BuildContext context) {
    switch (exercise.type) {
      case ExerciseType.multipleChoice:
        return MultipleChoiceWidget(
          exercise: exercise as MultipleChoiceExercise,
          onAnswer: onAnswer,
          isAnswered: isAnswered,
          isCorrect: isCorrect,
          selectedAnswer: userAnswer as int?,
        );
      case ExerciseType.fillBlank:
        return FillBlankWidget(
          exercise: exercise as FillBlankExercise,
          onAnswer: onAnswer,
          isAnswered: isAnswered,
          isCorrect: isCorrect,
          userAnswers: userAnswer as List<String>?,
        );
      case ExerciseType.trueFalse:
        return TrueFalseWidget(
          exercise: exercise as TrueFalseExercise,
          onAnswer: onAnswer,
          isAnswered: isAnswered,
          isCorrect: isCorrect,
          selectedAnswer: userAnswer as bool?,
        );
      case ExerciseType.matching:
        return MatchingWidget(
          exercise: exercise as MatchingExercise,
          onAnswer: onAnswer,
          isAnswered: isAnswered,
          isCorrect: isCorrect,
          userPairs: userAnswer as Map<int, int>?,
        );
      case ExerciseType.ordering:
        return OrderingWidget(
          exercise: exercise as OrderingExercise,
          onAnswer: onAnswer,
          isAnswered: isAnswered,
          isCorrect: isCorrect,
          userOrder: userAnswer as List<int>?,
        );
    }
  }
}

// ==========================================
// 1. MULTIPLE CHOICE WIDGET
// ==========================================

class MultipleChoiceWidget extends StatefulWidget {
  final MultipleChoiceExercise exercise;
  final Function(int) onAnswer;
  final bool isAnswered;
  final bool? isCorrect;
  final int? selectedAnswer;

  const MultipleChoiceWidget({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isAnswered = false,
    this.isCorrect,
    this.selectedAnswer,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.exercise.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = widget.selectedAnswer == index;
        final isCorrect = index == widget.exercise.correctIndex;

        return _buildOption(context, index, option, isSelected, isCorrect);
      }).toList(),
    );
  }

  Widget _buildOption(
    BuildContext context,
    int index,
    String option,
    bool isSelected,
    bool isCorrect,
  ) {
    Color? bgColor;
    Color? borderColor;
    IconData? icon;

    if (widget.isAnswered) {
      if (isCorrect) {
        bgColor = AppColors.success.withOpacity(0.1);
        borderColor = AppColors.success;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        bgColor = AppColors.error.withOpacity(0.1);
        borderColor = AppColors.error;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      bgColor = AppColors.primary.withOpacity(0.1);
      borderColor = AppColors.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedScale(
        scale: isSelected && !widget.isAnswered ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: InkWell(
          onTap: widget.isAnswered
              ? null
              : () {
                  _controller.forward().then((_) => _controller.reverse());
                  widget.onAnswer(index);
                },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor ?? AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor ?? AppColors.surfaceVariant,
                width: borderColor != null ? 2 : 1,
              ),
              boxShadow: isSelected && !widget.isAnswered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected && !widget.isAnswered
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: icon != null
                        ? Icon(
                            icon,
                            size: 24,
                            color: isCorrect
                                ? AppColors.success
                                : AppColors.error,
                          )
                        : Text(
                            String.fromCharCode(65 + index), // A, B, C, D...
                            style: AppTypography.labelLarge.copyWith(
                              color: isSelected && !widget.isAnswered
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
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

// ==========================================
// 2. FILL IN THE BLANK WIDGET
// ==========================================

class FillBlankWidget extends StatefulWidget {
  final FillBlankExercise exercise;
  final Function(List<String>) onAnswer;
  final bool isAnswered;
  final bool? isCorrect;
  final List<String>? userAnswers;

  const FillBlankWidget({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isAnswered = false,
    this.isCorrect,
    this.userAnswers,
  });

  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<FillBlankWidget> {
  late List<TextEditingController> _controllers;
  late List<String?> _selectedWords; // For word bank mode

  @override
  void initState() {
    super.initState();
    final numberOfBlanks = widget.exercise.numberOfBlanks;

    if (widget.exercise.wordBank != null) {
      // Word bank mode
      _selectedWords = List.filled(numberOfBlanks, null);
    } else {
      // Text input mode
      _controllers = List.generate(
        numberOfBlanks,
        (i) => TextEditingController(text: widget.userAnswers?[i] ?? ''),
      );

      // Listen to changes
      for (final controller in _controllers) {
        controller.addListener(_onTextChanged);
      }
    }
  }

  @override
  void dispose() {
    if (widget.exercise.wordBank == null) {
      for (final controller in _controllers) {
        controller.removeListener(_onTextChanged);
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _onTextChanged() {
    final answers = _controllers.map((c) => c.text).toList();
    if (answers.every((a) => a.isNotEmpty)) {
      widget.onAnswer(answers);
    }
  }

  void _onWordSelected(int blankIndex, String word) {
    setState(() {
      _selectedWords[blankIndex] = word;
    });

    if (_selectedWords.every((w) => w != null)) {
      widget.onAnswer(_selectedWords.cast<String>());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exercise.wordBank != null) {
      return _buildWordBankMode();
    } else {
      return _buildTextInputMode();
    }
  }

  Widget _buildTextInputMode() {
    final parts = widget.exercise.getSentenceParts();
    final widgets = <Widget>[];

    for (int i = 0; i < parts.length; i++) {
      // Add text part
      if (parts[i].isNotEmpty) {
        widgets.add(
          Text(
            parts[i],
            style: AppTypography.headlineSmall.copyWith(height: 1.8),
          ),
        );
      }

      // Add blank input (except after last part)
      if (i < parts.length - 1) {
        widgets.add(_buildBlankInput(i));
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: widgets,
    );
  }

  Widget _buildBlankInput(int index) {
    final isCorrect =
        widget.isAnswered &&
        widget.exercise.validate(_controllers.map((c) => c.text).toList());

    final thisBlankCorrect =
        widget.isAnswered &&
        _controllers[index].text.toLowerCase() ==
            widget.exercise.correctAnswers[index].toLowerCase();

    return Container(
      constraints: const BoxConstraints(minWidth: 80, maxWidth: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TextField(
        controller: _controllers[index],
        enabled: !widget.isAnswered,
        textAlign: TextAlign.center,
        style: AppTypography.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: widget.isAnswered
              ? (thisBlankCorrect ? AppColors.success : AppColors.error)
              : AppColors.primary,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.isAnswered
              ? (thisBlankCorrect
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1))
              : AppColors.primary.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.isAnswered
                  ? (thisBlankCorrect ? AppColors.success : AppColors.error)
                  : AppColors.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.5),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildWordBankMode() {
    final parts = widget.exercise.getSentenceParts();
    final usedWords = <String>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sentence with blanks
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: List.generate(parts.length * 2 - 1, (i) {
            if (i.isEven) {
              // Text part
              final partIndex = i ~/ 2;
              return Text(
                parts[partIndex],
                style: AppTypography.headlineSmall.copyWith(height: 1.8),
              );
            } else {
              // Blank
              final blankIndex = i ~/ 2;
              return _buildWordBankBlank(blankIndex);
            }
          }),
        ),

        const SizedBox(height: 32),

        // Word bank
        Text(
          'Tap a word to fill the blank',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.exercise.wordBank!.map((word) {
            final isUsed = _selectedWords.contains(word);
            return _buildWordBankChip(word, isUsed);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWordBankBlank(int index) {
    final selectedWord = _selectedWords[index];
    final isCorrect =
        widget.isAnswered &&
        selectedWord?.toLowerCase() ==
            widget.exercise.correctAnswers[index].toLowerCase();

    return Container(
      constraints: const BoxConstraints(minWidth: 80),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selectedWord != null
            ? (widget.isAnswered
                  ? (isCorrect
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1))
                  : AppColors.primary.withOpacity(0.1))
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selectedWord != null
              ? (widget.isAnswered
                    ? (isCorrect ? AppColors.success : AppColors.error)
                    : AppColors.primary)
              : AppColors.surfaceVariant,
          width: 2,
        ),
      ),
      child: Text(
        selectedWord ?? '___',
        style: AppTypography.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: selectedWord != null
              ? (widget.isAnswered
                    ? (isCorrect ? AppColors.success : AppColors.error)
                    : AppColors.primary)
              : AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildWordBankChip(String word, bool isUsed) {
    return AnimatedOpacity(
      opacity: isUsed && !widget.isAnswered ? 0.3 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: ActionChip(
        label: Text(word),
        onPressed: isUsed && !widget.isAnswered
            ? null
            : () {
                if (!widget.isAnswered) {
                  // Find first empty blank
                  final emptyIndex = _selectedWords.indexOf(null);
                  if (emptyIndex != -1) {
                    _onWordSelected(emptyIndex, word);
                  }
                }
              },
        backgroundColor: isUsed
            ? AppColors.surfaceVariant
            : AppColors.primary.withOpacity(0.1),
        side: BorderSide(
          color: isUsed ? AppColors.surfaceVariant : AppColors.primary,
        ),
      ),
    );
  }
}

// ==========================================
// 3. TRUE/FALSE WIDGET
// ==========================================

class TrueFalseWidget extends StatelessWidget {
  final TrueFalseExercise exercise;
  final Function(bool) onAnswer;
  final bool isAnswered;
  final bool? isCorrect;
  final bool? selectedAnswer;

  const TrueFalseWidget({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isAnswered = false,
    this.isCorrect,
    this.selectedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOption(context, true, 'True', Icons.check_circle_outline),
        const SizedBox(height: 16),
        _buildOption(context, false, 'False', Icons.cancel_outlined),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    bool value,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedAnswer == value;
    final isCorrect = value == exercise.correctAnswer;

    Color? bgColor;
    Color? borderColor;
    Color iconColor = AppColors.textSecondary;

    if (isAnswered) {
      if (isCorrect) {
        bgColor = AppColors.success.withOpacity(0.1);
        borderColor = AppColors.success;
        iconColor = AppColors.success;
      } else if (isSelected && !isCorrect) {
        bgColor = AppColors.error.withOpacity(0.1);
        borderColor = AppColors.error;
        iconColor = AppColors.error;
      }
    } else if (isSelected) {
      bgColor = AppColors.primary.withOpacity(0.1);
      borderColor = AppColors.primary;
      iconColor = AppColors.primary;
    }

    return AnimatedScale(
      scale: isSelected && !isAnswered ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: InkWell(
        onTap: isAnswered ? null : () => onAnswer(value),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? AppColors.surfaceVariant,
              width: borderColor != null ? 2 : 1,
            ),
            boxShadow: isSelected && !isAnswered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTypography.headlineSmall.copyWith(
                  color: isSelected || (isAnswered && isCorrect)
                      ? iconColor
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. MATCHING WIDGET
// ==========================================

class MatchingWidget extends StatefulWidget {
  final MatchingExercise exercise;
  final Function(Map<int, int>) onAnswer;
  final bool isAnswered;
  final bool? isCorrect;
  final Map<int, int>? userPairs;

  const MatchingWidget({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isAnswered = false,
    this.isCorrect,
    this.userPairs,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  int? _selectedLeft;
  final Map<int, int> _pairs = {};

  @override
  void initState() {
    super.initState();
    if (widget.userPairs != null) {
      _pairs.addAll(widget.userPairs!);
    }
  }

  void _onLeftTap(int index) {
    if (widget.isAnswered) return;

    setState(() {
      if (_selectedLeft == index) {
        _selectedLeft = null;
      } else {
        _selectedLeft = index;
      }
    });
  }

  void _onRightTap(int index) {
    if (widget.isAnswered || _selectedLeft == null) return;

    setState(() {
      // Remove any existing pair with this right item
      _pairs.removeWhere((k, v) => v == index);

      // Create new pair
      _pairs[_selectedLeft!] = index;
      _selectedLeft = null;
    });

    // Check if all pairs are made
    if (_pairs.length == widget.exercise.leftItems.length) {
      widget.onAnswer(_pairs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Tap an item on the left, then tap its match on the right',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                children: widget.exercise.leftItems.asMap().entries.map((
                  entry,
                ) {
                  return _buildLeftItem(entry.key, entry.value);
                }).toList(),
              ),
            ),

            const SizedBox(width: 16),

            // Right column
            Expanded(
              child: Column(
                children: widget.exercise.rightItems.asMap().entries.map((
                  entry,
                ) {
                  return _buildRightItem(entry.key, entry.value);
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeftItem(int index, String text) {
    final isSelected = _selectedLeft == index;
    final isPaired = _pairs.containsKey(index);
    final pairedRightIndex = _pairs[index];

    final isCorrect =
        widget.isAnswered &&
        widget.exercise.correctPairs[index] == pairedRightIndex;

    Color? bgColor;
    Color? borderColor;

    if (widget.isAnswered && isPaired) {
      bgColor = isCorrect
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1);
      borderColor = isCorrect ? AppColors.success : AppColors.error;
    } else if (isSelected) {
      bgColor = AppColors.primary.withOpacity(0.1);
      borderColor = AppColors.primary;
    } else if (isPaired) {
      bgColor = AppColors.accent.withOpacity(0.1);
      borderColor = AppColors.accent;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _onLeftTap(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? AppColors.surfaceVariant,
              width: borderColor != null ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (isPaired)
                Icon(
                  widget.isAnswered
                      ? (isCorrect ? Icons.check_circle : Icons.cancel)
                      : Icons.link,
                  size: 20,
                  color: widget.isAnswered
                      ? (isCorrect ? AppColors.success : AppColors.error)
                      : AppColors.accent,
                ),
              if (isPaired) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightItem(int index, String text) {
    final isPaired = _pairs.containsValue(index);
    final leftIndex = _pairs.entries
        .where((e) => e.value == index)
        .map((e) => e.key)
        .firstOrNull;

    final isCorrect =
        widget.isAnswered &&
        leftIndex != null &&
        widget.exercise.correctPairs[leftIndex] == index;

    Color? bgColor;
    Color? borderColor;

    if (widget.isAnswered && isPaired) {
      bgColor = isCorrect
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1);
      borderColor = isCorrect ? AppColors.success : AppColors.error;
    } else if (isPaired) {
      bgColor = AppColors.accent.withOpacity(0.1);
      borderColor = AppColors.accent;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _onRightTap(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? AppColors.surfaceVariant,
              width: borderColor != null ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(text, style: AppTypography.bodyMedium)),
              if (isPaired) const SizedBox(width: 8),
              if (isPaired)
                Icon(
                  widget.isAnswered
                      ? (isCorrect ? Icons.check_circle : Icons.cancel)
                      : Icons.link,
                  size: 20,
                  color: widget.isAnswered
                      ? (isCorrect ? AppColors.success : AppColors.error)
                      : AppColors.accent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. ORDERING/SEQUENCING WIDGET
// ==========================================

class OrderingWidget extends StatefulWidget {
  final OrderingExercise exercise;
  final Function(List<int>) onAnswer;
  final bool isAnswered;
  final bool? isCorrect;
  final List<int>? userOrder;

  const OrderingWidget({
    super.key,
    required this.exercise,
    required this.onAnswer,
    this.isAnswered = false,
    this.isCorrect,
    this.userOrder,
  });

  @override
  State<OrderingWidget> createState() => _OrderingWidgetState();
}

class _OrderingWidgetState extends State<OrderingWidget> {
  late List<int> _currentOrder;

  @override
  void initState() {
    super.initState();
    if (widget.userOrder != null) {
      _currentOrder = List.from(widget.userOrder!);
    } else {
      // Start with shuffled order
      _currentOrder = List.generate(widget.exercise.items.length, (i) => i);
      _currentOrder.shuffle();
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (widget.isAnswered) return;

    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _currentOrder.removeAt(oldIndex);
      _currentOrder.insert(newIndex, item);
    });

    widget.onAnswer(_currentOrder);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.touch_app, color: AppColors.info),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Drag items to reorder them',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: _onReorder,
          buildDefaultDragHandles: !widget.isAnswered,
          itemCount: _currentOrder.length,
          itemBuilder: (context, index) {
            return _buildOrderItem(index);
          },
        ),
      ],
    );
  }

  Widget _buildOrderItem(int displayIndex) {
    final itemIndex = _currentOrder[displayIndex];
    final text = widget.exercise.items[itemIndex];

    final correctOrder =
        widget.exercise.correctOrder ??
        List.generate(widget.exercise.items.length, (i) => i);
    final isCorrectPosition =
        widget.isAnswered && correctOrder[displayIndex] == itemIndex;

    Color? bgColor;
    Color? borderColor;

    if (widget.isAnswered) {
      bgColor = isCorrectPosition
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1);
      borderColor = isCorrectPosition ? AppColors.success : AppColors.error;
    }

    return Padding(
      key: ValueKey(itemIndex),
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? AppColors.surfaceVariant,
            width: borderColor != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.isAnswered
                    ? (isCorrectPosition ? AppColors.success : AppColors.error)
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${displayIndex + 1}',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(text, style: AppTypography.bodyLarge)),
            if (!widget.isAnswered)
              Icon(Icons.drag_handle, color: AppColors.textSecondary),
            if (widget.isAnswered)
              Icon(
                isCorrectPosition ? Icons.check_circle : Icons.cancel,
                color: isCorrectPosition ? AppColors.success : AppColors.error,
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// EXPLANATION CARD
// ==========================================

class ExplanationCard extends StatelessWidget {
  final String explanation;
  final bool isCorrect;

  const ExplanationCard({
    super.key,
    required this.explanation,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.lightbulb_outline : Icons.info_outline,
            color: AppColors.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Great job!' : 'Learn from this',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(explanation, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
