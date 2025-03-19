import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/user/pages/home/productsection/category_section_product.dart';
import 'package:mockhang_app/user/pages/home/productsection/featured_products_section.dart';
import 'package:mockhang_app/user/pages/home/section_widgets.dart';
import 'package:mockhang_app/user/pages/home/category_section.dart';

class ProductSection extends StatefulWidget {
  final bool isLoading;
  final String? error;
  final List<Product> products;
  final VoidCallback onRefresh;

  const ProductSection({
    Key? key,
    required this.isLoading,
    this.error,
    required this.products,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  // Danh mục cho các phần
  final List<String> _categoryTitles = [
    'Sản phẩm mới',
    'Sản phẩm đề xuất',
    'Sản phẩm bán chạy',
    'Sản phẩm giảm giá',
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return SectionWidgets.buildLoadingSection('Sản phẩm nổi bật');
    }
    if (widget.error != null) {
      return SectionWidgets.buildErrorSection(
        'Sản phẩm nổi bật',
        widget.error!,
        widget.onRefresh,
      );
    }
    if (widget.products.isEmpty) {
      return SectionWidgets.buildEmptySection(
        'Sản phẩm nổi bật',
        'Chưa có sản phẩm nào!',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phần 1: Sản phẩm nổi bật với tab bar
        FeaturedProductsSection(products: widget.products),

        const SizedBox(height: 24),

        // Phần 2: Các dòng sản phẩm riêng biệt
        _buildCategoryProductSections(),
      ],
    );
  }

  Widget _buildCategoryProductSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        _categoryTitles.length,
        (index) => CategoryProductSection(
          title: _categoryTitles[index],
          products: widget.products,
        ),
      ),
    );
  }
}
