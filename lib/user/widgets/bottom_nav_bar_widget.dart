import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';

class BottomNavBarWidget extends StatelessWidget {
  // Constant values
  static const List<String> _labels = [
    'Trang Chủ',
    'Khuyến mãi',
    'Liên hệ',
    'Giỏ hàng',
    'Tài Khoản',
  ];

  static const Color _activeColor = Colors.white;
  static const Color _inactiveColor = Colors.brown;
  static const Color _shadowColor = Colors.brown;

  // Configuration parameters
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final bool showLabels;

  const BottomNavBarWidget({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
    this.showLabels = true,
  }) : super(key: key);

  // Icons configuration
  List<Icon> get _activeIcons => [
    Icon(Icons.home, color: _activeColor),
    Icon(Icons.discount_sharp, color: _activeColor),
    Icon(Icons.phone_callback, color: _activeColor),
    Icon(Icons.shopping_cart, color: _activeColor),
    Icon(Icons.person, color: _activeColor),
  ];

  List<Icon> get _inactiveIcons => [
    Icon(Icons.home_outlined, color: _inactiveColor),
    Icon(Icons.discount_outlined, color: _inactiveColor),
    Icon(Icons.phone_callback_outlined, color: _inactiveColor),
    Icon(Icons.shopping_cart_outlined, color: _inactiveColor),
    Icon(Icons.person_outline, color: _inactiveColor),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_buildCircleNavBar(), if (showLabels) _buildLabels(context)],
    );
  }

  Widget _buildCircleNavBar() {
    return CircleNavBar(
      activeIcons: _activeIcons,
      inactiveIcons: _inactiveIcons,
      color: Colors.white,
      height: 60,
      circleWidth: 60,
      activeIndex: currentIndex,
      onTap: onItemSelected,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      cornerRadius: _buildCornerRadius(),
      shadowColor: _shadowColor.withOpacity(0.3),
      elevation: 10,
      circleShadowColor: _shadowColor.withOpacity(0.3),
      circleColor: _shadowColor,
    );
  }

  BorderRadius _buildCornerRadius() {
    return const BorderRadius.only(
      topLeft: Radius.circular(8),
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(24),
      bottomLeft: Radius.circular(24),
    );
  }

  Widget _buildLabels(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_labels.length, (index) {
          return _buildLabelItem(index, context);
        }),
      ),
    );
  }

  Widget _buildLabelItem(int index, BuildContext context) {
    final isActive = currentIndex == index;
    return Text(
      _labels[index],
      style: TextStyle(
        fontSize: 10,
        color: isActive ? _inactiveColor : Colors.grey,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
