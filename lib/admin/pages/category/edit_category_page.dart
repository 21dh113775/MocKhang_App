import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // Thư viện để chọn ảnh từ thư viện
import 'dart:io'; // Đảm bảo import 'dart:io' để sử dụng File

class EditCategoryPage extends StatefulWidget {
  final Category category;
  EditCategoryPage({required this.category});

  @override
  _EditCategoryPageState createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late String updatedCategoryName;
  String? imagePath; // Biến lưu trữ ảnh

  final _picker = ImagePicker(); // Khởi tạo đối tượng chọn ảnh

  @override
  void initState() {
    super.initState();
    updatedCategoryName = widget.category.name; // Lấy tên danh mục ban đầu
    imagePath = widget.category.icon; // Lấy ảnh nếu có từ danh mục hiện tại
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: Text("Sửa Danh mục")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Chọn ảnh
              GestureDetector(
                onTap: _pickImage, // Hàm chọn ảnh khi người dùng nhấn vào
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      imagePath == null
                          ? Icon(
                            Icons.category_rounded,
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          )
                          : Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                          ), // Hiển thị ảnh đã chọn
                ),
              ),
              SizedBox(height: 32),
              // Input field cho tên danh mục
              TextFormField(
                initialValue: updatedCategoryName,
                decoration: InputDecoration(labelText: "Tên danh mục"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return "Tên danh mục không được để trống";
                  return null;
                },
                onSaved: (value) => updatedCategoryName = value!,
              ),
              SizedBox(height: 20),
              // Nút cập nhật danh mục
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    categoryProvider.updateCategory(
                      Category(
                        id: widget.category.id,
                        name: updatedCategoryName,
                        icon: null,
                        imageUrl: imagePath,
                      ),
                    ); // Cập nhật danh mục
                    Navigator.pop(context);
                  }
                },
                child: Text("Cập nhật danh mục"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    ); // Dùng pickImage thay vì getImage
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path; // Lưu đường dẫn ảnh đã chọn
      });
    }
  }
}
