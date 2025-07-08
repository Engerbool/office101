import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/term.dart';
import '../models/email_template.dart';
import '../models/workplace_tip.dart';

class DatabaseService {
  static late Box<Term> _termBox;
  static late Box<EmailTemplate> _emailBox;
  static late Box<WorkplaceTip> _tipBox;

  static Future<void> initialize() async {
    print('DatabaseService: Starting initialization');
    Hive.registerAdapter(TermAdapter());
    Hive.registerAdapter(TermCategoryAdapter());
    Hive.registerAdapter(EmailTemplateAdapter());
    Hive.registerAdapter(EmailCategoryAdapter());
    Hive.registerAdapter(WorkplaceTipAdapter());
    Hive.registerAdapter(TipCategoryAdapter());

    _termBox = await Hive.openBox<Term>('terms');
    _emailBox = await Hive.openBox<EmailTemplate>('email_templates');
    _tipBox = await Hive.openBox<WorkplaceTip>('workplace_tips');

    print('DatabaseService: Boxes opened, loading initial data');
    await _loadInitialData();
    print('DatabaseService: Initialization complete, terms count: ${_termBox.length}');
  }

  static Future<void> _loadInitialData() async {
    if (_termBox.isEmpty) {
      await _loadTermsFromAssets();
    }
    if (_emailBox.isEmpty) {
      await _loadEmailTemplatesFromAssets();
    }
    if (_tipBox.isEmpty) {
      await _loadWorkplaceTipsFromAssets();
    }
  }

  static Future<void> _loadTermsFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/terms.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> termsList = data['terms'];

      for (var termData in termsList) {
        final term = Term.fromJson(termData);
        await _termBox.put(term.termId, term);
      }
    } catch (e) {
      print('Error loading terms: $e');
    }
  }

  static Future<void> _loadEmailTemplatesFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/email_templates.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> templatesList = data['templates'];

      for (var templateData in templatesList) {
        final template = EmailTemplate.fromJson(templateData);
        await _emailBox.put(template.templateId, template);
      }
    } catch (e) {
      print('Error loading email templates: $e');
    }
  }

  static Future<void> _loadWorkplaceTipsFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/workplace_tips.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> tipsList = data['tips'];

      for (var tipData in tipsList) {
        final tip = WorkplaceTip.fromJson(tipData);
        await _tipBox.put(tip.tipId, tip);
      }
    } catch (e) {
      print('Error loading workplace tips: $e');
    }
  }

  // Term operations
  static List<Term> getAllTerms() {
    final terms = _termBox.values.toList();
    print('DatabaseService: getAllTerms called, returning ${terms.length} terms');
    return terms;
  }

  static List<Term> getTermsByCategory(TermCategory category) {
    return _termBox.values.where((term) => term.category == category).toList();
  }

  static List<Term> searchTerms(String query) {
    final lowerQuery = query.toLowerCase();
    return _termBox.values.where((term) {
      return term.term.toLowerCase().contains(lowerQuery) ||
             term.definition.toLowerCase().contains(lowerQuery) ||
             term.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  static Future<void> addTerm(Term term) async {
    await _termBox.put(term.termId, term);
  }

  static Future<void> deleteTerm(String termId) async {
    await _termBox.delete(termId);
  }

  static Future<void> updateTerm(Term term) async {
    await _termBox.put(term.termId, term);
  }

  // Email template operations
  static List<EmailTemplate> getAllEmailTemplates() {
    return _emailBox.values.toList();
  }

  static List<EmailTemplate> getEmailTemplatesByCategory(EmailCategory category) {
    return _emailBox.values.where((template) => template.category == category).toList();
  }

  // Workplace tip operations
  static List<WorkplaceTip> getAllWorkplaceTips() {
    return _tipBox.values.toList();
  }

  static List<WorkplaceTip> getWorkplaceTipsByCategory(TipCategory category) {
    return _tipBox.values.where((tip) => tip.category == category).toList();
  }

  static Future<void> close() async {
    await _termBox.close();
    await _emailBox.close();
    await _tipBox.close();
  }
}