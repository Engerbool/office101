import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/error_service.dart';
import '../utils/performance_monitor.dart';

/// 고급 에러 처리 시스템
class AdvancedErrorHandler {
  static final Map<String, int> _errorCounts = {};
  static final Map<String, DateTime> _lastErrorTimes = {};
  static final StreamController<AppError> _errorStreamController = StreamController.broadcast();
  static const int _maxErrorsPerMinute = 5;
  static const Duration _errorCooldown = Duration(minutes: 1);
  
  /// 에러 스트림 (UI에서 에러 모니터링용)
  static Stream<AppError> get errorStream => _errorStreamController.stream;
  
  /// 에러 처리 및 로깅
  static void handleError(AppError error) {
    final errorKey = '${error.type}_${error.message}';
    final now = DateTime.now();
    
    // 에러 빈도 확인
    _errorCounts[errorKey] = (_errorCounts[errorKey] ?? 0) + 1;
    
    // 과도한 에러 발생 시 쿨다운 적용
    if (_shouldThrottleError(errorKey, now)) {
      developer.log(
        'Error throttled: $errorKey (count: ${_errorCounts[errorKey]})',
        name: 'AdvancedErrorHandler',
        level: 1000,
      );
      return;
    }
    
    _lastErrorTimes[errorKey] = now;
    
    // 성능 모니터링
    PerformanceMonitor.incrementCounter('error_${error.type}');
    
    // 에러 로깅
    _logError(error);
    
    // 에러 스트림에 전송
    _errorStreamController.add(error);
    
    // 심각한 에러의 경우 추가 처리
    if (_isCriticalError(error)) {
      _handleCriticalError(error);
    }
  }
  
  /// 에러 쿨다운 확인
  static bool _shouldThrottleError(String errorKey, DateTime now) {
    final lastTime = _lastErrorTimes[errorKey];
    if (lastTime == null) return false;
    
    final timeSinceLastError = now.difference(lastTime);
    if (timeSinceLastError < _errorCooldown) {
      return (_errorCounts[errorKey] ?? 0) > _maxErrorsPerMinute;
    }
    
    // 쿨다운 시간이 지났으면 카운터 리셋
    _errorCounts[errorKey] = 0;
    return false;
  }
  
  /// 심각한 에러 판단
  static bool _isCriticalError(AppError error) {
    switch (error.type) {
      case ErrorType.database:
        return error.message.contains('initialize') || 
               error.message.contains('corruption');
      case ErrorType.fileSystem:
        return error.message.contains('write') || 
               error.message.contains('delete');
      case ErrorType.network:
        return false; // 네트워크 에러는 일반적으로 심각하지 않음
      case ErrorType.validation:
        return false; // 검증 에러는 일반적으로 심각하지 않음
      case ErrorType.unknown:
        return true; // 알 수 없는 에러는 심각할 수 있음
    }
  }
  
  /// 심각한 에러 처리
  static void _handleCriticalError(AppError error) {
    developer.log(
      'CRITICAL ERROR: ${error.type} - ${error.message}',
      name: 'AdvancedErrorHandler',
      level: 1200,
      error: error.originalError,
      stackTrace: error.stackTrace,
    );
    
    // 필요한 경우 여기서 추가 복구 로직 실행
    // 예: 백업 데이터 복원, 안전 모드 진입 등
  }
  
  /// 에러 로깅
  static void _logError(AppError error) {
    final message = StringBuffer();
    message.writeln('Error: ${error.type} - ${error.message}');
    message.writeln('Message: ${error.userMessage}');
    message.writeln('Time: ${DateTime.now()}');
    
    if (error.originalError != null) {
      message.writeln('Original Error: ${error.originalError}');
    }
    
    if (error.stackTrace != null) {
      message.writeln('Stack Trace: ${error.stackTrace}');
    }
    
    developer.log(
      message.toString(),
      name: 'AdvancedErrorHandler',
      level: 1000,
      error: error.originalError,
      stackTrace: error.stackTrace,
    );
  }
  
  /// 에러 통계 조회
  static Map<String, dynamic> getErrorStats() {
    final stats = <String, dynamic>{};
    
    // 에러 발생 횟수
    stats['errorCounts'] = Map.from(_errorCounts);
    
    // 마지막 에러 시간
    final lastErrorTimes = <String, String>{};
    _lastErrorTimes.forEach((key, value) {
      lastErrorTimes[key] = value.toIso8601String();
    });
    stats['lastErrorTimes'] = lastErrorTimes;
    
    // 총 에러 수
    stats['totalErrors'] = _errorCounts.values.fold(0, (sum, count) => sum + count);
    
    return stats;
  }
  
  /// 에러 통계 초기화
  static void clearErrorStats() {
    _errorCounts.clear();
    _lastErrorTimes.clear();
  }
  
  /// 에러 핸들러 정리
  static void dispose() {
    _errorStreamController.close();
  }
}

/// 에러 복구 전략
class ErrorRecoveryStrategy {
  /// 데이터베이스 에러 복구
  static Future<bool> recoverFromDatabaseError(AppError error) async {
    try {
      // 데이터베이스 재초기화 시도
      developer.log('Attempting database recovery...', name: 'ErrorRecovery');
      
      // 여기서 실제 복구 로직 실행
      // 예: 데이터베이스 재연결, 백업 데이터 복원 등
      
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Database recovery failed: $e',
        name: 'ErrorRecovery',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
  
  /// 네트워크 에러 복구
  static Future<bool> recoverFromNetworkError(AppError error) async {
    try {
      // 네트워크 재연결 시도
      developer.log('Attempting network recovery...', name: 'ErrorRecovery');
      
      // 여기서 네트워크 복구 로직 실행
      // 예: 연결 재시도, 오프라인 모드 전환 등
      
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Network recovery failed: $e',
        name: 'ErrorRecovery',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
  
  /// 자동 복구 시도
  static Future<bool> attemptAutoRecovery(AppError error) async {
    switch (error.type) {
      case ErrorType.database:
        return await recoverFromDatabaseError(error);
      case ErrorType.network:
        return await recoverFromNetworkError(error);
      default:
        return false;
    }
  }
}

/// 에러 리포팅 위젯
class ErrorReportingWidget extends StatefulWidget {
  final Widget child;
  
  const ErrorReportingWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<ErrorReportingWidget> createState() => _ErrorReportingWidgetState();
}

class _ErrorReportingWidgetState extends State<ErrorReportingWidget> {
  late StreamSubscription<AppError> _errorSubscription;
  
  @override
  void initState() {
    super.initState();
    
    // 에러 스트림 구독
    _errorSubscription = AdvancedErrorHandler.errorStream.listen(
      (error) {
        // UI에 에러 표시
        _showErrorToUser(error);
      },
    );
  }
  
  @override
  void dispose() {
    _errorSubscription.cancel();
    super.dispose();
  }
  
  void _showErrorToUser(AppError error) {
    // 심각한 에러가 아닌 경우에만 SnackBar 표시
    if (!_isCriticalError(error)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.userMessage),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: '다시 시도',
            textColor: Colors.white,
            onPressed: () {
              // 자동 복구 시도
              ErrorRecoveryStrategy.attemptAutoRecovery(error);
            },
          ),
        ),
      );
    }
  }
  
  bool _isCriticalError(AppError error) {
    return error.type == ErrorType.database && 
           error.message.contains('initialize');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}