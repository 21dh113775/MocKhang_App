import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart'
    show CartProvider;
import 'package:mockhang_app/user/pages/cart/widget/cart_item_tile.dart';
import 'package:mockhang_app/user/pages/cart/widget/compact_cart_item_tile.dart';
import 'package:provider/provider.dart';

class CartItemsList extends StatelessWidget {
  const CartItemsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: cartProvider.items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final cartItem = cartProvider.items[index];
                return _buildResponsiveCartItemTile(
                  context,
                  cartItem,
                  cartProvider,
                  constraints.maxWidth,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildResponsiveCartItemTile(
    BuildContext context,
    CartItem cartItem,
    CartProvider cartProvider,
    double availableWidth,
  ) {
    bool isNarrow = availableWidth < 360;

    return isNarrow
        ? CompactCartItemTile(cartItem: cartItem, cartProvider: cartProvider)
        : CartItemTile(cartItem: cartItem, cartProvider: cartProvider);
  }
}
