import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workplace_tip.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/error_display_widget.dart';
import 'category_tips_screen.dart';

class WorkplaceTipsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<TermProvider, ThemeProvider>(
      builder: (context, termProvider, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          body: LoadingErrorWidget(
            isLoading: termProvider.isLoading,
            errorMessage: termProvider.errorMessage,
            onRetry: () {
              termProvider.clearError();
              termProvider.retryLoadData();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoriesSection(termProvider, themeProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildCategoriesSection(TermProvider termProvider, ThemeProvider themeProvider) {
    // 전체 직장생활 팁이 비어있는지 확인
    if (termProvider.workplaceTips.isEmpty && !termProvider.isLoading && !termProvider.hasError) {
      return _buildEmptyTipsState(themeProvider);
    }
    
    final availableCategories = TipCategory.values.where((category) {
      return termProvider.getWorkplaceTipsByCategory(category).isNotEmpty;
    }).toList();
    
    if (availableCategories.isEmpty && !termProvider.isLoading && !termProvider.hasError) {
      return _buildEmptyTipsState(themeProvider);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리별 직장생활 꿀팁',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '궁금한 분야를 선택해서 맞춤 꿀팁을 확인해보세요',
          style: TextStyle(
            fontSize: 14,
            color: themeProvider.subtitleColor.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 24),
        ...availableCategories.map((category) {
          final tips = termProvider.getWorkplaceTipsByCategory(category);
          return Column(
            children: [
              Builder(
                builder: (context) => _buildCategoryListCard(context, category, tips, themeProvider),
              ),
              SizedBox(height: 12),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildEmptyTipsState(ThemeProvider themeProvider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 64,
                  color: Color(0xFF5A8DEE).withOpacity(0.6),
                ),
                SizedBox(height: 16),
                Text(
                  '직장생활 팁이 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '아직 로드되지 않았거나\n데이터에 문제가 있을 수 있습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.textColor.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                Builder(
                  builder: (context) => TextButton.icon(
                    onPressed: () {
                      Provider.of<TermProvider>(context, listen: false).retryLoadData();
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Color(0xFF5A8DEE),
                    ),
                    label: Text(
                      '다시 시도',
                      style: TextStyle(
                        color: Color(0xFF5A8DEE),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryListCard(BuildContext context, TipCategory category, List<WorkplaceTip> tips, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryTipsScreen(category: category),
          ),
        );
      },
      child: NeumorphicContainer(
        backgroundColor: themeProvider.cardColor,
        shadowColor: themeProvider.shadowColor,
        highlightColor: themeProvider.highlightColor,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: _getCategoryColor(category),
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${tips.length}개의 꿀팁',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.subtitleColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: themeProvider.subtitleColor.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }


  IconData _getCategoryIcon(TipCategory category) {
    switch (category) {
      case TipCategory.basic_attitude:
        return Icons.person_outline;
      case TipCategory.reporting:
        return Icons.assignment;
      case TipCategory.todo_management:
        return Icons.check_box_outlined;
      case TipCategory.communication:
        return Icons.chat_bubble_outline;
      case TipCategory.self_growth:
        return Icons.trending_up;
      case TipCategory.general:
        return Icons.lightbulb_outline;
    }
  }

  Color _getCategoryColor(TipCategory category) {
    switch (category) {
      case TipCategory.basic_attitude:
        return Color(0xFF5A8DEE);
      case TipCategory.reporting:
        return Color(0xFF42A5F5);
      case TipCategory.todo_management:
        return Color(0xFF66BB6A);
      case TipCategory.communication:
        return Color(0xFFFF7043);
      case TipCategory.self_growth:
        return Color(0xFFAB47BC);
      case TipCategory.general:
        return Color(0xFF78909C);
    }
  }

}