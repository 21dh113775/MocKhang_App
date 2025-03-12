import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:provider/provider.dart';

class EditCategoryPage extends StatefulWidget {
  final Category category;
  EditCategoryPage({required this.category});

  @override
  _EditCategoryPageState createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late String updatedCategoryName;

  @override
  void initState() {
    super.initState();
    updatedCategoryName = widget.category.name;
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
              TextFormField(
                initialValue: updatedCategoryName,
                decoration: InputDecoration(labelText: "Tên danh mục"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Tên danh mục không được để trống";
                  }
                  return null;
                },
                onSaved: (value) => updatedCategoryName = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    categoryProvider.updateCategory(
                      Category(
                        id: widget.category.id,
                        name: updatedCategoryName,
                      ),
                    );
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
}
