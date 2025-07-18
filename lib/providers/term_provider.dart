import 'package:flutter/material.dart';
import 'dart:async';
import '../models/term.dart';
import '../models/email_template.dart';
import '../models/workplace_tip.dart';
import '../services/database_service.dart';
import '../services/error_service.dart';
import '../utils/validation_utils.dart';
import '../utils/korean_sort_utils.dart';
import '../utils/lru_cache.dart';

class TermProvider extends ChangeNotifier {
  List<Term> _allTerms = [];
  List<Term> _filteredTerms = [];
  List<EmailTemplate> _emailTemplates = [];
  List<WorkplaceTip> _workplaceTips = [];

  String _searchQuery = '';
  TermCategory? _selectedCategory;
  bool _isLoading = true;
  String? _errorMessage;
  AppError? _lastError;

  // 성능 최적화를 위한 변수들
  Timer? _searchDebouncer;
  final LRUCache<String, List<Term>> _searchCache = LRUCache(maxSize: 50);
  final LRUCache<TermCategory, List<Term>> _categoryCache =
      LRUCache(maxSize: 20);
  Set<TermCategory> _changedCategories = {};

  // Progressive Loading을 위한 변수들
  bool _isProgressiveLoading = false;
  int _loadedItemCount = 0;
  static const int _initialLoadCount = 10; // 초기 로딩 수 (즉시 표시)

  // Getters
  List<Term> get allTerms => _allTerms;
  List<Term> get filteredTerms => _filteredTerms;
  List<EmailTemplate> get emailTemplates => _emailTemplates;
  List<WorkplaceTip> get workplaceTips => _workplaceTips;
  String get searchQuery => _searchQuery;
  TermCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AppError? get lastError => _lastError;
  bool get hasError => _errorMessage != null;
  bool get isProgressiveLoading => _isProgressiveLoading;
  int get loadedItemCount => _loadedItemCount;

  // Progressive Loading용 필터링된 용어 (처음에는 제한된 개수만 반환)
  List<Term> get progressiveFilteredTerms {
    try {
      if (_isProgressiveLoading &&
          _loadedItemCount > 0 &&
          _filteredTerms.isNotEmpty) {
        final count = _loadedItemCount.clamp(0, _filteredTerms.length);
        return _filteredTerms.take(count).toList();
      }
      return _filteredTerms;
    } catch (e) {
      return _filteredTerms;
    }
  }

  TermProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _setLoadingState(true);
    _clearError();

