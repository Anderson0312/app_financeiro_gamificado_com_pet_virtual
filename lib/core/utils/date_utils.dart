import 'package:intl/intl.dart';

/// Utilitários para formatação de datas.
class AppDateUtils {
  AppDateUtils._();

  static String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM/yyyy', 'pt_BR').format(date);
  }
}
