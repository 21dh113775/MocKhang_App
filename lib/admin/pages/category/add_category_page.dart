import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:image_picker/image_picker.dart'; // Thư viện để chọn ảnh từ thư viện
import 'dart:io'; // Đảm bảo import 'dart:io' để sử dụng File

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>(); // Khóa để kiểm tra form
  String categoryName = ''; // Biến lưu trữ tên danh mục
  bool _isSubmitting = false; // Biến trạng thái khi đang gửi dữ liệu
  String? imagePath; // Biến lưu trữ đường dẫn của ảnh đã chọn

  final _picker = ImagePicker(); // Khởi tạo đối tượng để chọn ảnh

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: true,
    ); // Lấy provider để quản lý trạng thái

    bool isSubmitting =
        _isSubmitting ||
        categoryProvider
            .isLoading; // Kiểm tra trạng thái gửi dữ liệu hoặc đang tải

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thêm Danh Mục",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần chọn ảnh
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage, // Hàm chọn ảnh khi người dùng nhấn vào
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
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
                                ), // Hiển thị ảnh nếu có, nếu không hiển thị icon mặc định
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Tiêu đề phần thông tin danh mục
                  Text(
                    "Thông Tin Danh Mục",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Vui lòng nhập tên cho danh mục mới",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  // Hiển thị lỗi từ provider nếu có
                  if (categoryProvider.error != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              categoryProvider.error!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Input field cho tên danh mục
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Tên danh mục",
                      hintText: "Nhập tên danh mục",
                      prefixIcon: Icon(Icons.edit_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return "Tên danh mục không được để trống"; // Kiểm tra nếu tên rỗng
                      if (value.trim().length < 2)
                        return "Tên danh mục phải có ít nhất 2 ký tự"; // Kiểm tra độ dài tên
                      return null;
                    },
                    onSaved: (value) => categoryName = value!.trim(),
                    enabled: !isSubmitting,
                  ),
                  SizedBox(height: 36),
                  // Nút submit
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          isSubmitting
                              ? null
                              : () async {
                                if (_formKey.currentState!.validate()) {
                                  // Kiểm tra form hợp lệ
                                  setState(() => _isSubmitting = true);
                                  _formKey.currentState!.save();

                                  try {
                                    await categoryProvider.addCategory(
                                      Category(
                                        name: categoryName,
                                        icon: null,
                                        imageUrl: imagePath,
                                      ),
                                    ); // Thêm danh mục mới
                                    if (categoryProvider.error == null) {
                                      Navigator.pop(context);
                                      AnimatedSnackBar.material(
                                        'Đã thêm danh mục thành công!',
                                        type: AnimatedSnackBarType.success,
                                      ).show(
                                        context,
                                      ); // Hiển thị thông báo thành công
                                    } else {
                                      setState(() => _isSubmitting = false);
                                    }
                                  } catch (e) {
                                    setState(() => _isSubmitting = false);
                                    AnimatedSnackBar.material(
                                      'Lỗi: ${e.toString()}',
                                      type: AnimatedSnackBarType.error,
                                    ).show(context); // Hiển thị thông báo lỗi
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child:
                          isSubmitting
                              ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 8),
                                  Text(
                                    "Thêm Danh Mục",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Nút hủy
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed:
                          isSubmitting ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: Text(
                        "Hủy",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
