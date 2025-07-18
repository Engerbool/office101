import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'services/database_service.dart';
import 'services/error_service.dart';
import 'providers/term_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/material_colors.dart';
import 'utils/platform_utils.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    final error = ErrorService.createUnknownError(
      details.exception,
      details.stack,
    );
    ErrorService.logError(error);

    // In debug mode, show the error
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  try {
    print('Main: Starting app initialization');
    
    // 병렬 초기화로 속도 개선
    await Future.wait([
      Hive.initFlutter(),
      Future.delayed(Duration.zero), // 다른 초기화 작업이 추가될 수 있음
    ]);
    print('Main: Hive initialized');
    
    await DatabaseService.initialize();
    print('Main: DatabaseService initialized');

    runApp(MyApp());
  } catch (e, stackTrace) {
    final error = ErrorService.createUnknownError(e, stackTrace);
    ErrorService.logError(error);

    // Show error app
    runApp(ErrorApp(error: error));
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // 앱이 완전히 종료될 때 Hive 박스 정리
      DatabaseService.close();
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // 시스템 테마 변경 감지
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.onSystemThemeChanged();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TermProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // ThemeProvider에 현재 컨텍스트 설정
          WidgetsBinding.instance.addPostFrameCallback((_) {
            themeProvider.setContext(context);
          });
          
          if (PlatformUtils.isIOS) {
            return CupertinoApp(
              title: '직장생활은 처음이라',
              theme: themeProvider.cupertinoTheme,
              home: SplashScreen(),
              builder: (context, widget) {
                // Global error boundary
                ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                  return _buildErrorWidget(context, errorDetails);
                };
                return widget ?? Container();
              },
            );
          } else {
            return MaterialApp(
              title: '직장생활은 처음이라',
              theme: MaterialTheme.lightTheme(),
              darkTheme: MaterialTheme.darkTheme(),
              themeMode: _getThemeMode(themeProvider),
              home: SplashScreen(),
              builder: (context, widget) {
                // Global error boundary
                ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                  return _buildErrorWidget(context, errorDetails);
                };
                return widget ?? Container();
              },
            );
          }
        },
      ),
    );
  }

  /// 테마 모드 결정
  ThemeMode _getThemeMode(ThemeProvider themeProvider) {
    switch (themeProvider.themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  Widget _buildErrorWidget(
      BuildContext context, FlutterErrorDetails errorDetails) {
    final error = ErrorService.createUnknownError(
      errorDetails.exception,
      errorDetails.stack,
    );
    ErrorService.logError(error);

    return Material(
      child: Container(
        color: Colors.red.shade50,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PlatformUtils.isIOS ? CupertinoIcons.exclamationmark_circle : Icons.error_outline,
              size: 64,
              color: PlatformUtils.isIOS ? CupertinoColors.systemRed : Colors.red.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.userMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Error app for critical initialization failures
class ErrorApp extends StatelessWidget {
  final AppError error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오류 발생',
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PlatformUtils.isIOS ? CupertinoIcons.exclamationmark_circle : Icons.error_outline,
                  size: 72,
                  color: PlatformUtils.isIOS ? CupertinoColors.systemRed : Colors.red.shade600,
                ),
                const SizedBox(height: 24),
                Text(
                  '앱을 시작할 수 없습니다',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error.userMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    exit(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('앱 다시 시작'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
