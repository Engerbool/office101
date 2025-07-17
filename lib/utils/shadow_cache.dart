import 'package:flutter/material.dart';

/// 뉴모피즘 그림자 캐싱 시스템
/// 동일한 설정의 그림자를 재사용하여 성능 최적화
class NeumorphicShadowCache {
  static final Map<String, List<BoxShadow>> _shadowCache = {};
  static const int _maxCacheSize = 100;
  
  /// 캐시된 그림자 가져오기 또는 생성
  static List<BoxShadow> getShadows({
    required Color shadowColor,
    required Color highlightColor,
    required double depth,
    required bool isPressed,
    double blurRadius = 10.0,
    double spreadRadius = 0.0,
  }) {
    final key = _generateKey(
      shadowColor: shadowColor,
      highlightColor: highlightColor,
      depth: depth,
      isPressed: isPressed,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
    );
    
    // 캐시에서 확인
    if (_shadowCache.containsKey(key)) {
      return _shadowCache[key]!;
    }
    
    // 캐시 크기 관리
    if (_shadowCache.length >= _maxCacheSize) {
      _evictOldestEntry();
    }
    
    // 새로운 그림자 생성
    final shadows = _createShadows(
      shadowColor: shadowColor,
      highlightColor: highlightColor,
      depth: depth,
      isPressed: isPressed,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
    );
    
    // 캐시에 저장
    _shadowCache[key] = shadows;
    
    return shadows;
  }
  
  /// 그림자 캐시 키 생성
  static String _generateKey({
    required Color shadowColor,
    required Color highlightColor,
    required double depth,
    required bool isPressed,
    required double blurRadius,
    required double spreadRadius,
  }) {
    return '${shadowColor.r}_${shadowColor.g}_${shadowColor.b}_${shadowColor.a}_${highlightColor.r}_${highlightColor.g}_${highlightColor.b}_${highlightColor.a}_${depth}_${isPressed}_${blurRadius}_${spreadRadius}';
  }
  
  /// 실제 그림자 생성
  static List<BoxShadow> _createShadows({
    required Color shadowColor,
    required Color highlightColor,
    required double depth,
    required bool isPressed,
    required double blurRadius,
    required double spreadRadius,
  }) {
    if (isPressed) {
      // 눌린 상태: 내부 그림자 효과
      return [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.5),
          offset: Offset(depth * 0.5, depth * 0.5),
          blurRadius: blurRadius * 0.5,
          spreadRadius: spreadRadius * 0.5,
        ),
      ];
    } else {
      // 기본 상태: 외부 그림자 효과
      return [
        // 어두운 그림자 (우측 하단)
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.3),
          offset: Offset(depth, depth),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        // 밝은 그림자 (좌측 상단)
        BoxShadow(
          color: highlightColor.withValues(alpha: 0.8),
          offset: Offset(-depth * 0.5, -depth * 0.5),
          blurRadius: blurRadius * 0.8,
          spreadRadius: spreadRadius * 0.8,
        ),
      ];
    }
  }
  
  /// 가장 오래된 캐시 항목 제거
  static void _evictOldestEntry() {
    if (_shadowCache.isNotEmpty) {
      final firstKey = _shadowCache.keys.first;
      _shadowCache.remove(firstKey);
    }
  }
  
  /// 캐시 정리
  static void clearCache() {
    _shadowCache.clear();
  }
  
  /// 캐시 상태 정보
  static Map<String, dynamic> getCacheInfo() {
    return {
      'size': _shadowCache.length,
      'maxSize': _maxCacheSize,
      'usage': _shadowCache.length / _maxCacheSize,
      'keys': _shadowCache.keys.take(5).toList(), // 처음 5개 키만 반환
    };
  }
}

/// 개선된 뉴모피즘 컨테이너 - 그림자 캐싱 적용
class OptimizedNeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? highlightColor;
  final double depth;
  final bool isPressed;
  final double borderRadius;
  final double blurRadius;
  final double spreadRadius;
  final VoidCallback? onTap;
  
  const OptimizedNeumorphicContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.shadowColor,
    this.highlightColor,
    this.depth = 4.0,
    this.isPressed = false,
    this.borderRadius = 12.0,
    this.blurRadius = 10.0,
    this.spreadRadius = 0.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.cardColor;
    final effectiveShadowColor = shadowColor ?? Colors.black;
    final effectiveHighlightColor = highlightColor ?? Colors.white;
    
    // 캐시된 그림자 사용
    final shadows = NeumorphicShadowCache.getShadows(
      shadowColor: effectiveShadowColor,
      highlightColor: effectiveHighlightColor,
      depth: depth,
      isPressed: isPressed,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
    );
    
    return Container(
      margin: margin,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}