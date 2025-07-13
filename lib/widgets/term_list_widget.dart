import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/term_detail_screen.dart';
import 'neumorphic_container.dart';

class TermListWidget extends StatelessWidget {
  final List<Term> terms;
  final bool isCompact;
  final bool showCategory;

  const TermListWidget({
    Key? key,
    required this.terms,
    this.isCompact = false,
    this.showCategory = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (terms.isEmpty) {
          return _buildEmptyState(themeProvider);
        }

        return Column(
          children: [
            ...terms.asMap().entries.map((entry) {
              final index = entry.key;
              final term = entry.value;
              return Column(
                children: [
                  _buildTermCard(context, term, themeProvider),
                  if (index < terms.length - 1) SizedBox(height: 12),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return NeumorphicContainer(
      backgroundColor: themeProvider.cardColor,
      shadowColor: themeProvider.shadowColor,
      highlightColor: themeProvider.highlightColor,
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: themeProvider.textColor.withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '다른 검색어를 시도해보세요',
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.subtitleColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermCard(BuildContext context, Term term, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TermDetailScreen(term: term),
          ),
        );
      },
      child: NeumorphicContainer(
        backgroundColor: themeProvider.cardColor,
        shadowColor: themeProvider.shadowColor,
        highlightColor: themeProvider.highlightColor,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      term.term,
                      style: TextStyle(
                        fontSize: isCompact ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ),
                  if (showCategory) ...[
                    SizedBox(width: 8),
                    _buildCategoryChip(term.category),
                  ],
                  if (term.userAdded) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF5A8DEE).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '내가 추가',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF5A8DEE),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  Spacer(),
                  _buildBookmarkButton(term, themeProvider),
                ],
              ),
              SizedBox(height: 8),
              Text(
                term.definition,
                style: TextStyle(
                  fontSize: isCompact ? 13 : 14,
                  color: themeProvider.subtitleColor.withOpacity(0.8),
                  height: 1.4,
                ),
                maxLines: isCompact ? 2 : null,
                overflow: isCompact ? TextOverflow.ellipsis : null,
              ),
              if (!isCompact && term.example.isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF5A8DEE).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.format_quote,
                        size: 16,
                        color: Color(0xFF5A8DEE).withOpacity(0.6),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          term.example,
                          style: TextStyle(
                            fontSize: 13,
                            color: themeProvider.subtitleColor.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (term.tags.isNotEmpty) ...[
                SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: term.tags.take(isCompact ? 3 : term.tags.length).map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeProvider.textColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 11,
                          color: themeProvider.textColor.withOpacity(0.7),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(TermCategory category) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.displayName,
        style: TextStyle(
          fontSize: 10,
          color: _getCategoryColor(category),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCategoryColor(TermCategory category) {
    switch (category) {
      case TermCategory.approval:
        return Color(0xFF5A8DEE);
      case TermCategory.business:
        return Color(0xFF42A5F5);
      case TermCategory.marketing:
        return Color(0xFF66BB6A);
      case TermCategory.it:
        return Color(0xFFFF7043);
      case TermCategory.hr:
        return Color(0xFFAB47BC);
      case TermCategory.communication:
        return Color(0xFFFFCA28);
      case TermCategory.time:
        return Color(0xFFEF5350);
      case TermCategory.other:
        return Color(0xFF78909C);
      case TermCategory.bookmarked:
        return Color(0xFFFFCA28);
    }
  }

  Widget _buildBookmarkButton(Term term, ThemeProvider themeProvider) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Provider.of<TermProvider>(context, listen: false).toggleBookmark(term.termId);
        },
        child: Container(
          padding: EdgeInsets.all(8),
          child: Icon(
            term.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: term.isBookmarked ? Color(0xFFFFCA28) : themeProvider.textColor.withOpacity(0.5),
            size: 20,
          ),
        ),
      ),
    );
  }
}