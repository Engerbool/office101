import 'package:flutter_test/flutter_test.dart';
import 'package:office101_app/providers/term_provider.dart';

void main() {
  group('TermProvider Tests', () {
    late TermProvider termProvider;

    setUp(() {
      termProvider = TermProvider();
    });

    test('Initial state', () {
      expect(termProvider.searchQuery, isEmpty);
      expect(termProvider.selectedCategory, isNull);
      expect(termProvider.hasError, isFalse);
      expect(termProvider.isProgressiveLoading, isFalse);
    });

    test('Provider is created successfully', () {
      expect(termProvider, isNotNull);
      expect(termProvider.allTerms, isA<List>());
      expect(termProvider.filteredTerms, isA<List>());
    });

    test('Error state management', () {
      expect(termProvider.hasError, isFalse);
      expect(termProvider.errorMessage, isNull);
    });
  });
}