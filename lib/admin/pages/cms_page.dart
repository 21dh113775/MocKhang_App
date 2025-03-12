import 'package:flutter/material.dart';

class CMSPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quản lý nội dung")),
      body: Center(
        child: Text(
          "Chỉnh sửa nội dung trang web",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
