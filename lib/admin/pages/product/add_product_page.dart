import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  double price = 0.0;
  String description = '';
  int stock = 0;
  String? selectedCategory;
  File? _image;
  bool _isPickingImage =
      false; // Trạng thái để kiểm tra xem việc chọn ảnh đã bắt đầu chưa

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Thêm Sản phẩm")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Chọn ảnh sản phẩm
              GestureDetector(
                onTap:
                    _isPickingImage
                        ? null
                        : _pickImage, // Ngừng chọn ảnh nếu đang chờ
                child:
                    _image == null
                        ? Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey[700],
                          ),
                        )
                        : Image.file(_image!, height: 150, fit: BoxFit.cover),
              ),
              SizedBox(height: 10),

              // Tên sản phẩm
              TextFormField(
                decoration: const InputDecoration(labelText: "Tên sản phẩm"),
                validator:
                    (value) => value!.isEmpty ? "Không được để trống" : null,
                onSaved: (value) => name = value!,
              ),

              // Giá tiền
              TextFormField(
                decoration: const InputDecoration(labelText: "Giá tiền"),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? "Không được để trống" : null,
                onSaved: (value) => price = double.parse(value!),
              ),

              // Mô tả sản phẩm
              TextFormField(
                decoration: const InputDecoration(labelText: "Mô tả sản phẩm"),
                maxLines: 3,
                onSaved: (value) => description = value!,
              ),

              // Số lượng tồn kho
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Số lượng tồn kho",
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? "Không được để trống" : null,
                onSaved: (value) => stock = int.parse(value!),
              ),

              // Dropdown chọn danh mục
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Danh mục"),
                value: selectedCategory,
                items:
                    categoryProvider.categories.isNotEmpty
                        ? categoryProvider.categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.name,
                            child: Text(category.name),
                          );
                        }).toList()
                        : [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              "Chưa có danh mục nào",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator:
                    (value) => value == null ? "Vui lòng chọn danh mục" : null,
              ),

              const SizedBox(height: 20),

              // Nút Thêm sản phẩm
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    productProvider.addProduct(
                      Product(
                        name: name,
                        category: selectedCategory ?? "Không có danh mục",
                        price: price,
                        stock: stock,
                        imageUrl: _image != null ? _image!.path : "",
                        description: description,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Thêm sản phẩm"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    // Đảm bảo rằng không có việc chọn ảnh nào đang diễn ra
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true; // Đánh dấu là đang chọn ảnh
    });

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      setState(() {
        _isPickingImage = false; // Đánh dấu kết thúc quá trình chọn ảnh
      });
    }
  }
}
