import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workplace_tip.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/error_display_widget.dart';
import 'workplace_tip_detail_screen.dart';
import '../constants/category_colors.dart';

class CategoryTipsScreen extends StatelessWidget {
  final TipCategory category;

  const CategoryTipsScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<TermProvider, ThemeProvider>(
      builder: (context, termProvider, themeProvider, child) {
        final tips = termProvider.getWorkplaceTipsByCategory(category);
        
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            title: Text(
              category.displayName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            backgroundColor: themeProvider.backgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: themeProvider.textColor),
          ),
          body: LoadingErrorWidget(
            isLoading: termProvider.isLoading,
            errorMessage: termProvider.errorMessage,
            onRetry: () {
              termProvider.clearError();
              termProvider.retryLoadData();
            },
            child: tips.isEmpty 
              ? _buildEmptyState(themeProvider)
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryHeader(themeProvider, tips.length),
                      SizedBox(height: 24),
                      ...tips.map((tip) => Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _buildTipCard(tip, themeProvider),
                      )).toList(),
                    ],
                  ),
                ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryHeader(ThemeProvider themeProvider, int tipCount) {
    return NeumorphicContainer(
      backgroundColor: themeProvider.cardColor,
      shadowColor: themeProvider.shadowColor,
      highlightColor: themeProvider.highlightColor,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: CategoryColors.getTipCategoryBackgroundColor(category),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(),
                color: CategoryColors.getTipCategoryColor(category),
                size: 28,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '총 ${tipCount}개의 꿀팁이 있습니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.subtitleColor.withAlpha(179),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(WorkplaceTip tip, ThemeProvider themeProvider) {
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
        child: NeumorphicContainer(
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
                    Expanded(
                      child: Text(
                        tip.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: CategoryColors.getTipCategoryColor(category),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  tip.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.subtitleColor.withAlpha(204),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tip.keyPoints.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CategoryColors.getTipCategoryColor(category).withAlpha(13),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: CategoryColors.getTipCategoryColor(category),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${tip.keyPoints.length}개의 핵심 포인트',
                          style: TextStyle(
                            fontSize: 12,
                            color: CategoryColors.getTipCategoryColor(category),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
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
                  color: CategoryColors.getTipCategoryColor(category).withAlpha(153),
                ),
                SizedBox(height: 16),
                Text(
                  '${category.displayName} 팁이 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '아직 이 카테고리의 팁이 준비되지 않았습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.textColor.withAlpha(179),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
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

}