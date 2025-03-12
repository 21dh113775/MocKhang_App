import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

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
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child:
                    _image == null && widget.product.imageUrl.isNotEmpty
                        ? Image.file(
                          File(widget.product.imageUrl),
                          height: 150,
                          fit: BoxFit.cover,
                        )
                        : _image != null
                        ? Image.file(_image!, height: 150, fit: BoxFit.cover)
                        : Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey[700],
                          ),
                        ),
              ),
              SizedBox(height: 10),

              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: "Tên sản phẩm"),
                validator:
                    (value) => value!.isEmpty ? "Không được để trống" : null,
                onSaved: (value) => name = value!,
              ),

              TextFormField(
                initialValue: price.toString(),
                decoration: InputDecoration(labelText: "Giá tiền"),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? "Không được để trống" : null,
                onSaved: (value) => price = double.parse(value!),
              ),

              TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: "Mô tả sản phẩm"),
                maxLines: 3,
                onSaved: (value) => description = value!,
              ),

              TextFormField(
                initialValue: stock.toString(),
                decoration: InputDecoration(labelText: "Số lượng tồn kho"),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? "Không được để trống" : null,
                onSaved: (value) => stock = int.parse(value!),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    productProvider.updateProduct(
                      Product(
                        id: widget.product.id,
                        name: name,
                        category: category,
                        price: price,
                        stock: stock,
                        imageUrl:
                            _image != null
                                ? _image!.path
                                : widget.product.imageUrl,
                        description: description,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text("Cập nhật sản phẩm"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Hàm chọn ảnh từ thư viện**
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
}
