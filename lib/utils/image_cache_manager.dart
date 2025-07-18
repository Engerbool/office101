import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'lru_cache.dart';

/// 이미지 캐시 관리자
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  final LRUCache<String, Uint8List> _imageCache = LRUCache(maxSize: 50);

  /// 이미지 로딩 (캐시 우선)
  Future<Uint8List?> loadImage(String assetPath) async {
    // 캐시에서 먼저 확인
    final cachedImage = _imageCache.get(assetPath);
    if (cachedImage != null) {
      return cachedImage;
    }

    try {
      // 이미지 로딩
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      
      // 캐시에 저장
      _imageCache.put(assetPath, bytes);
      
      return bytes;
    } catch (e) {
      debugPrint('이미지 로딩 실패: $assetPath - $e');
      return null;
    }
  }

  /// 이미지 위젯 생성 (최적화된)
  Widget buildOptimizedImage(
    String assetPath, {
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
  }) {
    return FutureBuilder<Uint8List?>(
      future: loadImage(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
            color: color,
            // 성능 최적화
            cacheWidth: width?.toInt(),
            cacheHeight: height?.toInt(),
            filterQuality: FilterQuality.medium,
          );
        } else if (snapshot.hasError) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade300,
            child: Icon(
              Icons.error,
              color: Colors.grey.shade600,
              size: 24,
            ),
          );
        } else {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }
      },
    );
  }

  /// 메모리 정리
  void clearCache() {
    _imageCache.clear();
  }

  /// 캐시 통계
  Map<String, dynamic> get stats => _imageCache.stats;
}