import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/term_detail_screen.dart';
import '../utils/haptic_utils.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_breakpoints.dart';
import 'neumorphic_container.dart';
import 'swipeable_term_card.dart';

class TermListWidget extends StatelessWidget {
  final List<Term> terms;
  final bool isCompact;
  final bool showCategory;
  final bool isSelfContained; // New parameter
  final TermCategory? currentCategory; // Track current category for context-aware empty states

  const TermListWidget({
    Key? key,
    required this.terms,
    this.isCompact = false,
    this.showCategory = false,
    this.isSelfContained = false, // Default to false
    this.currentCategory, // Optional category context
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, TermProvider>(
      builder: (context, themeProvider, termProvider, child) {
        // Progressive Loading 중이면 progressiveFilteredTerms 사용
        // 단, isSelfContained가 true인 경우 (인덱스 섹션)에는 전달받은 terms 사용
        final displayTerms =
            (termProvider.isProgressiveLoading && !isSelfContained)
                ? termProvider.progressiveFilteredTerms
                : terms;

        if (displayTerms.isEmpty) {
          return _buildEmptyState(themeProvider, termProvider);
        }

        Widget listView = ResponsiveBuilder(
          builder: (context, deviceType) {
            final itemSpacing = ResponsiveValues<double>(
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ).getValue(deviceType);

            return ListView.separated(
              padding: EdgeInsets.zero,
              physics: isSelfContained
                  ? NeverScrollableScrollPhysics()
                  : BouncingScrollPhysics(),
              shrinkWrap: isSelfContained,
              itemCount: displayTerms.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: itemSpacing),
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
          },
        );

        return isSelfContained ? listView : Expanded(child: listView);
      },
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider, TermProvider termProvider) {
    // Context-aware empty state based on current category and search query
    if (currentCategory == TermCategory.bookmarked) {
      return _buildBookmarkEmptyState(themeProvider);
    } else if (termProvider.searchQuery.isNotEmpty) {
      return _buildSearchEmptyState(themeProvider);
    } else {
      return _buildDefaultEmptyState(themeProvider);
    }
  }

  Widget _buildBookmarkEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ResponsiveIcon(
            Icons.bookmark_border,
            size: ResponsiveValues<double>(
              mobile: 64,
              tablet: 72,
              desktop: 80,
            ),
            color: themeProvider.subtitleColor.withAlpha(128),
          ),
          ResponsiveSizedBox.height(
            ResponsiveValues<double>(
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),
          ResponsiveText(
            '북마크가 없습니다',
            fontSize: ResponsiveValues<double>(
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
            fontWeight: FontWeight.w600,
            color: themeProvider.textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchEmptyState(ThemeProvider themeProvider) {
    return NeumorphicContainer(
      backgroundColor: themeProvider.cardColor,
      shadowColor: themeProvider.shadowColor,
      highlightColor: themeProvider.highlightColor,
      padding: ResponsiveValues<EdgeInsets>(
        mobile: EdgeInsets.all(32.0),
        tablet: EdgeInsets.all(36.0),
        desktop: EdgeInsets.all(40.0),
      ),
      child: Column(
        children: [
          ResponsiveIcon(
            Icons.search_off,
            size: ResponsiveValues<double>(
              mobile: 64,
              tablet: 72,
              desktop: 80,
            ),
            color: themeProvider.subtitleColor.withAlpha(128),
          ),
          ResponsiveSizedBox.height(
            ResponsiveValues<double>(
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),
          ResponsiveText(
            '검색 결과가 없습니다',
            fontSize: ResponsiveValues<double>(
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
            fontWeight: FontWeight.w600,
            color: themeProvider.textColor,
          ),
          ResponsiveSizedBox.height(
            ResponsiveValues<double>(
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
          ),
          ResponsiveText(
            '다른 검색어를 시도해보세요',
            fontSize: ResponsiveValues<double>(
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
            color: themeProvider.subtitleColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultEmptyState(ThemeProvider themeProvider) {
    return NeumorphicContainer(
      backgroundColor: themeProvider.cardColor,
      shadowColor: themeProvider.shadowColor,
      highlightColor: themeProvider.highlightColor,
      padding: ResponsiveValues<EdgeInsets>(
        mobile: EdgeInsets.all(32.0),
        tablet: EdgeInsets.all(36.0),
        desktop: EdgeInsets.all(40.0),
      ),
      child: Column(
        children: [
          ResponsiveIcon(
            Icons.info_outline,
            size: ResponsiveValues<double>(
              mobile: 64,
              tablet: 72,
              desktop: 80,
            ),
            color: themeProvider.subtitleColor.withAlpha(128),
          ),
          ResponsiveSizedBox.height(
            ResponsiveValues<double>(
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),
          ResponsiveText(
            '표시할 용어가 없습니다',
            fontSize: ResponsiveValues<double>(
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
            fontWeight: FontWeight.w600,
            color: themeProvider.textColor,
          ),
          ResponsiveSizedBox.height(
            ResponsiveValues<double>(
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
          ),
          ResponsiveText(
            '다른 카테고리를 선택해보세요',
            fontSize: ResponsiveValues<double>(
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
            color: themeProvider.subtitleColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLightweightCard(
      Term term, ThemeProvider themeProvider, BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightTap();
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
        padding: ResponsiveValues<EdgeInsets>(
          mobile: EdgeInsets.all(12.0),
          tablet: EdgeInsets.all(14.0),
          desktop: EdgeInsets.all(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              term.term,
              fontSize: ResponsiveValues<double>(
                mobile: 16,
                tablet: 17,
                desktop: 18,
              ),
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
            ResponsiveSizedBox.height(
              ResponsiveValues<double>(
                mobile: 6,
                tablet: 8,
                desktop: 10,
              ),
            ),
            ResponsiveText(
              term.definition,
              fontSize: ResponsiveValues<double>(
                mobile: 13,
                tablet: 14,
                desktop: 15,
              ),
              color: themeProvider.subtitleColor,
              height: 1.4,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
