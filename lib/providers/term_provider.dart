import 'package:flutter/material.dart';
import '../models/term.dart';
import '../models/email_template.dart';
import '../models/workplace_tip.dart';
import '../services/database_service.dart';
import '../services/error_service.dart';

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

  TermProvider() {
    loadData();
  }

  Future<void> loadData() async {
    print('TermProvider: Starting to load data');
    _setLoadingState(true);
    _clearError();

    try {
      if (!DatabaseService.isInitialized) {
        await DatabaseService.initialize();
      }
      
      _allTerms = DatabaseService.getAllTerms();
      _emailTemplates = DatabaseService.getAllEmailTemplates();
      _workplaceTips = DatabaseService.getAllWorkplaceTips();
      _filteredTerms = _allTerms;
      
      if (_allTerms.isEmpty) {
        _setError('데이터를 불러올 수 없습니다. 앱을 다시 시작해보세요.');
      }
      
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Loading provider data', e, stackTrace);
      ErrorService.logError(error);
      _setError(error.userMessage, error);
    } finally {
      _setLoadingState(false);
    }
  }

  void searchTerms(String query) {
    try {
      _searchQuery = query.trim();
      _applyFilters();
      _clearError();
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
      _applyFilters();
      _clearError();
      notifyListeners();
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      _setError('필터링 중 오류가 발생했습니다.', error);
    }
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
    try {
      List<Term> tempTerms = List.from(_allTerms);

      // Apply category filter
      if (_selectedCategory != null) {
        if (_selectedCategory == TermCategory.bookmarked) {
          tempTerms = tempTerms.where((term) => term.isBookmarked).toList();
        } else {
          tempTerms = tempTerms.where((term) => term.category == _selectedCategory).toList();
        }
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final lowerQuery = _searchQuery.toLowerCase();
        tempTerms = tempTerms.where((term) {
          return term.term.toLowerCase().contains(lowerQuery) ||
                 term.definition.toLowerCase().contains(lowerQuery) ||
                 term.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        }).toList();
      }

      _filteredTerms = tempTerms;
    } catch (e, stackTrace) {
      final error = ErrorService.createUnknownError(e, stackTrace);
      ErrorService.logError(error);
      _filteredTerms = [];
    }
  }

  Future<bool> addTerm(Term term) async {
    try {
      _clearError();
      
      // Validation
      if (term.term.trim().isEmpty) {
        final error = ErrorService.createValidationError('term', 'Term cannot be empty');
        _setError(error.userMessage, error);
        return false;
      }
      
      if (term.definition.trim().isEmpty) {
        final error = ErrorService.createValidationError('definition', 'Definition cannot be empty');
        _setError(error.userMessage, error);
        return false;
      }
      
      final success = await DatabaseService.addTerm(term);
      if (success) {
        _allTerms = DatabaseService.getAllTerms();
        _applyFilters();
        notifyListeners();
        return true;
      } else {
        _setError('용어 추가에 실패했습니다.');
        return false;
      }
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Adding term', e, stackTrace);
      ErrorService.logError(error);
      _setError(error.userMessage, error);
      return false;
    }
  }

  Future<bool> deleteTerm(String termId) async {
    try {
      _clearError();
      
      if (termId.trim().isEmpty) {
        final error = ErrorService.createValidationError('termId', 'Term ID cannot be empty');
        _setError(error.userMessage, error);
        return false;
      }
      
      final success = await DatabaseService.deleteTerm(termId);
      if (success) {
        _allTerms = DatabaseService.getAllTerms();
        _applyFilters();
        notifyListeners();
        return true;
      } else {
        _setError('용어 삭제에 실패했습니다.');
        return false;
      }
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Deleting term', e, stackTrace);
      ErrorService.logError(error);
      _setError(error.userMessage, error);
      return false;
    }
  }

  Future<bool> toggleBookmark(String termId) async {
    try {
      _clearError();
      
      if (termId.trim().isEmpty) {
        final error = ErrorService.createValidationError('termId', 'Term ID cannot be empty');
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
      final error = ErrorService.createDatabaseError('Toggling bookmark', e, stackTrace);
      ErrorService.logError(error);
      _setError(error.userMessage, error);
      return false;
    }
  }

  List<EmailTemplate> getEmailTemplatesByCategory(EmailCategory category) {
    try {
      return _emailTemplates.where((template) => template.category == category).toList();
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
}