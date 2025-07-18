import 'package:flutter_test/flutter_test.dart';
import 'package:office101_app/utils/korean_sort_utils.dart';
import 'package:office101_app/models/term.dart';

void main() {
  group('Korean Sort Utils Tests', () {
    test('getInitialSound - Korean consonants extraction', () {
      // 기본 한글 자음 추출 테스트
      expect(KoreanSortUtils.getInitialSound('가나다'), equals('ㄱ'));
      expect(KoreanSortUtils.getInitialSound('나무'), equals('ㄴ'));
      expect(KoreanSortUtils.getInitialSound('다람쥐'), equals('ㄷ'));
      expect(KoreanSortUtils.getInitialSound('라면'), equals('ㄹ'));
      expect(KoreanSortUtils.getInitialSound('마음'), equals('ㅁ'));
      expect(KoreanSortUtils.getInitialSound('바다'), equals('ㅂ'));
      expect(KoreanSortUtils.getInitialSound('사과'), equals('ㅅ'));
      expect(KoreanSortUtils.getInitialSound('아이'), equals('ㅇ'));
      expect(KoreanSortUtils.getInitialSound('자동차'), equals('ㅈ'));
      expect(KoreanSortUtils.getInitialSound('차례'), equals('ㅊ'));
      expect(KoreanSortUtils.getInitialSound('카메라'), equals('ㅋ'));
      expect(KoreanSortUtils.getInitialSound('타임'), equals('ㅌ'));
      expect(KoreanSortUtils.getInitialSound('파일'), equals('ㅍ'));
      expect(KoreanSortUtils.getInitialSound('하늘'), equals('ㅎ'));
    });

    test('getInitialSound - Complex consonants', () {
      // 복합 자음 테스트 (ㄲ은 ㄱ으로 매핑됨)
      expect(KoreanSortUtils.getInitialSound('까치'), equals('ㄱ'));
      expect(KoreanSortUtils.getInitialSound('따뜻함'), equals('ㄷ'));
      expect(KoreanSortUtils.getInitialSound('빠른'), equals('ㅂ'));
      expect(KoreanSortUtils.getInitialSound('싸움'), equals('ㅅ'));
      expect(KoreanSortUtils.getInitialSound('짜증'), equals('ㅈ'));
    });

    test('getInitialSound - English characters', () {
      // 영어 문자 테스트
      expect(KoreanSortUtils.getInitialSound('Apple'), equals('A'));
      expect(KoreanSortUtils.getInitialSound('application'), equals('A'));
      expect(KoreanSortUtils.getInitialSound('Business'), equals('B'));
      expect(KoreanSortUtils.getInitialSound('computer'), equals('C'));
      expect(KoreanSortUtils.getInitialSound('Database'), equals('D'));
      expect(KoreanSortUtils.getInitialSound('email'), equals('E'));
    });

    test('getInitialSound - Numbers and special characters', () {
      // 숫자와 특수문자 테스트
      expect(KoreanSortUtils.getInitialSound('123'), equals('#'));
      expect(KoreanSortUtils.getInitialSound('!@#'), equals('#'));
      expect(KoreanSortUtils.getInitialSound(''), equals('#'));
      expect(KoreanSortUtils.getInitialSound('   '), equals('#'));
    });

    test('getInitialSound - Mixed text', () {
      // 혼합 텍스트 테스트 (첫 글자 기준)
      expect(KoreanSortUtils.getInitialSound('가Apple'), equals('ㄱ'));
      expect(KoreanSortUtils.getInitialSound('Apple가'), equals('A'));
      expect(KoreanSortUtils.getInitialSound('123가'), equals('#'));
      expect(KoreanSortUtils.getInitialSound(' 가나다'), equals('#')); // 공백으로 시작
    });

    test('sortTermsKoreanEnglish - Basic Korean sorting', () {
      final unsortedTerms = [
        Term(
          termId: '1',
          term: '하늘',
          definition: '정의1',
          example: '예시1',
          category: TermCategory.business,
          tags: [],
          isBookmarked: false,
          userAdded: false,
        ),
        Term(
          termId: '2',
          term: '가족',
          definition: '정의2',
          example: '예시2',
          category: TermCategory.business,
          tags: [],
          isBookmarked: false,
          userAdded: false,
        ),
        Term(
          termId: '3',
          term: '나무',
          definition: '정의3',
          example: '예시3',
          category: TermCategory.business,
          tags: [],
          isBookmarked: false,
          userAdded: false,
        ),
      ];

      final sortedTerms = KoreanSortUtils.sortTermsKoreanEnglish(unsortedTerms);

      expect(sortedTerms[0].term, equals('가족'));
      expect(sortedTerms[1].term, equals('나무'));
      expect(sortedTerms[2].term, equals('하늘'));
    });

    test('indexList contains expected values', () {
      expect(KoreanSortUtils.indexList.contains('ㄱ'), isTrue);
      expect(KoreanSortUtils.indexList.contains('ㅎ'), isTrue);
      expect(KoreanSortUtils.indexList.contains('A'), isTrue);
      expect(KoreanSortUtils.indexList.contains('Z'), isTrue);
      expect(KoreanSortUtils.indexList.length, equals(40)); // 14 한글 + 26 영어
    });

    test('sortTermsKoreanEnglish returns a list', () {
      final emptyTerms = <Term>[];
      final result = KoreanSortUtils.sortTermsKoreanEnglish(emptyTerms);
      expect(result, isA<List<Term>>());
      expect(result, isEmpty);
    });
  });
}
