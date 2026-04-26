import 'package:intl/intl.dart';
import 'package:afc/models/currency.dart';

class CurrencyFormatter {
  static String format(double value, [Currency currency = Currency.brl]) {
    switch (currency) {
      case Currency.brl:
        return NumberFormat.currency(
          locale: 'pt_BR',
          symbol: r'R$',
          decimalDigits: 2,
        ).format(value);
      case Currency.usd:
        return NumberFormat.currency(
          locale: 'en_US',
          symbol: r'$',
          decimalDigits: 2,
        ).format(value);
      case Currency.eur:
        return NumberFormat.currency(
          locale: 'de_DE',
          symbol: '€',
          decimalDigits: 2,
        ).format(value);
    }
  }

  static String formatCompact(
    double value, [
    Currency currency = Currency.brl,
  ]) {
    final symbol = currency.symbol;
    final locale = currency == Currency.brl
        ? 'pt_BR'
        : currency == Currency.usd
        ? 'en_US'
        : 'de_DE';

    final formatter = NumberFormat.compactCurrency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 1,
    );
    return formatter.format(value);
  }
}
