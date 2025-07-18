import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import '../utils/platform_utils.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/neumorphic_container.dart';
import '../utils/material_snackbar.dart';
import '../utils/ios_icons.dart';
import '../widgets/ios_navigation.dart';
import '../utils/ios_dynamic_type.dart';
import '../utils/haptic_utils.dart';
import '../constants/category_colors.dart';

class TermDetailScreen extends StatelessWidget {
  final Term term;

  const TermDetailScreen({Key? key, required this.term}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: (!kIsWeb && PlatformUtils.isIOS)
              ? IOSNavigationBar(
                  title: '용어 상세',
                  backgroundColor: themeProvider.backgroundColor,
                  automaticallyImplyLeading: true,
                  actions: _buildActions(context, themeProvider),
                ) as PreferredSizeWidget?
              : AppBar(
                  title: Text(
                    '용어 상세',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  backgroundColor: themeProvider.backgroundColor,
                  elevation: 0,
                  iconTheme: IconThemeData(color: themeProvider.textColor),
                  actions: _buildActions(context, themeProvider),
                ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTermHeader(themeProvider),
                SizedBox(height: 24),
                _buildDefinitionSection(themeProvider),
                if (term.example.isNotEmpty) ...[
                  SizedBox(height: 24),
                  _buildExampleSection(themeProvider),
                ],
                if (term.tags.isNotEmpty) ...[
                  SizedBox(height: 24),
                  _buildTagsSection(themeProvider),
                ],
                SizedBox(height: 24),
                _buildCategorySection(themeProvider),
                if (term.userAdded) ...[
                  SizedBox(height: 24),
                  _buildUserAddedBadge(themeProvider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermHeader(ThemeProvider themeProvider) {
    return NeumorphicContainer(
      backgroundColor: themeProvider.cardColor,
      shadowColor: themeProvider.shadowColor,
      highlightColor: themeProvider.highlightColor,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                term.term,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CategoryColors.getCategoryBackgroundColor(term.category),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                term.category.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: CategoryColors.getCategoryColor(term.category),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정의',
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
            child: Text(
              term.definition,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.textColor,
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExampleSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사용 예시',
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
                  Icons.format_quote,
                  size: 24,
                  color: Color(0xFF5A8DEE).withAlpha(153),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    term.example,
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.textColor,
                      fontStyle: FontStyle.italic,
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

  Widget _buildTagsSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관련 태그',
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
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: term.tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: themeProvider.textColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.textColor.withAlpha(204),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CategoryColors.getCategoryBackgroundColor(
                        term.category),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: CategoryColors.getCategoryColor(term.category),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  term.category.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserAddedBadge(ThemeProvider themeProvider) {
    return NeumorphicContainer(
      backgroundColor: themeProvider.cardColor,
      shadowColor: themeProvider.shadowColor,
      highlightColor: themeProvider.highlightColor,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              Icons.person_add,
              color: Color(0xFF5A8DEE),
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              '사용자가 추가한 용어입니다',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF5A8DEE),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, ThemeProvider themeProvider) {
    return [
      Consumer<TermProvider>(
        builder: (context, termProvider, child) {
          return Semantics(
            label: term.isBookmarked ? '북마크 제거' : '북마크 추가',
            hint: term.isBookmarked 
                ? '현재 북마크되어 있습니다. 탭하여 북마크를 제거하세요'
                : '북마크에 추가하려면 탭하세요',
            button: true,
            child: IconButton(
              icon: Icon(
                term.isBookmarked
                    ? ((!kIsWeb && PlatformUtils.isIOS) ? IOSIcons.getIcon('bookmark') : Icons.bookmark)
                    : ((!kIsWeb && PlatformUtils.isIOS) ? IOSIcons.getIcon('bookmark_border') : Icons.bookmark_border),
                color: term.isBookmarked
                    ? Color(0xFFFFCA28)
                    : themeProvider.textColor,
              ),
              onPressed: () async {
                if (!kIsWeb && PlatformUtils.isIOS) {
                  await HapticUtils.lightTap();
                }
                
                final wasBookmarked = term.isBookmarked;
                termProvider.toggleBookmark(term.termId);
                
                // Material 스낵바로 피드백
                if (wasBookmarked) {
                  MaterialSnackBar.showUndo(
                    context,
                    message: '북마크에서 제거되었습니다',
                    onUndo: () {
                      termProvider.toggleBookmark(term.termId);
                    },
                  );
                } else {
                  MaterialSnackBar.showSuccess(
                    context,
                    message: '북마크에 추가되었습니다',
                    actionLabel: '보기',
                    onAction: () {
                      Navigator.pushNamed(context, '/bookmarks');
                    },
                  );
                }
              },
            ),
          );
        },
      ),
      Semantics(
        label: '공유하기',
        hint: '용어 정의를 다른 앱으로 공유하려면 탭하세요',
        button: true,
        child: IconButton(
          icon: Icon((!kIsWeb && PlatformUtils.isIOS) ? IOSIcons.getIcon('share') : Icons.share),
          onPressed: () => _shareTerm(context),
        ),
      ),
    ];
  }

  void _shareTerm(BuildContext context) {
    final shareText = '''
${term.term}

${term.definition}

${term.example.isNotEmpty ? '예시: ${term.example}' : ''}

- 직장생활은 처음이라 앱에서 공유
    '''
        .trim();

    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('용어 정보가 클립보드에 복사되었습니다'),
        backgroundColor: Color(0xFF5A8DEE),
      ),
    );
  }

  IconData _getCategoryIcon() {
    // iOS 플랫폼에서 iOS 아이콘 사용
    if (!kIsWeb && PlatformUtils.isIOS) {
      switch (term.category) {
        case TermCategory.approval:
          return IOSIcons.getIcon('settings');
        case TermCategory.business:
          return IOSIcons.getIcon('book');
        case TermCategory.marketing:
          return IOSIcons.getIcon('lightbulb');
        case TermCategory.it:
          return IOSIcons.getIcon('settings');
        case TermCategory.hr:
          return IOSIcons.getIcon('settings');
        case TermCategory.communication:
          return IOSIcons.getIcon('email');
        case TermCategory.time:
          return IOSIcons.getIcon('settings');
        case TermCategory.other:
          return IOSIcons.getIcon('settings');
        case TermCategory.bookmarked:
          return IOSIcons.getIcon('bookmark');
      }
    }
    
    // Android 기본 아이콘
    switch (term.category) {
      case TermCategory.approval:
        return Icons.approval;
      case TermCategory.business:
        return Icons.business_center;
      case TermCategory.marketing:
        return Icons.campaign;
      case TermCategory.it:
        return Icons.computer;
      case TermCategory.hr:
        return Icons.people;
      case TermCategory.communication:
        return Icons.chat_bubble;
      case TermCategory.time:
        return Icons.schedule;
      case TermCategory.other:
        return Icons.more_horiz;
      case TermCategory.bookmarked:
        return Icons.bookmark;
    }
  }
}
