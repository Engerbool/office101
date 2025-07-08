import 'package:hive/hive.dart';

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

  @HiveField(5)
  int priority;

  WorkplaceTip({
    required this.tipId,
    required this.title,
    required this.content,
    required this.keyPoints,
    required this.category,
    this.priority = 0,
  });

  factory WorkplaceTip.fromJson(Map<String, dynamic> json) {
    return WorkplaceTip(
      tipId: json['tip_id'],
      title: json['title'],
      content: json['content'],
      keyPoints: List<String>.from(json['key_points'] ?? []),
      category: TipCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TipCategory.general,
      ),
      priority: json['priority'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tip_id': tipId,
      'title': title,
      'content': content,
      'key_points': keyPoints,
      'category': category.name,
      'priority': priority,
    };
  }
}

@HiveType(typeId: 5)
enum TipCategory {
  @HiveField(0)
  schedule, // 일정관리

  @HiveField(1)
  report, // 보고스킬

  @HiveField(2)
  meeting, // 회의참석

  @HiveField(3)
  communication, // 커뮤니케이션

  @HiveField(4)
  general, // 일반
}

extension TipCategoryExtension on TipCategory {
  String get displayName {
    switch (this) {
      case TipCategory.schedule:
        return '일정관리';
      case TipCategory.report:
        return '보고스킬';
      case TipCategory.meeting:
        return '회의참석';
      case TipCategory.communication:
        return '커뮤니케이션';
      case TipCategory.general:
        return '일반';
    }
  }
}