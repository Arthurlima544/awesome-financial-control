import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat currencyPtBR = NumberFormat.simpleCurrency(
    locale: 'pt_BR',
  );
  static final NumberFormat percent = NumberFormat.percentPattern('pt_BR');
  static final NumberFormat decimal = NumberFormat.decimalPattern('pt_BR');

  static final DateFormat monthYear = DateFormat('MM/yyyy');
  static final DateFormat dayMonthYear = DateFormat('dd/MM/yyyy');
  static final DateFormat fullMonthYear = DateFormat('MMMM / yyyy', 'pt_BR');
  static final DateFormat monthYearFull = DateFormat('MMMM yyyy', 'pt_BR');
  static final DateFormat dayMonthYearShort = DateFormat.yMd('pt_BR');
}
