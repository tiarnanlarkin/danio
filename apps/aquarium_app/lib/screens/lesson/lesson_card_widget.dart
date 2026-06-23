import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/learning.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_card.dart';
import '../../widgets/danio_snack_bar.dart';

/// Renders the lesson content card (text, sections) and the "Take Quiz"
/// / "Complete Lesson" bottom action.  Pure display widget — all behaviour
/// callbacks are passed in from [_LessonScreenState].
class LessonCardWidget extends StatelessWidget {
  static const double _maxReadableWidth = 720;

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
    final guide = lesson.guide;
    final hasGuide = guide != null && !guide.isEmpty;
    // Calculate total items: title + spacing + time row + spacing + sections + final spacing
    final totalItems = 4 + (hasGuide ? 1 : 0) + lesson.sections.length + 1;
    final sectionsStartIndex = hasGuide ? 5 : 4;

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
                return _ReadableLessonFrame(
                  child: Hero(
                    tag: 'lesson-${lesson.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        lesson.title,
                        style: AppTypography.headlineLarge,
                      ),
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
                return _ReadableLessonFrame(
                  child: Row(
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
                  ),
                );
              }

              // Spacing before sections
              if (index == 3) {
                return const SizedBox(height: AppSpacing.lg);
              }

              if (hasGuide && index == 4) {
                return _ReadableLessonFrame(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: _LessonGuideCard(guide: guide),
                  ),
                );
              }

              // Lesson sections
              if (index < sectionsStartIndex + lesson.sections.length) {
                final sectionIndex = index - sectionsStartIndex;
                final section = lesson.sections[sectionIndex];
                return _ReadableLessonFrame(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildSection(context, section),
                  ),
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _maxReadableWidth,
                ),
                child: AppButton(
                  onPressed: isCompletingLesson ? null : onAction,
                  label: lesson.quiz != null ? 'Take Quiz' : 'Complete Lesson',
                  isLoading: isCompletingLesson,
                  isFullWidth: true,
                  size: AppButtonSize.large,
                ),
              ),
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
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.accentAlt,
                size: AppIconSizes.lg,
              ),
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
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                item,
                style: AppTypography.bodyLarge.copyWith(height: 1.5),
              ),
            );
          }).toList(),
        );

      case LessonSectionType.image:
        return _buildImageSection(context, section);
    }
  }

  Widget _buildImageSection(BuildContext context, LessonSection section) {
    final imageUrl = section.imageUrl?.trim();
    final caption = section.caption?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: AppRadius.mediumRadius,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: DecoratedBox(
              decoration: BoxDecoration(color: context.surfaceVariant),
              child: imageUrl == null || imageUrl.isEmpty
                  ? _buildImageFallback(context)
                  : _buildImage(context, imageUrl),
            ),
          ),
        ),
        if (caption != null && caption.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            caption,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImage(BuildContext context, String imageUrl) {
    final image = imageUrl.startsWith('assets/')
        ? Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImageFallback(context),
          )
        : Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes == null
                        ? null
                        : loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _buildImageFallback(context),
          );

    return Semantics(image: true, label: 'Lesson visual', child: image);
  }

  Widget _buildImageFallback(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: AppIconSizes.xl,
            color: context.textHint,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Visual unavailable',
            style: AppTypography.bodySmall.copyWith(color: context.textHint),
          ),
        ],
      ),
    );
  }
}

class _ReadableLessonFrame extends StatelessWidget {
  final Widget child;

  const _ReadableLessonFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: LessonCardWidget._maxReadableWidth,
        ),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class _LessonGuideCard extends StatelessWidget {
  final LessonLearningGuide guide;

  const _LessonGuideCard({required this.guide});

  @override
  Widget build(BuildContext context) {
    final outcomes = _cleanItems(guide.outcomes);
    final drill = _cleanItems(guide.careDrill);
    final scenario = guide.scenario.trim();
    final sources = guide.sources.where((source) {
      return source.title.trim().isNotEmpty &&
          source.publisher.trim().isNotEmpty;
    }).toList();

    return AppCard(
      variant: AppCardVariant.filled,
      padding: AppCardPadding.standard,
      backgroundColor: AppOverlays.primary10,
      border: Border.all(color: AppOverlays.primary30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuideSectionTitle(
            icon: Icons.route_outlined,
            title: 'You\'ll learn',
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...outcomes.map(
            (outcome) => _GuideBullet(icon: Icons.check_circle, text: outcome),
          ),
          if (scenario.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _GuideSectionTitle(
              icon: Icons.psychology_alt_outlined,
              title: 'Real tank scenario',
              color: AppColors.info,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              scenario,
              style: AppTypography.bodyMedium.copyWith(height: 1.45),
            ),
          ],
          if (drill.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _GuideSectionTitle(
              icon: Icons.fact_check_outlined,
              title: 'Care drill',
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < drill.length; i++)
              _GuideNumberedStep(index: i + 1, text: drill[i]),
          ],
          if (sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _GuideSectionTitle(
              icon: Icons.verified_outlined,
              title: 'References',
              color: AppColors.accentAlt,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...sources.map((source) => _LessonSourceRow(source: source)),
          ],
        ],
      ),
    );
  }

  static List<String> _cleanItems(List<String> items) {
    return items.map((item) => item.trim()).where((item) {
      return item.isNotEmpty;
    }).toList();
  }
}

class _GuideSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _GuideSectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: AppIconSizes.sm),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: AppTypography.titleSmall),
      ],
    );
  }
}

class _GuideBullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GuideBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppIconSizes.sm, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideNumberedStep extends StatelessWidget {
  final int index;
  final String text;

  const _GuideNumberedStep({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: AppTypography.labelSmall.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonSourceRow extends StatelessWidget {
  final LessonSource source;

  const _LessonSourceRow({required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(184),
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(source.title, style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${source.publisher} - ${source.note}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            label: 'Open',
            leadingIcon: Icons.open_in_new,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
            onPressed: () => _openSource(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openSource(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(source.url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      DanioSnackBar.error(context, 'Could not open source');
    }
  }
}
