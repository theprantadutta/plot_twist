import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Optimized image caching system for better performance
class ImageCacheOptimizer {
  static final ImageCacheOptimizer _instance = ImageCacheOptimizer._internal();
  factory ImageCacheOptimizer() => _instance;
  ImageCacheOptimizer._internal();

  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxCacheObjects = 1000;

  /// Initialize optimized image cache settings
  void initialize() {
    // Configure image cache
    PaintingBinding.instance.imageCache.maximumSize = _maxCacheObjects;
    PaintingBinding.instance.imageCache.maximumSizeBytes = _maxCacheSize;

    if (kDebugMode) {
      debugPrint('🖼️ Image Cache Optimizer: Initialized');
      debugPrint('   Max Size: ${_maxCacheSize ~/ (1024 * 1024)}MB');
      debugPrint('   Max Objects: $_maxCacheObjects');
    }
  }

  /// Clear image cache
  void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    if (kDebugMode) {
      debugPrint('🖼️ Image Cache: Cleared');
    }
  }

  /// Get cache statistics
  ImageCacheStatus getCacheStatus() {
    final cache = PaintingBinding.instance.imageCache;
    return ImageCacheStatus(
      currentSize: cache.currentSizeBytes,
      maxSize: cache.maximumSizeBytes,
      currentObjects: cache.currentSize,
      maxObjects: cache.maximumSize,
      liveImageCount: cache.liveImageCount,
      pendingImageCount: cache.pendingImageCount,
    );
  }

  /// Preload critical images
  Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    final futures = imageUrls.map((url) => _preloadImage(context, url));
    await Future.wait(futures);

    if (kDebugMode) {
      debugPrint('🖼️ Preloaded ${imageUrls.length} images');
    }
  }

  Future<void> _preloadImage(BuildContext context, String imageUrl) async {
    try {
      final imageProvider = NetworkImage(imageUrl);
      await precacheImage(imageProvider, context);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🖼️ Failed to preload image: $imageUrl - $e');
      }
    }
  }

  /// Optimize image for display
  static ImageProvider optimizeImage(
    String imageUrl, {
    int? width,
    int? height,
    ImageQuality quality = ImageQuality.medium,
  }) {
    // Add size parameters to URL if supported by the image service
    String optimizedUrl = imageUrl;

    if (width != null || height != null) {
      final uri = Uri.parse(imageUrl);
      final queryParams = Map<String, String>.from(uri.queryParameters);

      if (width != null) queryParams['w'] = width.toString();
      if (height != null) queryParams['h'] = height.toString();

      switch (quality) {
        case ImageQuality.low:
          queryParams['q'] = '60';
          break;
        case ImageQuality.medium:
          queryParams['q'] = '80';
          break;
        case ImageQuality.high:
          queryParams['q'] = '95';
          break;
      }

      optimizedUrl = uri.replace(queryParameters: queryParams).toString();
    }

    return NetworkImage(optimizedUrl);
  }
}

/// Image cache status information
class ImageCacheStatus {
  final int currentSize;
  final int maxSize;
  final int currentObjects;
  final int maxObjects;
  final int liveImageCount;
  final int pendingImageCount;

  const ImageCacheStatus({
    required this.currentSize,
    required this.maxSize,
    required this.currentObjects,
    required this.maxObjects,
    required this.liveImageCount,
    required this.pendingImageCount,
  });

  double get sizeUsagePercent => (currentSize / maxSize) * 100;
  double get objectUsagePercent => (currentObjects / maxObjects) * 100;

  @override
  String toString() {
    return '''
Image Cache Status:
- Size: ${(currentSize / (1024 * 1024)).toStringAsFixed(1)}MB / ${(maxSize / (1024 * 1024)).toStringAsFixed(1)}MB (${sizeUsagePercent.toStringAsFixed(1)}%)
- Objects: $currentObjects / $maxObjects (${objectUsagePercent.toStringAsFixed(1)}%)
- Live Images: $liveImageCount
- Pending Images: $pendingImageCount
''';
  }
}

enum ImageQuality { low, medium, high }

/// Optimized network image widget with caching and performance features
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final ImageQuality quality;
  final bool enableMemoryCache;
  final Duration fadeInDuration;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.quality = ImageQuality.medium,
    this.enableMemoryCache = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = ImageCacheOptimizer.optimizeImage(
      imageUrl,
      width: width?.toInt(),
      height: height?.toInt(),
      quality: quality,
    );

    return FadeInImage(
      placeholder: _buildPlaceholder(),
      image: imageProvider,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      imageErrorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildErrorWidget();
      },
    );
  }

  ImageProvider _buildPlaceholder() {
    if (placeholder != null) {
      return MemoryImage(Uint8List(0)); // Empty placeholder
    }

    // Create a simple colored placeholder
    return MemoryImage(_createPlaceholderBytes());
  }

  Uint8List _createPlaceholderBytes() {
    // Create a simple 1x1 pixel image as placeholder
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.grey.shade300;

    canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1), paint);

    // final picture = recorder.endRecording();
    recorder.endRecording();
    return Uint8List(0); // Simplified for now
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.broken_image_outlined,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}

