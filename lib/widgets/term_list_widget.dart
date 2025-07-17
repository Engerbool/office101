import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/term_detail_screen.dart';
import '../utils/haptic_utils.dart';
import 'neumorphic_container.dart';
import 'swipeable_term_card.dart';

class TermListWidget extends StatelessWidget {
  final List<Term> terms;
  final bool isCompact;
  final bool showCategory;
  final bool isSelfContained; // New parameter

  const TermListWidget({
    Key? key,
    required this.terms,
    this.isCompact = false,
    this.showCategory = false,
    this.isSelfContained = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, TermProvider>(
      builder: (context, themeProvider, termProvider, child) {
        // Progressive Loading 중이면 progressiveFilteredTerms 사용
        // 단, isSelfContained가 true인 경우 (인덱스 섹션)에는 전달받은 terms 사용
        final displayTerms = (termProvider.isProgressiveLoading && !isSelfContained) 
            ? termProvider.progressiveFilteredTerms 
            : terms;
        
        if (displayTerms.isEmpty) {
          return _buildEmptyState(themeProvider);
        }

        Widget listView = ListView.separated(
          padding: EdgeInsets.zero,
          physics: isSelfContained ? NeverScrollableScrollPhysics() : BouncingScrollPhysics(),
          shrinkWrap: isSelfContained,
          itemCount: displayTerms.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final term = displayTerms[index];
            // 100개 이상일 때는 간단한 카드로 성능 향상
            if (displayTerms.length > 100 && index > 50) {
              return _buildLightweightCard(term, themeProvider, context);
            }
            return SwipeableTermCard(
              term: term,
              isCompact: isCompact,
            );
          },
        );

        return isSelfContained ? listView : Expanded(child: listView);
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
              color: themeProvider.textColor.withAlpha(77),
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
                color: themeProvider.subtitleColor.withAlpha(153),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightweightCard(Term term, ThemeProvider themeProvider, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await HapticUtils.lightTap();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TermDetailScreen(term: term),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeProvider.dividerColor.withAlpha(77),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    term.term,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    term.definition,
                    style: TextStyle(
                      fontSize: 13,
                      color: themeProvider.subtitleColor,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                await HapticUtils.bookmarkToggle();
                Provider.of<TermProvider>(context, listen: false)
                    .toggleBookmark(term.termId);
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(
                  term.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: term.isBookmarked 
                      ? Color(0xFFFFCA28) 
                      : themeProvider.textColor.withAlpha(102),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}