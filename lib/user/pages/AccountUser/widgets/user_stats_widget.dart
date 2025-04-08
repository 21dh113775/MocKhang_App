import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class UserStatsWidget extends StatelessWidget {
  final int completedOrderCount;
  final int favoriteCount;
  final double rewardPoints;

  const UserStatsWidget({
    Key? key,
    required this.completedOrderCount,
    required this.favoriteCount,
    required this.rewardPoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _buildStatItem(
            context: context,
            icon: Icons.shopping_bag,
            title: 'Đơn hàng',
            value: '$completedOrderCount',
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, '/order-history'),
          ),
          _buildStatItem(
            context: context,
            icon: Icons.favorite,
            title: 'Yêu thích',
            value: '$favoriteCount',
            color: Colors.red,
            onTap: () => Navigator.pushNamed(context, '/favorite'),
          ),
          _buildStatItem(
            context: context,
            icon: Icons.stars,
            title: 'Điểm thưởng',
            value: '$rewardPoints',
            color: Colors.amber,
            onTap: () {
              // TODO: Điều hướng đến trang điểm thưởng
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
