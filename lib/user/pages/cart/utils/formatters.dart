// utils/formatters.dart
import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final formatter = NumberFormat("#,###", "vi_VN");
  return formatter.format(amount);
}
