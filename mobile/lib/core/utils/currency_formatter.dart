import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
    locale: 'en_US',
  );

  static final _compactFormatter = NumberFormat.compactCurrency(
    symbol: '\$',
    locale: 'en_US',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(double amount) {
    return _compactFormatter.format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    return _formatter.format(amount).replaceAll('\$', '').trim();
  }

  static double parse(String amount) {
    try {
      return _formatter.parse(amount).toDouble();
    } catch (e) {
      return 0.0;
    }
  }
}
