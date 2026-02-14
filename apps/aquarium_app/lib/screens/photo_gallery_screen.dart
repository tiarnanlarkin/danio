import 'dart:io';
import '../widgets/core/bubble_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/optimized_image.dart';
import '../widgets/error_state.dart';

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
        error: (e, _) => ErrorState(
          message: 'Failed to load photos',
          details: 'Please check your connection and try again.',
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
                padding: EdgeInsets.only(top: 16),
                sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              
              // For each month, add header + grid
              for (int i = 0; i < months.length; i++) ...[
                // Month header
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                padding: EdgeInsets.only(bottom: 16),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _PhotoViewerScreen(photos: photos, initialIndex: initialIndex),
      ),
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
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No Photos Yet', style: AppTypography.headlineSmall),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
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
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: AppRadius.xsRadius,
                  ),
                  child: Text(
                    DateFormat('d').format(photo.date),
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
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
  Widget build(BuildContext context) {
    final photo = widget.photos[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(DateFormat('MMMM d, y').format(photo.date)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1} / ${widget.photos.length}',
                style: AppTypography.bodySmall.copyWith(color: Colors.white),
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
                        color: Colors.black,
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
              color: Colors.black87,
              child: Text(
                photo.notes!,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
