import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/term_detail_screen.dart';
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
              child: NeumorphicContainer(
                margin: EdgeInsets.only(bottom: isCompact ? 8.0 : 12.0),
                padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
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
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? Colors.amber : themeProvider.subtitleColor,
                            size: 20,
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
            );
          },
          // 정적 컨텐츠 (한 번만 빌드되고 재사용)
          child: _buildStaticContent(context, themeProvider),
        );
      },
    );
  }

  /// 정적 컨텐츠 빌드 - 북마크 상태와 무관하게 불변
  Widget _buildStaticContent(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 용어 제목
        Text(
          term.term,
          style: TextStyle(
            fontSize: isCompact ? 16.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        
        SizedBox(height: isCompact ? 6.0 : 8.0),
        
        // 정의
        Text(
          term.definition,
          style: TextStyle(
            fontSize: isCompact ? 13.0 : 14.0,
            color: themeProvider.subtitleColor,
            height: 1.4,
          ),
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),
        
        if (!isCompact && term.example.isNotEmpty) ...[
          SizedBox(height: 8.0),
          
          // 예시
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: themeProvider.backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: themeProvider.dividerColor.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: Text(
              '예시: ${term.example}',
              style: TextStyle(
                fontSize: 12.0,
                color: themeProvider.subtitleColor.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
        
        if (term.tags.isNotEmpty) ...[
          SizedBox(height: 8.0),
          
          // 태그들
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: term.tags.take(isCompact ? 2 : 3).map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Color(0xFF5A8DEE).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(0xFF5A8DEE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
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