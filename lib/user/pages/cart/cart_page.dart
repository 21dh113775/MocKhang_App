import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/user/pages/cart/widget/cart_items_list.dart';
import 'package:mockhang_app/user/pages/cart/widget/cart_summary.dart';
import 'package:mockhang_app/user/pages/cart/widget/empty_cart_widget.dart';
import 'package:mockhang_app/user/pages/cart/widget/select_all_section.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            return const EmptyCartWidget();
          }
          return const Column(
            children: [
              SelectAllSection(),
              Expanded(child: CartItemsList()),
              CartSummary(),
            ],
          );
        },
      ),
    );
  }
}
