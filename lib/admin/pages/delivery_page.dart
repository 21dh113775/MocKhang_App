import 'package:flutter/material.dart';

class DeliveryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quản lý vận chuyển")),
      body: Center(
        child: Text(
          "Theo dõi vận chuyển đơn hàng",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
