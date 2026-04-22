import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:afc/utils/config/app_config.dart';

class ReceiptExtractionResult {
  final double? amount;
  final String? merchant;

  ReceiptExtractionResult({this.amount, this.merchant});

  @override
  String toString() =>
      'ReceiptExtractionResult(amount: $amount, merchant: $merchant)';
}

class ReceiptService {
  final String _apiKey;

  ReceiptService({String? apiKey}) : _apiKey = apiKey ?? AppConfig.geminiApiKey;

  Future<ReceiptExtractionResult> extractFromImage(File imageFile) async {
    developer.log(
      'ReceiptService: Starting extraction from image: ${imageFile.path}',
    );

    if (_apiKey.isEmpty) {
      developer.log(
        'ReceiptService: Error - GEMINI_API_KEY is not set',
        level: 1000,
      );
      throw Exception('GEMINI_API_KEY is not set');
    }

    final modelsToTry = [
      AppConfig.geminiModel,
      'gemini-2.5-flash',
      'gemini-1.5-flash', // Last resort
    ];

    for (final modelName in modelsToTry) {
      try {
        developer.log(
          'ReceiptService: Attempting extraction with model: $modelName',
        );
        final model = GenerativeModel(model: modelName, apiKey: _apiKey);

        final imageBytes = await imageFile.readAsBytes();
        final prompt = TextPart(
          'Analyze this receipt and extract the total amount and the merchant name. '
          'Return ONLY a JSON object with keys "amount" (number) and "merchant" (string). '
          'Example: {"amount": 42.50, "merchant": "Starbucks"}. '
          'If you cannot find a value, use null.',
        );

        final content = [
          Content.multi([prompt, DataPart('image/jpeg', imageBytes)]),
        ];

        final response = await model.generateContent(content);
        final text = response.text;
        developer.log(
          'ReceiptService: Raw response from Gemini ($modelName): $text',
        );

        if (text == null || text.isEmpty) {
          developer.log('ReceiptService: Empty response from model $modelName');
          continue; // Try next model
        }

        final jsonString = _extractJson(text);
        developer.log(
          'ReceiptService: Extracted JSON string ($modelName): $jsonString',
        );

        if (jsonString == null) {
          developer.log(
            'ReceiptService: No JSON found in response from $modelName',
          );
          continue; // Try next model
        }

        final Map<String, dynamic> data = json.decode(jsonString);

        final amount = data['amount'];
        final merchant = data['merchant'];

        final result = ReceiptExtractionResult(
          amount: amount is num ? amount.toDouble() : null,
          merchant: merchant is String ? merchant : null,
        );

        developer.log(
          'ReceiptService: Final extracted result with $modelName: $result',
        );
        return result;
      } catch (e, stack) {
        developer.log(
          'ReceiptService: Exception with model $modelName',
          error: e,
          stackTrace: stack,
          level: 1000,
        );

        // If it's the last model, don't just continue, return empty result
        if (modelName == modelsToTry.last) {
          return ReceiptExtractionResult();
        }

        developer.log('ReceiptService: Trying fallback model...');
      }
    }

    return ReceiptExtractionResult();
  }

  String? _extractJson(String text) {
    final match = RegExp(r'\{.*\}', dotAll: true).stringMatch(text);
    return match;
  }
}
