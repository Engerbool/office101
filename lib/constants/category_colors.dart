import 'package:flutter/material.dart';
import '../models/term.dart';
import '../models/workplace_tip.dart';
import '../models/email_template.dart';

class CategoryColors {
  static const Color _approval = Color(0xFF5A8DEE);
  static const Color _business = Color(0xFF42A5F5);
  static const Color _marketing = Color(0xFF66BB6A);
  static const Color _it = Color(0xFFFF7043);
  static const Color _hr = Color(0xFFAB47BC);
  static const Color _communication = Color(0xFFFFCA28);
  static const Color _time = Color(0xFFEF5350);
  static const Color _other = Color(0xFF78909C);
  static const Color _bookmarked = Color(0xFFFFCA28);

  /// 카테고리별 색상을 반환합니다.
  static Color getCategoryColor(TermCategory category) {
    switch (category) {
      case TermCategory.approval:
        return _approval;
      case TermCategory.business:
        return _business;
      case TermCategory.marketing:
        return _marketing;
      case TermCategory.it:
        return _it;
      case TermCategory.hr:
        return _hr;
      case TermCategory.communication:
        return _communication;
      case TermCategory.time:
        return _time;
      case TermCategory.other:
        return _other;
      case TermCategory.bookmarked:
        return _bookmarked;
    }
  }

  /// 카테고리별 연한 배경색을 반환합니다 (투명도 0.1).
  static Color getCategoryBackgroundColor(TermCategory category) {
    return getCategoryColor(category).withAlpha(26); // 0.1 * 255 ≈ 26
  }

  /// TipCategory별 색상을 반환합니다.
  static Color getTipCategoryColor(TipCategory category) {
    switch (category) {
      case TipCategory.basic_attitude:
        return _approval; // 0xFF5A8DEE
      case TipCategory.reporting:
        return _business; // 0xFF42A5F5
      case TipCategory.todo_management:
        return _marketing; // 0xFF66BB6A
      case TipCategory.communication:
        return _it; // 0xFFFF7043
      case TipCategory.self_growth:
        return _hr; // 0xFFAB47BC
      case TipCategory.general:
        return _other; // 0xFF78909C
    }
  }

  /// TipCategory별 연한 배경색을 반환합니다 (투명도 0.1).
  static Color getTipCategoryBackgroundColor(TipCategory category) {
    return getTipCategoryColor(category).withAlpha(26); // 0.1 * 255 ≈ 26
  }

  /// EmailCategory별 색상을 반환합니다.
  static Color getEmailCategoryColor(EmailCategory category) {
    switch (category) {
      case EmailCategory.request:
        return _approval; // 0xFF5A8DEE
      case EmailCategory.report:
        return _business; // 0xFF42A5F5
      case EmailCategory.meeting:
        return _marketing; // 0xFF66BB6A
      case EmailCategory.apology:
        return _it; // 0xFFFF7043
      case EmailCategory.general:
        return _other; // 0xFF78909C
    }
  }

  /// EmailCategory별 연한 배경색을 반환합니다 (투명도 0.1).
  static Color getEmailCategoryBackgroundColor(EmailCategory category) {
    return getEmailCategoryColor(category).withAlpha(26); // 0.1 * 255 ≈ 26
  }
}