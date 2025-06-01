import 'package:flutter/material.dart';

class MessageForShopSection extends StatelessWidget {
  final TextEditingController messageController;

  const MessageForShopSection({Key? key, required this.messageController})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lời nhắn cho shop',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.message, color: Colors.blue),
              ],
            ),
            const Divider(thickness: 1),
            TextFormField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập lời nhắn của bạn (không bắt buộc)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
