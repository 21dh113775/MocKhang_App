// 5. File category_section.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/user/pages/home/productsection/product_grid.dart';
import 'package:mockhang_app/user/pages/home/widget/section_widgets.dart';
import 'dart:math';

class CategoryProductSection extends StatelessWidget {
  final String title;
  final List<Product> products;

  const CategoryProductSection({
    Key? key,
    required this.title,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Random random = Random();

    // Lấy một số sản phẩm ngẫu nhiên cho mỗi danh mục
    List<Product> getRandomProducts() {
      if (products.isEmpty) return [];
      if (products.length <= 4) return List.from(products);

      // Trộn danh sách và lấy một số lượng ngẫu nhiên
      final shuffled = List<Product>.from(products)..shuffle(random);
      final count = random.nextInt(4) + 4; // Lấy 4-7 sản phẩm
      return shuffled.take(min(count, shuffled.length)).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionWidgets.buildSectionHeader(
          title: title,
          viewAllText: 'Xem tất cả',
          onViewAll: () => Navigator.pushNamed(context, '/products_user'),
        ),
        const SizedBox(height: 10),
        ProductGrid(products: getRandomProducts(), maxDisplayCount: 8),
        const SizedBox(height: 24),
      ],
    );
  }
}
