import 'package:flutter_test/flutter_test.dart';
import 'package:office101_app/models/term.dart';

void main() {
  group('Term Model Tests', () {
    test('Term creation with all fields', () {
      final term = Term(
        termId: 'test-id',
        term: '테스트 용어',
        definition: '테스트 정의',
        example: '테스트 예시',
        category: TermCategory.business,
        tags: ['태그1', '태그2'],
        isBookmarked: false,
        userAdded: false,
      );

      expect(term.termId, equals('test-id'));
      expect(term.term, equals('테스트 용어'));
      expect(term.definition, equals('테스트 정의'));
      expect(term.example, equals('테스트 예시'));
      expect(term.category, equals(TermCategory.business));
      expect(term.tags, equals(['태그1', '태그2']));
      expect(term.isBookmarked, equals(false));
      expect(term.userAdded, equals(false));
    });

    test('Term JSON serialization and deserialization', () {
      final originalTerm = Term(
        termId: 'json-test',
        term: 'JSON 테스트',
        definition: 'JSON 변환 테스트',
        example: 'JSON 예시',
        category: TermCategory.it,
        tags: ['JSON', '테스트'],
        isBookmarked: true,
        userAdded: true,
      );

      // JSON으로 변환
      final json = originalTerm.toJson();

      // JSON에서 다시 객체로 변환
      final deserializedTerm = Term.fromJson(json);

      // 모든 필드가 일치하는지 확인
      expect(deserializedTerm.termId, equals(originalTerm.termId));
      expect(deserializedTerm.term, equals(originalTerm.term));
      expect(deserializedTerm.definition, equals(originalTerm.definition));
      expect(deserializedTerm.example, equals(originalTerm.example));
      expect(deserializedTerm.category, equals(originalTerm.category));
      expect(deserializedTerm.tags, equals(originalTerm.tags));
      expect(deserializedTerm.isBookmarked, equals(originalTerm.isBookmarked));
      expect(deserializedTerm.userAdded, equals(originalTerm.userAdded));
    });

    test('Term with empty/null fields handling', () {
      final term = Term(
        termId: 'empty-test',
        term: '',
        definition: '',
        example: '',
        category: TermCategory.other,
        tags: [],
        isBookmarked: false,
        userAdded: false,
      );

      expect(term.term, equals(''));
      expect(term.definition, equals(''));
      expect(term.example, equals(''));
      expect(term.tags, isEmpty);
    });

    test('Term bookmark toggle functionality', () {
      final term = Term(
        termId: 'bookmark-test',
        term: '북마크 테스트',
        definition: '북마크 테스트 정의',
        example: '북마크 테스트 예시',
        category: TermCategory.business,
        tags: ['북마크'],
        isBookmarked: false,
        userAdded: false,
      );

      expect(term.isBookmarked, equals(false));

      // 북마크 상태 변경
      term.isBookmarked = true;
      expect(term.isBookmarked, equals(true));

      // 다시 변경
      term.isBookmarked = false;
      expect(term.isBookmarked, equals(false));
    });
  });
}
