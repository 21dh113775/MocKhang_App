// user/pages/home/sections/product_section.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/user/pages/home/section_widgets.dart';
import 'package:mockhang_app/user/pages/product_detail_page_user.dart';
import 'package:mockhang_app/user/widgets/product_item_card.dart';

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
  int _selectedFeaturedIndex = 0;

  // Dữ liệu mẫu cho sản phẩm nổi bật
  final List<Map<String, dynamic>> _featuredCategories = [
    {'title': 'Mới nhất', 'key': 'newest'},
    {'title': 'Phổ biến', 'key': 'popular'},
    {'title': 'Bán chạy', 'key': 'bestseller'},
    {'title': 'Giảm giá', 'key': 'discount'},
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
        SectionWidgets.buildSectionHeader(
          title: 'Sản phẩm nổi bật',
          viewAllText: 'Xem tất cả',
          onViewAll: () => Navigator.pushNamed(context, '/products_user'),
        ),
        _buildFeaturedTabBar(),
        const SizedBox(height: 16),
        _buildProductGrid(),
      ],
    );
  }

  Widget _buildFeaturedTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            _featuredCategories.length,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFeaturedIndex = index;
                  // TODO: Load products based on selected category
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      _selectedFeaturedIndex == index
                          ? Colors.brown
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        _selectedFeaturedIndex == index
                            ? Colors.brown
                            : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  _featuredCategories[index]['title'],
                  style: TextStyle(
                    color:
                        _selectedFeaturedIndex == index
                            ? Colors.white
                            : Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: widget.products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final product = widget.products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPageUser(product: product),
              ),
            );
          },
          child: ProductItemCard(product: product),
        );
      },
    );
  }
}
