import 'package:hive/hive.dart';
import '../utils/validation_utils.dart';

part 'workplace_tip.g.dart';

@HiveType(typeId: 4)
class WorkplaceTip extends HiveObject {
  @HiveField(0)
  String tipId;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  List<String> keyPoints;

  @HiveField(4)
  TipCategory category;

  WorkplaceTip({
    required this.tipId,
    required this.title,
    required this.content,
    required this.keyPoints,
    required this.category,
  });

  factory WorkplaceTip.fromJson(Map<String, dynamic> json) {
    // JSON 검증
    if (!ValidationUtils.validateWorkplaceTipJson(json)) {
      throw ArgumentError('Invalid workplace tip JSON structure');
    }

    return WorkplaceTip(
      tipId: ValidationUtils.sanitizeString(json['tip_id'] ?? ''),
      title: ValidationUtils.sanitizeString(json['title'] ?? ''),
      content: ValidationUtils.sanitizeString(json['content'] ?? ''),
      keyPoints: ValidationUtils.sanitizeStringList(json['key_points'] ?? []),
      category: TipCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TipCategory.general,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tip_id': tipId,
      'title': title,
      'content': content,
      'key_points': keyPoints,
      'category': category.name,
    };
  }
}

@HiveType(typeId: 5)
enum TipCategory {
  @HiveField(0)
  basic_attitude, // 기본 자세

  @HiveField(1)
  reporting, // 보고

  @HiveField(2)
  todo_management, // 할 일 관리

  @HiveField(3)
  communication, // 커뮤니케이션

  @HiveField(4)
  self_growth, // 자기 성장

  @HiveField(5)
  general, // 일반
}

extension TipCategoryExtension on TipCategory {
  String get displayName {
    switch (this) {
      case TipCategory.basic_attitude:
        return '기본 자세';
      case TipCategory.reporting:
        return '보고';
      case TipCategory.todo_management:
        return '할 일 관리';
      case TipCategory.communication:
        return '커뮤니케이션';
      case TipCategory.self_growth:
        return '자기 성장';
      case TipCategory.general:
        return '일반';
    }
  }
}
