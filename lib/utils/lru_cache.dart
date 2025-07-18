import 'dart:collection';

/// LRU (Least Recently Used) 캐시 구현
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  LRUCache({required this.maxSize});

  V? get(K key) {
    if (!_cache.containsKey(key)) {
      return null;
    }

    // 접근한 항목을 맨 뒤로 이동 (가장 최근 사용)
    final value = _cache.remove(key)!;
    _cache[key] = value;
    return value;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      // 이미 존재하는 키는 제거하고 다시 추가 (맨 뒤로 이동)
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // 캐시가 가득 찼으면 가장 오래된 항목 제거
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = value;
  }

  void remove(K key) {
    _cache.remove(key);
  }

  void removeWhere(bool Function(K key, V value) test) {
    _cache.removeWhere(test);
  }

  void clear() {
    _cache.clear();
  }

  bool containsKey(K key) {
    return _cache.containsKey(key);
  }

  int get length => _cache.length;

  bool get isEmpty => _cache.isEmpty;

  bool get isNotEmpty => _cache.isNotEmpty;

  /// 캐시 사용률 반환 (0.0 ~ 1.0)
  double get usage => _cache.length / maxSize;
  
  /// 메모리 압박 시 캐시 크기 줄이기
  void shrink([int? newSize]) {
    final targetSize = newSize ?? (maxSize * 0.7).floor(); // 기본값: 70%로 축소
    
    while (_cache.length > targetSize) {
      _cache.remove(_cache.keys.first);
    }
  }
  
  /// 캐시 통계 정보
  Map<String, dynamic> get stats => {
    'size': _cache.length,
    'maxSize': maxSize,
    'usage': usage,
    'keys': _cache.keys.take(5).toList(), // 최근 5개 키만 표시
  };
}
