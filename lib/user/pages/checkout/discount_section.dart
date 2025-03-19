import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/user/pages/checkout/discount_selector.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';

class DiscountSection extends StatefulWidget {
  final CartProvider cartProvider;
  final DiscountProvider discountProvider;
  final Function(DiscountModel?) onDiscountSelected;

  const DiscountSection({
    Key? key,
    required this.cartProvider,
    required this.discountProvider,
    required this.onDiscountSelected,
  }) : super(key: key);

  @override
  _DiscountSectionState createState() => _DiscountSectionState();
}

class _DiscountSectionState extends State<DiscountSection> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Sử dụng addPostFrameCallback để đảm bảo gọi sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDiscounts();
      }
    });
  }

  Future<void> _loadDiscounts() async {
    // Chỉ cập nhật state nếu widget vẫn còn mounted
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Sử dụng listen: false để tránh thông báo thay đổi trong quá trình build
      await widget.discountProvider.ensureDataLoaded();
    } catch (e) {
      // Xử lý lỗi nếu cần
      print('Error loading discounts: $e');
    } finally {
      // Chỉ cập nhật state nếu widget vẫn còn mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
                  'Mã giảm giá',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.discount, color: Colors.blue),
              ],
            ),
            const Divider(thickness: 1),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              DiscountSelector(
                onDiscountSelected: (discount) {
                  // Sử dụng Future.microtask để tránh gọi hàm thay đổi state trong quá trình build
                  Future.microtask(() {
                    widget.onDiscountSelected(discount);
                  });
                },
                orderTotal: widget.cartProvider.subtotal,
                availableDiscounts: widget.discountProvider.discounts,
              ),
          ],
        ),
      ),
    );
  }
}
