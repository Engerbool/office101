import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/email_template.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/neumorphic_container.dart';
import 'email_template_detail_screen.dart';

class EmailTemplatesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<TermProvider, ThemeProvider>(
      builder: (context, termProvider, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          body: SingleChildScrollView(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoriesSection(termProvider, themeProvider),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildCategoriesSection(TermProvider termProvider, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...EmailCategory.values.map((category) {
          final templates = termProvider.getEmailTemplatesByCategory(category);
          if (templates.isEmpty) return SizedBox();
          
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
                    color: _getCategoryColor(category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
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
                      Text(
                        '${templates.length}개 템플릿',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.subtitleColor.withOpacity(0.6),
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
              color: themeProvider.dividerColor.withOpacity(0.3),
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
                  color: themeProvider.subtitleColor.withOpacity(0.7),
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

  Color _getCategoryColor(EmailCategory category) {
    switch (category) {
      case EmailCategory.request:
        return Color(0xFF5A8DEE);
      case EmailCategory.report:
        return Color(0xFF42A5F5);
      case EmailCategory.meeting:
        return Color(0xFF66BB6A);
      case EmailCategory.apology:
        return Color(0xFFFF7043);
      case EmailCategory.general:
        return Color(0xFF78909C);
    }
  }
}