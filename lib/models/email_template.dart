import 'package:hive/hive.dart';

part 'email_template.g.dart';

@HiveType(typeId: 2)
class EmailTemplate extends HiveObject {
  @HiveField(0)
  String templateId;

  @HiveField(1)
  String title;

  @HiveField(2)
  String situation;

  @HiveField(3)
  String subject;

  @HiveField(4)
  String body;

  @HiveField(5)
  List<String> tips;

  @HiveField(6)
  EmailCategory category;

  EmailTemplate({
    required this.templateId,
    required this.title,
    required this.situation,
    required this.subject,
    required this.body,
    required this.tips,
    required this.category,
  });

  factory EmailTemplate.fromJson(Map<String, dynamic> json) {
    return EmailTemplate(
      templateId: json['template_id'],
      title: json['title'],
      situation: json['situation'],
      subject: json['subject'],
      body: json['body'],
      tips: List<String>.from(json['tips'] ?? []),
      category: EmailCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EmailCategory.general,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      'title': title,
      'situation': situation,
      'subject': subject,
      'body': body,
      'tips': tips,
      'category': category.name,
    };
  }
}

@HiveType(typeId: 3)
enum EmailCategory {
  @HiveField(0)
  request, // 요청

  @HiveField(1)
  report, // 보고

  @HiveField(2)
  meeting, // 회의

  @HiveField(3)
  apology, // 사과

  @HiveField(4)
  general, // 일반
}

extension EmailCategoryExtension on EmailCategory {
  String get displayName {
    switch (this) {
      case EmailCategory.request:
        return '요청';
      case EmailCategory.report:
        return '보고';
      case EmailCategory.meeting:
        return '회의';
      case EmailCategory.apology:
        return '사과';
      case EmailCategory.general:
        return '일반';
    }
  }
}