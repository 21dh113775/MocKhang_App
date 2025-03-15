// user/pages/home/sections/category_section.dart
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/user/pages/home/section_widgets.dart';
import 'package:mockhang_app/user/widgets/category_item_card.dart';

class CategorySection extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Category> categories;
  final VoidCallback onRefresh;

  const CategorySection({
    Key? key,
    required this.isLoading,
    this.error,
    required this.categories,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SectionWidgets.buildLoadingSection('Danh mục');
    }
    if (error != null) {
      return SectionWidgets.buildErrorSection('Danh mục', error!, onRefresh);
    }
    if (categories.isEmpty) {
      return SectionWidgets.buildEmptySection(
        'Danh mục',
        'Chưa có danh mục nào!',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionWidgets.buildSectionHeader(
          title: 'Danh mục sản phẩm',
          viewAllText: 'Xem tất cả',
          onViewAll: () => Navigator.pushNamed(context, '/categories'),
        ),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.brown.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: CategoryItemCard(category: cat),
              );
            },
          ),
        ),
      ],
    );
  }
}
