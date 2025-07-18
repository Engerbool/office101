import '../models/term.dart';

class KoreanSortUtils {
  // 초성 추출 캐시
  static final Map<String, String> _initialSoundCache = {};
  static final Map<String, String> _sortKeyCache = {};

  // 캐시 크기 제한
  static const int _maxCacheSize = 1000;
  // 한글 초성 매핑
  static const Map<String, String> _choseongMap = {
    'ㄱ': 'ㄱ',
    'ㄴ': 'ㄴ',
    'ㄷ': 'ㄷ',
    'ㄹ': 'ㄹ',
    'ㅁ': 'ㅁ',
    'ㅂ': 'ㅂ',
    'ㅅ': 'ㅅ',
    'ㅇ': 'ㅇ',
    'ㅈ': 'ㅈ',
    'ㅊ': 'ㅊ',
    'ㅋ': 'ㅋ',
    'ㅌ': 'ㅌ',
    'ㅍ': 'ㅍ',
    'ㅎ': 'ㅎ',
    'ㄲ': 'ㄱ',
    'ㄸ': 'ㄷ',
    'ㅃ': 'ㅂ',
    'ㅆ': 'ㅅ',
    'ㅉ': 'ㅈ'
  };

  // 인덱스 리스트 (한글 초성 + 영어)
  static const List<String> indexList = [
    'ㄱ',
    'ㄴ',
    'ㄷ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅅ',
    'ㅇ',
    'ㅈ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];

  /// 문자열의 첫 번째 문자에서 초성 추출 (캐싱 적용)
  static String getInitialSound(String text) {
    if (text.isEmpty) return '#';

    // 캐시에서 확인
    if (_initialSoundCache.containsKey(text)) {
      return _initialSoundCache[text]!;
    }

    final firstChar = text[0];
    final charCode = firstChar.codeUnitAt(0);

    String result = '#';

    // 한글 완성형 문자 범위 (가-힣)
    if (charCode >= 0xAC00 && charCode <= 0xD7A3) {
      // 초성 추출 공식
      final choseongIndex = ((charCode - 0xAC00) / 588).floor();
      final choseongList = [
        'ㄱ',
        'ㄲ',
        'ㄴ',
        'ㄷ',
        'ㄸ',
        'ㄹ',
        'ㅁ',
        'ㅂ',
        'ㅃ',
        'ㅅ',
        'ㅆ',
        'ㅇ',
        'ㅈ',
        'ㅉ',
        'ㅊ',
        'ㅋ',
        'ㅌ',
        'ㅍ',
        'ㅎ'
      ];

      if (choseongIndex >= 0 && choseongIndex < choseongList.length) {
        final choseong = choseongList[choseongIndex];
        result = _choseongMap[choseong] ?? choseong;
      }
    }
    // 영어 대문자 변환
    else if (RegExp(r'[a-zA-Z]').hasMatch(firstChar)) {
      result = firstChar.toUpperCase();
    }

    // 캐시에 저장 (크기 제한 적용)
    if (_initialSoundCache.length < _maxCacheSize) {
      _initialSoundCache[text] = result;
    }

    return result;
  }

  /// 용어 리스트를 한글-영어 순으로 정렬 (캐싱 적용)
  static List<Term> sortTermsKoreanEnglish(List<Term> terms) {
    final sortedTerms = List<Term>.from(terms);

    // 정렬 키 미리 계산하여 캐싱
    final sortKeys = <Term, String>{};
    for (final term in sortedTerms) {
      if (_sortKeyCache.containsKey(term.term)) {
        sortKeys[term] = _sortKeyCache[term.term]!;
      } else {
        final sortKey = _computeSortKey(term.term);
        sortKeys[term] = sortKey;

        // 캐시에 저장
        if (_sortKeyCache.length < _maxCacheSize) {
          _sortKeyCache[term.term] = sortKey;
        }
      }
    }

    sortedTerms.sort((a, b) {
      final aKey = sortKeys[a]!;
      final bKey = sortKeys[b]!;
      return aKey.compareTo(bKey);
    });

    return sortedTerms;
  }

  /// 정렬 키 계산
  static String _computeSortKey(String term) {
    final initial = getInitialSound(term);
    final indexInList = indexList.indexOf(initial);

    // 인덱스를 3자리 패딩 + 원본 문자열로 정렬 키 생성
    final paddedIndex = indexInList.toString().padLeft(3, '0');
    return '${paddedIndex}_${term}';
  }

  /// 용어 목록에 대한 초성 미리 계산 (성능 최적화)
  static void precomputeInitialSounds(List<Term> terms) {
    for (final term in terms) {
      getInitialSound(term.term);
    }
  }

  /// 캐시 정리
  static void clearCache() {
    _initialSoundCache.clear();
    _sortKeyCache.clear();
  }

  /// 캐시 사용률 정보
  static Map<String, dynamic> getCacheInfo() {
    return {
      'initialSoundCache': _initialSoundCache.length,
      'sortKeyCache': _sortKeyCache.length,
      'maxCacheSize': _maxCacheSize,
      'usage': ((_initialSoundCache.length + _sortKeyCache.length) /
              (_maxCacheSize * 2) *
              100)
          .toStringAsFixed(1),
    };
  }

  /// 인덱스별로 용어 그룹핑
  static Map<String, List<Term>> groupTermsByIndex(List<Term> terms) {
    final Map<String, List<Term>> groupedTerms = {};

    for (final term in terms) {
      final initial = getInitialSound(term.term);
      if (!groupedTerms.containsKey(initial)) {
        groupedTerms[initial] = [];
      }
      groupedTerms[initial]!.add(term);
    }

    return groupedTerms;
  }

  /// 특정 인덱스의 용어들 가져오기
  static List<Term> getTermsByIndex(List<Term> terms, String index) {
    return terms.where((term) => getInitialSound(term.term) == index).toList();
  }
}
