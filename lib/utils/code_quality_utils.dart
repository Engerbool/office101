import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// 코드 품질 및 타입 안전성 유틸리티
class CodeQualityUtils {
  /// 널 안전성 검사
  static T ensureNotNull<T>(T? value, String context) {
    if (value == null) {
      developer.log(
        'Null value encountered in $context',
        name: 'CodeQualityUtils',
        level: 1000,
      );
      throw ArgumentError('Null value not allowed in $context');
    }
    return value;
  }
  
  /// 범위 검사
  static T ensureInRange<T extends num>(T value, T min, T max, String context) {
    if (value < min || value > max) {
      developer.log(
        'Value $value is out of range [$min, $max] in $context',
        name: 'CodeQualityUtils',
        level: 1000,
      );
      throw ArgumentError('Value $value is out of range [$min, $max] in $context');
    }
    return value;
  }
  
  /// 빈 문자열 검사
  static String ensureNotEmpty(String? value, String context) {
    if (value == null || value.isEmpty) {
      developer.log(
        'Empty string encountered in $context',
        name: 'CodeQualityUtils',
        level: 1000,
      );
      throw ArgumentError('Empty string not allowed in $context');
    }
    return value;
  }
  
  /// 리스트 빈 값 검사
  static List<T> ensureNotEmptyList<T>(List<T>? value, String context) {
    if (value == null || value.isEmpty) {
      developer.log(
        'Empty list encountered in $context',
        name: 'CodeQualityUtils',
        level: 1000,
      );
      throw ArgumentError('Empty list not allowed in $context');
    }
    return value;
  }
  
  /// 조건 검사
  static void ensureCondition(bool condition, String message, String context) {
    if (!condition) {
      developer.log(
        'Condition failed in $context: $message',
        name: 'CodeQualityUtils',
        level: 1000,
      );
      throw ArgumentError('Condition failed in $context: $message');
    }
  }
  
  /// 타입 안전성 검사
  static T ensureType<T>(dynamic value, String context) {
    if (value is! T) {
      developer.log(
        'Type mismatch in $context: expected ${T.toString()}, got ${value.runtimeType}',
        name: 'CodeQualityUtils',
        level: 1000,
      );
      throw ArgumentError('Type mismatch in $context: expected ${T.toString()}, got ${value.runtimeType}');
    }
    return value;
  }
}

/// 입력 검증 유틸리티
class InputValidator {
  /// 이메일 형식 검증
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
  
  /// 한국어 텍스트 검증
  static bool isValidKoreanText(String text) {
    // 한글, 영어, 숫자, 기본 특수문자 허용
    return RegExp(r'^[가-힣a-zA-Z0-9\s\-_.,!?()]+$').hasMatch(text);
  }
  
  /// 용어 ID 검증
  static bool isValidTermId(String termId) {
    // 알파벳, 숫자, 하이픈, 언더스코어만 허용
    return RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(termId);
  }
  
  /// 텍스트 길이 검증
  static bool isValidLength(String text, int minLength, int maxLength) {
    return text.length >= minLength && text.length <= maxLength;
  }
  
