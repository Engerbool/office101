import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ErrorType {
  database,
  network,
  fileSystem,
  validation,
  unknown,
}

class AppError {
  final String message;
  final String userMessage;
  final ErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppError({
    required this.message,
    required this.userMessage,
    required this.type,
    this.originalError,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'AppError{type: $type, message: $message, timestamp: $timestamp}';
  }
}

class ErrorService {
  static final List<AppError> _errorLog = [];
  static const int _maxLogSize = 100;

  static void logError(AppError error) {
    _errorLog.add(error);
    
    // 로그 크기 제한
    if (_errorLog.length > _maxLogSize) {
      _errorLog.removeAt(0);
    }

    // 디버그 모드에서만 콘솔에 출력
    if (kDebugMode) {
      debugPrint('🚨 Error logged: ${error.toString()}');
      if (error.originalError != null) {
        debugPrint('Original error: ${error.originalError}');
      }
      if (error.stackTrace != null) {
        debugPrint('Stack trace: ${error.stackTrace}');
      }
    }
  }

  static AppError createDatabaseError(String operation, dynamic error, [StackTrace? stackTrace]) {
    return AppError(
      message: 'Database operation failed: $operation - $error',
      userMessage: '데이터를 처리하는 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
      type: ErrorType.database,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static AppError createDataError(String operation, [dynamic error, StackTrace? stackTrace]) {
    return AppError(
      message: 'Data processing failed: $operation - $error',
      userMessage: '데이터 처리 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
      type: ErrorType.database,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static AppError createNetworkError(String operation, dynamic error, [StackTrace? stackTrace]) {
    String userMessage = '네트워크 연결을 확인하고 다시 시도해주세요.';
    
    // 에러 타입에 따른 구체적 메시지
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('timeout') || errorString.contains('시간 초과')) {
      userMessage = '요청 시간이 초과되었습니다. 인터넷 연결을 확인하고 다시 시도해주세요.';
    } else if (errorString.contains('connection') || errorString.contains('연결')) {
      userMessage = '인터넷 연결을 확인하고 다시 시도해주세요.';
    } else if (errorString.contains('server') || errorString.contains('서버')) {
      userMessage = '서버에 일시적인 문제가 있습니다. 잠시 후 다시 시도해주세요.';
    }
    
    return AppError(
      message: 'Network operation failed: $operation - $error',
      userMessage: userMessage,
      type: ErrorType.network,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static AppError createFileSystemError(String operation, dynamic error, [StackTrace? stackTrace]) {
    String userMessage = '파일을 처리하는 중 문제가 발생했습니다.';
    
    // 파일 시스템 에러 타입에 따른 구체적 메시지
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('not found') || errorString.contains('찾을 수 없')) {
      userMessage = '필요한 파일을 찾을 수 없습니다. 앱을 다시 설치해주세요.';
    } else if (errorString.contains('permission') || errorString.contains('권한')) {
      userMessage = '파일 접근 권한이 없습니다. 앱 권한을 확인해주세요.';
    } else if (errorString.contains('space') || errorString.contains('공간')) {
      userMessage = '저장 공간이 부족합니다. 기기의 저장 공간을 확보해주세요.';
    } else if (operation.contains('JSON') || operation.contains('parse')) {
      userMessage = '데이터 형식에 문제가 있습니다. 앱을 다시 시작해주세요.';
    }
    
    return AppError(
      message: 'File system operation failed: $operation - $error',
      userMessage: userMessage,
      type: ErrorType.fileSystem,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static AppError createValidationError(String field, String reason) {
    String userMessage = '입력한 정보를 확인해주세요.';
    
    // 필드에 따른 구체적 메시지
    switch (field.toLowerCase()) {
      case 'term':
        userMessage = '용어를 올바르게 입력해주세요.';
        break;
      case 'definition':
        userMessage = '정의를 올바르게 입력해주세요.';
        break;
      case 'email':
        userMessage = '이메일 주소를 올바르게 입력해주세요.';
        break;
      case 'password':
        userMessage = '비밀번호를 올바르게 입력해주세요.';
        break;
      case 'termid':
        userMessage = '용어 ID가 올바르지 않습니다.';
        break;
    }
    
    // 이유에 따른 추가 메시지
    if (reason.toLowerCase().contains('empty')) {
      userMessage += ' 만일 내용이 비어있다면 다시 입력해주세요.';
    } else if (reason.toLowerCase().contains('invalid')) {
      userMessage += ' 입력 형식을 확인해주세요.';
    }
    
    return AppError(
      message: 'Validation failed for $field: $reason',
      userMessage: userMessage,
      type: ErrorType.validation,
    );
  }

  static AppError createUnknownError(dynamic error, [StackTrace? stackTrace]) {
    return AppError(
      message: 'Unknown error occurred: $error',
      userMessage: '예상치 못한 오류가 발생했습니다. 다시 시도해주세요.',
      type: ErrorType.unknown,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static List<AppError> getErrorLog() {
    return List.unmodifiable(_errorLog);
  }

  static void clearErrorLog() {
    _errorLog.clear();
  }

  static void showErrorSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 기존 스낵바 숨김
    
    Duration duration = const Duration(seconds: 4);
    String actionLabel = '확인';
    
    // 에러 타입에 따른 맞춤 설정
    switch (error.type) {
      case ErrorType.network:
        duration = const Duration(seconds: 6);
        actionLabel = '다시 시도';
        break;
      case ErrorType.validation:
        duration = const Duration(seconds: 3);
        break;
      case ErrorType.database:
        duration = const Duration(seconds: 5);
        actionLabel = '재시도';
        break;
      default:
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                error.userMessage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error.type),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.database:
        return Icons.storage;
      case ErrorType.fileSystem:
        return Icons.folder_off;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.unknown:
      default:
        return Icons.warning;
    }
  }
  
  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange.shade600;
      case ErrorType.database:
        return Colors.red.shade600;
      case ErrorType.fileSystem:
        return Colors.purple.shade600;
      case ErrorType.validation:
        return Colors.amber.shade600;
      case ErrorType.unknown:
      default:
        return Colors.red.shade600;
    }
  }

  static void showErrorDialog(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류 발생'),
          content: Text(error.userMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}