import 'package:hive/hive.dart';
import '../utils/validation_utils.dart';

part 'term.g.dart';

@HiveType(typeId: 0)
class Term extends HiveObject {
  @HiveField(0)
  String termId;

  @HiveField(1)
  TermCategory category;

  @HiveField(2)
  String term;

  @HiveField(3)
  String definition;

  @HiveField(4)
  String example;

  @HiveField(5)
  List<String> tags;

  @HiveField(6)
  bool userAdded;

  @HiveField(7)
  bool isBookmarked;

  Term({
    required this.termId,
    required this.category,
    required this.term,
    required this.definition,
    required this.example,
    required this.tags,
    this.userAdded = false,
    this.isBookmarked = false,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    // JSON 검증
    if (!ValidationUtils.validateTermJson(json)) {
      throw ArgumentError('Invalid term JSON structure');
    }
    
    return Term(
      termId: ValidationUtils.sanitizeString(json['term_id'] ?? ''),
      category: TermCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TermCategory.other,
      ),
      term: ValidationUtils.sanitizeString(json['term'] ?? ''),
      definition: ValidationUtils.sanitizeString(json['definition'] ?? ''),
      example: ValidationUtils.sanitizeString(json['example'] ?? ''),
      tags: ValidationUtils.sanitizeStringList(json['tags'] ?? []),
      userAdded: json['user_added'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term_id': termId,
      'category': category.name,
      'term': term,
      'definition': definition,
      'example': example,
      'tags': tags,
      'user_added': userAdded,
      'is_bookmarked': isBookmarked,
    };
  }
}

@HiveType(typeId: 1)
enum TermCategory {
  @HiveField(0)
  approval, // 결재/보고

  @HiveField(1)
  business, // 비즈니스/전략

  @HiveField(2)
  marketing, // 마케팅/세일즈

  @HiveField(3)
  it, // IT/개발

  @HiveField(4)
  hr, // 인사(HR)/조직문화

  @HiveField(5)
  communication, // 커뮤니케이션

  @HiveField(6)
  time, // 시간/일정

  @HiveField(7)
  other, // 기타

  @HiveField(8)
  bookmarked, // 북마크
}

extension TermCategoryExtension on TermCategory {
  String get displayName {
    switch (this) {
      case TermCategory.approval:
        return '결재/보고';
      case TermCategory.business:
        return '비즈니스/전략';
      case TermCategory.marketing:
        return '마케팅/세일즈';
      case TermCategory.it:
        return 'IT/개발';
      case TermCategory.hr:
        return '인사(HR)/조직문화';
      case TermCategory.communication:
        return '커뮤니케이션';
      case TermCategory.time:
        return '시간/일정';
      case TermCategory.other:
        return '기타';
      case TermCategory.bookmarked:
        return '북마크';
    }
  }

  String get iconPath {
    switch (this) {
      case TermCategory.approval:
        return 'assets/images/approval.png';
      case TermCategory.business:
        return 'assets/images/business.png';
      case TermCategory.marketing:
        return 'assets/images/marketing.png';
      case TermCategory.it:
        return 'assets/images/it.png';
      case TermCategory.hr:
        return 'assets/images/hr.png';
      case TermCategory.communication:
        return 'assets/images/communication.png';
      case TermCategory.time:
        return 'assets/images/time.png';
      case TermCategory.other:
        return 'assets/images/other.png';
      case TermCategory.bookmarked:
        return 'assets/images/bookmark.png';
    }
  }
}