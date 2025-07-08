import 'package:flutter/material.dart';
import '../models/term.dart';
import '../models/email_template.dart';
import '../models/workplace_tip.dart';
import '../services/database_service.dart';

class TermProvider extends ChangeNotifier {
  List<Term> _allTerms = [];
  List<Term> _filteredTerms = [];
  List<EmailTemplate> _emailTemplates = [];
  List<WorkplaceTip> _workplaceTips = [];
  
  String _searchQuery = '';
  TermCategory? _selectedCategory;
  bool _isLoading = true;

  // Getters
  List<Term> get allTerms => _allTerms;
  List<Term> get filteredTerms => _filteredTerms;
  List<EmailTemplate> get emailTemplates => _emailTemplates;
  List<WorkplaceTip> get workplaceTips => _workplaceTips;
  String get searchQuery => _searchQuery;
  TermCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  TermProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allTerms = DatabaseService.getAllTerms();
      _emailTemplates = DatabaseService.getAllEmailTemplates();
      _workplaceTips = DatabaseService.getAllWorkplaceTips();
      _filteredTerms = _allTerms;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchTerms(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(TermCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _filteredTerms = _allTerms;
    notifyListeners();
  }

  void _applyFilters() {
    List<Term> tempTerms = _allTerms;

    // Apply category filter
    if (_selectedCategory != null) {
      tempTerms = tempTerms.where((term) => term.category == _selectedCategory).toList();
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
  }

  Future<void> addTerm(Term term) async {
    try {
      await DatabaseService.addTerm(term);
      _allTerms = DatabaseService.getAllTerms();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Error adding term: $e');
    }
  }

  Future<void> deleteTerm(String termId) async {
    try {
      await DatabaseService.deleteTerm(termId);
      _allTerms = DatabaseService.getAllTerms();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Error deleting term: $e');
    }
  }

  List<EmailTemplate> getEmailTemplatesByCategory(EmailCategory category) {
    return _emailTemplates.where((template) => template.category == category).toList();
  }

  List<WorkplaceTip> getWorkplaceTipsByCategory(TipCategory category) {
    return _workplaceTips.where((tip) => tip.category == category).toList();
  }

  List<Term> getTermsByCategory(TermCategory category) {
    return _allTerms.where((term) => term.category == category).toList();
  }

  // Get popular terms (can be based on search frequency, favorites, etc.)
  List<Term> getPopularTerms({int limit = 5}) {
    // For now, return the first few terms. In a real app, this could be based on analytics
    return _allTerms.take(limit).toList();
  }

  // Get recent terms (for user-added terms)
  List<Term> getRecentTerms({int limit = 5}) {
    final userTerms = _allTerms.where((term) => term.userAdded).toList();
    return userTerms.take(limit).toList();
  }
}