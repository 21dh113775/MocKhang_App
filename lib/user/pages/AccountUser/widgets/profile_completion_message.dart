import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ProfileCompletionMessage extends StatelessWidget {
  final VoidCallback onEditPressed;
  final bool isEditing;

  const ProfileCompletionMessage({
    Key? key,
    required this.onEditPressed,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.amber.shade100, Colors.amber.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Cập nhật thông tin cá nhân',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Vui lòng cập nhật đầy đủ thông tin cá nhân để sử dụng tất cả tính năng của ứng dụng. Thông tin của bạn sẽ được bảo mật và chỉ sử dụng cho quá trình mua hàng.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 16),
            if (!isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onEditPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('CẬP NHẬT NGAY'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
