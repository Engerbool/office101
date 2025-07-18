import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workplace_tip.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/error_display_widget.dart';
import 'workplace_tip_detail_screen.dart';
import '../constants/category_colors.dart';

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
              padding:
                  EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
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

  Widget _buildCategoriesSection(
      TermProvider termProvider, ThemeProvider themeProvider) {
    // 전체 직장생활 팁이 비어있는지 확인
    if (termProvider.workplaceTips.isEmpty &&
        !termProvider.isLoading &&
        !termProvider.hasError) {
      return _buildEmptyTipsState(themeProvider);
    }

    final availableCategories = TipCategory.values.where((category) {
      return termProvider.getWorkplaceTipsByCategory(category).isNotEmpty;
    }).toList();

    if (availableCategories.isEmpty &&
        !termProvider.isLoading &&
        !termProvider.hasError) {
      return _buildEmptyTipsState(themeProvider);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...availableCategories.map((category) {
          final tips = termProvider.getWorkplaceTipsByCategory(category);

          return Column(
            children: [
              _buildCategoryCard(category, tips, themeProvider),
              SizedBox(height: 16),
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
                  color: Color(0xFF5A8DEE).withAlpha(153),
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
                    color: themeProvider.textColor.withAlpha(179),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                Builder(
                  builder: (context) => TextButton.icon(
                    onPressed: () {
                      Provider.of<TermProvider>(context, listen: false)
                          .retryLoadData();
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

  Widget _buildCategoryCard(TipCategory category, List<WorkplaceTip> tips,
      ThemeProvider themeProvider) {
    return NeumorphicContainer(
      backgroundColor: themeProvider.cardColor,
      shadowColor: themeProvider.shadowColor,
      highlightColor: themeProvider.highlightColor,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        CategoryColors.getTipCategoryBackgroundColor(category),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: CategoryColors.getTipCategoryColor(category),
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
                      Text(
                        '${tips.length}개 팁',
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
            ...tips.map((tip) => _buildTipItem(tip, themeProvider)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(WorkplaceTip tip, ThemeProvider themeProvider) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkplaceTipDetailScreen(tip: tip),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.dividerColor.withAlpha(77),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tip.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                tip.content,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.subtitleColor.withAlpha(179),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (tip.keyPoints.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  '주요 포인트: ${tip.keyPoints.take(2).join(', ')}${tip.keyPoints.length > 2 ? '...' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5A8DEE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Color(0xFF5A8DEE),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '자세히 보기',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5A8DEE),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
        return Icons.assignment_turned_in;
      case TipCategory.todo_management:
        return Icons.check_box_outlined;
      case TipCategory.communication:
        return Icons.forum;
      case TipCategory.self_growth:
        return Icons.trending_up;
      case TipCategory.general:
        return Icons.work;
    }
  }
}
