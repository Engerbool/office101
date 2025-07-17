import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/email_template.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/error_display_widget.dart';
import 'email_template_detail_screen.dart';
import '../constants/category_colors.dart';

class EmailTemplatesScreen extends StatelessWidget {
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
    // 전체 이메일 템플릿이 비어있는지 확인
    if (termProvider.emailTemplates.isEmpty && !termProvider.isLoading && !termProvider.hasError) {
      return _buildEmptyTemplatesState(themeProvider);
    }
    
    final availableCategories = EmailCategory.values.where((category) {
      return termProvider.getEmailTemplatesByCategory(category).isNotEmpty;
    }).toList();
    
    if (availableCategories.isEmpty && !termProvider.isLoading && !termProvider.hasError) {
      return _buildEmptyTemplatesState(themeProvider);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...availableCategories.map((category) {
          final templates = termProvider.getEmailTemplatesByCategory(category);
          
          return Column(
            children: [
              _buildCategoryCard(category, templates, themeProvider),
              SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildEmptyTemplatesState(ThemeProvider themeProvider) {
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
                  Icons.email_outlined,
                  size: 64,
                  color: Color(0xFF5A8DEE).withAlpha(153),
                ),
                SizedBox(height: 16),
                Text(
                  '이메일 템플릿이 없습니다',
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

  Widget _buildCategoryCard(EmailCategory category, List<EmailTemplate> templates, ThemeProvider themeProvider) {
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
                    color: CategoryColors.getEmailCategoryBackgroundColor(category),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: CategoryColors.getEmailCategoryColor(category),
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
                        '${templates.length}개 템플릿',
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
            ...templates.map((template) => _buildTemplateItem(template, themeProvider)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateItem(EmailTemplate template, ThemeProvider themeProvider) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmailTemplateDetailScreen(template: template),
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
              Text(
                template.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                template.situation,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.subtitleColor.withAlpha(179),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
                    '템플릿 보기',
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

  IconData _getCategoryIcon(EmailCategory category) {
    switch (category) {
      case EmailCategory.request:
        return Icons.help_outline;
      case EmailCategory.report:
        return Icons.assignment;
      case EmailCategory.meeting:
        return Icons.event;
      case EmailCategory.apology:
        return Icons.sentiment_very_dissatisfied;
      case EmailCategory.general:
        return Icons.email;
    }
  }

}