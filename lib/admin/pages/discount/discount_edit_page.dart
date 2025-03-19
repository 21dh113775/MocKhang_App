import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:provider/provider.dart';

class DiscountEditPageAdmin extends StatefulWidget {
  final DiscountModel discount;

  DiscountEditPageAdmin({required this.discount});

  @override
  _DiscountEditPageAdminState createState() => _DiscountEditPageAdminState();
}

class _DiscountEditPageAdminState extends State<DiscountEditPageAdmin> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String selectedType = 'Percentage'; // Loại khuyến mãi mặc định

  @override
  void initState() {
    super.initState();
    nameController.text = widget.discount.name;
    valueController.text = widget.discount.value.toString();
    descriptionController.text = widget.discount.description ?? '';
    selectedType = widget.discount.type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sửa Khuyến Mãi")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(labelText: 'Loại Khuyến Mãi'),
                items:
                    ['Percentage', 'Fixed Amount'].map((String type) {
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
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Mô Tả'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateDiscount,
                child: Text('Cập Nhật Khuyến Mãi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateDiscount() {
    if (_formKey.currentState!.validate()) {
      final discountProvider = Provider.of<DiscountProvider>(
        context,
        listen: false,
      );
      final updatedDiscount = widget.discount.copyWith(
        name: nameController.text,
        value: double.tryParse(valueController.text) ?? 0.0,
        type: selectedType,
        description: descriptionController.text,
      );

      discountProvider.updateDiscount(updatedDiscount);
      Navigator.pop(context); // Quay lại trang trước
    }
  }
}
