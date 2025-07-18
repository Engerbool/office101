import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/term_detail_screen.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_breakpoints.dart';
import 'neumorphic_container.dart';

/// 메모이제이션된 용어 카드 - 성능 최적화를 위한 위젯
class MemoizedTermCard extends StatelessWidget {
  final Term term;
  final bool isCompact;
  final bool showBookmark;

  const MemoizedTermCard({
    Key? key,
    required this.term,
    this.isCompact = false,
    this.showBookmark = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Selector<TermProvider, bool>(
          selector: (context, provider) => term.isBookmarked,
          builder: (context, isBookmarked, staticChild) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TermDetailScreen(term: term),
                  ),
                );
              },
              child: ResponsiveContainer(
                margin: ResponsiveValues<EdgeInsetsGeometry>(
                  mobile: EdgeInsets.only(bottom: isCompact ? 8.0 : 12.0),
                  tablet: EdgeInsets.only(bottom: isCompact ? 10.0 : 16.0),
                  desktop: EdgeInsets.only(bottom: isCompact ? 12.0 : 20.0),
                ),
                child: NeumorphicContainer(
                  padding: ResponsiveValues<EdgeInsets>(
                    mobile: EdgeInsets.all(isCompact ? 12.0 : 16.0),
                    tablet: EdgeInsets.all(isCompact ? 16.0 : 20.0),
                    desktop: EdgeInsets.all(isCompact ? 20.0 : 24.0),
                  ),
                  backgroundColor: themeProvider.cardColor,
                  shadowColor: themeProvider.shadowColor,
                  highlightColor: themeProvider.highlightColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 정적 컨텐츠 (미리 빌드된 child 사용)
                      if (staticChild != null) staticChild,

                      // 동적 컨텐츠 (북마크 상태에 따라 변경)
                      if (showBookmark)
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: ResponsiveIcon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              size: ResponsiveValues<double>(
                                mobile: 20.0,
                                tablet: 22.0,
                                desktop: 24.0,
                              ),
                              color: isBookmarked
                                  ? Colors.amber
                                  : themeProvider.subtitleColor,
                            ),
                            onPressed: () {
                              Provider.of<TermProvider>(context, listen: false)
                                  .toggleBookmark(term.termId);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          // 정적 컨텐츠 (한 번만 빌드되고 재사용)
          child: _buildStaticContent(context, themeProvider),
        );
      },
    );
  }

  /// 정적 컨텐츠 빌드 - 북마크 상태와 무관하게 불변
  Widget _buildStaticContent(
      BuildContext context, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 용어 제목
        ResponsiveText(
          term.term,
          fontSize: ResponsiveValues<double>(
            mobile: isCompact ? 16.0 : 18.0,
            tablet: isCompact ? 18.0 : 20.0,
            desktop: isCompact ? 20.0 : 22.0,
          ),
          fontWeight: FontWeight.bold,
          color: themeProvider.textColor,
        ),

        ResponsiveSizedBox.height(
          ResponsiveValues<double>(
            mobile: isCompact ? 6.0 : 8.0,
            tablet: isCompact ? 8.0 : 10.0,
            desktop: isCompact ? 10.0 : 12.0,
          ),
        ),

        // 정의
        ResponsiveText(
          term.definition,
          fontSize: ResponsiveValues<double>(
            mobile: isCompact ? 13.0 : 14.0,
            tablet: isCompact ? 14.0 : 15.0,
            desktop: isCompact ? 15.0 : 16.0,
          ),
          color: themeProvider.subtitleColor,
          height: 1.4,
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),

        if (!isCompact && term.example.isNotEmpty) ...[
          ResponsiveSizedBox.height(
            ResponsiveValues<double>(
              mobile: 8.0,
              tablet: 10.0,
              desktop: 12.0,
            ),
          ),

          // 예시
          ResponsiveContainer(
            padding: ResponsiveValues<EdgeInsetsGeometry>(
              mobile: EdgeInsets.all(10.0),
              tablet: EdgeInsets.all(12.0),
              desktop: EdgeInsets.all(14.0),
            ),
            decoration: BoxDecoration(
              color: themeProvider.backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: themeProvider.dividerColor.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: ResponsiveText(
              '예시: ${term.example}',
              fontSize: ResponsiveValues<double>(
                mobile: 12.0,
                tablet: 13.0,
                desktop: 14.0,
              ),
              color: themeProvider.subtitleColor.withValues(alpha: 0.8),
            ),
          ),
        ],

        if (term.tags.isNotEmpty) ...[
          ResponsiveSizedBox.height(
            ResponsiveValues<double>(
              mobile: 8.0,
              tablet: 10.0,
              desktop: 12.0,
            ),
          ),

          // 태그들
          ResponsiveBuilder(
            builder: (context, deviceType) {
              final spacing = ResponsiveValues<double>(
                mobile: 4.0,
                tablet: 6.0,
                desktop: 8.0,
              ).getValue(deviceType);

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: term.tags.take(isCompact ? 2 : 3).map((tag) {
                  return ResponsiveContainer(
                    padding: ResponsiveValues<EdgeInsetsGeometry>(
                      mobile:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      tablet:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      desktop:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF5A8DEE).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ResponsiveText(
                      tag,
                      fontSize: ResponsiveValues<double>(
                        mobile: 10.0,
                        tablet: 11.0,
                        desktop: 12.0,
                      ),
                      color: Color(0xFF5A8DEE),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ],
    );
  }
}

/// 자동 생명주기 유지 용어 카드 - 스크롤 성능 최적화
class KeepAliveTermCard extends StatefulWidget {
  final Term term;
  final bool isCompact;

  const KeepAliveTermCard({
    Key? key,
    required this.term,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<KeepAliveTermCard> createState() => _KeepAliveTermCardState();
}

class _KeepAliveTermCardState extends State<KeepAliveTermCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수 호출

    return MemoizedTermCard(
      term: widget.term,
      isCompact: widget.isCompact,
    );
  }
}
