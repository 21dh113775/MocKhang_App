import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:provider/provider.dart' show Provider;

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  String categoryName = '';

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: Text("Thêm Danh mục")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Tên danh mục"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Tên danh mục không được để trống";
                  }
                  return null;
                },
                onSaved: (value) => categoryName = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    categoryProvider.addCategory(Category(name: categoryName));
                    Navigator.pop(context);
                  }
                },
                child: Text("Thêm danh mục"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
