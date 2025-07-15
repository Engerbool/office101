import 'dart:convert';
import '../services/error_service.dart';

class ValidationUtils {
  // 문자열 sanitization
  static String sanitizeString(String input) {
    if (input.isEmpty) return input;
    
    // HTML 태그 제거
    String sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // 스크립트 태그 제거
    sanitized = sanitized.replaceAll(RegExp(r'<script[^>]*>.*?</script>', 
        caseSensitive: false, multiLine: true), '');
    
    // 위험한 문자 이스케이프
    sanitized = sanitized.replaceAll(RegExp(r'[<>"]'), '');
    sanitized = sanitized.replaceAll("'", "");
    
    // 연속된 공백 정리
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return sanitized;
  }

  // 리스트 sanitization
  static List<String> sanitizeStringList(List<dynamic> input) {
    return input
        .where((item) => item is String)
        .map((item) => sanitizeString(item.toString()))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  // Term JSON 검증
  static bool validateTermJson(Map<String, dynamic> json) {
    try {
      // 필수 필드 확인
      if (!json.containsKey('term_id') || json['term_id'] == null) {
        return false;
      }
      if (!json.containsKey('term') || json['term'] == null) {
        return false;
      }
      if (!json.containsKey('definition') || json['definition'] == null) {
        return false;
      }
      if (!json.containsKey('category') || json['category'] == null) {
        return false;
      }

      // 타입 검증
      if (json['term_id'] is! String) return false;
      if (json['term'] is! String) return false;
      if (json['definition'] is! String) return false;
      if (json['category'] is! String) return false;

      // 선택적 필드 타입 검증
      if (json.containsKey('example') && json['example'] != null) {
        if (json['example'] is! String) return false;
      }
      if (json.containsKey('tags') && json['tags'] != null) {
        if (json['tags'] is! List) return false;
      }
      if (json.containsKey('user_added') && json['user_added'] != null) {
        if (json['user_added'] is! bool) return false;
      }
      if (json.containsKey('is_bookmarked') && json['is_bookmarked'] != null) {
        if (json['is_bookmarked'] is! bool) return false;
      }

      // 문자열 길이 검증
      if (json['term_id'].toString().length > 100) return false;
      if (json['term'].toString().length > 200) return false;
      if (json['definition'].toString().length > 2000) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  // EmailTemplate JSON 검증
  static bool validateEmailTemplateJson(Map<String, dynamic> json) {
    try {
      // 필수 필드 확인
      if (!json.containsKey('template_id') || json['template_id'] == null) {
        return false;
      }
      if (!json.containsKey('situation') || json['situation'] == null) {
        return false;
      }
      if (!json.containsKey('subject') || json['subject'] == null) {
        return false;
      }
      if (!json.containsKey('body') || json['body'] == null) {
        return false;
      }
      if (!json.containsKey('category') || json['category'] == null) {
        return false;
      }

      // 타입 검증
      if (json['template_id'] is! String) return false;
      if (json['situation'] is! String) return false;
      if (json['subject'] is! String) return false;
      if (json['body'] is! String) return false;
      if (json['category'] is! String) return false;

      // 선택적 필드 타입 검증
      if (json.containsKey('tips') && json['tips'] != null) {
        if (json['tips'] is! List) return false;
      }

      // 문자열 길이 검증
      if (json['template_id'].toString().length > 100) return false;
      if (json['situation'].toString().length > 200) return false;
      if (json['subject'].toString().length > 200) return false;
      if (json['body'].toString().length > 5000) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  // WorkplaceTip JSON 검증
  static bool validateWorkplaceTipJson(Map<String, dynamic> json) {
    try {
      // 필수 필드 확인
      if (!json.containsKey('tip_id') || json['tip_id'] == null) {
        return false;
      }
      if (!json.containsKey('title') || json['title'] == null) {
        return false;
      }
      if (!json.containsKey('content') || json['content'] == null) {
        return false;
      }
      if (!json.containsKey('category') || json['category'] == null) {
        return false;
      }

      // 타입 검증
      if (json['tip_id'] is! String) return false;
      if (json['title'] is! String) return false;
      if (json['content'] is! String) return false;
      if (json['category'] is! String) return false;

      // 선택적 필드 타입 검증
      if (json.containsKey('key_points') && json['key_points'] != null) {
        if (json['key_points'] is! List) return false;
      }
      if (json.containsKey('priority') && json['priority'] != null) {
        if (json['priority'] is! String) return false;
      }

      // 문자열 길이 검증
      if (json['tip_id'].toString().length > 100) return false;
      if (json['title'].toString().length > 200) return false;
      if (json['content'].toString().length > 3000) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  // 안전한 JSON 파싱
  static Map<String, dynamic>? safeJsonDecode(String jsonString) {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 사용자 입력 검증 (용어 추가/수정 시)
  static String? validateTermInput(String input) {
    if (input.trim().isEmpty) {
      return '입력값이 비어있습니다.';
    }
    
    if (input.length > 200) {
      return '입력값이 너무 깁니다. (최대 200자)';
    }
    
    // 위험한 패턴 검사
    if (RegExp(r'<script|javascript:|data:|vbscript:', caseSensitive: false).hasMatch(input)) {
      return '허용되지 않는 내용이 포함되어 있습니다.';
    }
    
    return null;
  }

  // 정의 입력 검증
  static String? validateDefinitionInput(String input) {
    if (input.trim().isEmpty) {
      return '정의가 비어있습니다.';
    }
    
    if (input.length > 2000) {
      return '정의가 너무 깁니다. (최대 2000자)';
    }
    
    // 위험한 패턴 검사
    if (RegExp(r'<script|javascript:|data:|vbscript:', caseSensitive: false).hasMatch(input)) {
      return '허용되지 않는 내용이 포함되어 있습니다.';
    }
    
    return null;
  }

  // 태그 입력 검증
  static List<String> validateAndSanitizeTags(List<String> tags) {
    return tags
        .map((tag) => sanitizeString(tag))
        .where((tag) => tag.isNotEmpty && tag.length <= 50)
        .take(10) // 최대 10개 태그만 허용
        .toList();
  }
}