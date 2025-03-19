import 'package:flutter/material.dart';
import 'package:mockhang_app/user/pages/checkout/oder/customer_orders_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutButton extends StatelessWidget {
  final CartProvider cartProvider;
  final bool isProcessing;
  final GlobalKey<FormState> formKey;
  final TextEditingController messageController;
  final VoidCallback? onCheckoutPressed; // Added this parameter

  const CheckoutButton({
    Key? key,
    required this.cartProvider,
    required this.isProcessing,
    required this.formKey,
    required this.messageController,
    this.onCheckoutPressed, // Made it optional with default value of null
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed:
            isProcessing
                ? null
                : () {
                  // Call the provided callback if it exists, otherwise use default implementation
                  if (onCheckoutPressed != null) {
                    onCheckoutPressed!();
                  } else {
                    _processCheckout(context);
                  }
                },
        child:
            isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  'Xác nhận thanh toán',
                  style: TextStyle(fontSize: 16),
                ),
      ),
    );
  }

  void _processCheckout(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Lấy người dùng hiện tại
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thanh toán')),
      );
      return;
    }

    try {
      // Tạo ID đơn hàng mới
      final orderId = const Uuid().v4();

      // Tạo đơn hàng mới
      final order = OrderModel(
        orderId: orderId,
        customerId: currentUser.uid,
        totalAmount: cartProvider.total,
        status: 'Đang xử lý', // Trạng thái mặc định khi tạo đơn hàng
        dateTime: DateTime.now(),
        items:
            cartProvider.items
                .map((item) => item.product.id.toString())
                .toList(),
        shippingMethod: cartProvider.shippingMethod ?? 'Tiêu chuẩn',
        paymentMethod: cartProvider.paymentMethod ?? 'Tiền mặt',
        messageForShop: messageController.text,
      );

      // Lưu đơn hàng vào database
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.saveOrder(order);

      // Xóa giỏ hàng
      cartProvider.clearCart();

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt hàng thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Chuyển đến trang đơn hàng của khách hàng
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CustomerOrdersPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
