import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/error_service.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String? errorMessage;
  final AppError? error;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final IconData? icon;
  final bool isCompact;

  const ErrorDisplayWidget({
    Key? key,
    this.errorMessage,
    this.error,
    this.onRetry,
    this.showRetryButton = true,
    this.icon,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final errorInfo = _getErrorInfo();

        if (isCompact) {
          return _buildCompactError(context, themeProvider, errorInfo);
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  errorInfo.icon,
                  size: 64,
                  color: errorInfo.color,
                ),
                const SizedBox(height: 16),
                Text(
                  errorInfo.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: themeProvider.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorInfo.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: themeProvider.subtitleColor,
                      ),
                ),
                if (errorInfo.suggestion != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: errorInfo.color.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: errorInfo.color.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: errorInfo.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorInfo.suggestion!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: themeProvider.textColor,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (showRetryButton && onRetry != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorInfo.color,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                  ),
                ],
                if (_isNetworkError()) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 16,
                        color: themeProvider.subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '오프라인 모드',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: themeProvider.subtitleColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactError(
      BuildContext context, ThemeProvider themeProvider, ErrorInfo errorInfo) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: errorInfo.color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: errorInfo.color.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            errorInfo.icon,
            size: 20,
            color: errorInfo.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  errorInfo.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: themeProvider.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  errorInfo.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: themeProvider.subtitleColor,
                      ),
                ),
              ],
            ),
          ),
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: errorInfo.color,
              tooltip: '다시 시도',
            ),
          ],
        ],
      ),
    );
  }

  ErrorInfo _getErrorInfo() {
    if (error != null) {
      switch (error!.type) {
        case ErrorType.network:
          return ErrorInfo(
            icon: Icons.wifi_off,
            title: '네트워크 오류',
            message: '인터넷 연결을 확인해주세요.',
            suggestion: 'Wi-Fi 또는 모바일 데이터 연결 상태를 확인하세요.',
            color: Colors.orange,
          );
        case ErrorType.database:
          return ErrorInfo(
            icon: Icons.storage,
            title: '데이터베이스 오류',
            message: '데이터를 불러올 수 없습니다.',
            suggestion: '앱을 재시작하거나 잠시 후 다시 시도해보세요.',
            color: Colors.red,
          );
        case ErrorType.fileSystem:
          return ErrorInfo(
            icon: Icons.folder_off,
            title: '파일 시스템 오류',
            message: '파일에 접근할 수 없습니다.',
            suggestion: '기기 저장 공간을 확인하고 앱 권한을 점검해보세요.',
            color: Colors.purple,
          );
        case ErrorType.validation:
          return ErrorInfo(
            icon: Icons.warning,
            title: '입력 오류',
            message: '올바르지 않은 입력입니다.',
            suggestion: '입력한 내용을 다시 확인해보세요.',
            color: Colors.amber,
          );
        case ErrorType.unknown:
          return ErrorInfo(
            icon: Icons.error_outline,
            title: '알 수 없는 오류',
            message: errorMessage ?? error?.message ?? '알 수 없는 오류가 발생했습니다.',
            suggestion: '문제가 지속되면 앱을 재시작해보세요.',
            color: Colors.red,
          );
      }
    }

    return ErrorInfo(
      icon: icon ?? Icons.error_outline,
      title: '문제가 발생했습니다',
      message: errorMessage ?? '알 수 없는 오류가 발생했습니다.',
      suggestion: null,
      color: Colors.red,
    );
  }

  bool _isNetworkError() {
    return error?.type == ErrorType.network;
  }
}

class ErrorInfo {
  final IconData icon;
  final String title;
  final String message;
  final String? suggestion;
  final Color color;

  const ErrorInfo({
    required this.icon,
    required this.title,
    required this.message,
    this.suggestion,
    required this.color,
  });
}

class ErrorBoundaryWidget extends StatelessWidget {
  final Widget child;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorBoundaryWidget({
    Key? key,
    required this.child,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TermProvider>(
      builder: (context, termProvider, _) {
        if (termProvider.hasError) {
          return ErrorDisplayWidget(
            errorMessage: termProvider.errorMessage,
            onRetry: onRetry ??
                () {
                  termProvider.clearError();
                  termProvider.retryLoadData();
                },
          );
        }
        return child;
      },
    );
  }
}

class LoadingErrorWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget child;

  const LoadingErrorWidget({
    Key? key,
    required this.isLoading,
    required this.child,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('데이터를 불러오는 중...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return ErrorDisplayWidget(
        errorMessage: errorMessage,
        onRetry: onRetry,
      );
    }

    return child;
  }
}

// Snackbar helper for quick error messages
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: '확인',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

// Success snackbar for positive feedback
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
