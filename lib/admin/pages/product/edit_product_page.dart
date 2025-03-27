import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  EditProductPage({required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late double price;
  late String description;
  late int stock;
  late String category;
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    name = widget.product.name;
    price = widget.product.price;
    description = widget.product.description;
    stock = widget.product.stock;
    category = widget.product.category;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: Text("Chỉnh sửa Sản phẩm")),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Hiển thị vòng quay khi đang tải
              : Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Hiển thị ảnh sản phẩm và chọn ảnh mới
                      GestureDetector(
                        onTap: _pickImage,
                        child:
                            _image == null && widget.product.imageUrl.isNotEmpty
                                ? Image.network(
                                  widget.product.imageUrl,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                                : _image != null
                                ? Image.file(
                                  _image!,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 50,
                                    color: Colors.grey[700],
                                  ),
                                ),
                      ),
                      SizedBox(height: 10),

                      // Tên sản phẩm
                      TextFormField(
                        initialValue: name,
                        decoration: InputDecoration(labelText: "Tên sản phẩm"),
                        validator:
                            (value) =>
                                value!.isEmpty ? "Không được để trống" : null,
                        onSaved: (value) => name = value!,
                      ),

                      // Giá tiền
                      TextFormField(
                        initialValue: price.toString(),
                        decoration: InputDecoration(labelText: "Giá tiền"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return "Không được để trống";
                          if (double.tryParse(value) == null)
                            return "Giá tiền không hợp lệ";
                          return null;
                        },
                        onSaved: (value) => price = double.parse(value!),
                      ),

                      // Mô tả sản phẩm
                      TextFormField(
                        initialValue: description,
                        decoration: InputDecoration(
                          labelText: "Mô tả sản phẩm",
                        ),
                        maxLines: 3,
                        validator:
                            (value) =>
                                value!.isEmpty ? "Không được để trống" : null,
                        onSaved: (value) => description = value!,
                      ),

                      // Số lượng tồn kho
                      TextFormField(
                        initialValue: stock.toString(),
                        decoration: InputDecoration(
                          labelText: "Số lượng tồn kho",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return "Không được để trống";
                          if (int.tryParse(value) == null)
                            return "Số lượng không hợp lệ";
                          return null;
                        },
                        onSaved: (value) => stock = int.parse(value!),
                      ),

                      // Dropdown chọn danh mục
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: "Danh mục"),
                        value: category,
                        items:
                            ["Điện thoại", "Laptop", "Phụ kiện"].map((
                              String cat,
                            ) {
                              return DropdownMenuItem<String>(
                                value: cat,
                                child: Text(cat),
                              );
                            }).toList(),
                        onChanged: (value) => setState(() => category = value!),
                        validator:
                            (value) =>
                                value == null ? "Vui lòng chọn danh mục" : null,
                      ),

                      SizedBox(height: 20),

                      // Nút cập nhật sản phẩm
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text("Cập nhật sản phẩm"),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  // Hàm upload ảnh lên Firebase Storage và trả về URL
  Future<String> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child(
      "products/$fileName.jpg",
    );
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  // Hàm xử lý khi bấm nút "Cập nhật sản phẩm"
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save(); // Lưu dữ liệu nhập vào
    setState(() => _isLoading = true);

    try {
      String imageUrl = widget.product.imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!); // Tải ảnh mới lên Firebase
      }

      // Cập nhật sản phẩm trong Firestore
      await Provider.of<ProductProvider>(context, listen: false).updateProduct(
        Product(
          id: widget.product.id,
          name: name,
          category: category,
          price: price,
          stock: stock,
          imageUrl: imageUrl,
          description: description,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cập nhật sản phẩm thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Quay lại màn hình trước
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi cập nhật sản phẩm: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
