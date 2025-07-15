import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import 'neumorphic_container.dart';

class CategoryFilterChips extends StatefulWidget {
  @override
  _CategoryFilterChipsState createState() => _CategoryFilterChipsState();
}

class _CategoryFilterChipsState extends State<CategoryFilterChips> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftGradient = false;
  bool _showRightGradient = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // 초기 상태에서 오른쪽 그라데이션만 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateGradients();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateGradients();
  }

  void _updateGradients() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final showLeft = position.pixels > 10;
    final showRight = position.pixels < position.maxScrollExtent - 10;

    if (_showLeftGradient != showLeft || _showRightGradient != showRight) {
      setState(() {
        _showLeftGradient = showLeft;
        _showRightGradient = showRight;
      });
    }
  }

  // 자동 스크롤 기능 제거됨 - 사용자 선택 위치 유지
  // void _scrollToSelectedChip(TermCategory? selectedCategory) {
  //   // 더 이상 사용하지 않음 - 카테고리 선택 시 스크롤 위치 유지
  // }
  @override
  Widget build(BuildContext context) {
    return Consumer2<TermProvider, ThemeProvider>(
      builder: (context, termProvider, themeProvider, child) {
        return Container(
          height: 50, // 고정 높이 지정
          child: Stack(
            children: [
              // 메인 스크롤 영역 (Scrollable로 마우스 휠 지원)
              Scrollbar(
                controller: _scrollController,
                scrollbarOrientation: ScrollbarOrientation.bottom,
                thumbVisibility: false, // 스크롤바 숨김
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(), // 부드러운 스크롤 효과
                  padding: EdgeInsets.symmetric(horizontal: 16), // 좌우 패딩
                  child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      termProvider,
                      themeProvider,
                      '전체',
                      null,
                      termProvider.selectedCategory == null,
                    ),
                    SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      termProvider,
                      themeProvider,
                      '북마크',
                      TermCategory.bookmarked,
                      termProvider.selectedCategory == TermCategory.bookmarked,
                    ),
                    SizedBox(width: 8),
                    ...TermCategory.values.where((category) => category != TermCategory.other && category != TermCategory.bookmarked).map((category) {
                      return Row(
                        children: [
                          _buildFilterChip(
                            context,
                            termProvider,
                            themeProvider,
                            category.displayName,
                            category,
                            termProvider.selectedCategory == category,
                          ),
                          SizedBox(width: 8),
                        ],
                      );
                    }).toList(),
                    ],
                  ),
                ),
              ),
              
              // 왼쪽 페이드 그라데이션
              if (_showLeftGradient)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeProvider.backgroundColor,
                          themeProvider.backgroundColor.withOpacity(0),
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              
              // 오른쪽 페이드 그라데이션
              if (_showRightGradient)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeProvider.backgroundColor.withOpacity(0),
                          themeProvider.backgroundColor,
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    TermProvider termProvider,
    ThemeProvider themeProvider,
    String label,
    TermCategory? category,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        termProvider.filterByCategory(category);
        // 자동 스크롤 제거 - 사용자가 선택한 위치 유지
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF5A8DEE) : themeProvider.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Color(0xFF5A8DEE).withOpacity(0.3),
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: themeProvider.shadowColor.withOpacity(0.3),
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: themeProvider.highlightColor.withOpacity(0.8),
                      offset: Offset(-2, -2),
                      blurRadius: 4,
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected 
                  ? Colors.white
                  : themeProvider.textColor.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(TermCategory? category) {
    if (category == null) return Color(0xFF5A8DEE);
    
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
}