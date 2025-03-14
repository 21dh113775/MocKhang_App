import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/consultation_request.dart';
import 'package:mockhang_app/admin/data/service/consultation_service.dart';
import 'package:uuid/uuid.dart';

class ConsultationPage extends StatefulWidget {
  @override
  _ConsultationPageState createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedTopic = 'Sản phẩm';
  bool _isSubmitting = false;

  final List<String> _consultationTopics = [
    'Sản phẩm',
    'Đơn hàng',
    'Thanh toán',
    'Vận chuyển',
    'Khác',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tư Vấn"), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề và mô tả
              Text(
                "Chúng tôi luôn sẵn sàng hỗ trợ bạn",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                "Vui lòng điền thông tin bên dưới, chúng tôi sẽ liên hệ lại với bạn trong thời gian sớm nhất.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 24),

              // Form tư vấn
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chủ đề tư vấn",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedTopic,
                          items:
                              _consultationTopics.map((topic) {
                                return DropdownMenuItem<String>(
                                  value: topic,
                                  child: Text(topic),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTopic = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Họ tên
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Họ và tên",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập họ tên';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Số điện thoại
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: "Số điện thoại",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          bool emailValid = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value);
                          if (!emailValid) {
                            return 'Email không hợp lệ';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Nội dung
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: "Nội dung cần tư vấn",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập nội dung cần tư vấn';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Nút gửi
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _isSubmitting
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate()) {
                                    _submitConsultationRequest();
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isSubmitting
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  "Gửi yêu cầu tư vấn",
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Thông tin liên hệ trực tiếp
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hoặc liên hệ trực tiếp",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      _buildContactItem(Icons.phone, "Hotline", "1900 xxxx xx"),
                      _buildContactItem(
                        Icons.email,
                        "Email",
                        "support@company.com",
                      ),
                      _buildContactItem(
                        Icons.access_time,
                        "Giờ làm việc",
                        "8:00 - 17:30 (Thứ 2 - Thứ 6)",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(content),
            ],
          ),
        ],
      ),
    );
  }

  void _submitConsultationRequest() {
    setState(() {
      _isSubmitting = true;
    });

    // Tạo yêu cầu mới
    final newRequest = ConsultationRequest(
      id: Uuid().v4(), // Tạo ID ngẫu nhiên
      topic: _selectedTopic,
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      message: _messageController.text,
      timestamp: DateTime.now(),
    );

    // Gửi yêu cầu lên service
    ConsultationService.addRequest(newRequest)
        .then((_) {
          setState(() {
            _isSubmitting = false;
          });

          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Yêu cầu tư vấn của bạn đã được gửi thành công!'),
              backgroundColor: Colors.green,
            ),
          );

          // Reset form
          _nameController.clear();
          _phoneController.clear();
          _emailController.clear();
          _messageController.clear();
          setState(() {
            _selectedTopic = 'Sản phẩm';
          });
        })
        .catchError((error) {
          // Xử lý lỗi nếu có
          setState(() {
            _isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Có lỗi xảy ra. Vui lòng thử lại sau.'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
