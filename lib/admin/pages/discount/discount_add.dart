import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DiscountAddPageAdmin extends StatefulWidget {
  @override
  _DiscountAddPageAdminState createState() => _DiscountAddPageAdminState();
}

class _DiscountAddPageAdminState extends State<DiscountAddPageAdmin> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String selectedType = 'Percentage'; // Loại khuyến mãi mặc định
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String barcode = '';

  final List<String> discountTypes = ['Percentage', 'Fixed Amount'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thêm Khuyến Mãi Mới")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tên khuyến mãi
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tên Khuyến Mãi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên khuyến mãi';
                  }
                  return null;
                },
              ),
              // Giá trị khuyến mãi
              TextFormField(
                controller: valueController,
                decoration: InputDecoration(labelText: 'Giá trị'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá trị';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Giá trị phải là số';
                  }
                  return null;
                },
              ),
              // Loại khuyến mãi
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(labelText: 'Loại Khuyến Mãi'),
                items:
                    discountTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
              // Thời gian bắt đầu
              ListTile(
                title: Text(
                  'Thời gian bắt đầu: ${selectedStartDate != null ? DateFormat('dd/MM/yyyy').format(selectedStartDate!) : 'Chưa chọn'}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectStartDate(context),
              ),
              // Thời gian kết thúc
              ListTile(
                title: Text(
                  'Thời gian kết thúc: ${selectedEndDate != null ? DateFormat('dd/MM/yyyy').format(selectedEndDate!) : 'Chưa chọn'}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectEndDate(context),
              ),
              SizedBox(height: 16),
              // Mô tả
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Mô Tả'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              // Button thêm
              ElevatedButton(
                onPressed: _addDiscount,
                child: Text('Thêm Khuyến Mãi'),
              ),
              if (barcode.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      Text("Mã vạch khuyến mãi: $barcode"),
                      // Hiển thị mã vạch
                      BarcodeWidget(
                        barcode: Barcode.code128(), // Sử dụng Barcode Code 128
                        data: barcode, // Dữ liệu mã vạch (barcode)
                        width: 200, // Chiều rộng của mã vạch
                        height: 100, // Chiều cao của mã vạch
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm chọn thời gian bắt đầu
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedStartDate)
      setState(() {
        selectedStartDate = picked;
      });
  }

  // Hàm chọn thời gian kết thúc
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedEndDate)
      setState(() {
        selectedEndDate = picked;
      });
  }

  // Hàm thêm khuyến mãi
  void _addDiscount() {
    if (_formKey.currentState!.validate() &&
        selectedStartDate != null &&
        selectedEndDate != null) {
      final discountProvider = Provider.of<DiscountProvider>(
        context,
        listen: false,
      );
      final newDiscount = DiscountModel(
        id: '', // ID sẽ được tạo tự động
        name: nameController.text,
        type: selectedType,
        value: double.parse(valueController.text),
        startDate: selectedStartDate!.millisecondsSinceEpoch,
        endDate: selectedEndDate!.millisecondsSinceEpoch,
        code: '', // Chưa sử dụng code ở đây
        description: descriptionController.text,
        barcode: '', // Mã vạch sẽ được tạo và gán sau khi thêm khuyến mãi
      );

      discountProvider.addDiscount(newDiscount).then((discount) {
        setState(() {
          barcode = discount?.barcode ?? ''; // Gán mã vạch vào biến barcode
        });

        // Sau khi thêm khuyến mãi xong, quay lại trang trước
        Navigator.pop(context);
      });
    }
  }
}
