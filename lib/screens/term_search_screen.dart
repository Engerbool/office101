import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/autocomplete_search_bar.dart';
import '../widgets/term_list_widget.dart';
import '../widgets/error_display_widget.dart';
import '../widgets/performance_indicator.dart';
import 'term_detail_screen.dart';

class TermSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const TermSearchScreen({Key? key, this.initialQuery}) : super(key: key);

  @override
  _TermSearchScreenState createState() => _TermSearchScreenState();
}

class _TermSearchScreenState extends State<TermSearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<TermProvider>(context, listen: false)
            .searchTerms(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            title: Text(
              '용어 검색',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            backgroundColor: themeProvider.backgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: themeProvider.textColor),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: SearchPerformanceWidget(
                  resultCount:
                      Provider.of<TermProvider>(context).filteredTerms.length,
                  onSearch: (query) async {
                    final termProvider =
                        Provider.of<TermProvider>(context, listen: false);
                    termProvider.searchTerms(query);

                    // 검색 완료까지 대기 (디바운싱 고려)
                    await Future.delayed(Duration(milliseconds: 350));
                  },
                  child: AutocompleteSearchBar(
                    controller: _searchController,
                    onSearch: (query) {
                      Provider.of<TermProvider>(context, listen: false)
                          .searchTerms(query);
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
                    hintText: '검색할 용어를 입력하세요...',
                  ),
                ),
              ),
              Expanded(
                child: Consumer<TermProvider>(
                  builder: (context, termProvider, child) {
                    print(
                        'TermSearchScreen: Building with ${termProvider.allTerms.length} terms, loading: ${termProvider.isLoading}');

                    // 에러 상태 체크
                    if (termProvider.hasError) {
                      return ErrorDisplayWidget(
                        errorMessage: termProvider.errorMessage,
                        onRetry: () {
                          termProvider.clearError();
                          if (termProvider.searchQuery.isNotEmpty) {
                            termProvider.searchTerms(termProvider.searchQuery);
                          } else {
                            termProvider.retryLoadData();
                          }
                        },
                      );
                    }

                    if (termProvider.searchQuery.isEmpty && termProvider.selectedCategory == null) {
                      return _buildInitialState(themeProvider);
                    }

                    // 검색 결과가 없는 경우
                    if (termProvider.filteredTerms.isEmpty) {
                      return _buildNoResultsState(termProvider, themeProvider);
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchResultsHeader(
                              termProvider, themeProvider),
                          SizedBox(height: 16),
                          Expanded(
                            child: TermListWidget(
                              terms: termProvider.filteredTerms,
                              showCategory: true,
                              currentCategory: termProvider.selectedCategory,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInitialState(ThemeProvider themeProvider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: themeProvider.textColor.withAlpha(77),
            ),
            SizedBox(height: 24),
            Text(
              '용어 검색',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '궁금한 직장 용어를 검색해보세요.\n용어명, 정의, 태그로 검색할 수 있습니다.',
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.subtitleColor.withAlpha(153),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsHeader(
      TermProvider termProvider, ThemeProvider themeProvider) {
    final resultCount = termProvider.filteredTerms.length;

    return Row(
      children: [
        Text(
          '검색 결과',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFF5A8DEE).withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$resultCount개',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF5A8DEE),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Spacer(),
        if (termProvider.searchQuery.isNotEmpty)
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              termProvider.clearFilters();
            },
            icon: Icon(
              Icons.clear,
              size: 16,
              color: themeProvider.subtitleColor.withAlpha(153),
            ),
            label: Text(
              '초기화',
              style: TextStyle(
                color: themeProvider.subtitleColor.withAlpha(153),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoResultsState(
      TermProvider termProvider, ThemeProvider themeProvider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: themeProvider.textColor.withAlpha(77),
            ),
            SizedBox(height: 24),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '"${termProvider.searchQuery}"에 대한\n검색 결과를 찾을 수 없습니다.',
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.subtitleColor.withAlpha(153),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Column(
              children: [
                Text(
                  '다음을 확인해보세요:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor.withAlpha(204),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• 검색어의 철자가 정확한지 확인\n• 다른 키워드로 검색\n• 더 간단한 검색어 사용',
                  style: TextStyle(
                    fontSize: 13,
                    color: themeProvider.subtitleColor.withAlpha(153),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    termProvider.clearFilters();
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: Color(0xFF5A8DEE),
                  ),
                  label: Text(
                    '검색 초기화',
                    style: TextStyle(
                      color: Color(0xFF5A8DEE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
