import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afc/services/cache_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late CacheService cacheService;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    cacheService = CacheService(mockPrefs);
  });

  group('CacheService', () {
    const testKey = 'test_key';
    final testData = {'foo': 'bar', 'count': 42};
    final testJson = jsonEncode(testData);

    test('save stores data as json string', () async {
      when(
        () => mockPrefs.setString(testKey, testJson),
      ).thenAnswer((_) async => true);

      await cacheService.save(testKey, testData);

      verify(() => mockPrefs.setString(testKey, testJson)).called(1);
    });

    test('load returns decoded map when data exists', () {
      when(() => mockPrefs.getString(testKey)).thenReturn(testJson);

      final result = cacheService.load(testKey);

      expect(result, testData);
    });

    test('load returns null when no data exists', () {
      when(() => mockPrefs.getString(testKey)).thenReturn(null);

      final result = cacheService.load(testKey);

      expect(result, isNull);
    });

    test('load returns null when json is corrupted', () {
      when(() => mockPrefs.getString(testKey)).thenReturn('invalid json');

      final result = cacheService.load(testKey);

      expect(result, isNull);
    });

    test('clear removes the key', () async {
      when(() => mockPrefs.remove(testKey)).thenAnswer((_) async => true);

      await cacheService.clear(testKey);

      verify(() => mockPrefs.remove(testKey)).called(1);
    });
  });
}
