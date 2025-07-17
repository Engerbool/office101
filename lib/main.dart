import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'services/database_service.dart';
import 'services/error_service.dart';
import 'providers/term_provider.dart';
import 'providers/theme_provider.dart';
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
    await Hive.initFlutter();
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
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TermProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: '',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: SplashScreen(),
            builder: (context, widget) {
              // Global error boundary
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return _buildErrorWidget(context, errorDetails);
              };
              return widget ?? Container();
            },
          );
        },
      ),
    );
  }
  
  Widget _buildErrorWidget(BuildContext context, FlutterErrorDetails errorDetails) {
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
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade600,
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
                  Icons.error_outline,
                  size: 72,
                  color: Colors.red.shade600,
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