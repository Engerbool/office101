import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import '../utils/platform_utils.dart';
import '../providers/term_provider.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_grid.dart';
import '../widgets/term_list_widget.dart';
import '../widgets/error_display_widget.dart';
import '../utils/ios_icons.dart';
import '../widgets/ios_navigation.dart';
import '../utils/ios_dynamic_type.dart';
import '../utils/haptic_utils.dart';
import 'term_search_screen.dart';
import 'email_templates_screen.dart';
import 'workplace_tips_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // iOS 플랫폼에서 IOSNavigationBar 사용
    final appBar = (!kIsWeb && PlatformUtils.isIOS)
        ? IOSNavigationBar(
            title: '직장생활은 처음이라',
            backgroundColor: Color(0xFFEBF0F5),
          )
        : AppBar(
            title: Text(
              '직장생활은 처음이라',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F5A67),
              ),
            ),
            backgroundColor: Color(0xFFEBF0F5),
            elevation: 0,
            centerTitle: true,
          );

    return Scaffold(
      appBar: appBar,
      body: Consumer<TermProvider>(
        builder: (context, termProvider, child) {
          return LoadingErrorWidget(
            isLoading: termProvider.isLoading,
            errorMessage: termProvider.errorMessage,
            onRetry: () {
              termProvider.clearError();
              termProvider.retryLoadData();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),
                  SizedBox(height: 24),
                  _buildQuickActions(context),
                  SizedBox(height: 24),
                  _buildSearchSection(context),
                  SizedBox(height: 24),
                  _buildCategoriesSection(),
                  SizedBox(height: 24),
                  _buildPopularTermsSection(termProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return NeumorphicContainer(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (!kIsWeb && PlatformUtils.isIOS)
                ? IOSText(
                    '안녕하세요! 👋',
                    style: IOSTextStyle.title1,
                    color: Color(0xFF4F5A67),
                  )
                : Text(
                    '안녕하세요! 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F5A67),
                    ),
                  ),
            SizedBox(height: 8),
            (!kIsWeb && PlatformUtils.isIOS)
                ? IOSText(
                    '직장생활이 처음이신가요?\n여기서 필요한 모든 정보를 찾아보세요!',
                    style: IOSTextStyle.body,
                    color: Color(0xFF4F5A67).withAlpha(204),
                  )
                : Text(
                    '직장생활이 처음이신가요?\n여기서 필요한 모든 정보를 찾아보세요!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4F5A67).withAlpha(204),
                      height: 1.5,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (!kIsWeb && PlatformUtils.isIOS)
            ? IOSText(
                '빠른 메뉴',
                style: IOSTextStyle.title2,
                color: Color(0xFF4F5A67),
              )
            : Text(
                '빠른 메뉴',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F5A67),
                ),
              ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                '용어 검색',
                '모르는 용어를\n바로 찾아보세요',
                (!kIsWeb && PlatformUtils.isIOS) ? IOSIcons.getIcon('search') : Icons.search,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TermSearchScreen()),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                '이메일 가이드',
                '업무 이메일\n템플릿 보기',
                (!kIsWeb && PlatformUtils.isIOS) ? IOSIcons.getIcon('email') : Icons.email,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmailTemplatesScreen()),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                '직장생활 팁',
                '꿀팁으로\n스마트하게',
                (!kIsWeb && PlatformUtils.isIOS) ? IOSIcons.getIcon('lightbulb') : Icons.lightbulb,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkplaceTipsScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () async {
        if (!kIsWeb && PlatformUtils.isIOS) {
          await HapticUtils.lightTap();
        }
        onTap();
      },
      child: NeumorphicContainer(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Color(0xFF5A8DEE),
              ),
              SizedBox(height: 12),
              (!kIsWeb && PlatformUtils.isIOS)
                  ? IOSText(
                      title,
                      style: IOSTextStyle.callout,
                      color: Color(0xFF4F5A67),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F5A67),
                      ),
                      textAlign: TextAlign.center,
                    ),
              SizedBox(height: 4),
              (!kIsWeb && PlatformUtils.isIOS)
                  ? IOSText(
                      subtitle,
                      style: IOSTextStyle.caption1,
                      color: Color(0xFF4F5A67).withAlpha(179),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4F5A67).withAlpha(179),
                      ),
                      textAlign: TextAlign.center,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (!kIsWeb && PlatformUtils.isIOS)
            ? IOSText(
                '용어 검색',
                style: IOSTextStyle.title2,
                color: Color(0xFF4F5A67),
              )
            : Text(
                '용어 검색',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F5A67),
                ),
              ),
        SizedBox(height: 16),
        SearchBarWidget(
          onSearch: (query) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TermSearchScreen(initialQuery: query),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (!kIsWeb && PlatformUtils.isIOS)
            ? IOSText(
                '카테고리별 보기',
                style: IOSTextStyle.title2,
                color: Color(0xFF4F5A67),
              )
            : Text(
                '카테고리별 보기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F5A67),
                ),
              ),
        SizedBox(height: 16),
        CategoryGrid(),
      ],
    );
  }

  Widget _buildPopularTermsSection(TermProvider termProvider) {
    final popularTerms = termProvider.getPopularTerms();

    if (termProvider.allTerms.isEmpty &&
        !termProvider.isLoading &&
        !termProvider.hasError) {
      return _buildEmptyDataSection();
    }

    if (popularTerms.isEmpty) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (!kIsWeb && PlatformUtils.isIOS)
            ? IOSText(
                '인기 용어',
                style: IOSTextStyle.title2,
                color: Color(0xFF4F5A67),
              )
            : Text(
                '인기 용어',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F5A67),
                ),
              ),
        SizedBox(height: 16),
        TermListWidget(
          terms: popularTerms,
          isCompact: true,
        ),
      ],
    );
  }

  Widget _buildEmptyDataSection() {
    return NeumorphicContainer(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              (!kIsWeb && PlatformUtils.isIOS) ? IOSIcons.getIcon('book') : Icons.library_books_outlined,
              size: 64,
              color: Color(0xFF5A8DEE).withAlpha(153),
            ),
            SizedBox(height: 16),
            (!kIsWeb && PlatformUtils.isIOS)
                ? IOSText(
                    '아직 용어가 없습니다',
                    style: IOSTextStyle.title3,
                    color: Color(0xFF4F5A67),
                  )
                : Text(
                    '아직 용어가 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F5A67),
                    ),
                  ),
            SizedBox(height: 8),
            (!kIsWeb && PlatformUtils.isIOS)
                ? IOSText(
                    '앱을 다시 시작하거나\n새로운 용어를 추가해보세요!',
                    style: IOSTextStyle.body,
                    color: Color(0xFF4F5A67).withAlpha(179),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    '앱을 다시 시작하거나\n새로운 용어를 추가해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4F5A67).withAlpha(179),
                      height: 1.4,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
