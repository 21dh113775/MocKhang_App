import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class DiscountPageUser extends StatefulWidget {
  const DiscountPageUser({Key? key}) : super(key: key);

  @override
  State<DiscountPageUser> createState() => _DiscountPageUserState();
}

class _DiscountPageUserState extends State<DiscountPageUser> {
  bool _showActiveOnly = true;

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

  String getDiscountValueDisplay(DiscountModel discount) {
    if (discount.type == 'percentage') {
      return '${discount.value.toStringAsFixed(0)}%';
    } else {
      return '${NumberFormat('#,###').format(discount.value)} VNĐ';
    }
  }

  bool isActive(DiscountModel discount) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return discount.startDate <= now && discount.endDate >= now;
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép mã khuyến mãi'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khuyến Mãi'),
        actions: [
          Switch(
            value: _showActiveOnly,
            onChanged: (value) {
              setState(() {
                _showActiveOnly = value;
              });
            },
            activeTrackColor: Colors.green.shade100,
            activeColor: Colors.green,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('Đang hoạt động')),
          ),
        ],
      ),
      body: Consumer<DiscountProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải khuyến mãi: ${provider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadDiscounts();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Lọc khuyến mãi đang hoạt động nếu cần
          final discounts =
              _showActiveOnly
                  ? provider.discounts.where((d) => isActive(d)).toList()
                  : provider.discounts;

          if (discounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showActiveOnly
                        ? 'Không có khuyến mãi nào đang hoạt động'
                        : 'Không có khuyến mãi nào',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadDiscounts();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: discounts.length,
              itemBuilder: (context, index) {
                final discount = discounts[index];
                final active = isActive(discount);
                final daysLeft =
                    (discount.endDate -
                        DateTime.now().millisecondsSinceEpoch) ~/
                    (24 * 60 * 60 * 1000);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner khuyến mãi với hình ảnh
                      Stack(
                        children: [
                          if (discount.imageUrl != null &&
                              discount.imageUrl!.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: discount.imageUrl!,
                              height: 150,
                              width: double.infinity,
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
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade200,
                                          Colors.blue.shade500,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            discount.type == 'percentage'
                                                ? Icons.percent
                                                : Icons.local_offer,
                                            size: 48,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            getDiscountValueDisplay(discount),
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            )
                          else
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade200,
                                    Colors.blue.shade500,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      discount.type == 'percentage'
                                          ? Icons.percent
                                          : Icons.local_offer,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      getDiscountValueDisplay(discount),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Badge trạng thái (đang hoạt động/sắp hết hạn/hết hạn)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    active
                                        ? (daysLeft < 3
                                            ? Colors.orange
                                            : Colors.green)
                                        : Colors.grey,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                active
                                    ? (daysLeft < 3
                                        ? 'Sắp hết hạn'
                                        : 'Đang hoạt động')
                                    : 'Hết hạn',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Nội dung khuyến mãi
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              discount.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (discount.description != null &&
                                discount.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  discount.description!,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Thời gian: ${formatDate(discount.startDate)} - ${formatDate(discount.endDate)}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),

                            if (active && daysLeft >= 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  daysLeft == 0
                                      ? 'Hết hạn hôm nay'
                                      : 'Còn $daysLeft ngày',
                                  style: TextStyle(
                                    color:
                                        daysLeft < 3
                                            ? Colors.orange
                                            : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            // Mã khuyến mãi nếu có
                            if (discount.code != null &&
                                discount.code!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: InkWell(
                                  onTap:
                                      () => _copyToClipboard(
                                        context,
                                        discount.code!,
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Mã khuyến mãi:',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                discount.code!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                active
                                                    ? Colors.blue
                                                    : Colors.grey,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.copy,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'SAO CHÉP',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
