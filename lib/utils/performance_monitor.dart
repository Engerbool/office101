import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 성능 모니터링 유틸리티
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _measurements = {};
  static final Map<String, int> _counters = {};
  static bool _isEnabled = kDebugMode;
  
  /// 성능 모니터링 활성화/비활성화
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  /// 측정 시작
  static void startMeasurement(String name) {
    if (!_isEnabled) return;
    
    _startTimes[name] = DateTime.now();
    developer.Timeline.startSync(name);
  }
  
  /// 측정 종료
  static void endMeasurement(String name) {
    if (!_isEnabled) return;
    
    final endTime = DateTime.now();
    final startTime = _startTimes[name];
    
    if (startTime != null) {
      final duration = endTime.difference(startTime);
      
      // 측정값 저장
      _measurements.putIfAbsent(name, () => []).add(duration);
      
      // 최대 100개까지만 저장 (메모리 절약)
      if (_measurements[name]!.length > 100) {
        _measurements[name]!.removeAt(0);
      }
      
      _startTimes.remove(name);
      developer.Timeline.finishSync();
      
      // 긴 시간이 걸리는 작업 로깅
      if (duration.inMilliseconds > 100) {
        developer.log(
          'Performance Warning: $name took ${duration.inMilliseconds}ms',
          name: 'PerformanceMonitor',
          level: 900,
        );
      }
    }
  }
  
  /// 카운터 증가
  static void incrementCounter(String name) {
    if (!_isEnabled) return;
    
    _counters[name] = (_counters[name] ?? 0) + 1;
  }
  
  /// 메모리 사용량 측정
  static Map<String, dynamic> getMemoryUsage() {
    if (!_isEnabled) return {};
    
    try {
      final info = ProcessInfo.currentRss;
      final maxRss = ProcessInfo.maxRss;
      
      return {
        'currentRss': info,
        'maxRss': maxRss,
        'currentRssMB': (info / 1024 / 1024).toStringAsFixed(2),
        'maxRssMB': (maxRss / 1024 / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      return {'error': 'Memory info not available on this platform'};
    }
  }
  
  /// 성능 통계 조회
  static Map<String, dynamic> getPerformanceStats() {
    if (!_isEnabled) return {};
    
    final stats = <String, dynamic>{};
    
    // 측정값 통계
    _measurements.forEach((name, durations) {
      if (durations.isNotEmpty) {
        final total = durations.fold(Duration.zero, (sum, d) => sum + d);
        final average = Duration(microseconds: total.inMicroseconds ~/ durations.length);
        final min = durations.reduce((a, b) => a < b ? a : b);
        final max = durations.reduce((a, b) => a > b ? a : b);
        
        stats[name] = {
          'count': durations.length,
          'total': '${total.inMilliseconds}ms',
          'average': '${average.inMilliseconds}ms',
          'min': '${min.inMilliseconds}ms',
          'max': '${max.inMilliseconds}ms',
        };
      }
    });
    
    // 카운터 통계
    if (_counters.isNotEmpty) {
      stats['counters'] = Map.from(_counters);
    }
    
    // 메모리 사용량
    stats['memory'] = getMemoryUsage();
    
    return stats;
  }
  
  /// 성능 리포트 생성
  static String generateReport() {
    if (!_isEnabled) return 'Performance monitoring is disabled';
    
    final stats = getPerformanceStats();
    final buffer = StringBuffer();
    
    buffer.writeln('=== Performance Report ===');
    buffer.writeln('Generated at: ${DateTime.now()}');
    buffer.writeln();
    
    // 측정값 리포트
    buffer.writeln('Measurements:');
    stats.forEach((key, value) {
      if (key != 'counters' && key != 'memory') {
        buffer.writeln('  $key:');
        if (value is Map) {
          value.forEach((statKey, statValue) {
            buffer.writeln('    $statKey: $statValue');
          });
        }
        buffer.writeln();
      }
    });
    
    // 카운터 리포트
    if (stats.containsKey('counters')) {
      buffer.writeln('Counters:');
      final counters = stats['counters'] as Map;
      counters.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
      buffer.writeln();
    }
    
    // 메모리 리포트
    if (stats.containsKey('memory')) {
      buffer.writeln('Memory Usage:');
      final memory = stats['memory'] as Map;
      memory.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    
    return buffer.toString();
  }
  
  /// 성능 데이터 초기화
  static void clearAll() {
    _startTimes.clear();
    _measurements.clear();
    _counters.clear();
  }
  
  /// 특정 측정값 초기화
  static void clearMeasurement(String name) {
    _measurements.remove(name);
    _counters.remove(name);
  }
}

/// 성능 측정 데코레이터
class PerformanceMeasurement {
  final String name;
  
  PerformanceMeasurement(this.name);
  
  /// 함수 실행 시간 측정
  static Future<T> measureAsync<T>(String name, Future<T> Function() function) async {
    PerformanceMonitor.startMeasurement(name);
    try {
      return await function();
    } finally {
      PerformanceMonitor.endMeasurement(name);
    }
  }
  
  /// 동기 함수 실행 시간 측정
  static T measureSync<T>(String name, T Function() function) {
    PerformanceMonitor.startMeasurement(name);
    try {
      return function();
    } finally {
      PerformanceMonitor.endMeasurement(name);
    }
  }
}

/// 성능 측정 위젯
class PerformanceTracker extends StatefulWidget {
  final Widget child;
  final String name;
  
  const PerformanceTracker({
    Key? key,
    required this.child,
    required this.name,
  }) : super(key: key);

  @override
  State<PerformanceTracker> createState() => _PerformanceTrackerState();
}

class _PerformanceTrackerState extends State<PerformanceTracker> {
  @override
  void initState() {
    super.initState();
    PerformanceMonitor.startMeasurement('widget_${widget.name}_build');
  }

  @override
  void dispose() {
    PerformanceMonitor.endMeasurement('widget_${widget.name}_build');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}