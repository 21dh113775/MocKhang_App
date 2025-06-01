// 2. File featured_products_section.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/user/pages/home/productsection/featured_tab_bar.dart';
import 'package:mockhang_app/user/pages/home/productsection/product_grid.dart';
import 'package:mockhang_app/user/pages/home/widget/section_widgets.dart';
import 'dart:math';

class FeaturedProductsSection extends StatefulWidget {
  final List<Product> products;

  const FeaturedProductsSection({Key? key, required this.products})
    : super(key: key);

  @override
  State<FeaturedProductsSection> createState() =>
      _FeaturedProductsSectionState();
}

class _FeaturedProductsSectionState extends State<FeaturedProductsSection> {
  int _selectedFeaturedIndex = 0;
  final Random _random = Random();

  // Dữ liệu mẫu cho sản phẩm nổi bật
  final List<Map<String, dynamic>> _featuredCategories = [
    {'title': 'Mới nhất', 'key': 'newest'},
    {'title': 'Phổ biến', 'key': 'popular'},
    {'title': 'Bán chạy', 'key': 'bestseller'},
    {'title': 'Giảm giá', 'key': 'discount'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionWidgets.buildSectionHeader(
          title: 'Sản phẩm nổi bật',
          viewAllText: 'Xem tất cả',
          onViewAll: () => Navigator.pushNamed(context, '/products_user'),
        ),
        FeaturedTabBar(
          categories: _featuredCategories,
          selectedIndex: _selectedFeaturedIndex,
          onCategorySelected: (index) {
            setState(() {
              _selectedFeaturedIndex = index;
            });
          },
        ),
        const SizedBox(height: 16),
        ProductGrid(products: _getFilteredProducts()),
      ],
    );
  }

  List<Product> _getFilteredProducts() {
    final key = _featuredCategories[_selectedFeaturedIndex]['key'];
    final allProducts = List<Product>.from(widget.products);

    switch (key) {
      case 'newest':
        return allProducts;
      case 'popular':
        allProducts.shuffle(_random);
        return allProducts;
      case 'bestseller':
        allProducts.shuffle(_random);
        return allProducts.take((allProducts.length * 0.7).round()).toList();
      case 'discount':
        allProducts.shuffle(_random);
        return allProducts.take((allProducts.length * 0.5).round()).toList();
      default:
        return allProducts;
    }
  }
}
