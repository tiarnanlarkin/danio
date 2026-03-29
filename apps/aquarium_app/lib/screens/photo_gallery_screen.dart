import 'dart:io';
import '../widgets/core/bubble_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/optimized_image.dart';
import '../widgets/core/app_states.dart';
import '../utils/navigation_throttle.dart';

class PhotoGalleryScreen extends ConsumerWidget {
  final String tankId;
  final String tankName;

  const PhotoGalleryScreen({
    super.key,
    required this.tankId,
    required this.tankName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allLogsProvider(tankId));

    return Scaffold(
      appBar: AppBar(title: Text('$tankName Gallery')),
      body: logsAsync.when(
        loading: () => const Center(child: BubbleLoader()),
        error: (e, _) => AppErrorState(
          title: 'Couldn\'t load your photos',
          message: 'Check your connection and give it another go!',
          onRetry: () => ref.invalidate(allLogsProvider(tankId)),
        ),
        data: (logs) {
          // Get all logs with photos
          final photosLogs =
              logs
                  .where((l) => l.photoUrls != null && l.photoUrls!.isNotEmpty)
                  .toList()
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (photosLogs.isEmpty) {
            return _EmptyGallery();
          }

          // Flatten into photo entries
          final photos = <_PhotoEntry>[];
          for (final log in photosLogs) {
            for (final url in log.photoUrls!) {
              photos.add(
                _PhotoEntry(
                  url: url,
                  date: log.timestamp,
                  type: log.type,
                  notes: log.notes,
                ),
              );
            }
          }

          // Group by month
          final grouped = <String, List<_PhotoEntry>>{};
          for (final photo in photos) {
            final month = DateFormat('MMMM yyyy').format(photo.date);
            grouped.putIfAbsent(month, () => []).add(photo);
          }

          // Build list of slivers for each month group
          final months = grouped.keys.toList();

          return CustomScrollView(
            slivers: [
              // Top padding
              const SliverPadding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              // For each month, add header + grid
              for (int i = 0; i < months.length; i++) ...[
                // Month header
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          Text(months[i], style: AppTypography.headlineSmall),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${grouped[months[i]]!.length} photos',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Photo grid (lazy loaded via SliverGrid.builder)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                    itemCount: grouped[months[i]]!.length,
                    itemBuilder: (ctx, j) {
                      final monthPhotos = grouped[months[i]]!;
                      return _PhotoThumbnail(
                        photo: monthPhotos[j],
                        onTap: () => _showPhotoViewer(context, monthPhotos, j),
                      );
                    },
                  ),
                ),

                // Spacing after each month
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                ),
              ],

              // Bottom padding
              const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPhotoViewer(
    BuildContext context,
    List<_PhotoEntry> photos,
    int initialIndex,
  ) {
    NavigationThrottle.push(
      context,
      _PhotoViewerScreen(photos: photos, initialIndex: initialIndex),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: AppIconSizes.xxl,
              color: context.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No photos yet 📸', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Photos attached to log entries will appear here. Document your tank\'s journey!',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tip: Add photos when logging water tests, changes, or observations.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoEntry {
  final String url;
  final DateTime date;
  final LogType type;
  final String? notes;

  const _PhotoEntry({
    required this.url,
    required this.date,
    required this.type,
    this.notes,
  });
}

class _PhotoThumbnail extends StatelessWidget {
  final _PhotoEntry photo;
  final VoidCallback onTap;

  const _PhotoThumbnail({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Photo from ${DateFormat("d MMM yyyy").format(photo.date)}',
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: AppRadius.smallRadius,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.smallRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Load actual image
              OptimizedFileImage(file: File(photo.url), fit: BoxFit.cover),
              // Date badge
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs2,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blackAlpha50,
                    borderRadius: AppRadius.xsRadius,
                  ),
                  child: Text(
                    DateFormat('d').format(photo.date),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onPrimary,
                    ),
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

class _PhotoViewerScreen extends StatefulWidget {
  final List<_PhotoEntry> photos;
  final int initialIndex;

  const _PhotoViewerScreen({required this.photos, required this.initialIndex});

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.onPrimary,
        title: Text(DateFormat('d MMMM y').format(photo.date)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Text(
                '${_currentIndex + 1} / ${widget.photos.length}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.onPrimary),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemCount: widget.photos.length,
              itemBuilder: (ctx, i) {
                final p = widget.photos[i];
                return Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Container(
                      margin: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: ClipRRect(
                        borderRadius: AppRadius.mediumRadius,
                        child: OptimizedFileImage(
                          file: File(p.url),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (photo.notes != null && photo.notes!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.blackAlpha85,
              child: Text(
                photo.notes!,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onPrimary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
