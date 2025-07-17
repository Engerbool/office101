import 'package:flutter_test/flutter_test.dart';
import 'package:office101_app/services/database_service.dart';
import 'package:office101_app/models/term.dart';

void main() {
  group('DatabaseService Tests', () {
    test('Static methods exist', () {
      // DatabaseService의 정적 메서드들이 존재하는지 확인
      expect(DatabaseService.getAllTerms, isA<Function>());
      expect(DatabaseService.getTermsByCategory, isA<Function>());
      expect(DatabaseService.searchTerms, isA<Function>());
    });

    test('Search functionality type check', () {
      // 검색 기능의 타입 확인
      final results = DatabaseService.searchTerms('test');
      expect(results, isA<List<Term>>());
    });

    test('Category filtering type check', () {
      // 카테고리 필터링의 타입 확인
      final results = DatabaseService.getTermsByCategory(TermCategory.business);
      expect(results, isA<List<Term>>());
    });

    test('All terms type check', () {
      // 전체 용어 조회의 타입 확인
      final results = DatabaseService.getAllTerms();
      expect(results, isA<List<Term>>());
    });

    test('Database service initialization', () {
      // 초기화 상태 확인
      expect(DatabaseService.isInitialized, isA<bool>());
    });
  });
}