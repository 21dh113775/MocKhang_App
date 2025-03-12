import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'discount_add.dart';
import 'discount_edit_page.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({Key? key}) : super(key: key);

  @override
  _DiscountPageAdminState createState() => _DiscountPageAdminState();
}

class _DiscountPageAdminState extends State<DiscountPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiscountProvider>(context, listen: false).loadDiscounts();
    });
  }

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String getDiscountTypeDisplay(String type) {
    switch (type) {
      case 'percentage':
        return 'Giảm giá theo %';
      case 'fixed':
        return 'Giảm giá cố định';
      default:
        return type;
    }
  }

  String getDiscountValueDisplay(DiscountModel discount) {
    if (discount.type == 'percentage') {
      return '${discount.value.toStringAsFixed(0)}%';
    } else {
      return '${NumberFormat('#,###').format(discount.value)} VNĐ';
    }
  }

  bool isValidImageUrl(String? url) {
    return url != null &&
        url.trim().isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    final discountProvider = Provider.of<DiscountProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý khuyến mãi'), elevation: 0),
      body:
          discountProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : discountProvider.error != null
              ? Center(child: Text('Lỗi: ${discountProvider.error}'))
              : RefreshIndicator(
                onRefresh: discountProvider.loadDiscounts,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: discountProvider.discounts.length,
                  itemBuilder: (context, index) {
                    final discount = discountProvider.discounts[index];
                    final isActive =
                        discount.startDate <=
                            DateTime.now().millisecondsSinceEpoch &&
                        discount.endDate >=
                            DateTime.now().millisecondsSinceEpoch;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isValidImageUrl(discount.imageUrl)
                              ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: discount.imageUrl!.trim(),
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                ),
                              )
                              : Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                  ),
                                ),
                              ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        discount.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => EditDiscountPage(
                                                    discountId: discount.id,
                                                  ),
                                            ),
                                          ).then(
                                            (_) =>
                                                discountProvider
                                                    .loadDiscounts(),
                                          ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: Text('Xác nhận xóa'),
                                                  content: Text(
                                                    'Bạn có muốn xóa khuyến mãi này không?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                      child: Text('Hủy'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        discountProvider
                                                            .deleteDiscount(
                                                              discount.id,
                                                            );
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        'Xóa',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Loại: ${getDiscountTypeDisplay(discount.type)}',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Giá trị: ${getDiscountValueDisplay(discount)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Thời gian: ${formatDate(discount.startDate)} - ${formatDate(discount.endDate)}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Thêm mới'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDiscountPage()),
          ).then((_) => discountProvider.loadDiscounts());
        },
      ),
    );
  }
}
