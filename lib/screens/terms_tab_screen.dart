import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../models/term.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/autocomplete_search_bar.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/term_list_widget.dart';
import '../widgets/index_scroll_bar.dart';
import '../widgets/error_display_widget.dart';
import '../utils/korean_sort_utils.dart';
import 'term_search_screen.dart';
import 'term_detail_screen.dart';
import 'add_term_screen.dart';

class TermsTabScreen extends StatefulWidget {
  @override
  _TermsTabScreenState createState() => _TermsTabScreenState();
}

class _TermsTabScreenState extends State<TermsTabScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _termsListKey = GlobalKey();
  
  bool _showIndexBar = false;
  bool _showScrollToTopButton = false;
  Map<String, GlobalKey> _indexKeys = {};
  Map<String, List<Term>> _groupedTerms = {};
  List<String> _availableIndexes = [];
  Timer? _hideTimer;
  Timer? _hideScrollToTopTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // 인덱스별 GlobalKey 생성
    for (String index in KoreanSortUtils.indexList) {
      _indexKeys[index] = GlobalKey();
    }
    
    // 초기 상태에서 인덱스 바는 이미 true로 설정됨
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _hideTimer?.cancel();
    _hideScrollToTopTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    // 스크롤 위치에 따라 맨 위로 버튼 표시/숨김
    final showScrollToTop = _scrollController.offset > 300;
    if (_showScrollToTopButton != showScrollToTop) {
      setState(() {
        _showScrollToTopButton = showScrollToTop;
      });
      
      if (showScrollToTop) {
        // 맨 위로 버튼 자동 숨김 타이머 (인덱스 바와 동일하게 2초)
        _hideScrollToTopTimer?.cancel();
        _hideScrollToTopTimer = Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showScrollToTopButton = false;
            });
          }
        });
      }
    }
    
    // 스크롤 중이면 인덱스 바 표시
    if (!_showIndexBar) {
      setState(() {
        _showIndexBar = true;
      });
    }
    
    // 기존 타이머 취소
    _hideTimer?.cancel();
    _hideScrollToTopTimer?.cancel();
    
    // 2초 후 인덱스 바와 맨 위로 버튼 동시에 숨기기
    _hideTimer = Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showIndexBar = false;
          _showScrollToTopButton = false;
        });
      }
    });
  }

  void _scrollToIndex(String index) {
    final key = _indexKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    
    // 인덱스 클릭 시에도 타이머 리셋
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showIndexBar = false;
        });
      }
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    
    setState(() {
      _showScrollToTopButton = false;
    });
  }

  void _updateGroupedTerms(List<Term> terms) {
    final sortedTerms = KoreanSortUtils.sortTermsKoreanEnglish(terms);
    _groupedTerms = KoreanSortUtils.groupTermsByIndex(sortedTerms);
    _availableIndexes = _groupedTerms.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TermProvider, ThemeProvider>(
      builder: (context, termProvider, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          body: LoadingErrorWidget(
            isLoading: termProvider.isLoading,
            errorMessage: termProvider.errorMessage,
            onRetry: () {
              termProvider.clearError();
              termProvider.retryLoadData();
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildQuickSearchSection(context, themeProvider)),
                          SizedBox(width: 12),
                          _buildAddButton(context, themeProvider),
                        ],
                      ),
                      SizedBox(height: 16),
                      CategoryFilterChips(),
                      SizedBox(height: 24),
                      _buildFilteredTermsSection(termProvider),
                    ],
                  ),
                ),
                // 인덱스 스크롤바 (용어가 있을 때만 표시)
                if (_availableIndexes.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IndexScrollBar(
                      scrollController: _scrollController,
                      availableIndexes: _availableIndexes,
                      onIndexSelected: _scrollToIndex,
                      isVisible: _showIndexBar,
                    ),
                  ),
                
                // 맨 위로 버튼
                if (_showScrollToTopButton)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _showScrollToTopButton ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: _scrollToTop,
                          child: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Color(0xFF5A8DEE).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return NeumorphicContainer(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.book,
                  color: Color(0xFF5A8DEE),
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  '용어사전',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F5A67),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '모르는 직장 용어를 쉽게 찾아보세요!\n카테고리별 검색으로 더 빠르게 찾을 수 있습니다.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4F5A67).withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSearchSection(BuildContext context, ThemeProvider themeProvider) {
    return AutocompleteSearchBar(
      controller: _searchController,
      onSearch: (query) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TermSearchScreen(initialQuery: query),
          ),
        );
      },
      onTermSelected: (term) {
        // 용어가 선택되면 상세 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TermDetailScreen(term: term),
          ),
        );
      },
      hintText: '궁금한 용어를 검색해보세요...',
    );
  }

  Widget _buildAddButton(BuildContext context, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddTermScreen()),
        );
      },
      child: NeumorphicContainer(
        borderRadius: 20,
        backgroundColor: themeProvider.cardColor,
        shadowColor: themeProvider.shadowColor,
        highlightColor: themeProvider.highlightColor,
        child: Container(
          width: 48,
          height: 48,
          child: Icon(
            Icons.add,
            color: Color(0xFF5A8DEE),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredTermsSection(TermProvider termProvider) {
    List<Term> termsToShow;
    
    if (termProvider.selectedCategory != null) {
      termsToShow = termProvider.getTermsByCategory(termProvider.selectedCategory!);
    } else {
      // 전체 카테고리 선택 시: 검색어가 있으면 필터된 결과, 없으면 모든 용어 표시
      if (termProvider.searchQuery.isNotEmpty) {
        termsToShow = termProvider.filteredTerms;
      } else {
        termsToShow = termProvider.allTerms;
      }
    }
    
    if (termsToShow.isEmpty) {
      return SizedBox();
    }

    // 용어들을 한글-영어 순으로 정렬하고 인덱스별로 그룹화
    _updateGroupedTerms(termsToShow);

    return Column(
      key: _termsListKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildIndexedTermsList(termProvider),
    );
  }

  List<Widget> _buildIndexedTermsList(TermProvider termProvider) {
    List<Widget> widgets = [];
    
    // 인덱스 순서대로 정렬
    final sortedIndexes = _availableIndexes.toList()
      ..sort((a, b) {
        final aIndex = KoreanSortUtils.indexList.indexOf(a);
        final bIndex = KoreanSortUtils.indexList.indexOf(b);
        return aIndex.compareTo(bIndex);
      });

    for (String index in sortedIndexes) {
      final termsForIndex = _groupedTerms[index];
      if (termsForIndex != null && termsForIndex.isNotEmpty) {
        widgets.add(_buildIndexSection(index, termsForIndex, termProvider));
      }
    }

    return widgets;
  }

  Widget _buildIndexSection(String index, List<Term> terms, TermProvider termProvider) {
    return Container(
      key: _indexKeys[index],
      child: TermListWidget(
        terms: terms,
        isCompact: true,
        showCategory: termProvider.selectedCategory == null,
      ),
    );
  }
}