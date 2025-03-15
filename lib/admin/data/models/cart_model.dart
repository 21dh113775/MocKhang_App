import 'package:mockhang_app/admin/data/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  bool isSelected;

  CartItem({
    required this.product,
    required this.quantity,
    this.isSelected = true,
  });
}
