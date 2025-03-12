import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final bool showLabels; // Thêm tham số mới

  const BottomNavBarWidget({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
    this.showLabels = true, // Mặc định là hiển thị nhãn
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Danh sách nhãn cho các tab
    final labels = [
      'Trang Chủ',
      'Khuyến mãi',
      'Liên hệ',
      'Giỏ hàng',
      'Tài Khoản',
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleNavBar(
          // Các thuộc tính chính của CircleNavBar
          activeIcons: [
            Icon(Icons.home, color: Colors.white),
            Icon(Icons.discount_sharp, color: Colors.white),
            Icon(Icons.phone_callback, color: Colors.white),
            Icon(Icons.shopping_cart, color: Colors.white),
            Icon(Icons.person, color: Colors.white),
          ],
          inactiveIcons: [
            Icon(Icons.home_outlined, color: Colors.brown),
            Icon(Icons.discount_outlined, color: Colors.brown),
            Icon(Icons.phone_callback_outlined, color: Colors.brown),
            Icon(Icons.shopping_cart_outlined, color: Colors.brown),
            Icon(Icons.person_outline, color: Colors.brown),
          ],
          color: Colors.white,
          height: 60,
          circleWidth: 60,
          activeIndex: currentIndex,
          onTap: (index) {
            // Gọi callback để cập nhật index
            onItemSelected(index);
          },
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          cornerRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          shadowColor: Colors.brown.withOpacity(0.3),
          elevation: 10,
          circleShadowColor: Colors.brown.withOpacity(0.3),
          circleColor: Colors.brown,
        ),
        // Chỉ hiển thị nhãn nếu showLabels = true
        if (showLabels)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                return Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 10,
                    color: currentIndex == index ? Colors.brown : Colors.grey,
                    fontWeight:
                        currentIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
