import 'package:afc/models/category_model.dart';

class CategorizationResult {
  final String? categoryId;
  final double confidence;

  const CategorizationResult({this.categoryId, required this.confidence});
}

class CategorizationMatcher {
  final Map<String, String> _patterns = {
    // Alimentação / Restaurantes
    'IFOOD': 'Alimentação',
    'RAPPI': 'Alimentação',
    'UBER EATS': 'Alimentação',
    'MCDONALDS': 'Alimentação',
    'BURGER KING': 'Alimentação',
    'RESTAURANTE': 'Alimentação',
    'OUTBACK': 'Alimentação',
    'STARBUCKS': 'Alimentação',
    'PADARIA': 'Alimentação',
    'LANCHONETE': 'Alimentação',

    // Transporte
    'UBER': 'Transporte',
    '99APP': 'Transporte',
    'CABIFY': 'Transporte',
    'POSTO': 'Transporte',
    'SHELL': 'Transporte',
    'IPIRANGA': 'Transporte',
    'PETROBRAS': 'Transporte',
    'METRO': 'Transporte',
    'CPTM': 'Transporte',
    'ESTACIONAMENTO': 'Transporte',

    // Supermercado
    'CARREFOUR': 'Alimentação',
    'PÃO DE AÇÚCAR': 'Alimentação',
    'EXTRA': 'Alimentação',
    'MERCADO': 'Alimentação',
    'SUPERMERCADO': 'Alimentação',
    'HORTIFRUTI': 'Alimentação',
    'ASSAI': 'Alimentação',
    'ATACADÃO': 'Alimentação',

    // Saúde
    'DROGASIL': 'Saúde',
    'DROGARAIA': 'Saúde',
    'FARMACIA': 'Saúde',
    'HOSPITAL': 'Saúde',
    'CLINICA': 'Saúde',
    'UNIMED': 'Saúde',
    'LABORATORIO': 'Saúde',

    // Assinaturas / Lazer
    'NETFLIX': 'Assinaturas',
    'SPOTIFY': 'Assinaturas',
    'AMAZON PRIME': 'Assinaturas',
    'APPLE.COM': 'Assinaturas',
    'GOOGLE': 'Assinaturas',
    'YOUTUBE': 'Assinaturas',
    'DISNEY PLUS': 'Assinaturas',
    'HBO': 'Assinaturas',
    'STEAM': 'Assinaturas',
    'NINTENDO': 'Assinaturas',
    'PLAYSTATION': 'Assinaturas',

    // Educação
    'UDEMY': 'Educação',
    'COURSERA': 'Educação',
    'ESCOLA': 'Educação',
    'FACULDADE': 'Educação',
    'LIVRARIA': 'Educação',

    // Impostos / Outros
    'IPVA': 'Moradia',
    'IPTU': 'Moradia',
    'CEMIG': 'Moradia',
    'COPASA': 'Moradia',
    'CONDOMINIO': 'Moradia',
    'ALUGUEL': 'Moradia',
  };

  CategorizationResult match(
    String description,
    List<CategoryModel> categories,
  ) {
    final upperDesc = description.toUpperCase();

    for (final entry in _patterns.entries) {
      if (upperDesc.contains(entry.key)) {
        final categoryName = entry.value;
        final category = categories.firstWhere(
          (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
          orElse: () => categories.firstWhere(
            (c) => c.name.toLowerCase() == 'outros',
            orElse: () => categories.first,
          ),
        );

        // High confidence if it's a direct keyword match
        return CategorizationResult(categoryId: category.id, confidence: 0.9);
      }
    }

    // Fallback to "Outros" with low confidence
    final othersCategory = categories.firstWhere(
      (c) => c.name.toLowerCase() == 'outros',
      orElse: () => categories.first,
    );

    return CategorizationResult(categoryId: othersCategory.id, confidence: 0.1);
  }
}
