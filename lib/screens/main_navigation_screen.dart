import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import '../utils/platform_utils.dart';
import '../providers/theme_provider.dart';
import '../utils/haptic_utils.dart';
import '../utils/responsive_breakpoints.dart';
import '../utils/responsive_helper.dart';
import '../utils/ios_icons.dart';
import '../widgets/ios_navigation.dart';
import '../widgets/ios_swipe_gesture.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/material_ripple_button.dart';
import 'terms_tab_screen.dart';
import 'email_templates_screen.dart';
import 'workplace_tips_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TermsTabScreen(),
      EmailTemplatesScreen(),
      WorkplaceTipsScreen(),
      SettingsScreen(),
    ];
  }

  /// 백 버튼 처리
  Future<bool> _onWillPop() async {
    // 첫 번째 탭(0)에서만 종료 확인 로직 실행
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }

    // 이전 백 버튼 누른 시간 확인
    if (_lastBackPressed != null &&
        DateTime.now().difference(_lastBackPressed!) < Duration(seconds: 2)) {
      return true; // 앱 종료
    }

    // 첫 번째 백 버튼 누름
    _lastBackPressed = DateTime.now();
    _showExitSnackBar();
    return false;
  }

  /// 종료 안내 스냅바 표시
  void _showExitSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('앱을 끄려면 한 번 더 눌러주세요.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF5A8DEE),
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ResponsiveBuilder(
            builder: (context, deviceType) {
              // iOS 플랫폼에서 사용할 컴포넌트들
              if (!kIsWeb && PlatformUtils.isIOS) {
                return IOSSwipeGesture(
                  onSwipeBack: () {
                    if (_currentIndex > 0) {
                      setState(() {
                        _currentIndex = _currentIndex - 1;
                      });
                    }
                  },
                  child: Scaffold(
                    backgroundColor: themeProvider.backgroundColor,
                    body: IndexedStack(
                      index: _currentIndex,
                      children: _screens,
                    ),
                    bottomNavigationBar: IOSTabBar(
                      currentIndex: _currentIndex,
                      onTap: (index) async {
                        await HapticUtils.lightTap();
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      items: [
                        IOSTabItem(
                          icon: IOSIcons.getIcon('book'),
                          label: '용어사전',
                        ),
                        IOSTabItem(
                          icon: IOSIcons.getIcon('email'),
                          label: '이메일',
                        ),
                        IOSTabItem(
                          icon: IOSIcons.getIcon('lightbulb'),
                          label: '꿀팁',
                        ),
                        IOSTabItem(
                          icon: IOSIcons.getIcon('settings'),
                          label: '설정',
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              // Android 및 기타 플랫폼
              return Scaffold(
              backgroundColor: themeProvider.backgroundColor,
              body: deviceType == DeviceType.mobile
                  ? IndexedStack(
                      index: _currentIndex,
                      children: _screens,
                    )
                  : Row(
                      children: [
                        // 네비게이션 레일
                        _buildBottomNavigationBar(themeProvider),
                        // 메인 콘텐츠
                        Expanded(
                          child: IndexedStack(
                            index: _currentIndex,
                            children: _screens,
                          ),
                        ),
                      ],
                    ),
              bottomNavigationBar: deviceType == DeviceType.mobile
                  ? _buildBottomNavigationBar(themeProvider)
                  : null,
              floatingActionButton: _buildFloatingActionButton(themeProvider),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(ThemeProvider themeProvider) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        // 모바일에서는 기존 하단 네비게이션 사용
        if (deviceType == DeviceType.mobile) {
          return Container(
            decoration: BoxDecoration(
              color: themeProvider.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: themeProvider.shadowColor.withAlpha(77),
                  offset: Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              child: ResponsiveContainer(
                height: ResponsiveValues<double>(
                  mobile: 80,
                  tablet: 90,
                  desktop: 100,
                ),
                padding: ResponsiveValues<EdgeInsetsGeometry>(
                  mobile: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  tablet: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  desktop: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      themeProvider: themeProvider,
                      index: 0,
                      icon: (!kIsWeb && PlatformUtils.isIOS) ? IOSIcons.getIcon('book') : Icons.book,
                      label: '용어사전',
                      color: Color(0xFF5A8DEE),
                    ),
                    _buildNavItem(
                      themeProvider: themeProvider,
                      index: 1,
                      icon: (!kIsWeb && PlatformUtils.isIOS) ? IOSIcons.getIcon('email') : Icons.email,
                      label: '이메일',
                      color: Color(0xFF5A8DEE),
                    ),
                    _buildNavItem(
                      themeProvider: themeProvider,
                      index: 2,
                      icon: (!kIsWeb && PlatformUtils.isIOS) ? IOSIcons.getIcon('lightbulb') : Icons.lightbulb,
                      label: '꿀팁',
                      color: Color(0xFF5A8DEE),
                    ),
                    _buildNavItem(
                      themeProvider: themeProvider,
                      index: 3,
                      icon: (!kIsWeb && PlatformUtils.isIOS) ? IOSIcons.getIcon('settings') : Icons.settings,
                      label: '설정',
                      color: Color(0xFF5A8DEE),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 태블릿/데스크톱에서는 네비게이션 레일 사용
        return Container(
          width: ResponsiveValues<double>(
            mobile: 80,
            tablet: 120,
            desktop: 240,
          ).getValue(deviceType),
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: themeProvider.shadowColor.withAlpha(77),
                offset: Offset(2, 0),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                ResponsiveSizedBox.height(
                  ResponsiveValues<double>(
                    mobile: 20,
                    tablet: 30,
                    desktop: 40,
                  ),
                ),
                _buildNavItemVertical(
                  themeProvider: themeProvider,
                  index: 0,
                  icon: Icons.book,
                  label: '용어사전',
                  color: Color(0xFF5A8DEE),
                  deviceType: deviceType,
                ),
                ResponsiveSizedBox.height(
                  ResponsiveValues<double>(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                _buildNavItemVertical(
                  themeProvider: themeProvider,
                  index: 1,
                  icon: Icons.email,
                  label: '이메일',
                  color: Color(0xFF5A8DEE),
                  deviceType: deviceType,
                ),
                ResponsiveSizedBox.height(
                  ResponsiveValues<double>(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                _buildNavItemVertical(
                  themeProvider: themeProvider,
                  index: 2,
                  icon: Icons.lightbulb,
                  label: '꿀팁',
                  color: Color(0xFF5A8DEE),
                  deviceType: deviceType,
                ),
                ResponsiveSizedBox.height(
                  ResponsiveValues<double>(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                _buildNavItemVertical(
                  themeProvider: themeProvider,
                  index: 3,
                  icon: Icons.settings,
                  label: '설정',
                  color: Color(0xFF5A8DEE),
                  deviceType: deviceType,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required ThemeProvider themeProvider,
    required int index,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _currentIndex == index;

    return Semantics(
      label: '$label 탭',
      hint: isSelected ? '현재 선택된 탭입니다' : '탭하여 $label 화면으로 이동',
      button: true,
      selected: isSelected,
      child: MaterialRippleButton(
        onTap: () async {
          await HapticUtils.lightTap();
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(20),
        rippleColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          child: NeumorphicContainer(
            isPressed: isSelected,
            borderRadius: ResponsiveValues<double>(
              mobile: 20.0,
              tablet: 22.0,
              desktop: 24.0,
            ),
            depth: ResponsiveValues<double>(
              mobile: isSelected ? 2.0 : 4.0,
              tablet: isSelected ? 3.0 : 5.0,
              desktop: isSelected ? 4.0 : 6.0,
            ),
            backgroundColor: themeProvider.cardColor,
            shadowColor: themeProvider.shadowColor,
            highlightColor: themeProvider.highlightColor,
            child: ResponsiveContainer(
              width: ResponsiveValues<double>(
                mobile: 80,
                tablet: 90,
                desktop: 100,
              ),
              height: ResponsiveValues<double>(
                mobile: 64,
                tablet: 72,
                desktop: 80,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ResponsiveIcon(
                    icon,
                    size: ResponsiveValues<double>(
                      mobile: 24,
                      tablet: 28,
                      desktop: 32,
                    ),
                    color: isSelected
                        ? color
                        : themeProvider.textColor.withAlpha(153),
                  ),
                  ResponsiveSizedBox.height(
                    ResponsiveValues<double>(
                      mobile: 4,
                      tablet: 6,
                      desktop: 8,
                    ),
                  ),
                  ResponsiveText(
                    label,
                    fontSize: ResponsiveValues<double>(
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                    ),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? color
                        : themeProvider.textColor.withAlpha(153),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemVertical({
    required ThemeProvider themeProvider,
    required int index,
    required IconData icon,
    required String label,
    required Color color,
    required DeviceType deviceType,
  }) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticUtils.lightTap();
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: NeumorphicContainer(
          isPressed: isSelected,
          borderRadius: ResponsiveValues<double>(
            mobile: 16.0,
            tablet: 18.0,
            desktop: 20.0,
          ),
          depth: ResponsiveValues<double>(
            mobile: isSelected ? 2.0 : 4.0,
            tablet: isSelected ? 3.0 : 5.0,
            desktop: isSelected ? 4.0 : 6.0,
          ),
          backgroundColor: themeProvider.cardColor,
          shadowColor: themeProvider.shadowColor,
          highlightColor: themeProvider.highlightColor,
          child: ResponsiveContainer(
            width: ResponsiveValues<double>(
              mobile: 80,
              tablet: 100,
              desktop: 200,
            ),
            height: ResponsiveValues<double>(
              mobile: 60,
              tablet: 70,
              desktop: 80,
            ),
            child: deviceType == DeviceType.desktop
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ResponsiveSizedBox.width(
                        ResponsiveValues<double>(
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),
                      ResponsiveIcon(
                        icon,
                        size: ResponsiveValues<double>(
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                        ),
                        color: isSelected
                            ? color
                            : themeProvider.textColor.withAlpha(153),
                      ),
                      ResponsiveSizedBox.width(
                        ResponsiveValues<double>(
                          mobile: 12,
                          tablet: 16,
                          desktop: 20,
                        ),
                      ),
                      ResponsiveText(
                        label,
                        fontSize: ResponsiveValues<double>(
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? color
                            : themeProvider.textColor.withAlpha(153),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveIcon(
                        icon,
                        size: ResponsiveValues<double>(
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                        ),
                        color: isSelected
                            ? color
                            : themeProvider.textColor.withAlpha(153),
                      ),
                      ResponsiveSizedBox.height(
                        ResponsiveValues<double>(
                          mobile: 4,
                          tablet: 6,
                          desktop: 8,
                        ),
                      ),
                      ResponsiveText(
                        label,
                        fontSize: ResponsiveValues<double>(
                          mobile: 10,
                          tablet: 12,
                          desktop: 14,
                        ),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? color
                            : themeProvider.textColor.withAlpha(153),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// 플로팅 액션 버튼 (탭별로 다른 액션)
  Widget? _buildFloatingActionButton(ThemeProvider themeProvider) {
    switch (_currentIndex) {
      case 0: // 용어사전 탭
        // iOS에서는 FloatingActionButton 대신 상단 버튼 사용
        if (!kIsWeb && PlatformUtils.isIOS) {
          return null;
        }
        return FloatingActionButton(
          onPressed: () {
            // 용어 추가 화면으로 이동
            Navigator.pushNamed(context, '/add_term');
          },
          backgroundColor: Color(0xFF5A8DEE),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          tooltip: '새 용어 추가',
        );
      case 1: // 이메일 탭
        // iOS에서는 FloatingActionButton 대신 상단 버튼 사용
        if (!kIsWeb && PlatformUtils.isIOS) {
          return null;
        }
        return FloatingActionButton(
          onPressed: () {
            // 이메일 템플릿 추가 또는 검색
            _showEmailActions(themeProvider);
          },
          backgroundColor: Color(0xFF5A8DEE),
          child: Icon(
            Icons.email,
            color: Colors.white,
          ),
          tooltip: '이메일 템플릿 액션',
        );
      case 2: // 꿀팁 탭
        // iOS에서는 FloatingActionButton 대신 상단 버튼 사용
        if (!kIsWeb && PlatformUtils.isIOS) {
          return null;
        }
        return FloatingActionButton(
          onPressed: () {
            // 꿀팁 추가 또는 검색
            _showTipActions(themeProvider);
          },
          backgroundColor: Color(0xFF5A8DEE),
          child: Icon(
            Icons.lightbulb,
            color: Colors.white,
          ),
          tooltip: '꿀팁 액션',
        );
      case 3: // 설정 탭
        return null; // 설정 탭에는 FAB 없음
      default:
        return null;
    }
  }

  /// 이메일 액션 바텀시트 표시
  void _showEmailActions(ThemeProvider themeProvider) {
    // iOS에서는 CupertinoActionSheet 사용
    if (!kIsWeb && PlatformUtils.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text('이메일 템플릿 액션'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/email_search');
              },
              child: Text('이메일 템플릿 검색'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _showComingSoonDialog();
              },
              child: Text('새 이메일 템플릿 추가'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '이메일 템플릿 액션',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            SizedBox(height: 20),
            MaterialRippleButton(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/email_search');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Color(0xFF5A8DEE),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '이메일 템플릿 검색',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            MaterialRippleButton(
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: Color(0xFF5A8DEE),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '새 이메일 템플릿 추가',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 꿀팁 액션 바텀시트 표시
  void _showTipActions(ThemeProvider themeProvider) {
    // iOS에서는 CupertinoActionSheet 사용
    if (!kIsWeb && PlatformUtils.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text('꿀팁 액션'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _showComingSoonDialog();
              },
              child: Text('새 꿀팁 추가'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '꿀팁 액션',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            SizedBox(height: 20),
            MaterialRippleButton(
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: Color(0xFF5A8DEE),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '새 꿀팁 추가',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 준비 중 다이얼로그
  void _showComingSoonDialog() {
    // iOS에서는 CupertinoAlertDialog 사용
    if (!kIsWeb && PlatformUtils.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('준비 중'),
          content: Text('이 기능은 곧 추가될 예정입니다.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('준비 중'),
        content: Text('이 기능은 곧 추가될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
