import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'main_navigation_screen.dart';
import 'dart:async';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    
    // 3초 후 자동으로 메인 화면으로 이동
    _navigationTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        _navigateToMain();
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          body: Stack(
            children: [
              // 배경 이미지 (전체 화면)
              Center(
                child: Image.asset(
                  'assets/images/landing.png',
                  fit: BoxFit.contain,
                ),
              ),
              
              // 앱 제목 (이미지 위에 겹침)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 제목을 이미지 위쪽에 위치시키기 위해 위로 이동
                    Transform.translate(
                      offset: Offset(0, -120),
                      child: Column(
                        children: [
                          Text(
                            '직장생활은',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w400,
                              color: themeProvider.textColor,
                            ),
                          ),
                          Text(
                            '처음이라',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF5A8DEE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}