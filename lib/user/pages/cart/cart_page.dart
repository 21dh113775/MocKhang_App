// cart_page.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/cart/cart_app_bar.dart';
import 'package:mockhang_app/user/pages/cart/cart_footer.dart';
import 'package:mockhang_app/user/pages/cart/cart_header.dart';
import 'package:mockhang_app/user/pages/cart/cart_item_list.dart';
import 'package:mockhang_app/user/pages/cart/empty_cart.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _selectAll = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectAllState();
    });
  }

  void _updateSelectAllState() {
    if (!mounted) return; // Check if the widget is still mounted
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    setState(() {
      _selectAll =
          cartProvider.items.isNotEmpty &&
          cartProvider.items.every((item) => item.isSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CartAppBar(),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            return EmptyCart();
          }

          return Column(
            children: [
              CartHeader(
                selectAll: _selectAll,
                onSelectAllChanged: (value) {
                  setState(() {
                    _selectAll = value ?? false;
                    cartProvider.selectAll(_selectAll);
                  });
                },
              ),
              CartItemList(onSelectionChanged: _updateSelectAllState),
              CartFooter(),
            ],
          );
        },
      ),
    );
  }
}
