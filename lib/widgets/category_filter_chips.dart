import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_breakpoints.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer2<TermProvider, ThemeProvider>(
      builder: (context, termProvider, themeProvider, child) {
        return ResponsiveContainer(
          height: ResponsiveValues<double>(
            mobile: 50,
            tablet: 56,
            desktop: 64,
          ),
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
                  padding: ResponsiveValues<EdgeInsets>(
                    mobile: EdgeInsets.symmetric(horizontal: 16),
                    tablet: EdgeInsets.symmetric(horizontal: 20),
                    desktop: EdgeInsets.symmetric(horizontal: 24),
                  ).getValueFromContext(context),
                  child: ResponsiveBuilder(
                    builder: (context, deviceType) {
                      final chipSpacing = ResponsiveValues<double>(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ).getValue(deviceType);

                      return Row(
                        children: [
                          _buildFilterChip(
                            context,
                            termProvider,
                            themeProvider,
                            '전체',
                            null,
                            termProvider.selectedCategory == null,
                          ),
                          SizedBox(width: chipSpacing),
                          _buildFilterChip(
                            context,
                            termProvider,
                            themeProvider,
                            '북마크',
                            TermCategory.bookmarked,
                            termProvider.selectedCategory ==
                                TermCategory.bookmarked,
                          ),
                          SizedBox(width: chipSpacing),
                          ...TermCategory.values
                              .where((category) =>
                                  category != TermCategory.other &&
                                  category != TermCategory.bookmarked)
                              .map((category) {
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
                                SizedBox(width: chipSpacing),
                              ],
                            );
                          }).toList(),
                        ],
                      );
                    },
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
                    width: ResponsiveValues<double>(
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    ).getValueFromContext(context),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeProvider.backgroundColor,
                          themeProvider.backgroundColor.withAlpha(0),
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
                    width: ResponsiveValues<double>(
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    ).getValueFromContext(context),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeProvider.backgroundColor.withAlpha(0),
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
        child: ResponsiveContainer(
          padding: ResponsiveValues<EdgeInsetsGeometry>(
            mobile: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            tablet: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            desktop: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF5A8DEE) : themeProvider.cardColor,
            borderRadius: BorderRadius.circular(
              ResponsiveValues<double>(
                mobile: 20,
                tablet: 22,
                desktop: 24,
              ).getValueFromContext(context),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Color(0xFF5A8DEE).withAlpha(77),
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: themeProvider.shadowColor.withAlpha(77),
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: themeProvider.highlightColor.withAlpha(204),
                      offset: Offset(-2, -2),
                      blurRadius: 4,
                    ),
                  ],
          ),
          child: ResponsiveText(
            label,
            fontSize: ResponsiveValues<double>(
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : themeProvider.textColor.withAlpha(179),
          ),
        ),
      ),
    );
  }
}
