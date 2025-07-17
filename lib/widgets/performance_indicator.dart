import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class PerformanceIndicator extends StatelessWidget {
  final int? resultCount;
  final Duration? searchDuration;
  final Duration? loadDuration;
  final String? operation;
  final bool isLoading;

  const PerformanceIndicator({
    Key? key,
    this.resultCount,
    this.searchDuration,
    this.loadDuration,
    this.operation,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isLoading) {
      return _buildLoadingIndicator(themeProvider);
    }

    if (resultCount == null && searchDuration == null && loadDuration == null) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (resultCount != null) _buildResultCount(themeProvider),
          if (searchDuration != null || loadDuration != null) 
            _buildDurationInfo(themeProvider),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                themeProvider.textColor.withAlpha(153),
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            operation ?? '검색 중...',
            style: TextStyle(
              color: themeProvider.textColor.withAlpha(153),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCount(ThemeProvider themeProvider) {
    return Row(
      children: [
        Icon(
          Icons.search,
          size: 14,
          color: themeProvider.textColor.withAlpha(153),
        ),
        SizedBox(width: 4),
        Text(
          '${resultCount}개 결과',
          style: TextStyle(
            color: themeProvider.textColor.withAlpha(153),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationInfo(ThemeProvider themeProvider) {
    final duration = searchDuration ?? loadDuration;
    if (duration == null) return SizedBox.shrink();

    final durationText = _formatDuration(duration);
    final icon = searchDuration != null ? Icons.timer : Icons.download;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: themeProvider.textColor.withAlpha(153),
        ),
        SizedBox(width: 4),
        Text(
          durationText,
          style: TextStyle(
            color: themeProvider.textColor.withAlpha(153),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds >= 1) {
      return '${duration.inSeconds}초';
    } else {
      return '${duration.inMilliseconds}ms';
    }
  }
}

class SearchPerformanceWidget extends StatefulWidget {
  final Widget child;
  final Function(String)? onSearch;
  final int? resultCount;

  const SearchPerformanceWidget({
    Key? key,
    required this.child,
    this.onSearch,
    this.resultCount,
  }) : super(key: key);

  @override
  _SearchPerformanceWidgetState createState() => _SearchPerformanceWidgetState();
}

class _SearchPerformanceWidgetState extends State<SearchPerformanceWidget> {
  Duration? _lastSearchDuration;
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.child,
        PerformanceIndicator(
          resultCount: widget.resultCount,
          searchDuration: _lastSearchDuration,
          isLoading: _isSearching,
          operation: '검색 중...',
        ),
      ],
    );
  }
}

class LoadingPerformanceWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onLoad;
  final String? operation;

  const LoadingPerformanceWidget({
    Key? key,
    required this.child,
    this.onLoad,
    this.operation,
  }) : super(key: key);

  @override
  _LoadingPerformanceWidgetState createState() => _LoadingPerformanceWidgetState();
}

class _LoadingPerformanceWidgetState extends State<LoadingPerformanceWidget> {
  Duration? _lastLoadDuration;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _performLoad();
  }

  void _performLoad() async {
    if (widget.onLoad == null) return;
    
    setState(() {
      _isLoading = true;
    });

    final stopwatch = Stopwatch()..start();
    
    try {
      await widget.onLoad!();
    } catch (e) {
      // 에러 처리는 상위에서 담당
    }
    
    stopwatch.stop();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _lastLoadDuration = stopwatch.elapsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.child,
        PerformanceIndicator(
          loadDuration: _lastLoadDuration,
          isLoading: _isLoading,
          operation: widget.operation ?? '로딩 중...',
        ),
      ],
    );
  }
}

// 성능 메트릭 수집용 싱글톤 클래스
class PerformanceMetrics {
  static final PerformanceMetrics _instance = PerformanceMetrics._internal();
  factory PerformanceMetrics() => _instance;
  PerformanceMetrics._internal();

  final Map<String, Duration> _searchTimes = {};
  final Map<String, Duration> _loadTimes = {};
  final Map<String, int> _searchCounts = {};

  void recordSearchTime(String query, Duration duration) {
    _searchTimes[query] = duration;
    _searchCounts[query] = (_searchCounts[query] ?? 0) + 1;
  }

  void recordLoadTime(String operation, Duration duration) {
    _loadTimes[operation] = duration;
  }

  Duration? getAverageSearchTime() {
    if (_searchTimes.isEmpty) return null;
    
    final total = _searchTimes.values.fold<int>(
      0, 
      (sum, duration) => sum + duration.inMilliseconds,
    );
    
    return Duration(milliseconds: total ~/ _searchTimes.length);
  }

  Duration? getAverageLoadTime() {
    if (_loadTimes.isEmpty) return null;
    
    final total = _loadTimes.values.fold<int>(
      0, 
      (sum, duration) => sum + duration.inMilliseconds,
    );
    
    return Duration(milliseconds: total ~/ _loadTimes.length);
  }

  Map<String, dynamic> getMetrics() {
    return {
      'avgSearchTime': getAverageSearchTime()?.inMilliseconds,
      'avgLoadTime': getAverageLoadTime()?.inMilliseconds,
      'searchCount': _searchCounts.values.fold<int>(0, (sum, count) => sum + count),
      'uniqueSearches': _searchTimes.length,
      'loadOperations': _loadTimes.length,
    };
  }

  void clearMetrics() {
    _searchTimes.clear();
    _loadTimes.clear();
    _searchCounts.clear();
  }
}