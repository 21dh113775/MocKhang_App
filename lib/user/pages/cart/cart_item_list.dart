// cart_item_list.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/cart/cart_item_tile.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';

class CartItemList extends StatelessWidget {
  final VoidCallback onSelectionChanged;

  const CartItemList({Key? key, required this.onSelectionChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Expanded(
      child: ListView.builder(
        itemCount: cartProvider.items.length,
        itemBuilder: (context, index) {
          return CartItemTile(
            item: cartProvider.items[index],
            onSelectionChanged: onSelectionChanged,
          );
        },
      ),
    );
  }
}
