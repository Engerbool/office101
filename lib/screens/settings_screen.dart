import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/neumorphic_container.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: _buildAppBar(themeProvider),
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
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: Color(0xFF5A8DEE),
                  ),
                ),
                SizedBox(height: 16),
                _buildSettingItem(
                  themeProvider: themeProvider,
                  icon: Icons.dark_mode,
                  title: '다크 모드',
                  subtitle: '어두운 테마 사용',
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: Color(0xFF5A8DEE),
                  ),
                ),
                SizedBox(height: 16),
                _buildSettingItem(
                  themeProvider: themeProvider,
                  icon: Icons.text_fields,
                  title: '글자 크기',
                  subtitle: '앱 전체 글자 크기 조정',
                  trailing: Container(
                    width: 120,
                    child: Slider(
                      value: _fontSize,
                      min: 12.0,
                      max: 20.0,
                      divisions: 8,
                      label: _fontSize.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                      },
                      activeColor: Color(0xFF5A8DEE),
                    ),
                  ),
                ),
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
        borderRadius: 16,
        depth: 4,
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
                  color: Color(0xFF5A8DEE).withOpacity(0.1),
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
                        color: themeProvider.subtitleColor.withOpacity(0.6),
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
                  color: themeProvider.textColor.withOpacity(0.4),
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
        content: Text('개선 사항이나 버그 신고는 앱 스토어 리뷰를 통해 제안해주세요. 더 나은 앱을 만들기 위해 노력하겠습니다.'),
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
}