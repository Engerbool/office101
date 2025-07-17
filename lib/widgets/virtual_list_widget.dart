import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/theme_provider.dart';
import 'swipeable_term_card.dart';

class VirtualListWidget extends StatefulWidget {
  final List<Term> terms;
  final bool isCompact;
  final int initialItemCount;
  final int itemsPerPage;

  const VirtualListWidget({
    Key? key,
    required this.terms,
    this.isCompact = false,
    this.initialItemCount = 20,
    this.itemsPerPage = 10,
  }) : super(key: key);

  @override
  _VirtualListWidgetState createState() => _VirtualListWidgetState();
}

class _VirtualListWidgetState extends State<VirtualListWidget> {
  late ScrollController _scrollController;
  int _currentItemCount = 0;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentItemCount = widget.initialItemCount;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() async {
    if (_isLoadingMore || _currentItemCount >= widget.terms.length) return;

    setState(() {
      _isLoadingMore = true;
    });

    // 실제 로딩 지연 시뮬레이션 (부드러운 UX를 위해)
    await Future.delayed(Duration(milliseconds: 100));

    setState(() {
      _currentItemCount = (_currentItemCount + widget.itemsPerPage)
          .clamp(0, widget.terms.length);
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.terms.isEmpty) {
      return _buildEmptyState();
    }

    final displayTerms = widget.terms.take(_currentItemCount).toList();

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            itemCount: displayTerms.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final term = displayTerms[index];
              return SwipeableTermCard(
                term: term,
                isCompact: widget.isCompact,
              );
            },
          ),
        ),
        if (_isLoadingMore) _buildLoadingIndicator(),
        if (_currentItemCount < widget.terms.length && !_isLoadingMore)
          _buildLoadMoreButton(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: themeProvider.textColor.withAlpha(77),
              ),
              SizedBox(height: 16),
              Text(
                '해당하는 용어가 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.textColor.withAlpha(153),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    themeProvider.textColor.withAlpha(153),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                '더 많은 용어를 불러오는 중...',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.textColor.withAlpha(153),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreButton() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _loadMore,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.cardColor,
              foregroundColor: themeProvider.textColor,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.expand_more, size: 20),
                SizedBox(width: 8),
                Text('더 보기 (${widget.terms.length - _currentItemCount}개 남음)'),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 향상된 TermListWidget
class OptimizedTermListWidget extends StatelessWidget {
  final List<Term> terms;
  final bool isCompact;
  final bool enableVirtualScrolling;

  const OptimizedTermListWidget({
    Key? key,
    required this.terms,
    this.isCompact = false,
    this.enableVirtualScrolling = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 100개 이상의 용어가 있을 때만 가상 스크롤링 사용
    if (enableVirtualScrolling && terms.length > 100) {
      return VirtualListWidget(
        terms: terms,
        isCompact: isCompact,
        initialItemCount: 20,
        itemsPerPage: 15,
      );
    }

    // 일반 리스트 (100개 이하)
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (terms.isEmpty) {
          return _buildEmptyState(themeProvider);
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: terms.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final term = terms[index];
            return SwipeableTermCard(
              term: term,
              isCompact: isCompact,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: themeProvider.textColor.withAlpha(77),
          ),
          SizedBox(height: 16),
          Text(
            '해당하는 용어가 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.textColor.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }
}