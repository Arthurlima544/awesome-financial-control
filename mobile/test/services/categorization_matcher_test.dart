import 'package:flutter_test/flutter_test.dart';
import 'package:afc/models/category_model.dart';
import 'package:afc/services/categorization_matcher.dart';

void main() {
  late CategorizationMatcher matcher;
  late List<CategoryModel> categories;

  setUp(() {
    matcher = CategorizationMatcher();
    categories = [
      CategoryModel(id: '1', name: 'Alimentação', createdAt: DateTime.now()),
      CategoryModel(id: '2', name: 'Transporte', createdAt: DateTime.now()),
      CategoryModel(id: '3', name: 'Saúde', createdAt: DateTime.now()),
      CategoryModel(id: '4', name: 'Assinaturas', createdAt: DateTime.now()),
      CategoryModel(id: '5', name: 'Moradia', createdAt: DateTime.now()),
      CategoryModel(id: '6', name: 'Educação', createdAt: DateTime.now()),
      CategoryModel(id: '7', name: 'Outros', createdAt: DateTime.now()),
    ];
  });

  group('CategorizationMatcher', () {
    test('should match IFOOD to Alimentação with high confidence', () {
      final result = matcher.match('IFOOD *RESTAURANTE', categories);
      expect(result.categoryId, '1');
      expect(result.confidence, 0.9);
    });

    test('should match UBER to Transporte with high confidence', () {
      final result = matcher.match('UBER TRIP HELP.UBER.COM', categories);
      expect(result.categoryId, '2');
      expect(result.confidence, 0.9);
    });

    test('should match NETFLIX to Assinaturas with high confidence', () {
      final result = matcher.match('NETFLIX.COM', categories);
      expect(result.categoryId, '4');
      expect(result.confidence, 0.9);
    });

    test('should match DROGASIL to Saúde with high confidence', () {
      final result = matcher.match('DROGASIL 015', categories);
      expect(result.categoryId, '3');
      expect(result.confidence, 0.9);
    });

    test('should match faculdade to Educação with high confidence', () {
      final result = matcher.match('FACULDADE MENSALIDADE', categories);
      expect(result.categoryId, '6');
      expect(result.confidence, 0.9);
    });

    test('should match CEMIG to Moradia with high confidence', () {
      final result = matcher.match('CEMIG FATURA', categories);
      expect(result.categoryId, '5');
      expect(result.confidence, 0.9);
    });

    test(
      'should fallback to Outros with low confidence for unknown descriptions',
      () {
        final result = matcher.match('COMPRA DESCONHECIDA 123', categories);
        expect(result.categoryId, '7');
        expect(result.confidence, 0.1);
      },
    );
  });
}
