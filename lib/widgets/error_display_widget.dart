import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/error_service.dart';
import '../providers/term_provider.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final IconData? icon;

  const ErrorDisplayWidget({
    Key? key,
    this.errorMessage,
    this.onRetry,
    this.showRetryButton = true,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Colors.red.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              '문제가 발생했습니다',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? '알 수 없는 오류가 발생했습니다.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade700,
              ),
            ),
            if (showRetryButton) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
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
            onRetry: onRetry ?? () {
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