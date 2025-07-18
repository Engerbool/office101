import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import '../utils/platform_utils.dart';
import '../widgets/neumorphic_container.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_breakpoints.dart';
import '../widgets/ios_navigation.dart';
import '../utils/haptic_utils.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: PlatformUtils.isIOS ? IOSNavigationBar(title: '설정') : _buildAppBar(themeProvider),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('앱 설정', themeProvider),
                SizedBox(height: 16),
                _buildSettingItem(
                  themeProvider: themeProvider,
                  icon: Icons.notifications,
                  title: '알림 설정',
                  subtitle: '새로운 콘텐츠 업데이트 알림',
                  trailing: PlatformUtils.isIOS
                      ? CupertinoSwitch(
                          value: _notificationsEnabled,
                          onChanged: (value) async {
                            await HapticUtils.toggleSwitch();
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                          activeTrackColor: Color(0xFF5A8DEE),
                        )
                      : Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                          activeTrackColor: Color(0xFF5A8DEE),
                        ),
                ),
                SizedBox(height: 16),
                _buildThemeSettingItem(themeProvider),
                SizedBox(height: 32),
                _buildSectionTitle('정보', themeProvider),
                SizedBox(height: 16),
                _buildSettingItem(
                  themeProvider: themeProvider,
                  icon: Icons.info,
                  title: '앱 정보',
                  subtitle: '버전 1.0.0',
                  onTap: () {
                    _showAppInfoDialog();
                  },
                ),
                SizedBox(height: 16),
                _buildSettingItem(
                  themeProvider: themeProvider,
                  icon: Icons.help,
                  title: '도움말',
                  subtitle: '앱 사용법 및 FAQ',
                  onTap: () {
                    _showHelpDialog();
                  },
                ),
                SizedBox(height: 16),
                _buildSettingItem(
                  themeProvider: themeProvider,
                  icon: Icons.feedback,
                  title: '피드백',
                  subtitle: '개선 사항 제안하기',
                  onTap: () {
                    _showFeedbackDialog();
                  },
                ),
                SizedBox(height: 32),
                _buildSectionTitle('데이터', themeProvider),
                SizedBox(height: 16),
                _buildSettingItem(
                  themeProvider: themeProvider,
                  icon: Icons.refresh,
                  title: '데이터 초기화',
                  subtitle: '모든 사용자 데이터 삭제',
                  onTap: () {
                    _showResetDataDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeSettingItem(ThemeProvider themeProvider) {
    return NeumorphicContainer(
      borderRadius: ResponsiveValues<double>(
        mobile: 16.0,
        tablet: 18.0,
        desktop: 20.0,
      ),
      depth: ResponsiveValues<double>(
        mobile: 4.0,
        tablet: 5.0,
        desktop: 6.0,
      ),
      backgroundColor: themeProvider.cardColor,
      shadowColor: themeProvider.shadowColor,
      highlightColor: themeProvider.highlightColor,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF5A8DEE).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.palette,
                    size: 24,
                    color: Color(0xFF5A8DEE),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '테마 설정',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '앱 테마를 선택하세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.subtitleColor.withAlpha(153),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...AppThemeMode.values.map((mode) => _buildThemeOption(
              themeProvider: themeProvider,
              mode: mode,
              isSelected: themeProvider.themeMode == mode,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required ThemeProvider themeProvider,
    required AppThemeMode mode,
    required bool isSelected,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => themeProvider.setThemeMode(mode),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? Color(0xFF5A8DEE).withAlpha(26)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
                ? Border.all(color: Color(0xFF5A8DEE), width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                mode.icon,
                size: 20,
                color: isSelected 
                    ? Color(0xFF5A8DEE)
                    : themeProvider.textColor.withAlpha(153),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  mode.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected 
                        ? Color(0xFF5A8DEE)
                        : themeProvider.textColor,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Color(0xFF5A8DEE),
                ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        '설정',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: themeProvider.textColor,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeProvider themeProvider) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: themeProvider.textColor,
      ),
    );
  }

  Widget _buildSettingItem({
    required ThemeProvider themeProvider,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        borderRadius: ResponsiveValues<double>(
          mobile: 16.0,
          tablet: 18.0,
          desktop: 20.0,
        ),
        depth: ResponsiveValues<double>(
          mobile: 4.0,
          tablet: 5.0,
          desktop: 6.0,
        ),
        backgroundColor: themeProvider.cardColor,
        shadowColor: themeProvider.shadowColor,
        highlightColor: themeProvider.highlightColor,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF5A8DEE).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Color(0xFF5A8DEE),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.subtitleColor.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (onTap != null && trailing == null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: themeProvider.textColor.withAlpha(102),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('앱 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('직장생활은 처음이라'),
            SizedBox(height: 8),
            Text('버전: 1.0.0'),
            SizedBox(height: 8),
            Text('신입사원을 위한 직장생활 가이드 앱'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('도움말'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 용어사전: 직장에서 사용하는 용어들을 검색하고 학습하세요'),
            SizedBox(height: 8),
            Text('• 이메일: 상황별 이메일 템플릿을 활용하세요'),
            SizedBox(height: 8),
            Text('• 꿀팁: 직장생활에 도움이 되는 실용적인 팁들을 확인하세요'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('피드백'),
        content:
            Text('개선 사항이나 버그 신고는 앱 스토어 리뷰를 통해 제안해주세요. 더 나은 앱을 만들기 위해 노력하겠습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showResetDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('데이터 초기화'),
        content: Text('모든 사용자 데이터가 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('데이터가 초기화되었습니다')),
              );
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  String _getIOSIconName(IconData icon) {
    if (icon == Icons.notifications) return 'notifications';
    if (icon == Icons.info) return 'info';
    if (icon == Icons.help) return 'help';
    if (icon == Icons.feedback) return 'feedback';
    if (icon == Icons.refresh) return 'refresh';
    return 'help'; // default
  }
}
