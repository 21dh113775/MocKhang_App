import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/user/pages/category-products.dart';

class CategoryItemCard extends StatelessWidget {
  final Category category;

  const CategoryItemCard({Key? key, required this.category}) : super(key: key);

  // Hàm xác định icon dựa trên tên hoặc id của danh mục
  IconData getCategoryIcon(Category category) {
    // Sử dụng tên danh mục để xác định icon
    final name = category.name.toLowerCase();

    if (name.contains('đá')) return Icons.diamond_outlined;
    if (name.contains('tượng')) return Icons.emoji_objects_outlined;
    if (name.contains('vòng')) return Icons.watch;
    if (name.contains('phong thuỷ')) return Icons.filter_vintage;
    if (name.contains('thỉnh')) return Icons.local_offer_outlined;
    if (name.contains('chuông')) return Icons.notifications_active_outlined;
    if (name.contains('tỳ hưu')) return Icons.pets_outlined;
    if (name.contains('phật')) return Icons.self_improvement;
    if (name.contains('thiềm thừ')) return Icons.spa_outlined;
    if (name.contains('charm')) return Icons.star_outline;
    if (name.contains('bùa')) return Icons.security;
    if (name.contains('dây')) return Icons.link;
    if (name.contains('vật phẩm')) return Icons.card_giftcard;

    // Icon mặc định nếu không khớp
    return Icons.category_outlined;
  }

  // Hàm lấy màu gradient dựa trên category
  List<Color> getCategoryGradient(Category category) {
    // Tạo màu gradient ngẫu nhiên nhưng ổn định dựa trên id
    final categoryId = category.id ?? 0;
    final colorSeed = categoryId % 5;

    switch (colorSeed) {
      case 0:
        return [Colors.brown.shade300, Colors.brown.shade500];
      case 1:
        return [Colors.brown.shade300, Colors.brown.shade700];
      case 2:
        return [Colors.brown.shade300, Colors.brown.shade700];
      case 3:
        return [Colors.brown.shade300, Colors.brown.shade500];
      case 4:
        return [Colors.brown.shade300, Colors.brown.shade700];
      default:
        return [Colors.brown.shade300, Colors.brown.shade700];
    }
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon = getCategoryIcon(category);
    final List<Color> gradientColors = getCategoryGradient(category);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsPage(category: category),
          ),
        );
      },
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Đảm bảo chỉ chiếm không gian cần thiết
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[1].withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(child: Icon(icon, color: Colors.white, size: 30)),
            ),
            const SizedBox(height: 4), // Giảm khoảng cách
            Flexible(
              child: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 11, // Giảm kích thước font
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
