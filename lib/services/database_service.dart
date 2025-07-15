import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/term.dart';
import '../models/email_template.dart';
import '../models/workplace_tip.dart';
import '../utils/validation_utils.dart';
import 'error_service.dart';

class DatabaseService {
  static late Box<Term> _termBox;
  static late Box<EmailTemplate> _emailBox;
  static late Box<WorkplaceTip> _tipBox;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    try {
      if (_isInitialized) {
        print('DatabaseService: Already initialized');
        return;
      }

      print('DatabaseService: Starting initialization');
      
      // Adapter 등록
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TermAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TermCategoryAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(EmailTemplateAdapter());
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(EmailCategoryAdapter());
      if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(WorkplaceTipAdapter());
      if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(TipCategoryAdapter());

      // Box 열기
      _termBox = await Hive.openBox<Term>('terms');
      _emailBox = await Hive.openBox<EmailTemplate>('email_templates');
      _tipBox = await Hive.openBox<WorkplaceTip>('workplace_tips');

      print('DatabaseService: Boxes opened, loading initial data');
      await _loadInitialData();
      
      _isInitialized = true;
      print('DatabaseService: Initialization complete, terms count: ${_termBox.length}');
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Database initialization', e, stackTrace);
      ErrorService.logError(error);
      rethrow;
    }
  }

  static Future<void> _loadInitialData() async {
    try {
      if (_termBox.isEmpty) {
        await _loadTermsFromAssets();
      }
      if (_emailBox.isEmpty) {
        await _loadEmailTemplatesFromAssets();
      }
      if (_tipBox.isEmpty) {
        await _loadWorkplaceTipsFromAssets();
      }
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Loading initial data', e, stackTrace);
      ErrorService.logError(error);
      rethrow;
    }
  }

  static Future<void> _loadTermsFromAssets() async {
    try {
      // 카테고리별 파일 목록
      final List<String> categoryFiles = [
        'assets/data/terms/business.json',
        'assets/data/terms/marketing.json',
        'assets/data/terms/it.json',
        'assets/data/terms/hr.json',
        'assets/data/terms/communication.json',
        'assets/data/terms/approval.json',
        'assets/data/terms/time.json',
      ];

      int totalTermsLoaded = 0;

      for (String filePath in categoryFiles) {
        bool fileLoaded = false;
        int retryCount = 0;
        const maxRetries = 3;
        
        while (!fileLoaded && retryCount < maxRetries) {
          try {
            final String jsonString = await rootBundle.loadString(filePath);
            final Map<String, dynamic>? data = ValidationUtils.safeJsonDecode(jsonString);
            
            if (data == null) {
              final error = ErrorService.createDataError('Invalid JSON format in $filePath');
              ErrorService.logError(error);
              break; // JSON 파싱 실패는 재시도 불필요
            }
            
            if (!data.containsKey('terms')) {
              final error = ErrorService.createDataError('Invalid JSON structure in $filePath: missing "terms" key');
              ErrorService.logError(error);
              break; // 구조적 문제는 재시도 불필요
            }
            
            final List<dynamic> termsList = data['terms'];
            
            if (termsList.isEmpty) {
              final error = ErrorService.createDataError('No terms found in $filePath');
              ErrorService.logError(error);
              break; // 빈 데이터는 재시도 불필요
            }

            int fileTermsLoaded = 0;
            for (var termData in termsList) {
              try {
                final term = Term.fromJson(termData);
                await _termBox.put(term.termId, term);
                fileTermsLoaded++;
              } catch (e, stackTrace) {
                final error = ErrorService.createDataError('Error parsing term data in $filePath: $termData', e, stackTrace);
                ErrorService.logError(error);
                continue; // 개별 항목 파싱 실패 시 계속 진행
              }
            }
            
            totalTermsLoaded += fileTermsLoaded;
            print('Successfully loaded $fileTermsLoaded terms from $filePath');
            fileLoaded = true;
          } catch (e, stackTrace) {
            retryCount++;
            final error = ErrorService.createDataError('Error loading file $filePath (attempt $retryCount/$maxRetries)', e, stackTrace);
            ErrorService.logError(error);
            
            if (retryCount < maxRetries) {
              // 재시도 전 잠시 대기
              await Future.delayed(Duration(milliseconds: 500 * retryCount));
            } else {
              // 최종 실패 시 에러 로깅
              final finalError = ErrorService.createDataError('Failed to load $filePath after $maxRetries attempts', e, stackTrace);
              ErrorService.logError(finalError);
            }
          }
        }
      }
      
      print('Successfully loaded total $totalTermsLoaded terms from ${categoryFiles.length} category files');
      
      // 최소한의 데이터도 로드되지 않았을 경우 기본 데이터 제공
      if (totalTermsLoaded == 0) {
        await _loadFallbackTerms();
      }
    } catch (e, stackTrace) {
      final error = ErrorService.createFileSystemError('Loading terms from assets', e, stackTrace);
      ErrorService.logError(error);
      
      // 전체 로딩 실패 시 기본 데이터 제공
      await _loadFallbackTerms();
    }
  }
  
  static Future<void> _loadFallbackTerms() async {
    try {
      // 기본 필수 용어들 제공
      final fallbackTerms = [
        Term(
          termId: 'fallback_1',
          term: '회사',
          definition: '사업을 목적으로 설립된 조직',
          category: TermCategory.business,
          example: '우리 회사는 IT 서비스를 제공합니다.',
          tags: ['기본', '회사'],
          userAdded: false,
        ),
        Term(
          termId: 'fallback_2',
          term: '부서',
          definition: '회사 내에서 특정 업무를 담당하는 조직 단위',
          category: TermCategory.business,
          example: '마케팅 부서에서 근무하고 있습니다.',
          tags: ['기본', '조직'],
          userAdded: false,
        ),
      ];
      
      for (final term in fallbackTerms) {
        await _termBox.put(term.termId, term);
      }
      
      print('Loaded ${fallbackTerms.length} fallback terms');
    } catch (e, stackTrace) {
      final error = ErrorService.createDataError('Loading fallback terms', e, stackTrace);
      ErrorService.logError(error);
    }
  }

  static Future<void> _loadEmailTemplatesFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/email_templates.json');
      final Map<String, dynamic>? data = ValidationUtils.safeJsonDecode(jsonString);
      
      if (data == null) {
        final error = ErrorService.createDataError('Invalid JSON format in email_templates.json');
        ErrorService.logError(error);
        return;
      }
      
      if (!data.containsKey('templates')) {
        throw Exception('Invalid JSON structure: missing "templates" key');
      }
      
      final List<dynamic> templatesList = data['templates'];
      
      if (templatesList.isEmpty) {
        print('Warning: No email templates found in assets');
        return;
      }

      for (var templateData in templatesList) {
        try {
          final template = EmailTemplate.fromJson(templateData);
          await _emailBox.put(template.templateId, template);
        } catch (e) {
          print('Error parsing email template data: $templateData, error: $e');
          continue;
        }
      }
      
      print('Successfully loaded ${_emailBox.length} email templates');
    } catch (e, stackTrace) {
      final error = ErrorService.createFileSystemError('Loading email templates from assets', e, stackTrace);
      ErrorService.logError(error);
      rethrow;
    }
  }

  static Future<void> _loadWorkplaceTipsFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/workplace_tips.json');
      final Map<String, dynamic>? data = ValidationUtils.safeJsonDecode(jsonString);
      
      if (data == null) {
        final error = ErrorService.createDataError('Invalid JSON format in workplace_tips.json');
        ErrorService.logError(error);
        return;
      }
      
      if (!data.containsKey('tips')) {
        throw Exception('Invalid JSON structure: missing "tips" key');
      }
      
      final List<dynamic> tipsList = data['tips'];
      
      if (tipsList.isEmpty) {
        print('Warning: No workplace tips found in assets');
        return;
      }

      for (var tipData in tipsList) {
        try {
          final tip = WorkplaceTip.fromJson(tipData);
          await _tipBox.put(tip.tipId, tip);
        } catch (e) {
          print('Error parsing workplace tip data: $tipData, error: $e');
          continue;
        }
      }
      
      print('Successfully loaded ${_tipBox.length} workplace tips');
    } catch (e, stackTrace) {
      final error = ErrorService.createFileSystemError('Loading workplace tips from assets', e, stackTrace);
      ErrorService.logError(error);
      rethrow;
    }
  }

  // Term operations
  static List<Term> getAllTerms() {
    try {
      _ensureInitialized();
      final terms = _termBox.values.toList();
      print('DatabaseService: getAllTerms called, returning ${terms.length} terms');
      return terms;
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Getting all terms', e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  static List<Term> getTermsByCategory(TermCategory category) {
    try {
      _ensureInitialized();
      return _termBox.values.where((term) => term.category == category).toList();
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Getting terms by category', e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  static List<Term> searchTerms(String query) {
    try {
      _ensureInitialized();
      
      if (query.trim().isEmpty) {
        return getAllTerms();
      }
      
      final lowerQuery = query.toLowerCase().trim();
      return _termBox.values.where((term) {
        return term.term.toLowerCase().contains(lowerQuery) ||
               term.definition.toLowerCase().contains(lowerQuery) ||
               term.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Searching terms', e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  static Future<bool> addTerm(Term term) async {
    try {
      _ensureInitialized();
      
      if (term.termId.trim().isEmpty) {
        throw Exception('Term ID cannot be empty');
      }
      
      await _termBox.put(term.termId, term);
      return true;
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Adding term', e, stackTrace);
      ErrorService.logError(error);
      return false;
    }
  }

  static Future<bool> deleteTerm(String termId) async {
    try {
      _ensureInitialized();
      
      if (termId.trim().isEmpty) {
        throw Exception('Term ID cannot be empty');
      }
      
      if (!_termBox.containsKey(termId)) {
        throw Exception('Term with ID "$termId" not found');
      }
      
      await _termBox.delete(termId);
      return true;
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Deleting term', e, stackTrace);
      ErrorService.logError(error);
      return false;
    }
  }

  static Future<bool> updateTerm(Term term) async {
    try {
      _ensureInitialized();
      
      if (term.termId.trim().isEmpty) {
        throw Exception('Term ID cannot be empty');
      }
      
      if (!_termBox.containsKey(term.termId)) {
        throw Exception('Term with ID "${term.termId}" not found');
      }
      
      await _termBox.put(term.termId, term);
      return true;
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Updating term', e, stackTrace);
      ErrorService.logError(error);
      return false;
    }
  }

  // Email template operations
  static List<EmailTemplate> getAllEmailTemplates() {
    try {
      _ensureInitialized();
      return _emailBox.values.toList();
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Getting all email templates', e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  static List<EmailTemplate> getEmailTemplatesByCategory(EmailCategory category) {
    try {
      _ensureInitialized();
      return _emailBox.values.where((template) => template.category == category).toList();
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Getting email templates by category', e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  // Workplace tip operations
  static List<WorkplaceTip> getAllWorkplaceTips() {
    try {
      _ensureInitialized();
      return _tipBox.values.toList();
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Getting all workplace tips', e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  static List<WorkplaceTip> getWorkplaceTipsByCategory(TipCategory category) {
    try {
      _ensureInitialized();
      return _tipBox.values.where((tip) => tip.category == category).toList();
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Getting workplace tips by category', e, stackTrace);
      ErrorService.logError(error);
      return [];
    }
  }

  static Future<void> close() async {
    try {
      if (_isInitialized) {
        await _termBox.close();
        await _emailBox.close();
        await _tipBox.close();
        _isInitialized = false;
      }
    } catch (e, stackTrace) {
      final error = ErrorService.createDatabaseError('Closing database', e, stackTrace);
      ErrorService.logError(error);
    }
  }
  
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized. Call initialize() first.');
    }
  }
  
  static bool get isInitialized => _isInitialized;
}