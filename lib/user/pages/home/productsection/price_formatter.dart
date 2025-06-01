import 'package:intl/intl.dart';

extension PriceFormatter on num {
  String toVND() {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(this)}đ';
  }
}
