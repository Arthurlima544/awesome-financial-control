import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _brlFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static String format(double value) {
    return _brlFormat.format(value);
  }
}