  /// 위험한 문자 검증
  static bool containsDangerousCharacters(String text) {
    // 스크립트 태그, SQL 인젝션 패턴 등
    final dangerousPatterns = [
      r'<script[^>]*>',
      r'</script>',
      r'javascript:',
      r'data:',
      r'vbscript:',
      r'SELECT.*FROM',
      r'INSERT.*INTO',
      r'UPDATE.*SET',
      r'DELETE.*FROM',
      r'DROP.*TABLE',
    ];
    
    for (final pattern in dangerousPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(text)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// 입력값 정규화
  static String normalizeInput(String input) {
    return input
        .trim() // 앞뒤 공백 제거
        .replaceAll(RegExp(r'\s+'), ' ') // 연속된 공백을 하나로
        .replaceAll(RegExp(r'[^\w\s가-힣\-_.,!?()]'), ''); // 안전한 문자만 허용
  }
}

/// 성능 검증 유틸리티
class PerformanceValidator {
  /// 함수 실행 시간 검증
  static Future<T> validateExecutionTime<T>(
    Future<T> Function() function,
    Duration maxDuration,
    String context,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await function();
      stopwatch.stop();
      
      if (stopwatch.elapsed > maxDuration) {
        developer.log(
          'Performance warning: $context took ${stopwatch.elapsed.inMilliseconds}ms (max: ${maxDuration.inMilliseconds}ms)',
          name: 'PerformanceValidator',
          level: 900,
        );
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      developer.log(
        'Function failed in $context after ${stopwatch.elapsed.inMilliseconds}ms',
        name: 'PerformanceValidator',
        level: 1000,
        error: e,
      );
      rethrow;
    }
  }
  
  /// 메모리 사용량 검증
  static void validateMemoryUsage(int currentBytes, int maxBytes, String context) {
    if (currentBytes > maxBytes) {
      developer.log(
        'Memory warning: $context is using ${(currentBytes / 1024 / 1024).toStringAsFixed(2)}MB (max: ${(maxBytes / 1024 / 1024).toStringAsFixed(2)}MB)',
        name: 'PerformanceValidator',
        level: 900,
      );
    }
  }
  
  /// 캐시 효율성 검증
  static void validateCacheEfficiency(int hits, int misses, String context) {
    final total = hits + misses;
    if (total > 0) {
      final hitRate = hits / total;
      if (hitRate < 0.7) { // 70% 미만의 캐시 효율성
        developer.log(
          'Cache efficiency warning: $context has ${(hitRate * 100).toStringAsFixed(1)}% hit rate',
          name: 'PerformanceValidator',
          level: 900,
        );
      }
    }
  }
}

/// 디버깅 유틸리티
class DebugUtils {
  /// 디버그 모드에서만 로그 출력
  static void debugLog(String message, {String? context}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: context ?? 'DebugUtils',
        level: 500,
      );
    }
  }
  
  /// 객체 상태 덤프
  static void dumpObjectState(Object object, String context) {
    if (kDebugMode) {
      developer.log(
        'Object state dump for $context:\n${object.toString()}',
        name: 'DebugUtils',
        level: 500,
      );
    }
  }
  
  /// 함수 호출 추적
  static T traceFunction<T>(T Function() function, String functionName) {
    if (kDebugMode) {
      developer.log('Entering $functionName', name: 'DebugUtils');
      try {
        final result = function();
        developer.log('Exiting $functionName', name: 'DebugUtils');
        return result;
      } catch (e, stackTrace) {
        developer.log(
          'Error in $functionName: $e',
          name: 'DebugUtils',
          error: e,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    } else {
      return function();
    }
  }
  
  /// 비동기 함수 호출 추적
  static Future<T> traceFunctionAsync<T>(
    Future<T> Function() function,
    String functionName,
  ) async {
    if (kDebugMode) {
      developer.log('Entering $functionName', name: 'DebugUtils');
      try {
        final result = await function();
        developer.log('Exiting $functionName', name: 'DebugUtils');
        return result;
      } catch (e, stackTrace) {
        developer.log(
          'Error in $functionName: $e',
          name: 'DebugUtils',
          error: e,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    } else {
      return await function();
    }
  }
}

/// 타입 안전성 확장
extension SafeList<T> on List<T> {
  /// 안전한 인덱스 접근
  T? safeGet(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }
  
  /// 안전한 첫 번째 요소 접근
  T? get safeFirst => isEmpty ? null : first;
  
  /// 안전한 마지막 요소 접근
  T? get safeLast => isEmpty ? null : last;
}

extension SafeMap<K, V> on Map<K, V> {
  /// 안전한 키 접근 (기본값 포함)
  V getOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }
  
  /// 안전한 키 접근 (널 허용)
  V? safeGet(K key) {
    return this[key];
  }
}