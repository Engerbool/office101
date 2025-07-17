import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/haptic_utils.dart';
import '../screens/term_detail_screen.dart';
import '../constants/category_colors.dart';
import 'neumorphic_container.dart';

class SwipeableTermCard extends StatefulWidget {
  final Term term;
  final bool isCompact;

  const SwipeableTermCard({
    Key? key,
    required this.term,
    this.isCompact = false,
  }) : super(key: key);

  @override
  _SwipeableTermCardState createState() => _SwipeableTermCardState();
}

class _SwipeableTermCardState extends State<SwipeableTermCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double _dragExtent = 0;
  bool _dragUnderway = false;

  static const double _kDragThreshold = 0.3;
  static const double _kMinFlingVelocity = 700.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragUnderway) return;

    final double delta = details.primaryDelta! / context.size!.width;
    _dragExtent += delta;
    
    if (_dragExtent < 0) _dragExtent = 0;
    if (_dragExtent > 1) _dragExtent = 1;

    _controller.value = _dragExtent;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragUnderway) return;
    _dragUnderway = false;

    final double velocity = details.primaryVelocity! / context.size!.width;
    
    if (velocity.abs() >= _kMinFlingVelocity) {
      // 빠른 스와이프
      if (velocity > 0) {
        _performSwipeAction();
      } else {
        _controller.animateTo(0.0);
      }
    } else {
      // 느린 스와이프 - 임계값 확인
      if (_dragExtent > _kDragThreshold) {
        _performSwipeAction();
      } else {
        _controller.animateTo(0.0);
      }
    }
  }

  void _performSwipeAction() async {
    await HapticUtils.swipeAction();
    
    // 북마크 토글
    Provider.of<TermProvider>(context, listen: false)
        .toggleBookmark(widget.term.termId);
    
    // 애니메이션 리셋
    _controller.animateTo(0.0);
    _dragExtent = 0;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // 배경 액션 영역
          _buildSwipeBackground(themeProvider),
          // 메인 카드
          SlideTransition(
            position: _offsetAnimation,
            child: _buildTermCard(context, themeProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground(ThemeProvider themeProvider) {
    return Container(
      height: widget.isCompact ? 80 : 120,
      decoration: BoxDecoration(
        color: widget.term.isBookmarked ? Colors.red.withAlpha(26) : Colors.orange.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.term.isBookmarked ? Icons.bookmark_remove : Icons.bookmark_add,
                  color: widget.term.isBookmarked ? Colors.red : Colors.orange,
                  size: 24,
                ),
                SizedBox(height: 4),
                Text(
                  widget.term.isBookmarked ? '북마크\n해제' : '북마크\n추가',
                  style: TextStyle(
                    color: widget.term.isBookmarked ? Colors.red : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildTermCard(BuildContext context, ThemeProvider themeProvider) {
    return Semantics(
      label: '${widget.term.term} 용어 카드',
      hint: '탭하여 자세한 정보를 확인하거나, 오른쪽으로 스와이프하여 북마크를 ${widget.term.isBookmarked ? "해제" : "추가"}할 수 있습니다',
      button: true,
      child: GestureDetector(
        onTap: () async {
          await HapticUtils.lightTap();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TermDetailScreen(term: widget.term),
            ),
          );
        },
        child: NeumorphicContainer(
        backgroundColor: themeProvider.cardColor,
        shadowColor: themeProvider.shadowColor,
        highlightColor: themeProvider.highlightColor,
        child: Container(
          height: widget.isCompact ? 80 : 120,
          padding: EdgeInsets.all(widget.isCompact ? 12.0 : 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.term.term,
                      style: TextStyle(
                        fontSize: widget.isCompact ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CategoryColors.getCategoryBackgroundColor(widget.term.category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getCategoryName(widget.term.category),
                        style: TextStyle(
                          fontSize: 10,
                          color: CategoryColors.getCategoryColor(widget.term.category),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: widget.isCompact ? 4 : 6),
              if (!widget.isCompact)
                Flexible(
                  child: Text(
                    widget.term.definition,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.subtitleColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (widget.isCompact)
                Text(
                  widget.term.definition,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.subtitleColor,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }


  String _getCategoryName(TermCategory category) {
    switch (category) {
      case TermCategory.business:
        return '비즈니스';
      case TermCategory.marketing:
        return '마케팅';
      case TermCategory.it:
        return 'IT';
      case TermCategory.hr:
        return '인사';
      case TermCategory.communication:
        return '소통';
      case TermCategory.approval:
        return '결재';
      case TermCategory.time:
        return '시간';
      case TermCategory.other:
        return '기타';
      case TermCategory.bookmarked:
        return '북마크';
    }
  }
}