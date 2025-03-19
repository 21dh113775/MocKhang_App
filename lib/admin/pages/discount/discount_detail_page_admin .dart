import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';

class DiscountDetailsPageAdmin extends StatelessWidget {
  final DiscountModel discount;

  DiscountDetailsPageAdmin({required this.discount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chi Tiết Khuyến Mãi")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tên Khuyến Mãi: ${discount.name}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text("Giá trị: ${discount.value}"),
            Text("Loại: ${discount.type}"),
            Text("Mô tả: ${discount.description ?? 'Không có'}"),
            SizedBox(height: 16),
            Text(
              "Thời gian bắt đầu: ${DateTime.fromMillisecondsSinceEpoch(discount.startDate)}",
            ),
            Text(
              "Thời gian kết thúc: ${DateTime.fromMillisecondsSinceEpoch(discount.endDate)}",
            ),
            SizedBox(height: 16),
            if (discount.barcode?.isNotEmpty ?? false)
              BarcodeWidget(
                barcode: Barcode.code128(), // Mã vạch Code128
                data: discount.barcode!, // Dữ liệu mã vạch
                width: 200,
                height: 80,
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Quay lại trang trước
              },
              child: Text('Quay Lại'),
            ),
          ],
        ),
      ),
    );
  }
}
