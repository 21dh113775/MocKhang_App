import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/product_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockhang_app/admin/pages/category/add_category_page.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class AddProductPageAdmin extends StatefulWidget {
  final Product? productToEdit;

  const AddProductPageAdmin({Key? key, this.productToEdit}) : super(key: key);

  @override
  State<AddProductPageAdmin> createState() => _AddProductPageAdminState();
}

class _AddProductPageAdminState extends State<AddProductPageAdmin> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường nhập liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = '';
  String _imageUrl = '';
  File? _imageFile;
  bool _isUploading = false;
  bool _isProcessing = false;
  String _errorMessage = '';
  double _uploadProgress = 0;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();

    // Nếu đang chỉnh sửa sản phẩm, điền thông tin vào các trường
    if (widget.productToEdit != null) {
      _nameController.text = widget.productToEdit!.name;
      _priceController.text = widget.productToEdit!.price.toString();
      _stockController.text = widget.productToEdit!.stock.toString();
      _descriptionController.text = widget.productToEdit!.description;
      _selectedCategory = widget.productToEdit!.category;
      _imageUrl = widget.productToEdit!.imageUrl;
    } else {
      _stockController.text = '0'; // Giá trị mặc định cho sản phẩm mới
    }

    // Tải danh sách danh mục
    _fetchCategories();
  }

  /// Tải danh sách danh mục từ CategoryProvider
  Future<void> _fetchCategories() async {
    // Tránh gọi setState trong build, dùng WidgetsBinding để xử lý sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoadingCategories = true;
      });

      try {
        final categoryProvider = Provider.of<CategoryProvider>(
          context,
          listen: false,
        );
        await categoryProvider.fetchCategories();

        // Thiết lập danh mục mặc định nếu chưa có danh mục được chọn
        if (_selectedCategory.isEmpty) {
          final defaultCategory = categoryProvider.getDefaultCategory();
          if (defaultCategory != null) {
            setState(() {
              _selectedCategory = defaultCategory;
            });
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Lỗi khi tải danh mục: $e';
        });
      } finally {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Chọn hình ảnh từ thiết bị
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể chọn hình ảnh: $e';
      });
    }
  }

  /// Tải ảnh lên Firebase Storage
  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      // Debug: Print file path and size
      print('Uploading file: ${_imageFile!.path}');
      print('File size: ${_imageFile!.lengthSync()} bytes');

      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('products')
          .child(fileName);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-from': 'device'},
      );

      final uploadTask = storageRef.putFile(_imageFile!, metadata);

      // Use stream to track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          print(
            'Upload progress: ${(_uploadProgress * 100).toStringAsFixed(2)}%',
          );
        });
      });

      // Await the upload completion
      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Debug: Print download URL
      print('Image uploaded successfully. Download URL: $downloadUrl');

      setState(() {
        _isUploading = false;
        _imageUrl = downloadUrl;
      });

      return downloadUrl;
    } catch (e) {
      print("Detailed upload error: $e");
      setState(() {
        _isUploading = false;
        _errorMessage = 'Lỗi khi tải ảnh lên: $e';
      });
      return null;
    }
  }

  /// Lưu hoặc cập nhật sản phẩm
  Future<void> _saveProduct() async {
    // Kiểm tra validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Cập nhật UI để hiển thị trạng thái đang xử lý
    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });

    try {
      // Kiểm tra xem có file ảnh mới không
      String finalImageUrl =
          _imageUrl; // Sử dụng URL hiện tại nếu không có file mới

      // Nếu có file ảnh mới, tải lên Firebase Storage
      if (_imageFile != null) {
        print("Đang tải lên file ảnh mới...");
        final uploadedImageUrl = await _uploadImage();

        // Nếu tải lên thành công, cập nhật URL ảnh
        if (uploadedImageUrl != null) {
          finalImageUrl = uploadedImageUrl;
          print("Đã tải ảnh lên thành công, URL mới: $finalImageUrl");
        } else {
          print("Tải ảnh lên thất bại, giữ nguyên URL cũ: $finalImageUrl");
        }
      } else {
        print("Không có file ảnh mới, sử dụng URL hiện tại: $finalImageUrl");
      }

      // Chuyển đổi giá và số lượng kho từ text sang số
      final double price = double.parse(
        _priceController.text.replaceAll(',', '.'),
      );
      final int stock = int.parse(_stockController.text);

      // Tạo đối tượng Product với thông tin đã nhập
      final Product product = Product(
        id: widget.productToEdit?.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: price,
        stock: stock,
        soldQuantity: widget.productToEdit?.soldQuantity ?? 0,
        importedQuantity: widget.productToEdit?.importedQuantity ?? 0,
        imageUrl: finalImageUrl,
        description: _descriptionController.text.trim(),
      );

      // Lấy provider để thực hiện thêm/cập nhật sản phẩm
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Thêm mới hoặc cập nhật sản phẩm tùy thuộc vào tình huống
      if (widget.productToEdit == null) {
        print("Đang thêm sản phẩm mới...");
        await productProvider.addProduct(product);
        print("Đã thêm sản phẩm thành công");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm sản phẩm thành công')),
        );
      } else {
        print("Đang cập nhật sản phẩm...");
        await productProvider.updateProduct(product);
        print("Đã cập nhật sản phẩm thành công");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật sản phẩm thành công')),
        );
      }

      // Quay lại màn hình trước đó với kết quả thành công
      Navigator.pop(context, true);
    } catch (e) {
      // Ghi log lỗi chi tiết để debug
      print("Lỗi khi lưu sản phẩm: $e");
      if (e is FirebaseException) {
        print("Mã lỗi Firebase: ${e.code}");
        print("Thông điệp lỗi Firebase: ${e.message}");
      }

      // Cập nhật UI để hiển thị lỗi
      setState(() {
        _errorMessage = 'Lỗi khi lưu sản phẩm: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.productToEdit == null
              ? 'Thêm sản phẩm mới'
              : 'Chỉnh sửa sản phẩm',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phần chọn và hiển thị hình ảnh
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            _imageFile != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : _imageUrl.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                )
                                : const Center(
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _isUploading ? null : _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hiển thị thanh tiến trình tải lên (nếu đang tải)
                if (_isUploading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(value: _uploadProgress),
                        const SizedBox(height: 4),
                        Text(
                          'Đang tải ảnh lên: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Tên sản phẩm
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên sản phẩm';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Phần chọn danh mục - Đã sửa để tránh lỗi setState trong build
                Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    // Nếu đang tải danh mục, hiển thị spinner
                    if (_isLoadingCategories) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    // Nếu không có danh mục nào, hiển thị thông báo
                    if (categoryProvider.categories.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Không có danh mục nào. Vui lòng thêm danh mục trước.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Điều hướng đến trang thêm danh mục
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCategoryPage(),
                                  ),
                                ).then((_) => _fetchCategories());
                              },
                              child: const Text('Thêm'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Xác định giá trị hiện tại cho dropdown - KHÔNG gọi setState ở đây
                    String currentValue = _selectedCategory;
                    bool isValidCategory = categoryProvider.categories.any(
                      (cat) => cat.name == _selectedCategory,
                    );

                    // Nếu danh mục đã chọn không hợp lệ, sử dụng danh mục đầu tiên
                    if (!isValidCategory &&
                        categoryProvider.categories.isNotEmpty) {
                      currentValue = categoryProvider.categories.first.name;
                    }

                    // Hiển thị dropdown với danh sách danh mục
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Danh mục',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      value: currentValue,
                      items:
                          categoryProvider.categories.map((category) {
                            return DropdownMenuItem(
                              value: category.name,
                              child: Text(category.name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng chọn danh mục';
                        }
                        return null;
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Giá sản phẩm
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Giá (VNĐ)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập giá sản phẩm';
                    }

                    // Kiểm tra giá trị có phải là số hợp lệ không
                    final double? price = double.tryParse(
                      value.replaceAll(',', '.'),
                    );
                    if (price == null) {
                      return 'Giá không hợp lệ';
                    }
                    if (price <= 0) {
                      return 'Giá phải lớn hơn 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Số lượng kho
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng kho',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số lượng kho';
                    }

                    // Kiểm tra số lượng có phải là số nguyên hợp lệ không
                    final int? stock = int.tryParse(value);
                    if (stock == null) {
                      return 'Số lượng không hợp lệ';
                    }
                    if (stock < 0) {
                      return 'Số lượng không được âm';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Mô tả sản phẩm
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả sản phẩm',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 80),
                      child: Icon(Icons.description),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Thông báo lỗi (nếu có)
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Nút lưu
                ElevatedButton(
                  onPressed:
                      _isProcessing || _isUploading || _isLoadingCategories
                          ? null
                          : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.blue.withOpacity(0.5),
                  ),
                  child:
                      _isProcessing
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Đang xử lý...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                          : Text(
                            widget.productToEdit == null
                                ? 'Thêm sản phẩm'
                                : 'Cập nhật sản phẩm',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
