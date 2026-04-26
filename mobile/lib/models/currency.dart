enum Currency {
  brl,
  usd,
  eur;

  String get symbol {
    switch (this) {
      case Currency.brl:
        return 'R\$';
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
    }
  }

  String get code {
    return name.toUpperCase();
  }
}
