import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({Key? key}) : super(key: key);

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  bool _isSubmitting = false;
  String? _imagePath;
  final _primaryColor = const Color(0xFF2C3E50);
  final _picker = ImagePicker();

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final bool isSubmitting = _isSubmitting || categoryProvider.isLoading;
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thêm Danh Mục",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: _primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.06,
              vertical: screenSize.height * 0.03,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSelector(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context),
                  _buildErrorMessage(categoryProvider),
                  const SizedBox(height: 16),
                  _buildCategoryNameField(isSubmitting),
                  const SizedBox(height: 36),
                  _buildActionButtons(context, isSubmitting, categoryProvider),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: !_isSubmitting ? _pickImage : null,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _primaryColor.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child:
                    _imagePath == null
                        ? Icon(
                          Icons.category_rounded,
                          size: 45,
                          color: _primaryColor,
                        )
                        : Image.file(File(_imagePath!), fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Chọn hình ảnh đại diện",
            style: TextStyle(
              fontSize: 14,
              color: _primaryColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article_rounded, color: _primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                "Thông Tin Danh Mục",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Vui lòng nhập tên cho danh mục mới",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(CategoryProvider categoryProvider) {
    if (categoryProvider.error == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              categoryProvider.error!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryNameField(bool isSubmitting) {
    return TextFormField(
      controller: _categoryNameController,
      decoration: InputDecoration(
        labelText: "Tên danh mục",
        hintText: "Nhập tên danh mục",
        prefixIcon: Icon(Icons.edit_outlined, color: _primaryColor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: TextStyle(color: _primaryColor.withOpacity(0.8)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Tên danh mục không được để trống";
        }
        if (value.trim().length < 2) {
          return "Tên danh mục phải có ít nhất 2 ký tự";
        }
        return null;
      },
      enabled: !isSubmitting,
      textInputAction: TextInputAction.done,
      style: TextStyle(color: _primaryColor),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    bool isSubmitting,
    CategoryProvider categoryProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: isSubmitting ? null : () => _submitForm(categoryProvider),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child:
              isSubmitting
                  ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.5,
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_circle_outline),
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
        const SizedBox(height: 16),
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: _primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _primaryColor.withOpacity(0.3)),
            ),
          ),
          child: const Text(
            "Hủy",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Giảm chất lượng ảnh để tối ưu bộ nhớ
      );

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      AnimatedSnackBar.material(
        'Lỗi khi chọn ảnh: ${e.toString()}',
        type: AnimatedSnackBarType.error,
      ).show(context);
    }
  }

  Future<void> _submitForm(CategoryProvider categoryProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final String categoryName = _categoryNameController.text.trim();

      await categoryProvider.addCategory(
        Category(name: categoryName, icon: null, imageUrl: _imagePath),
      );

      if (categoryProvider.error == null) {
        Navigator.pop(context);
        AnimatedSnackBar.material(
          'Đã thêm danh mục thành công!',
          type: AnimatedSnackBarType.success,
          duration: const Duration(seconds: 3),
        ).show(context);
      } else {
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      AnimatedSnackBar.material(
        'Lỗi: ${e.toString()}',
        type: AnimatedSnackBarType.error,
      ).show(context);
    }
  }
}
