import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';
import 'package:mockhang_app/admin/data/models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:uuid/uuid.dart';
import 'package:mockhang_app/user/pages/checkout/order/customer_orders_page.dart';
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

  // Hàm xử lý thanh toán thông thường (không phải PayPal)
  Future<void> _processPayment(
    CartProvider cartProvider,
    OrderProvider orderProvider,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Lấy thông tin người dùng hiện tại từ Firebase Auth
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        // Hiển thị thông báo nếu người dùng chưa đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để thanh toán')),
        );
        return;
      }

      // Tạo ID đơn hàng ngẫu nhiên bằng UUID
      final String orderId = const Uuid().v4();

      // Tạo đối tượng đơn hàng mới
      final order = OrderModel(
        orderId: orderId,
        customerId: currentUser.uid,
        totalAmount: cartProvider.total,
        status: 'Đang xử lý',
        dateTime: DateTime.now(),
        items:
            cartProvider.items
                .map((item) => item.product.id.toString())
                .toList(),
        shippingMethod: cartProvider.shippingMethod ?? 'Tiêu chuẩn',
        paymentMethod: cartProvider.paymentMethod ?? 'Tiền mặt',
        messageForShop: _messageController.text,
      );

      // Lưu đơn hàng vào database thông qua OrderProvider
      await orderProvider.saveOrder(order);

      // Xóa giỏ hàng sau khi đặt hàng thành công
      cartProvider.clearCart();

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt hàng thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Chuyển hướng người dùng đến trang đơn hàng
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CustomerOrdersPage()),
      );
    } catch (e) {
      // Xử lý lỗi nếu có
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Cập nhật trạng thái xử lý
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Hàm xử lý thanh toán qua PayPal
  Future<void> _processPaypalPayment(CartProvider cartProvider) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Kiểm tra người dùng đã đăng nhập chưa
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để thanh toán')),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Tính phí vận chuyển
      final double shippingCost = 0.0;

      // Định nghĩa các thông tin giao dịch PayPal
      final transactions = [
        {
          "amount": {
            "total": cartProvider.total.toStringAsFixed(2),
            "currency": "USD",
            "details": {
              "subtotal": cartProvider.subtotal.toStringAsFixed(2),
              "shipping": shippingCost.toStringAsFixed(2),
              "shipping_discount": (cartProvider.discountAmount)
                  .toStringAsFixed(2),
            },
          },
          "description": "Thanh toán đơn hàng tại MockHang App",
          "item_list": {
            "items":
                cartProvider.items.map((item) {
                  return {
                    "name": item.product.name,
                    "quantity": item.quantity,
                    "price": item.product.price.toStringAsFixed(2),
                    "currency": "USD",
                  };
                }).toList(),
          },
        },
      ];

      // Chuyển hướng sang trang thanh toán PayPal
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (BuildContext context) => UsePaypal(
                sandboxMode: true,
                clientId: "YOUR_PAYPAL_CLIENT_ID",
                secretKey: "YOUR_PAYPAL_SECRET_KEY",
                returnURL: "https://example.com/return",
                cancelURL: "https://example.com/cancel",
                transactions: transactions,
                note: "Liên hệ với chúng tôi nếu bạn cần hỗ trợ",
                onSuccess: (Map params) async {
                  // Xử lý khi thanh toán PayPal thành công
                  print("Thanh toán PayPal thành công: $params");

                  // Lấy mã giao dịch PayPal
                  final String? paypalTransactionId = params['data']?['id'];

                  // Tiếp tục xử lý đơn hàng với thông tin thanh toán PayPal
                  final orderProvider = Provider.of<OrderProvider>(
                    context,
                    listen: false,
                  );

                  // Tạo ID đơn hàng ngẫu nhiên
                  final String orderId = const Uuid().v4();

                  // Tạo thông tin đơn hàng mới với thông tin PayPal
                  final order = OrderModel(
                    orderId: orderId,
                    customerId: currentUser.uid,
                    totalAmount: cartProvider.total,
                    status: 'Đã thanh toán',
                    dateTime: DateTime.now(),
                    items:
                        cartProvider.items
                            .map((item) => item.product.id.toString())
                            .toList(),
                    shippingMethod: cartProvider.shippingMethod ?? 'Tiêu chuẩn',
                    paymentMethod: 'PayPal',
                    messageForShop: _messageController.text,
                    paypalTransactionId: paypalTransactionId,
                  );

                  // Lưu đơn hàng vào database
                  await orderProvider.saveOrder(order);

                  // Xóa giỏ hàng
                  cartProvider.clearCart();

                  // Hiển thị thông báo thành công và quay lại trang chính
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thanh toán PayPal thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Chuyển đến trang đơn hàng
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const CustomerOrdersPage(),
                    ),
                  );
                },
                onError: (error) {
                  // Xử lý khi có lỗi trong quá trình thanh toán PayPal
                  print("Lỗi thanh toán PayPal: $error");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi thanh toán PayPal: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setState(() {
                    _isProcessing = false;
                  });
                },
                onCancel: () {
                  // Xử lý khi người dùng hủy thanh toán PayPal
                  print('Thanh toán PayPal bị hủy');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bạn đã hủy thanh toán PayPal'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  setState(() {
                    _isProcessing = false;
                  });
                },
              ),
        ),
      );
    } catch (e) {
      // Xử lý các lỗi khác trong quá trình khởi tạo PayPal
      print("Lỗi khởi tạo PayPal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khởi tạo PayPal: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Xử lý chức năng thanh toán dựa trên phương thức thanh toán được chọn
  Future<void> _handleCheckout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final paymentMethod = cartProvider.paymentMethod ?? 'Tiền mặt';

    // Kiểm tra phương thức thanh toán và gọi hàm xử lý tương ứng
    if (paymentMethod == 'PayPal') {
      await _processPaypalPayment(cartProvider);
    } else {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await _processPayment(cartProvider, orderProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh Toán'), elevation: 0),
      body: Consumer2<CartProvider, DiscountProvider>(
        builder: (context, cartProvider, discountProvider, child) {
          // Hiển thị thông báo nếu giỏ hàng trống
          if (cartProvider.items.isEmpty) {
            return const Center(child: Text('Giỏ hàng của bạn đang trống'));
          }

          // Hiển thị giao diện thanh toán khi có sản phẩm trong giỏ hàng
          return Form(
            key: _formKey,
            child: ListView(
              children: [
                // Hiển thị thông tin tóm tắt đơn hàng
                OrderSummary(cartProvider: cartProvider),

                // Phần chọn phương thức vận chuyển
                ShippingMethodSection(cartProvider: cartProvider),

                // Phần chọn phương thức thanh toán
                PaymentMethodSection(cartProvider: cartProvider),

                // Phần áp dụng mã giảm giá
                DiscountSection(
                  cartProvider: cartProvider,
                  discountProvider: discountProvider,
                  onDiscountSelected: _onDiscountSelected,
                ),

                // Phần nhập lời nhắn cho shop
                MessageForShopSection(messageController: _messageController),

                // Hiển thị tổng số tiền phải thanh toán
                TotalAmountSection(cartProvider: cartProvider),
              ],
            ),
          );
        },
      ),
      // Nút thanh toán ở cuối màn hình
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return CheckoutButton(
            cartProvider: cartProvider,
            isProcessing: _isProcessing,
            formKey: _formKey,
            messageController: _messageController,
            onCheckoutPressed: _handleCheckout,
          );
        },
      ),
    );
  }
}
