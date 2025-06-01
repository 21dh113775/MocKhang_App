import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class AddProductPageAdmin extends StatefulWidget {
  final Product? productToEdit;

  const AddProductPageAdmin({Key? key, this.productToEdit}) : super(key: key);
  @override
  _AddProductPageAdminState createState() => _AddProductPageAdminState();
}

class _AddProductPageAdminState extends State<AddProductPageAdmin> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryColor = const Color(0xFF2C3E50);

  // Text controllers để lưu giá trị từ các trường nhập liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String name = '';
  double price = 0.0;
  String description = '';
  int stock = 0;
  String? selectedCategory;
  File? _image; // Đây là ảnh được chọn từ thư viện
  bool _isPickingImage =
      false; // Trạng thái để kiểm tra xem việc chọn ảnh đã bắt đầu chưa
  bool _isLoading = false;
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();

    // Tải danh sách danh mục nếu cần
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      if (categoryProvider.categories.isEmpty) {
        categoryProvider.fetchCategories();
      }
    });

    // Nếu đang chỉnh sửa sản phẩm, điền các thông tin sẵn có
    if (widget.productToEdit != null) {
      _nameController.text = widget.productToEdit!.name;
      _priceController.text = widget.productToEdit!.price.toString();
      _descriptionController.text = widget.productToEdit!.description ?? '';
      _stockController.text = widget.productToEdit!.stock.toString();
      selectedCategory = widget.productToEdit!.category;
      _imageUrl = widget.productToEdit!.imageUrl;

      name = widget.productToEdit!.name;
      price = widget.productToEdit!.price.toDouble();
      description = widget.productToEdit!.description ?? '';
      stock = widget.productToEdit!.stock;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    // Đảm bảo rằng không có việc chọn ảnh nào đang diễn ra
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true; // Đánh dấu là đang chọn ảnh
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path); // Lưu đường dẫn ảnh được chọn
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPickingImage = false; // Đánh dấu kết thúc quá trình chọn ảnh
      });
    }
  }

  // Hàm tải ảnh lên Firebase Storage
  Future<String> _uploadImage() async {
    if (_image == null) return '';

    setState(() {
      _isLoading = true;
    });

    try {
      // Kiểm tra file tồn tại
      if (!await _image!.exists()) {
        throw Exception('File không tồn tại');
      }

      // Log để debug
      print('Bắt đầu tải lên: ${_image!.path}');

      final fileName = path.basename(_image!.path);
      final destination =
          'product_images/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      print('Destination path: $destination');

      // Tham chiếu đến Firebase Storage
      final ref = FirebaseStorage.instance.ref(destination);

      // Tải lên với cấu hình chi tiết
      final uploadTask = ref.putFile(
        _image!,
        SettableMetadata(
          contentType: 'image/jpeg', // hoặc xác định loại tệp cụ thể
          customMetadata: {'picked-file-path': _image!.path},
        ),
      );

      // Theo dõi tiến trình upload (thêm điều này nếu muốn hiển thị tiến trình)
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          print(
            'Đã tải lên: ${snapshot.bytesTransferred}/${snapshot.totalBytes}',
          );
        },
        onError: (e) {
          print('Lỗi trong quá trình tải lên: $e');
        },
      );

      // Đợi cho đến khi tải lên hoàn tất
      final snapshot = await uploadTask;
      print('Tải lên hoàn tất');

      // Lấy URL tải xuống
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('Đã nhận URL: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      print('Lỗi khi tải ảnh lên Firebase: $e');
      print('Stack trace: $stackTrace');

      // Hiển thị thông báo lỗi chi tiết hơn
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải ảnh: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Chi tiết',
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Chi tiết lỗi'),
                      content: SingleChildScrollView(
                        child: Text('$e\n\n$stackTrace'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Đóng'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ),
      );
      return '';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm lưu sản phẩm
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      // Lấy URL ảnh nếu đã chọn ảnh mới
      String finalImageUrl = _imageUrl;
      if (_image != null) {
        finalImageUrl = await _uploadImage();
        if (finalImageUrl.isEmpty && _isLoading) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      if (widget.productToEdit == null) {
        // Thêm sản phẩm mới
        final newProduct = Product(
          name: name,
          category: selectedCategory ?? "Chưa phân loại",
          price: price,
          stock: stock,
          importedQuantity: stock, // Số lượng nhập kho ban đầu
          soldQuantity: 0, // Số lượng đã bán ban đầu là 0
          imageUrl: finalImageUrl,
          description: description,
        );

        await productProvider.addProduct(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm sản phẩm thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Cập nhật sản phẩm hiện có
        final updatedProduct = widget.productToEdit!.copyWith(
          name: name,
          category: selectedCategory ?? widget.productToEdit!.category,
          price: price,
          stock: stock,
          imageUrl: finalImageUrl,
          description: description,
        );

        await productProvider.updateProduct(updatedProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật sản phẩm thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;
    final pageTitle = isEditing ? "Sửa Sản Phẩm" : "Thêm Sản Phẩm";
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        title: Text(
          pageTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: _primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      _image != null
                          ? 'Đang tải ảnh lên...'
                          : 'Đang lưu sản phẩm...',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image Picker
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildImagePicker(),
                          ),
                          const SizedBox(height: 20),

                          // Product Details Section
                          Text(
                            'Thông tin sản phẩm',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: _primaryColor,
                            ),
                          ),
                          const Divider(height: 24),

                          // Name Field
                          _buildTextField(
                            controller: _nameController,
                            label: 'Tên sản phẩm',
                            hint: 'Nhập tên sản phẩm',
                            icon: Icons.inventory,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên sản phẩm';
                              }
                              return null;
                            },
                            onSaved: (value) => name = value!,
                          ),

                          const SizedBox(height: 16),

                          // Price Field
                          _buildTextField(
                            controller: _priceController,
                            label: 'Giá bán',
                            hint: 'Nhập giá bán',
                            icon: Icons.monetization_on,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập giá bán';
                              }
                              try {
                                final priceValue = double.parse(value);
                                if (priceValue <= 0) {
                                  return 'Giá phải lớn hơn 0';
                                }
                              } catch (e) {
                                return 'Giá không hợp lệ';
                              }
                              return null;
                            },
                            onSaved: (value) => price = double.parse(value!),
                          ),

                          const SizedBox(height: 16),

                          // Stock Field
                          _buildTextField(
                            controller: _stockController,
                            label: 'Số lượng tồn kho',
                            hint: 'Nhập số lượng sản phẩm',
                            icon: Icons.inventory_2,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số lượng';
                              }
                              try {
                                final stockValue = int.parse(value);
                                if (stockValue < 0) {
                                  return 'Số lượng không thể âm';
                                }
                              } catch (e) {
                                return 'Số lượng không hợp lệ';
                              }
                              return null;
                            },
                            onSaved: (value) => stock = int.parse(value!),
                          ),

                          const SizedBox(height: 16),

                          // Category Dropdown
                          _buildCategoryDropdown(categoryProvider),

                          const SizedBox(height: 16),

                          // Description Field
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Mô tả sản phẩm',
                            hint:
                                'Nhập mô tả chi tiết sản phẩm (không bắt buộc)',
                            icon: Icons.description,
                            maxLines: 3,
                            onSaved: (value) => description = value!,
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _saveProduct,
                            child: Text(
                              isEditing
                                  ? 'Cập nhật sản phẩm'
                                  : 'Thêm sản phẩm mới',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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

  Widget _buildImagePicker() {
    final hasImage = _image != null || _imageUrl.isNotEmpty;

    return Stack(
      children: [
        InkWell(
          onTap: _isPickingImage ? null : _pickImage,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child:
                hasImage
                    ? _image != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  color: _primaryColor,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red[300],
                                      size: 40,
                                    ),
                                    const Text('Không thể tải ảnh'),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 60,
                          color: _primaryColor.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chọn ảnh sản phẩm',
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
        if (hasImage)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                tooltip: 'Đổi ảnh khác',
                onPressed: _pickImage,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Function(String?)? onSaved,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildCategoryDropdown(CategoryProvider categoryProvider) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Danh mục',
          prefixIcon: Icon(Icons.category, color: _primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        value: selectedCategory,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down),
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
                      "Đang tải danh mục...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
        onChanged: (value) {
          setState(() {
            selectedCategory = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Vui lòng chọn danh mục';
          }
          return null;
        },
        onSaved: (value) => selectedCategory = value,
      ),
    );
  }
}
