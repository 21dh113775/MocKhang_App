import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/checkout/order/customer_orders_page.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String orderId;
  final double amount;
  final String paymentMethod;

  const PaymentSuccessPage({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán thành công'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon thành công
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),

              // Tiêu đề
              const Text(
                'Đặt hàng thành công!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Thông tin đơn hàng
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Mã đơn hàng:', orderId.substring(0, 8)),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Tổng tiền:',
                      '${amount.toStringAsFixed(2)} USD',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow('Phương thức:', paymentMethod),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Thông báo
              const Text(
                'Cảm ơn bạn đã mua hàng. Chúng tôi sẽ xử lý đơn hàng của bạn trong thời gian sớm nhất.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Các nút điều hướng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Tiếp tục mua sắm'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const CustomerOrdersPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Xem đơn hàng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị thông tin hàng
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
