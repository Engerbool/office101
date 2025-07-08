import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';
import 'providers/term_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Main: Starting app initialization');
  await Hive.initFlutter();
  print('Main: Hive initialized');
  await DatabaseService.initialize();
  print('Main: DatabaseService initialized');
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
            title: '직장생활은 처음이라',
            theme: themeProvider.lightTheme.copyWith(
              textTheme: GoogleFonts.notoSansKrTextTheme(
                themeProvider.lightTheme.textTheme,
              ),
            ),
            darkTheme: themeProvider.darkTheme.copyWith(
              textTheme: GoogleFonts.notoSansKrTextTheme(
                themeProvider.darkTheme.textTheme,
              ),
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: MainNavigationScreen(),
          );
        },
      ),
    );
  }
}