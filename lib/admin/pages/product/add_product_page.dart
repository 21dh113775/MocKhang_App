import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddProductPageAdmin extends StatefulWidget {
  final Product? productToEdit;

  const AddProductPageAdmin({Key? key, this.productToEdit}) : super(key: key);
  @override
  _DiscountAddPageAdminState createState() => _DiscountAddPageAdminState();
}

class _DiscountAddPageAdminState extends State<AddProductPageAdmin> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String selectedType = 'Giảm theo phần trăm';
  DateTime? selectedStartDateTime;
  DateTime? selectedEndDateTime;
  String? generatedBarcode;

  final List<String> discountTypes = [
    'Giảm theo phần trăm',
    'Giảm theo số tiền cố định',
    'Miễn phí vận chuyển',
    'Mua 1 tặng 1',
  ];

  // Thêm getter để kiểm tra loại khuyến mãi cần giá trị
  bool get _requiresValue {
    return selectedType == 'Giảm theo phần trăm' ||
        selectedType == 'Giảm theo số tiền cố định';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tạo Khuyến Mãi Mới")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên Khuyến Mãi',
                  prefixIcon: Icon(Icons.label_important),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên khuyến mãi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Loại khuyến mãi
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Loại Khuyến Mãi',
                  prefixIcon: Icon(Icons.category),
                ),
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
                    // Xóa giá trị khi chuyển sang loại không cần giá trị
                    if (!_requiresValue) {
                      valueController.text = '';
                    }
                  });
                },
              ),
              SizedBox(height: 16),

              // Giá trị khuyến mãi - chỉ hiển thị khi cần
              if (_requiresValue)
                TextFormField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: 'Giá trị Khuyến Mãi',
                    prefixIcon: Icon(Icons.money),
                    suffixText:
                        selectedType == 'Giảm theo phần trăm' ? '%' : 'đ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập giá trị';
                    }
                    final numValue = double.tryParse(value);
                    if (numValue == null) {
                      return 'Giá trị phải là số';
                    }
                    if (selectedType == 'Giảm theo phần trăm' &&
                        numValue > 100) {
                      return 'Phần trăm không được vượt quá 100%';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 16),

              // Thời gian bắt đầu
              _buildDateTimePicker(
                label: 'Thời gian bắt đầu',
                dateTime: selectedStartDateTime,
                onDateTimeChanged: (DateTime picked) {
                  setState(() {
                    selectedStartDateTime = picked;
                  });
                },
              ),
              SizedBox(height: 16),

              // Thời gian kết thúc
              _buildDateTimePicker(
                label: 'Thời gian kết thúc',
                dateTime: selectedEndDateTime,
                onDateTimeChanged: (DateTime picked) {
                  setState(() {
                    selectedEndDateTime = picked;
                  });
                },
              ),
              SizedBox(height: 16),

              // Mã vạch
              TextFormField(
                controller: barcodeController,
                decoration: InputDecoration(
                  labelText: 'Mã Vạch (Tùy chọn)',
                  prefixIcon: Icon(Icons.qr_code),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.grade_rounded),
                    onPressed: _generateBarcode,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Mô tả
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô Tả',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // Nút thêm khuyến mãi
              ElevatedButton.icon(
                onPressed: _addDiscount,
                icon: Icon(Icons.add_circle_outline),
                label: Text('Tạo Khuyến Mãi'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              // Hiển thị mã vạch (nếu có)
              if (generatedBarcode != null) ...[
                SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Mã Vạch Khuyến Mãi",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: generatedBarcode!,
                        width: 250,
                        height: 100,
                        drawText: true,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget xây dựng picker ngày giờ
  Widget _buildDateTimePicker({
    required String label,
    required DateTime? dateTime,
    required Function(DateTime) onDateTimeChanged,
  }) {
    return InkWell(
      onTap: () async {
        final pickedDateTime = await showDateTimePicker(context, dateTime);
        if (pickedDateTime != null) {
          onDateTimeChanged(pickedDateTime);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(),
        ),
        child: Text(
          dateTime != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(dateTime)
              : 'Chưa chọn',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // Hàm hiển thị picker ngày giờ
  Future<DateTime?> showDateTimePicker(
    BuildContext context,
    DateTime? initialDateTime,
  ) async {
    return await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) {
        DateTime? selectedDateTime = initialDateTime ?? DateTime.now();
        return Container(
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: selectedDateTime,
                  mode: CupertinoDatePickerMode.dateAndTime,
                  onDateTimeChanged: (DateTime newDateTime) {
                    selectedDateTime = newDateTime;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(selectedDateTime),
                child: Text('Xác Nhận'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hàm sinh mã vạch tự động
  void _generateBarcode() {
    final generatedCode = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      generatedBarcode = generatedCode;
      barcodeController.text = generatedCode;
    });
  }

  // Hàm thêm khuyến mãi
  void _addDiscount() async {
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra logic ngày giờ
    if (selectedStartDateTime == null || selectedEndDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn đầy đủ thời gian bắt đầu và kết thúc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedStartDateTime!.isAfter(selectedEndDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thời gian bắt đầu phải trước thời gian kết thúc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final discountProvider = Provider.of<DiscountProvider>(
      context,
      listen: false,
    );

    try {
      // Xác định giá trị khuyến mãi
      double discountValue = 0;
      if (_requiresValue) {
        discountValue = double.parse(valueController.text.trim());
      }

      final newDiscount = DiscountModel(
        id: '',
        name: nameController.text.trim(),
        type: selectedType,
        value: discountValue,
        startDate: selectedStartDateTime!.millisecondsSinceEpoch,
        endDate: selectedEndDateTime!.millisecondsSinceEpoch,
        description: descriptionController.text.trim(),
        barcode: generatedBarcode ?? barcodeController.text.trim(),
      );

      final createdDiscount = await discountProvider.addDiscount(newDiscount);

      // Đóng loading dialog
      Navigator.of(context).pop();

      if (createdDiscount != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm khuyến mãi thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Quay lại trang trước
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể thêm khuyến mãi. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Đóng loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
