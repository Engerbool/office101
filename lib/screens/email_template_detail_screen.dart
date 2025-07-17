import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/email_template.dart';
import '../providers/theme_provider.dart';
import '../widgets/neumorphic_container.dart';
import '../constants/category_colors.dart';

class EmailTemplateDetailScreen extends StatelessWidget {
  final EmailTemplate template;

  const EmailTemplateDetailScreen({Key? key, required this.template}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            title: Text(
              '이메일 템플릿',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            backgroundColor: themeProvider.backgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: themeProvider.textColor),
            actions: [
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () => _copyTemplate(context),
                tooltip: '템플릿 복사',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(themeProvider),
                SizedBox(height: 24),
                _buildSituationSection(themeProvider),
                SizedBox(height: 24),
                _buildSubjectSection(themeProvider),
                SizedBox(height: 24),
                _buildBodySection(themeProvider),
                SizedBox(height: 24),
                _buildTipsSection(themeProvider),
                SizedBox(height: 24),
                _buildCopyButton(context, themeProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
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
                    color: CategoryColors.getEmailCategoryBackgroundColor(template.category),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: CategoryColors.getEmailCategoryColor(template.category),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CategoryColors.getEmailCategoryBackgroundColor(template.category),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          template.category.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: CategoryColors.getEmailCategoryColor(template.category),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSituationSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사용 상황',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        SizedBox(height: 12),
        NeumorphicContainer(
          backgroundColor: themeProvider.cardColor,
          shadowColor: themeProvider.shadowColor,
          highlightColor: themeProvider.highlightColor,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF5A8DEE),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    template.situation,
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.textColor,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '제목',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        SizedBox(height: 12),
        NeumorphicContainer(
          backgroundColor: themeProvider.cardColor,
          shadowColor: themeProvider.shadowColor,
          highlightColor: themeProvider.highlightColor,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(
                  Icons.subject,
                  color: Color(0xFF5A8DEE),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    template.subject,
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodySection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '본문',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        SizedBox(height: 12),
        NeumorphicContainer(
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
                    Icon(
                      Icons.article,
                      color: Color(0xFF5A8DEE),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '이메일 본문 템플릿',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeProvider.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: themeProvider.dividerColor.withAlpha(77),
                    ),
                  ),
                  child: Text(
                    template.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.textColor,
                      height: 1.6,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(ThemeProvider themeProvider) {
    if (template.tips.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '작성 팁',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        SizedBox(height: 12),
        NeumorphicContainer(
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
                    Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFFFFCA28),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '이메일 작성시 참고사항',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ...template.tips.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tip = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Color(0xFF5A8DEE).withAlpha(26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5A8DEE),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.textColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCopyButton(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => _copyTemplate(context),
        child: NeumorphicContainer(
          backgroundColor: themeProvider.cardColor,
          shadowColor: themeProvider.shadowColor,
          highlightColor: themeProvider.highlightColor,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.copy,
                  color: Color(0xFF5A8DEE),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  '템플릿 복사하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A8DEE),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyTemplate(BuildContext context) {
    final templateText = '''
제목: ${template.subject}

${template.body}

---
💡 작성 팁:
${template.tips.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value}').join('\n')}

- 직장생활은 처음이라 앱에서 제공
    '''.trim();

    Clipboard.setData(ClipboardData(text: templateText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('이메일 템플릿이 클립보드에 복사되었습니다'),
        backgroundColor: Color(0xFF5A8DEE),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (template.category) {
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