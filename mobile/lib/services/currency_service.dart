import 'package:dio/dio.dart';
import 'package:afc/models/currency.dart';
import 'package:afc/services/cache_service.dart';

class CurrencyService {
  final Dio _dio;
  final CacheService _cacheService;
  static const _cacheKey = 'exchange_rates';
  static const _cacheDuration = Duration(hours: 24);

  Map<String, double> _rates = {'USD': 0.20, 'EUR': 0.18, 'BRL': 1.0};

  CurrencyService({Dio? dio, required CacheService cacheService})
    : _dio = dio ?? Dio(),
      _cacheService = cacheService;

  Future<void> init() async {
    final cached = _cacheService.load(_cacheKey);
    if (cached != null) {
      final timestamp = cached['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp < _cacheDuration.inMilliseconds) {
        _rates = Map<String, double>.from(cached['rates']);
        return;
      }
    }
    await fetchRates();
  }

  Future<void> fetchRates() async {
    try {
      final response = await _dio.get(
        'https://api.exchangerate-api.com/v4/latest/BRL',
      );
      final data = response.data as Map<String, dynamic>;
      final rates = Map<String, num>.from(data['rates']);

      _rates = rates.map((key, value) => MapEntry(key, value.toDouble()));

      await _cacheService.save(_cacheKey, {
        'rates': _rates,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Keep using default/cached rates on failure
    }
  }

  double convert(double amount, Currency target) {
    if (target == Currency.brl) return amount;
    final rate = _rates[target.code] ?? 1.0;
    return amount * rate;
  }

  double getRate(Currency target) {
    return _rates[target.code] ?? 1.0;
  }
}
