import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/discount_model.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class EditDiscountPage extends StatefulWidget {
  final String discountId;

  const EditDiscountPage({Key? key, required this.discountId})
    : super(key: key);

  @override
  _EditDiscountPageState createState() => _EditDiscountPageState();
}

class _EditDiscountPageState extends State<EditDiscountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();

  String _type = 'percentage';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  File? _imageFile;
  String? _imageUrl;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  DiscountModel? _discount;

  @override
  void initState() {
    super.initState();
    _loadDiscountData();
  }

  Future<void> _loadDiscountData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<DiscountProvider>(context, listen: false);
      final discount = await provider.getDiscount(widget.discountId);

      if (discount != null) {
        setState(() {
          _discount = discount;
          _nameController.text = discount.name;
          _type = discount.type;
          _valueController.text = discount.value.toString();
          _startDate = DateTime.fromMillisecondsSinceEpoch(discount.startDate);
          _endDate = DateTime.fromMillisecondsSinceEpoch(discount.endDate);
          _imageUrl = discount.imageUrl;
        });
      } else {
        setState(() {
          _error = 'Không tìm thấy khuyến mãi';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Trong thực tế, bạn sẽ cần upload ảnh lên server và lấy URL
      // _imageUrl = await uploadImageToServer(_imageFile);
      // Giả định rằng có một hàm uploadImageToServer để xử lý việc này

      // Giả định tạm thời, trong ứng dụng thực tế cần thay thế logic này
      _imageUrl = pickedFile.path;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // Cho phép chọn ngày trong quá khứ để chỉnh sửa
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Đảm bảo _endDate không sớm hơn _startDate
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (_discount == null) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Parse giá trị từ controller
        final double value = double.parse(
          _valueController.text.replaceAll(',', ''),
        );

        // Tạo model khuyến mãi cập nhật
        final updatedDiscount = _discount!.copyWith(
          name: _nameController.text.trim(),
          type: _type,
          value: value,
          startDate: _startDate.millisecondsSinceEpoch,
          endDate: _endDate.millisecondsSinceEpoch,
          imageUrl: _imageUrl,
        );

        // Cập nhật khuyến mãi
        await Provider.of<DiscountProvider>(
          context,
          listen: false,
        ).updateDiscount(updatedDiscount);

        // Quay lại trang trước
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật khuyến mãi thành công')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // Hiển thị thông báo lỗi
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa khuyến mãi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa khuyến mãi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa khuyến mãi')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên khuyến mãi
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên khuyến mãi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên khuyến mãi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Loại khuyến mãi
              const Text('Loại khuyến mãi', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'percentage',
                    label: Text('Giảm giá theo %'),
                    icon: Icon(Icons.percent),
                  ),
                  ButtonSegment(
                    value: 'fixed',
                    label: Text('Giảm giá cố định'),
                    icon: Icon(Icons.money),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                    // Xóa giá trị cũ khi đổi loại
                    _valueController.clear();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Giá trị khuyến mãi
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText:
                      _type == 'percentage'
                          ? 'Phần trăm giảm giá (%)'
                          : 'Số tiền giảm giá (VNĐ)',
                  border: const OutlineInputBorder(),
                  prefixIcon:
                      _type == 'percentage'
                          ? const Icon(Icons.percent)
                          : const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá trị';
                  }

                  final double? parsedValue = double.tryParse(
                    value.replaceAll(',', ''),
                  );
                  if (parsedValue == null) {
                    return 'Giá trị không hợp lệ';
                  }

                  if (_type == 'percentage' &&
                      (parsedValue <= 0 || parsedValue > 100)) {
                    return 'Phần trăm giảm giá phải từ 0-100%';
                  }

                  if (_type == 'fixed' && parsedValue <= 0) {
                    return 'Số tiền giảm giá phải lớn hơn 0';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ngày bắt đầu
              ListTile(
                title: const Text('Ngày bắt đầu'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 16),

              // Ngày kết thúc
              ListTile(
                title: const Text('Ngày kết thúc'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 16),

              // Hình ảnh khuyến mãi
              const Text(
                'Hình ảnh khuyến mãi (tùy chọn)',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      _imageFile != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                          : _imageUrl != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey.shade400,
                                      ),
                                      const Text('Ảnh không khả dụng'),
                                    ],
                                  ),
                            ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                              const Text('Nhấn để chọn ảnh'),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 24),

              // Nút cập nhật
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text(
                            'Cập nhật khuyến mãi',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
