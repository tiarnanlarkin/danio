import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';
import 'package:path/path.dart' as path;
import '../utils/logger.dart';
import '../widgets/core/bubble_loader.dart';

/// Service for optimizing image loading and caching
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  /// Cache size limits
  static const int maxCacheSize = 100; // Maximum number of cached images
  static const int maxImageDimension = 1920; // Max width/height for compression

  /// In-memory cache for recently accessed images
  final Map<String, ImageProvider> _memoryCache = {};
  final List<String> _cacheKeys = []; // For LRU eviction

  /// Get a cached image provider or create a new one with optimization
  ImageProvider getCachedImage(String imagePath, {bool thumbnail = false}) {
    final cacheKey = thumbnail ? '${imagePath}_thumb' : imagePath;

    // Check memory cache first
    if (_memoryCache.containsKey(cacheKey)) {
      _updateCacheAccess(cacheKey);
      return _memoryCache[cacheKey]!;
    }

    // Create optimized image provider
    final provider = _createOptimizedProvider(imagePath, thumbnail: thumbnail);

    // Add to cache
    _addToCache(cacheKey, provider);

    return provider;
  }

  /// Create an optimized image provider
  ImageProvider _createOptimizedProvider(
    String imagePath, {
    bool thumbnail = false,
  }) {
    final file = File(imagePath);

    if (!file.existsSync()) {
      // Return a placeholder if file doesn't exist
      return const AssetImage('assets/images/placeholder.webp');
    }

    // For thumbnails, use ResizeImage to reduce memory usage
    if (thumbnail) {
      return ResizeImage(
        FileImage(file),
        width: 200,
        height: 200,
        policy: ResizeImagePolicy.fit,
      );
    }

    // For full images, limit the maximum dimension
    return ResizeImage(
      FileImage(file),
      width: maxImageDimension,
      height: maxImageDimension,
      policy: ResizeImagePolicy.fit,
    );
  }

  /// Add image to cache with LRU eviction
  void _addToCache(String key, ImageProvider provider) {
    if (_memoryCache.length >= maxCacheSize) {
      // Remove oldest entry
      final oldestKey = _cacheKeys.removeAt(0);
      _memoryCache.remove(oldestKey);
    }

    _memoryCache[key] = provider;
    _cacheKeys.add(key);
  }

  /// Update cache access for LRU
  void _updateCacheAccess(String key) {
    _cacheKeys.remove(key);
    _cacheKeys.add(key);
  }

  /// Clear the entire cache
  void clearCache() {
    _memoryCache.clear();
    _cacheKeys.clear();
  }

  /// Compress and save image to disk
  /// Returns the path to the compressed image
  Future<String> compressAndSaveImage(
    File sourceFile, {
    required String tankId,
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final tankDir = Directory('${directory.path}/tanks/$tankId/photos');
      if (!tankDir.existsSync()) {
        tankDir.createSync(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(sourceFile.path);
      final outputPath = '${tankDir.path}/photo_$timestamp$extension';

      // Read and decode image
      final bytes = await sourceFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: maxWidth,
        targetHeight: maxHeight,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Encode to PNG (or JPEG with quality setting)
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to encode image');
      }

      // Write to file
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(byteData.buffer.asUint8List());

      return outputPath;
    } catch (e, st) {
      logError('ImageCacheService: image compression failed, falling back to copy: $e', stackTrace: st, tag: 'ImageCacheService');
      // Fallback: just copy the original file
      final directory = await getApplicationDocumentsDirectory();
      final tankDir = Directory('${directory.path}/tanks/$tankId/photos');
      if (!tankDir.existsSync()) {
        tankDir.createSync(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(sourceFile.path);
      final outputPath = '${tankDir.path}/photo_$timestamp$extension';

      await sourceFile.copy(outputPath);
      return outputPath;
    }
  }

  /// Preload images for better performance
  Future<void> preloadImages(
    BuildContext context,
    List<String> imagePaths,
  ) async {
    for (final imagePath in imagePaths) {
      final provider = getCachedImage(imagePath);
      await precacheImage(provider, context);
    }
  }
}

/// Cached image widget with automatic optimization
class CachedImage extends StatelessWidget {
  final String imagePath;
  final bool thumbnail;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImage({
    super.key,
    required this.imagePath,
    this.thumbnail = false,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final provider = ImageCacheService().getCachedImage(
      imagePath,
      thumbnail: thumbnail,
    );

    return Image(
      image: provider,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }

        if (frame == null) {
          return placeholder ??
              const Center(child: BubbleLoader.small());
        }

        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Center(child: Icon(Icons.broken_image, color: AppColors.textHint));
      },
    );
  }
}
