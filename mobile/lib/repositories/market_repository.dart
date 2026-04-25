import 'package:dio/dio.dart';
import 'package:afc/utils/config/app_config.dart';

class MarketOpportunity {
  final String ticker;
  final String name;
  final double price;
  final double changePercent;
  final double dividendYield;
  final bool isFii;
  final double? priceEarnings;
  final String? sector;
  final double dyVsCdi;
  final DateTime lastUpdated;

  MarketOpportunity({
    required this.ticker,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.dividendYield,
    required this.isFii,
    this.priceEarnings,
    this.sector,
    required this.dyVsCdi,
    required this.lastUpdated,
  });

  factory MarketOpportunity.fromJson(Map<String, dynamic> json) {
    return MarketOpportunity(
      ticker: json['ticker'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      dividendYield: (json['dividendYield'] as num).toDouble(),
      isFii: json['isFii'],
      priceEarnings: json['priceEarnings'] != null
          ? (json['priceEarnings'] as num).toDouble()
          : null,
      sector: json['sector'],
      dyVsCdi: (json['dyVsCdi'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class MarketBenchmarks {
  final double cdiRate;
  final double selicRate;

  MarketBenchmarks({required this.cdiRate, required this.selicRate});

  factory MarketBenchmarks.fromJson(Map<String, dynamic> json) {
    return MarketBenchmarks(
      cdiRate: (json['cdiRate'] as num).toDouble(),
      selicRate: (json['selicRate'] as num).toDouble(),
    );
  }
}

class MarketRepository {
  final Dio _dio;

  MarketRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<MarketOpportunity>> getOpportunities() async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/api/v1/market/opportunities',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MarketOpportunity.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to fetch opportunities: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch opportunities: $e');
    }
  }

  Future<MarketBenchmarks> getBenchmarks() async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/api/v1/market/benchmarks',
      );
      if (response.statusCode == 200) {
        return MarketBenchmarks.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch benchmarks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch benchmarks: $e');
    }
  }
}
