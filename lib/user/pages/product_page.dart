import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:mockhang_app/user/widgets/product_item_card.dart';
import 'package:provider/provider.dart';

class ProductPageUser extends StatefulWidget {
  const ProductPageUser({Key? key}) : super(key: key);

  @override
  _ProductPageUserState createState() => _ProductPageUserState();
}

class _ProductPageUserState extends State<ProductPageUser> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      await productProvider.fetchProducts();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text('Lỗi khi tải sản phẩm: $_errorMessage'))
              : products.isEmpty
              ? const Center(child: Text('Không có sản phẩm!'))
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductItemCard(product: product);
                },
              ),
    );
  }
}