    try {
      if (!DatabaseService.isInitialized) {
        await DatabaseService.initialize();
      }

      _allTerms = DatabaseService.getAllTerms();

      // 한글-영어 순으로 정렬하여 일관된 순서 보장
      _allTerms = KoreanSortUtils.sortTermsKoreanEnglish(_allTerms);

      _emailTemplates = DatabaseService.getAllEmailTemplates();
      _workplaceTips = DatabaseService.getAllWorkplaceTips();
      _invalidateCache();

      // 모든 카테고리를 미리 캐싱하여 즉시 응답 보장
      await _preloadAllCategories();

      _filteredTerms = _allTerms;

      if (_allTerms.isEmpty) {
        _setError('데이터를 불러올 수 없습니다. 앱을 다시 시작해보세요.');
      }
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError(
          'Loading provider data', e, stackTrace);
      ErrorService.logError(error);
      _setError(error.userMessage, error);
    } finally {
      _setLoadingState(false);
    }
  }

  void searchTerms(String query) {
    try {
      final trimmedQuery = query.trim();

      // 디바운싱: 이전 타이머 취소
      _searchDebouncer?.cancel();

      // 300ms 후에 실제 검색 수행
      _searchDebouncer = Timer(Duration(milliseconds: 300), () {
        _performSearch(trimmedQuery);
      });

      _clearError();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      _setError('검색 중 오류가 발생했습니다.', error);
    }
  }

  void _performSearch(String query) {
    try {
      _searchQuery = query;
      _applyFiltersOptimized();
      notifyListeners();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      _setError('검색 중 오류가 발생했습니다.', error);
    }
  }

  void filterByCategory(TermCategory? category) {
    try {
      _selectedCategory = category;

      // 전체 카테고리인 경우 Progressive Loading 적용
      if (category == null) {
        _startProgressiveLoading(_allTerms);
        return;
      }

      // 캐시된 데이터가 있으면 Progressive Loading 적용
      final cachedCategory = _categoryCache.get(category);
      if (cachedCategory != null) {
        _startProgressiveLoading(cachedCategory);
        return;
      }

      // 캐시가 없는 경우에만 필터링 수행 (북마크는 동적이므로)
      if (category == TermCategory.bookmarked) {
        final bookmarked =
            _allTerms.where((term) => term.isBookmarked).toList();
        _categoryCache.put(category, bookmarked);
        _startProgressiveLoading(bookmarked);
      } else {
        // 다른 카테고리는 이미 캐시되어 있어야 함
        _applyFiltersAsync();
      }

      _clearError();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      _setError('필터링 중 오류가 발생했습니다.', error);
    }
  }

  // Progressive Loading 시작
  void _startProgressiveLoading(List<Term> targetTerms) {
    try {
      _filteredTerms = targetTerms;

      if (targetTerms.length <= _initialLoadCount) {
        // 데이터가 적으면 즉시 모두 표시
        _isProgressiveLoading = false;
        _loadedItemCount = targetTerms.length;
        _clearError();
        notifyListeners();
        return;
      }

      // Progressive Loading 시작
      _isProgressiveLoading = true;
      _loadedItemCount = _initialLoadCount.clamp(0, targetTerms.length);
      _clearError();
      notifyListeners();

      // 백그라운드에서 나머지 데이터 로딩
      _loadRemainingItemsProgressively();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      _setError('데이터 로딩 중 오류가 발생했습니다.', error);
      _isProgressiveLoading = false;
      notifyListeners();
    }
  }

  // 적응형 청크 크기 계산 (성능 최적화)
  int _getAdaptiveChunkSize(int remainingCount) {
    // 데이터셋 크기에 따른 적응형 청크 크기
    if (remainingCount <= 100) {
      return 25; // 작은 데이터셋: 작은 청크
    } else if (remainingCount <= 500) {
      return 50; // 중간 데이터셋: 기본 청크
    } else if (remainingCount <= 1000) {
      return 100; // 큰 데이터셋: 큰 청크
    } else {
      return 150; // 매우 큰 데이터셋: 최대 청크
    }
  }

  // 나머지 아이템들을 점진적으로 로딩
  Future<void> _loadRemainingItemsProgressively() async {
    try {
      int iterationCount = 0;
      const maxIterations = 20; // 무한 루프 방지 (50 -> 20으로 최적화)

      while (_isProgressiveLoading &&
          _loadedItemCount < _filteredTerms.length &&
          iterationCount < maxIterations) {
        iterationCount++;

        // Progressive Loading이 중단된 경우 루프 종료
        if (!_isProgressiveLoading) {
          break;
        }

        final remainingCount = _filteredTerms.length - _loadedItemCount;
        if (remainingCount <= 0) {
          break;
        }

        // 대용량 데이터셋에 대한 청크 크기 최적화
        final adaptiveChunkSize = _getAdaptiveChunkSize(remainingCount);
        final nextChunkSize = remainingCount > adaptiveChunkSize
            ? adaptiveChunkSize
            : remainingCount;

        _loadedItemCount += nextChunkSize;
        _loadedItemCount = _loadedItemCount.clamp(0, _filteredTerms.length);

        // 모든 아이템이 로드되면 Progressive Loading 종료
        if (_loadedItemCount >= _filteredTerms.length) {
          _isProgressiveLoading = false;
          _loadedItemCount = _filteredTerms.length;
          notifyListeners();
          break;
        }

        notifyListeners();

        // 사용자 경험을 위한 짧은 딜레이 (딜레이 감소)
        await Future.delayed(Duration(milliseconds: 16));
      }

      // 최대 반복 횟수에 도달한 경우 강제 종료
      if (iterationCount >= maxIterations) {
        _isProgressiveLoading = false;
        _loadedItemCount = _filteredTerms.length;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      _isProgressiveLoading = false;
      _loadedItemCount = _filteredTerms.length;
      notifyListeners();
    }
  }

  Future<void> _applyFiltersAsync() async {
    // UI 블로킹 방지를 위한 마이크로태스크 사용
    await Future.microtask(() {
      _applyFiltersOptimized();
    });
    notifyListeners();
  }

  void clearFilters() {
    try {
      _searchQuery = '';
      _selectedCategory = null;
      _filteredTerms = _allTerms;
      _clearError();
      notifyListeners();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      _setError('필터 초기화 중 오류가 발생했습니다.', error);
    }
  }

  void _applyFilters() {
    _applyFiltersOptimized();
  }

  void _applyFiltersOptimized() {
    try {
      // 캐시 키 생성
      final cacheKey =
          '${_selectedCategory?.toString() ?? 'null'}_${_searchQuery}';

      // 캐시에서 확인
      final cachedResult = _searchCache.get(cacheKey);
      if (cachedResult != null) {
        _filteredTerms = cachedResult;
        return;
      }

      List<Term> tempTerms = _allTerms;

      // Apply category filter with enhanced caching
      if (_selectedCategory != null) {
        final cachedCategory = _categoryCache.get(_selectedCategory!);
        if (cachedCategory != null) {
          tempTerms = cachedCategory;
        } else {
          // 청크 단위로 처리하여 성능 향상
          if (_selectedCategory == TermCategory.bookmarked) {
            tempTerms = _filterInChunks(_allTerms, (term) => term.isBookmarked);
          } else {
            tempTerms = _filterInChunks(
                _allTerms, (term) => term.category == _selectedCategory);
          }
          _categoryCache.put(_selectedCategory!, tempTerms);
        }
      }

      // Apply search filter with chunked processing
      if (_searchQuery.isNotEmpty) {
        final lowerQuery = _searchQuery.toLowerCase();
        tempTerms = _filterInChunks(tempTerms, (term) {
          return term.term.toLowerCase().contains(lowerQuery) ||
              term.definition.toLowerCase().contains(lowerQuery) ||
              term.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        });
      }

      _filteredTerms = tempTerms;

      // LRU 캐시에 저장
      _searchCache.put(cacheKey, List.from(_filteredTerms));
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      _filteredTerms = [];
    }
  }

  // 청크 단위로 필터링하여 성능 향상
  List<Term> _filterInChunks(List<Term> terms, bool Function(Term) predicate) {
    const int chunkSize = 50;
    List<Term> result = [];

    for (int i = 0; i < terms.length; i += chunkSize) {
      final chunk = terms.skip(i).take(chunkSize);
      result.addAll(chunk.where(predicate));
    }

    return result;
  }

  Future<bool> addTerm(Term term) async {
    try {
      _clearError();

      // Enhanced validation with sanitization
      final termValidation = ValidationUtils.validateTermInput(term.term);
      if (termValidation != null) {
        final error =
            ErrorService.createValidationError('term', termValidation);
        _setError(error.userMessage, error);
        return false;
      }

      final definitionValidation =
          ValidationUtils.validateDefinitionInput(term.definition);
      if (definitionValidation != null) {
        final error = ErrorService.createValidationError(
            'definition', definitionValidation);
        _setError(error.userMessage, error);
        return false;
      }

      // Sanitize input data
      final sanitizedTerm = Term(
        termId: term.termId,
        term: ValidationUtils.sanitizeString(term.term),
        definition: ValidationUtils.sanitizeString(term.definition),
        category: term.category,
        example: ValidationUtils.sanitizeString(term.example),
        tags: ValidationUtils.validateAndSanitizeTags(term.tags),
        userAdded: term.userAdded,
        isBookmarked: term.isBookmarked,
      );

      final success = await DatabaseService.addTerm(sanitizedTerm);
      if (success) {
        _allTerms = DatabaseService.getAllTerms();
        _allTerms = KoreanSortUtils.sortTermsKoreanEnglish(_allTerms);
        _invalidateCache();
        _applyFilters();
        notifyListeners();
        return true;
      } else {
        _setError('용어 추가에 실패했습니다.');
        return false;
      }
    } catch (e, stackTrace) {
      final error =
          ErrorService.createDatabaseError('Adding term', e, stackTrace);
      ErrorService.logError(error);
      _setError(error.userMessage, error);
      return false;
    }
  }

  Future<bool> deleteTerm(String termId) async {
    try {
      _clearError();

      if (termId.trim().isEmpty) {
        final error = ErrorService.createValidationError(
            'termId', 'Term ID cannot be empty');
        _setError(error.userMessage, error);
        return false;
      }

      final success = await DatabaseService.deleteTerm(termId);
      if (success) {
        _allTerms = DatabaseService.getAllTerms();
        _allTerms = KoreanSortUtils.sortTermsKoreanEnglish(_allTerms);
        _invalidateCache();
        _applyFilters();
        notifyListeners();
        return true;
      } else {
        _setError('용어 삭제에 실패했습니다.');
        return false;
      }
    } catch (e, stackTrace) {
      final error =
          ErrorService.createDatabaseError('Deleting term', e, stackTrace);
      ErrorService.logError(error);
      _setError(error.userMessage, error);
      return false;
    }
  }

  Future<bool> toggleBookmark(String termId) async {
    try {
      _clearError();

      if (termId.trim().isEmpty) {
        final error = ErrorService.createValidationError(
            'termId', 'Term ID cannot be empty');
        _setError(error.userMessage, error);
        return false;
      }

      final termIndex = _allTerms.indexWhere((term) => term.termId == termId);
      if (termIndex == -1) {
        _setError('해당 용어를 찾을 수 없습니다.');
        return false;
      }

      _allTerms[termIndex].isBookmarked = !_allTerms[termIndex].isBookmarked;
      final success = await DatabaseService.updateTerm(_allTerms[termIndex]);

      if (success) {
        // 북마크 캐시 즉시 업데이트
        _updateBookmarkCache();
        _applyFilters();
        notifyListeners();
        return true;
      } else {
        // Revert the change if update failed
        _allTerms[termIndex].isBookmarked = !_allTerms[termIndex].isBookmarked;
        _setError('북마크 변경에 실패했습니다.');
        return false;
      }
    } catch (e, stackTrace) {
      final error =
          ErrorService.createDatabaseError('Toggling bookmark', e, stackTrace);
      ErrorService.logError(error);
      _setError(error.userMessage, error);
      return false;
    }
  }

  List<EmailTemplate> getEmailTemplatesByCategory(EmailCategory category) {
    try {
      return _emailTemplates
          .where((template) => template.category == category)
          .toList();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  List<WorkplaceTip> getWorkplaceTipsByCategory(TipCategory category) {
    try {
      return _workplaceTips.where((tip) => tip.category == category).toList();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  List<Term> getTermsByCategory(TermCategory category) {
    try {
      if (category == TermCategory.bookmarked) {
        return _allTerms.where((term) => term.isBookmarked).toList();
      }
      return _allTerms.where((term) => term.category == category).toList();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  // Get popular terms (can be based on search frequency, favorites, etc.)
  List<Term> getPopularTerms({int limit = 5}) {
    try {
      // For now, return the first few terms. In a real app, this could be based on analytics
      return _allTerms.take(limit).toList();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  // Get recent terms (for user-added terms)
  List<Term> getRecentTerms({int limit = 5}) {
    try {
      final userTerms = _allTerms.where((term) => term.userAdded).toList();
      return userTerms.take(limit).toList();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  // Helper methods for error and loading state management
  void _setLoadingState(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message, [AppError? error]) {
    _errorMessage = message;
    _lastError = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _lastError = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Retry mechanism for failed operations
  Future<void> retryLoadData() async {
    await loadData();
  }

  // 모든 카테고리를 미리 캐싱하여 즉시 응답 보장
  Future<void> _preloadAllCategories() async {
    final stopwatch = Stopwatch()..start();

    try {
      // 모든 카테고리에 대해 사전 캐싱
      final categories = TermCategory.values
          .where((cat) => cat != TermCategory.other)
          .toList();

      for (final category in categories) {
        if (category == TermCategory.bookmarked) {
          _categoryCache.put(
              category, _allTerms.where((term) => term.isBookmarked).toList());
        } else {
          _categoryCache.put(category,
              _allTerms.where((term) => term.category == category).toList());
        }
      }

      // 전체 카테고리도 캐싱 (null 키로)
      _searchCache.put('null_', List.from(_allTerms));

      stopwatch.stop();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
    }
  }

  // 북마크 캐시만 업데이트 (다른 캐시는 유지)
  void _updateBookmarkCache() {
    _categoryCache.put(TermCategory.bookmarked,
        _allTerms.where((term) => term.isBookmarked).toList());

    // 북마크 관련 검색 캐시만 제거
    _searchCache.removeWhere((key, value) => key.contains('bookmarked'));
  }

  // 캐시 무효화 메서드
  void _clearCache() {
    _searchCache.clear();
    _categoryCache.clear();
    _changedCategories.clear();
  }

  // 선택적 캐시 무효화 - 특정 카테고리만 또는 전체
  void _invalidateCache({TermCategory? specificCategory}) {
    if (specificCategory != null) {
      _categoryCache.remove(specificCategory);
      _searchCache.removeWhere((key, _) => key.contains(specificCategory.name));
      _changedCategories.add(specificCategory);
    } else {
      // 전체 캐시 무효화
      _clearCache();
    }
  }

  @override
  void dispose() {
    _searchDebouncer?.cancel();
    _searchDebouncer = null;
    _isProgressiveLoading = false; // Progressive Loading 중단
    _clearCache();
    
    // 메모리 정리
    _allTerms.clear();
    _filteredTerms.clear();
    _emailTemplates.clear();
    _workplaceTips.clear();
    _changedCategories.clear();
    
    super.dispose();
  }
  
  /// 메모리 정리 유틸리티
  void clearMemory() {
    if (!_isLoading) {
      _clearCache();
      _changedCategories.clear();
    }
  }
}
