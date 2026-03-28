import 'package:flutter/material.dart';
import '../../models/learning.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';

/// Renders the lesson content card (text, sections) and the "Take Quiz"
/// / "Complete Lesson" bottom action.  Pure display widget — all behaviour
/// callbacks are passed in from [_LessonScreenState].
class LessonCardWidget extends StatelessWidget {
  final Lesson lesson;
  final bool isCompletingLesson;
  final VoidCallback onAction;

  const LessonCardWidget({
    super.key,
    required this.lesson,
    required this.isCompletingLesson,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total items: title + spacing + time row + spacing + sections + final spacing
    final totalItems = 4 + lesson.sections.length + 1;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg2,
              AppSpacing.lg2,
              AppSpacing.lg2,
              160,
            ),
            itemCount: totalItems,
            itemBuilder: (context, index) {
              // Lesson title with Hero animation
              if (index == 0) {
                return Hero(
                  tag: 'lesson-${lesson.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      lesson.title,
                      style: AppTypography.headlineLarge,
                    ),
                  ),
                );
              }

              // Spacing after title
              if (index == 1) {
                return const SizedBox(height: AppSpacing.sm);
              }

              // Time estimate row
              if (index == 2) {
                return Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: AppIconSizes.xs,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${lesson.estimatedMinutes} min read',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                );
              }

              // Spacing before sections
              if (index == 3) {
                return const SizedBox(height: AppSpacing.lg);
              }

              // Lesson sections
              if (index < 4 + lesson.sections.length) {
                final sectionIndex = index - 4;
                final section = lesson.sections[sectionIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSection(context, section),
                );
              }

              // Final spacing
              return const SizedBox(height: AppSpacing.xl2);
            },
          ),
        ),

        // Bottom action
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg2),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: AppOverlays.black5,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: AppButton(
              onPressed: isCompletingLesson ? null : onAction,
              label: lesson.quiz != null ? 'Take Quiz' : 'Complete Lesson',
              isLoading: isCompletingLesson,
              isFullWidth: true,
              size: AppButtonSize.large,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, LessonSection section) {
    switch (section.type) {
      case LessonSectionType.heading:
        return Text(section.content, style: AppTypography.headlineMedium);

      case LessonSectionType.text:
        return Text(
          section.content,
          style: AppTypography.bodyLarge.copyWith(height: 1.6),
        );

      case LessonSectionType.keyPoint:
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppOverlays.primary10,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: AppOverlays.primary30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb,
                color: AppColors.primary,
                size: AppIconSizes.md,
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Text(
                  section.content,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

      case LessonSectionType.tip:
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppOverlays.success10,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: AppOverlays.success30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.tips_and_updates,
                color: AppColors.success,
                size: AppIconSizes.md,
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tip',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(section.content, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );

      case LessonSectionType.warning:
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppOverlays.warning10,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: AppOverlays.warning30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber,
                color: AppColors.warning,
                size: AppIconSizes.md,
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Heads up',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(section.content, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );

      case LessonSectionType.funFact:
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppOverlays.purple10,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: AppOverlays.purple30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🤓', style: Theme.of(context).textTheme.headlineSmall!),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fun Fact',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.accentAlt,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(section.content, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );

      case LessonSectionType.bulletList:
        final items = section.content.split('\n');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: AppTypography.bodyLarge.copyWith(height: 1.5),
              ),
            );
          }).toList(),
        );

      case LessonSectionType.numberedList:
        final items = section.content.split('\n');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: AppTypography.bodyLarge.copyWith(height: 1.5),
              ),
            );
          }).toList(),
        );

      case LessonSectionType.image:
        // Placeholder for future image support
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: context.surfaceVariant,
            borderRadius: AppRadius.mediumRadius,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: AppIconSizes.xl,
                  color: context.textHint,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Visual guide on the way!',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textHint,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