/// Cached network image with advanced features
class CachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final ImageQuality quality;
  final VoidCallback? onImageLoaded;
  final Function(Object error)? onImageError;

  const CachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.quality = ImageQuality.medium,
    this.onImageLoaded,
    this.onImageError,
  });

  @override
  State<CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<CachedNetworkImage> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? _buildDefaultErrorWidget();
    }

    return Image(
      image: ImageCacheOptimizer.optimizeImage(
        widget.imageUrl,
        width: widget.width?.toInt(),
        height: widget.height?.toInt(),
        quality: widget.quality,
      ),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          if (_isLoading) {
            _isLoading = false;
            widget.onImageLoaded?.call();
          }
          return child;
        }

        return widget.placeholder ?? _buildDefaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        if (!_hasError) {
          _hasError = true;
          widget.onImageError?.call(error);
        }

        return widget.errorWidget ?? _buildDefaultErrorWidget();
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade100,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.grey.shade400,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Image preloader for critical images
class ImagePreloader {
  static final Map<String, Completer<void>> _preloadingImages = {};

  /// Preload a single image
  static Future<void> preloadImage(
    BuildContext context,
    String imageUrl, {
    ImageQuality quality = ImageQuality.medium,
  }) async {
    if (_preloadingImages.containsKey(imageUrl)) {
      return _preloadingImages[imageUrl]!.future;
    }

    final completer = Completer<void>();
    _preloadingImages[imageUrl] = completer;

    try {
      final imageProvider = ImageCacheOptimizer.optimizeImage(
        imageUrl,
        quality: quality,
      );

      await precacheImage(imageProvider, context);
      completer.complete();
    } catch (e) {
      completer.completeError(e);
    } finally {
      _preloadingImages.remove(imageUrl);
    }
  }

  /// Preload multiple images
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls, {
    ImageQuality quality = ImageQuality.medium,
    int? concurrency,
  }) async {
    final futures = imageUrls.map(
      (url) => preloadImage(context, url, quality: quality),
    );

    if (concurrency != null) {
      // Limit concurrent preloading
      final chunks = <List<Future<void>>>[];
      for (int i = 0; i < futures.length; i += concurrency) {
        chunks.add(futures.skip(i).take(concurrency).toList());
      }

      for (final chunk in chunks) {
        await Future.wait(chunk);
      }
    } else {
      await Future.wait(futures);
    }
  }

  /// Clear preloading cache
  static void clearPreloadingCache() {
    _preloadingImages.clear();
  }
}

/// Memory usage monitor for images
class ImageMemoryMonitor {
  static int _totalImageMemory = 0;
  static final Map<String, int> _imageMemoryUsage = {};

  /// Track image memory usage
  static void trackImageMemory(String imageUrl, int sizeBytes) {
    if (_imageMemoryUsage.containsKey(imageUrl)) {
      _totalImageMemory -= _imageMemoryUsage[imageUrl]!;
    }

    _imageMemoryUsage[imageUrl] = sizeBytes;
    _totalImageMemory += sizeBytes;

    if (kDebugMode && _totalImageMemory > 50 * 1024 * 1024) {
      // 50MB warning
      debugPrint(
        '⚠️ High image memory usage: ${(_totalImageMemory / (1024 * 1024)).toStringAsFixed(1)}MB',
      );
    }
  }

  /// Remove image from memory tracking
  static void removeImageMemory(String imageUrl) {
    if (_imageMemoryUsage.containsKey(imageUrl)) {
      _totalImageMemory -= _imageMemoryUsage[imageUrl]!;
      _imageMemoryUsage.remove(imageUrl);
    }
  }

  /// Get total image memory usage
  static int get totalImageMemory => _totalImageMemory;

  /// Get memory usage report
  static String getMemoryReport() {
    return '''
Image Memory Usage:
- Total: ${(_totalImageMemory / (1024 * 1024)).toStringAsFixed(1)}MB
- Images Tracked: ${_imageMemoryUsage.length}
- Average per Image: ${_imageMemoryUsage.isEmpty ? 0 : ((_totalImageMemory / _imageMemoryUsage.length) / (1024 * 1024)).toStringAsFixed(1)}MB
''';
  }
}
