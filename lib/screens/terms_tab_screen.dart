import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
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
import '../widgets/performance_indicator.dart';
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
  List<String> _availableIndexes = [];
  Timer? _hideTimer;
  Timer? _hideScrollToTopTimer;
  
  // ScrollView Observer 컨트롤러
  late ListObserverController _observerController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _observerController = ListObserverController(controller: _scrollController);
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
    }
    
    // 스크롤 중이면 인덱스 바 표시
    if (!_showIndexBar) {
      setState(() {
        _showIndexBar = true;
      });
    }
    
    // 기존 타이머 취소 (스크롤 중에는 숨김 타이머 무효화)
    _hideTimer?.cancel();
    
    // 스크롤이 멈춘 후 2초 뒤에 인덱스 바 숨기기
    _hideTimer = Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showIndexBar = false;
        });
      }
    });
  }

  void _scrollToIndex(String index) {
    // Progressive Loading 완료 후에만 스크롤 이동 실행
    final termProvider = Provider.of<TermProvider>(context, listen: false);
    if (termProvider.isProgressiveLoading) {
      return; // Progressive Loading 중에는 스크롤 이동 불가
    }
    
    // 현재 표시된 용어 목록 가져오기
    final termsToShow = termProvider.selectedCategory != null 
        ? termProvider.getTermsByCategory(termProvider.selectedCategory!)
        : (termProvider.searchQuery.isNotEmpty 
            ? termProvider.filteredTerms 
            : termProvider.allTerms);
    
    // 해당 인덱스로 시작하는 첫 번째 단어 찾기
    final targetIndex = _findFirstTermIndexForCharacter(termsToShow, index);
    
    if (targetIndex != -1 && targetIndex < termsToShow.length) {
      // 해당 인덱스 위치로 스크롤
      _scrollToTermIndex(targetIndex);
    }
    
    // 인덱스 클릭 시 타이머 설정 (비주얼 피드백용)
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

  // 해당 문자로 시작하는 첫 번째 용어의 인덱스 찾기 (없으면 다음 문자 검색)
  int _findFirstTermIndexForCharacter(List<Term> terms, String character) {
    // 먼저 해당 문자로 시작하는 용어 찾기
    int result = _findExactCharacterMatch(terms, character);
    if (result != -1) {
      return result;
    }
    
    // 해당 문자가 없으면 다음 문자들 순서대로 검색
    final nextCharacters = _getNextCharacters(character);
    for (final nextChar in nextCharacters) {
      result = _findExactCharacterMatch(terms, nextChar);
      if (result != -1) {
        return result;
      }
    }
    
    return -1; // 모든 문자에서 찾지 못함
  }

  // 정확한 문자 매칭 찾기
  int _findExactCharacterMatch(List<Term> terms, String character) {
    for (int i = 0; i < terms.length; i++) {
      final term = terms[i];
      final firstChar = term.term.isNotEmpty ? term.term[0] : '';
      
      // 한글 초성 체크
      if (character == '#') {
        // 숫자나 특수문자로 시작하는 경우
        if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(firstChar)) {
          return i;
        }
      } else if (_isKoreanConsonant(character)) {
        // 한글 자음인 경우 초성 매칭
        final termInitial = _getKoreanInitial(firstChar);
        if (termInitial == character) {
          return i;
        }
      } else {
        // 영문자인 경우 대소문자 무시하고 매칭
        if (firstChar.toUpperCase() == character.toUpperCase()) {
          return i;
        }
      }
    }
    return -1; // 찾지 못함
  }

  // 다음 문자들 목록 가져오기
  List<String> _getNextCharacters(String character) {
    const allCharacters = ['#', 'ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ', 
                          'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
    
    final currentIndex = allCharacters.indexOf(character);
    if (currentIndex == -1 || currentIndex >= allCharacters.length - 1) {
      return []; // 현재 문자가 없거나 마지막 문자인 경우
    }
    
    // 현재 문자 다음부터 끝까지 반환
    return allCharacters.sublist(currentIndex + 1);
  }

  // 한글 자음인지 체크
  bool _isKoreanConsonant(String char) {
    const koreanConsonants = ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];
    return koreanConsonants.contains(char);
  }

  // 한글 문자의 초성 추출
  String _getKoreanInitial(String char) {
    if (char.isEmpty) return '';
    
    final code = char.codeUnitAt(0);
    if (code >= 0xAC00 && code <= 0xD7A3) {
      // 한글 완성형 문자인 경우
      final initialIndex = ((code - 0xAC00) ~/ 588);
      const initials = ['ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];
      if (initialIndex < initials.length) {
        // 쌍자음을 단자음으로 변환
        switch (initials[initialIndex]) {
          case 'ㄲ': return 'ㄱ';
          case 'ㄸ': return 'ㄷ';
          case 'ㅃ': return 'ㅂ';
          case 'ㅆ': return 'ㅅ';
          case 'ㅉ': return 'ㅈ';
          default: return initials[initialIndex];
        }
      }
    }
    return char.toUpperCase(); // 한글이 아니면 대문자로 반환
  }

  // 특정 인덱스 위치로 스크롤 (ScrollView Observer 사용)
  void _scrollToTermIndex(int index) {
    _observerController.jumpTo(index: index);
  }

  void _updateGroupedTerms(List<Term> terms) {
    // 빈 리스트 처리
    if (terms.isEmpty) {
      setState(() {
        _showIndexBar = false;
      });
      return;
    }
    
    // 비주얼 용도로만 사용 - 실제 로직은 제거
    // 임시 인덱스 리스트 생성 (비주얼 표시용)
    _availableIndexes = ['#', 'ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
    
    // 인덱스 바 상태는 스크롤 이벤트에서만 관리 (강제 숨김 제거)
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TermProvider, ThemeProvider>(
      builder: (context, termProvider, themeProvider, child) {
        // 검색창이 비어있는데 TermProvider에 검색 쿼리가 있다면 필터 초기화 (일관성 유지)
        if (termProvider.searchQuery.isNotEmpty && _searchController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              termProvider.clearFilters();
            }
          });
        }
        
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Row(
                        children: [
                          Expanded(child: _buildQuickSearchSection(context, themeProvider)),
                          SizedBox(width: 12),
                          _buildAddButton(context, themeProvider),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CategoryFilterChips(),
                    ),
                    SizedBox(height: 24),
                    Expanded(
                      child: _buildFilteredTermsSection(termProvider),
                    ),
                  ],
                ),
                // 인덱스 스크롤바 (Progressive Loading과 관계없이 표시)
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
      // 전체 카테고리 선택 시: 검색어와 로컬 검색 컨트롤러 모두 확인
      if (termProvider.searchQuery.isNotEmpty && _searchController.text.isNotEmpty) {
        termsToShow = termProvider.filteredTerms;
      } else {
        termsToShow = termProvider.allTerms;
      }
    }
    
    if (termsToShow.isEmpty) {
      return SizedBox();
    }

    // Progressive Loading 완료 시에만 인덱스 네비게이션용 그룹화 수행
    if (!termProvider.isProgressiveLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateGroupedTerms(termsToShow);
        }
      });
    } else {
      // Progressive Loading 중에는 인덱스 데이터 초기화
      _availableIndexes.clear();
    }

    // 카테고리가 변경되었을 때 스크롤 위치를 맨 위로 초기화 (제거됨)

    return ListViewObserver(
      controller: _observerController,
      child: ListView(
        controller: _scrollController,
        key: _termsListKey,
        children: _buildIndexedTermsList(termProvider),
      ),
    );
  }

  List<Widget> _buildIndexedTermsList(TermProvider termProvider) {
    List<Widget> widgets = [];
    
    // 로직 제거 - 단순히 전체 용어 리스트만 표시
    final termsToShow = termProvider.selectedCategory != null 
        ? termProvider.getTermsByCategory(termProvider.selectedCategory!)
        : (termProvider.searchQuery.isNotEmpty 
            ? termProvider.filteredTerms 
            : termProvider.allTerms);
    
    // 인덱스 섹션 없이 단순 리스트로 표시
    for (final term in termsToShow) {
      widgets.add(_buildTermCard(term, termProvider));
    }
    
    return widgets;
  }

  Widget _buildTermCard(Term term, TermProvider termProvider) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TermDetailScreen(term: term),
            ),
          );
        },
        child: NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 용어명, 카테고리, 북마크 아이콘
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // 용어명
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) => Text(
                              term.term,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode ? themeProvider.textColor : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          // 카테고리 표시 (전체 카테고리에서만)
                          if (termProvider.selectedCategory == null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF5A8DEE).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getCategoryDisplayName(term.category),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF5A8DEE),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 북마크 아이콘
                    GestureDetector(
                      onTap: () async {
                        await termProvider.toggleBookmark(term.termId);
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          term.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: term.isBookmarked ? Color(0xFF5A8DEE) : Colors.grey,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // 용어 정의
                Text(
                  term.definition,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 카테고리 표시 이름 가져오기
  String _getCategoryDisplayName(TermCategory category) {
    return category.displayName;
  }
}