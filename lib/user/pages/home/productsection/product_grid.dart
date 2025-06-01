// 4. File product_grid.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/user/pages/product_item_card.dart';
import 'package:mockhang_app/user/pages/home/productsection/product_detail_page_user.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final int maxDisplayCount;

  const ProductGrid({
    Key? key,
    required this.products,
    this.maxDisplayCount = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Giới hạn số lượng sản phẩm hiển thị
    final displayProducts =
        products.length > maxDisplayCount
            ? products.sublist(0, maxDisplayCount)
            : products;

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayProducts.length,
        itemBuilder: (context, index) {
          final product = displayProducts[index];
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ProductItemCard(
                product: product,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
