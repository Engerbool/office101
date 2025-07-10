import '../models/term.dart';

class KoreanSortUtils {
  // 한글 초성 매핑
  static const Map<String, String> _choseongMap = {
    'ㄱ': 'ㄱ', 'ㄴ': 'ㄴ', 'ㄷ': 'ㄷ', 'ㄹ': 'ㄹ', 'ㅁ': 'ㅁ', 'ㅂ': 'ㅂ', 'ㅅ': 'ㅅ',
    'ㅇ': 'ㅇ', 'ㅈ': 'ㅈ', 'ㅊ': 'ㅊ', 'ㅋ': 'ㅋ', 'ㅌ': 'ㅌ', 'ㅍ': 'ㅍ', 'ㅎ': 'ㅎ',
    'ㄲ': 'ㄱ', 'ㄸ': 'ㄷ', 'ㅃ': 'ㅂ', 'ㅆ': 'ㅅ', 'ㅉ': 'ㅈ'
  };

  // 인덱스 리스트 (한글 초성 + 영어)
  static const List<String> indexList = [
    'ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  /// 문자열의 첫 번째 문자에서 초성 추출
  static String getInitialSound(String text) {
    if (text.isEmpty) return '#';
    
    final firstChar = text[0];
    final charCode = firstChar.codeUnitAt(0);
    
    // 한글 완성형 문자 범위 (가-힣)
    if (charCode >= 0xAC00 && charCode <= 0xD7A3) {
      // 초성 추출 공식
      final choseongIndex = ((charCode - 0xAC00) / 588).floor();
      final choseongList = ['ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];
      
      if (choseongIndex >= 0 && choseongIndex < choseongList.length) {
        final choseong = choseongList[choseongIndex];
        return _choseongMap[choseong] ?? choseong;
      }
    }
    
    // 영어 대문자 변환
    if (RegExp(r'[a-zA-Z]').hasMatch(firstChar)) {
      return firstChar.toUpperCase();
    }
    
    // 숫자나 기타 문자
    return '#';
  }

  /// 용어 리스트를 한글-영어 순으로 정렬
  static List<Term> sortTermsKoreanEnglish(List<Term> terms) {
    final sortedTerms = List<Term>.from(terms);
    
    sortedTerms.sort((a, b) {
      final aInitial = getInitialSound(a.term);
      final bInitial = getInitialSound(b.term);
      
      // 인덱스 리스트에서의 순서로 비교
      final aIndex = indexList.indexOf(aInitial);
      final bIndex = indexList.indexOf(bInitial);
      
      // 같은 초성이거나 인덱스에 없는 경우 문자열 비교
      if (aIndex == bIndex || aIndex == -1 || bIndex == -1) {
        return a.term.compareTo(b.term);
      }
      
      return aIndex.compareTo(bIndex);
    });
    
    return sortedTerms;
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