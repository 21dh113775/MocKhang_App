import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'add_product_page.dart';
import 'edit_product_page.dart';
import 'product_detail_page.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          appBar: AppBar(title: Text("Quản lý Sản phẩm")),
          body:
              productProvider.products.isEmpty
                  ? Center(child: Text("Không có sản phẩm nào."))
                  : ListView.builder(
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: ListTile(
                          leading: _buildProductImage(product.imageUrl),
                          title: Text(product.name),
                          subtitle: Text("Giá: ${product.price} VND"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProductDetailPage(product: product),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              EditProductPage(product: product),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  productProvider.deleteProduct(product.id!);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  /// **Hàm kiểm tra ảnh sản phẩm**
  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isNotEmpty && File(imageUrl).existsSync()) {
      return Image.file(
        File(imageUrl),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } else {
      return Icon(Icons.image, size: 50, color: Colors.grey);
    }
  }
}
