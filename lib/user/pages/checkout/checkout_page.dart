import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:provider/provider.dart';
import 'discount_section.dart';
import 'order_summary.dart';
import 'shipping_method_section.dart';
import 'payment/payment_method_section.dart';
import 'message_for_shop_section.dart';
import 'total_amount_section.dart';
import 'checkout_button.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  DiscountModel? _selectedDiscount;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi chọn giảm giá
  void _onDiscountSelected(DiscountModel? discount) {
    setState(() {
      _selectedDiscount = discount;
    });
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (discount != null) {
      cartProvider.applyDiscount(discount);
    } else {
      cartProvider.removeDiscount();
    }
  }

  // Hàm xử lý thanh toán
  Future<void> _processPayment(
    CartProvider cartProvider,
    OrderProvider orderProvider,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Lấy thông tin người dùng từ Firebase Auth
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        // Nếu người dùng chưa đăng nhập, hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để thanh toán')),
        );
        return;
      }

      // Tạo ID duy nhất cho đơn hàng
      final String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      // Tạo thông tin đơn hàng
      final order = OrderModel(
        orderId: orderId,
        customerId: currentUser.uid, // ID khách hàng từ Firebase Auth
        totalAmount: cartProvider.total,
        status: 'Đang xử lý', // Trạng thái đơn hàng ban đầu
        dateTime: DateTime.now(),
        items:
            cartProvider.items
                .map((item) => item.product.id.toString())
                .toList(),
        shippingMethod:
            cartProvider.shippingMethod ??
            'Giao hàng nhanh', // Lấy phương thức giao hàng
        paymentMethod:
            cartProvider.paymentMethod ??
            'Thẻ tín dụng', // Lấy phương thức thanh toán
        messageForShop: _messageController.text, // Thông điệp cho shop
      );

      // Lưu đơn hàng vào Firestore qua OrderProvider
      await orderProvider.saveOrder(order);

      // Giảm giỏ hàng sau khi thanh toán
      cartProvider.clearCart();

      // Hiển thị thông báo thanh toán thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanh toán thành công, đơn hàng đang được xử lý'),
        ),
      );

      // Chuyển hướng đến trang cảm ơn hoặc trang đơn hàng
      Navigator.pushReplacementNamed(context, '/user_home');
    } catch (e) {
      // Nếu có lỗi trong quá trình thanh toán
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $e')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh Toán'), elevation: 0),
      body: Consumer2<CartProvider, DiscountProvider>(
        builder: (context, cartProvider, discountProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const Center(child: Text('Giỏ hàng của bạn đang trống'));
          }

          return Form(
            key: _formKey,
            child: ListView(
              children: [
                OrderSummary(cartProvider: cartProvider),
                ShippingMethodSection(cartProvider: cartProvider),
                PaymentMethodSection(cartProvider: cartProvider),
                DiscountSection(
                  cartProvider: cartProvider,
                  discountProvider: discountProvider,
                  onDiscountSelected: _onDiscountSelected,
                ),
                MessageForShopSection(messageController: _messageController),
                TotalAmountSection(cartProvider: cartProvider),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return CheckoutButton(
            cartProvider: cartProvider,
            isProcessing: _isProcessing,
            formKey: _formKey,
            messageController: _messageController,
            onCheckoutPressed: () {
              final orderProvider = Provider.of<OrderProvider>(
                context,
                listen: false,
              );
              _processPayment(cartProvider, orderProvider);
            },
          );
        },
      ),
    );
  }
}
