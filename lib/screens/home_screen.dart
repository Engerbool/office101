import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/term_provider.dart';
import '../models/term.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_grid.dart';
import '../widgets/term_list_widget.dart';
import 'term_search_screen.dart';
import 'email_templates_screen.dart';
import 'workplace_tips_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Consumer<TermProvider>(
        builder: (context, termProvider, child) {
          if (termProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A8DEE)),
              ),
            );
          }

          return SingleChildScrollView(
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
            Text(
              '안녕하세요! 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F5A67),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '직장생활이 처음이신가요?\n여기서 필요한 모든 정보를 찾아보세요!',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4F5A67).withOpacity(0.8),
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
        Text(
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
                Icons.search,
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
                Icons.email,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmailTemplatesScreen()),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                '직장생활 팁',
                '꿀팁으로\n스마트하게',
                Icons.lightbulb,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WorkplaceTipsScreen()),
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
      onTap: onTap,
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F5A67),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4F5A67).withOpacity(0.7),
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
        Text(
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
        Text(
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
    
    if (popularTerms.isEmpty) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
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
}