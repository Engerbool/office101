import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/term_provider.dart';
import '../models/term.dart';
import '../services/database_service.dart';
import 'neumorphic_container.dart';
import '../constants/category_colors.dart';

class AutocompleteSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(Term) onTermSelected;
  final String? hintText;
  final TextEditingController? controller;

  const AutocompleteSearchBar({
    Key? key,
    required this.onSearch,
    required this.onTermSelected,
    this.hintText,
    this.controller,
  }) : super(key: key);

  @override
  _AutocompleteSearchBarState createState() => _AutocompleteSearchBarState();
}

class _AutocompleteSearchBarState extends State<AutocompleteSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showSuggestions = false;
  List<Term> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    
    _focusNode.addListener(_onFocusChanged);
    
    // TermProvider 초기화를 강제로 트리거
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final termProvider = Provider.of<TermProvider>(context, listen: false);
      
      // TermProvider가 아직 로딩 중이지 않으면 강제로 로딩 시작
      if (!termProvider.isLoading && termProvider.allTerms.isEmpty) {
        termProvider.loadData();
      }
      
      // 초기 텍스트가 있는지 확인
      if (_controller.text.isNotEmpty) {
        // 초기 텍스트가 있으면 자동완성 수행
        final value = _controller.text;
        if (value.isNotEmpty) {
          _suggestions = _getAllTerms().where((term) => 
            term.term.toLowerCase().contains(value.toLowerCase())
          ).take(5).toList();
          _showSuggestions = _suggestions.isNotEmpty;
        }
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  List<Term> _getAllTerms() {
    try {
      // 먼저 DatabaseService에서 직접 시도
      final terms = DatabaseService.getAllTerms();
      if (terms.isNotEmpty) {
        return terms;
      }
      
      // DatabaseService가 실패하면 TermProvider에서 시도
      final termProvider = Provider.of<TermProvider>(context, listen: false);
      if (termProvider.allTerms.isNotEmpty) {
        return termProvider.allTerms;
      }
      
      // 모든 실제 데이터가 실패하면 테스트 데이터 사용
      return _getTestTerms();
    } catch (e) {
      return _getTestTerms();
    }
  }

  List<Term> _getTestTerms() {
    try {
      // 테스트용 하드코딩된 용어들
      return [
        Term(
          termId: 'test_001',
          category: TermCategory.approval,
          term: '상신',
          definition: '회사의 업무나 안건을 상급자에게 보고하여 승인을 요청하는 일',
          example: '이번 프로젝트 예산안을 팀장님께 상신하겠습니다.',
          tags: ['결재', '승인', '보고'],
          userAdded: false,
          isBookmarked: false,
        ),
        Term(
          termId: 'test_002',
          category: TermCategory.approval,
          term: '상품',
          definition: '판매를 목적으로 만들어진 물건',
          example: '새로운 상품을 개발하고 있습니다.',
          tags: ['제품', '판매'],
          userAdded: false,
          isBookmarked: false,
        ),
        Term(
          termId: 'test_003',
          category: TermCategory.business,
          term: '상황',
          definition: '현재의 형편이나 처지',
          example: '현재 상황을 파악해보겠습니다.',
          tags: ['현재', '상태'],
          userAdded: false,
          isBookmarked: false,
        ),
      ];
    } catch (e) {
      return [];
    }
  }



  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // 포커스를 잃으면 잠시 후 자동완성 숨기기 (사용자가 항목을 선택할 시간 제공)
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted && !_focusNode.hasFocus) {
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    } else {
      // 포커스를 받으면 자동완성 표시
      final value = _controller.text;
      if (value.isNotEmpty) {
        setState(() {
          _suggestions = _getAllTerms().where((term) => 
            term.term.toLowerCase().contains(value.toLowerCase())
          ).take(5).toList();
          _showSuggestions = _suggestions.isNotEmpty;
        });
      }
    }
  }

  void _onSuggestionTapped(Term term) {
    _controller.text = term.term;
    setState(() {
      _showSuggestions = false;
    });
    widget.onTermSelected(term);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: [
            NeumorphicContainer(
              backgroundColor: themeProvider.cardColor,
              shadowColor: themeProvider.shadowColor,
              highlightColor: themeProvider.highlightColor,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: themeProvider.textColor.withAlpha(153),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              final allTerms = _getAllTerms();
                              final queryLower = value.toLowerCase();
                              
                              // 검색 결과 필터링
                              final matches = allTerms.where((term) => 
                                term.term.toLowerCase().contains(queryLower)
                              ).toList();
                              
                              // 우선순위별로 정렬 (시작하는 것 우선)
                              matches.sort((a, b) {
                                final aLower = a.term.toLowerCase();
                                final bLower = b.term.toLowerCase();
                                final aStarts = aLower.startsWith(queryLower);
                                final bStarts = bLower.startsWith(queryLower);
                                
                                if (aStarts && !bStarts) return -1;
                                if (!aStarts && bStarts) return 1;
                                return a.term.compareTo(b.term);
                              });
                              
                              _suggestions = matches.take(5).toList();
                              _showSuggestions = _suggestions.isNotEmpty;
                            });
                          } else {
                            setState(() {
                              _suggestions = [];
                              _showSuggestions = false;
                            });
                          }
                        },
                        onSubmitted: (value) {
                          // 엔터 키를 눌러도 포커스를 유지하고 드롭다운을 계속 보여줌
                          widget.onSearch(value);
                          // 포커스를 다시 요청하여 드롭다운을 유지
                          _focusNode.requestFocus();
                        },
                        decoration: InputDecoration(
                          hintText: widget.hintText ?? '용어를 검색해보세요...',
                          hintStyle: TextStyle(
                            color: themeProvider.subtitleColor.withAlpha(128),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                        ),
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          // clear 후 상태 초기화
                          setState(() {
                            _suggestions = [];
                            _showSuggestions = false;
                          });
                          // X 버튼을 누를 때는 onSearch를 호출하지 않음
                          // 단순히 텍스트만 지우고 포커스 유지
                          _focusNode.requestFocus();
                        },
                        child: Icon(
                          Icons.clear,
                          color: themeProvider.textColor.withAlpha(153),
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_showSuggestions && _suggestions.isNotEmpty) ...[
              Container(
                margin: EdgeInsets.only(top: 8),
                child: NeumorphicContainer(
                  backgroundColor: themeProvider.cardColor,
                  shadowColor: themeProvider.shadowColor,
                  highlightColor: themeProvider.highlightColor,
                  child: Column(
                    children: _suggestions.map((term) {
                      return _buildSuggestionItem(term, themeProvider);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSuggestionItem(Term term, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => _onSuggestionTapped(term),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: themeProvider.dividerColor.withAlpha(26),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 16,
              color: themeProvider.textColor.withAlpha(102),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: _buildHighlightedText(
                        term.term,
                        _controller.text,
                        themeProvider,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    term.definition,
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.subtitleColor.withAlpha(153),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: CategoryColors.getCategoryBackgroundColor(term.category),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                term.category.displayName,
                style: TextStyle(
                  fontSize: 10,
                  color: CategoryColors.getCategoryColor(term.category),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildHighlightedText(String text, String query, ThemeProvider themeProvider) {
    if (query.isEmpty) {
      return [
        TextSpan(
          text: text,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ];
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return [
        TextSpan(
          text: text,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ];
    }

    return [
      if (index > 0)
        TextSpan(
          text: text.substring(0, index),
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          color: Color(0xFF5A8DEE),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      if (index + query.length < text.length)
        TextSpan(
          text: text.substring(index + query.length),
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
    ];
  }

}