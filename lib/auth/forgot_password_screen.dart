// forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;

  // Định nghĩa các màu chính
  final Color primaryBrown = const Color.fromARGB(
    255,
    52,
    24,
    4,
  ); // Màu nâu chính
  final Color lightBrown = const Color(0xFFD2B48C); // Màu nâu nhạt
  final Color backgroundWhite = Colors.white;
  final Color accentBrown = const Color.fromARGB(
    255,
    93,
    42,
    27,
  ); // Màu nâu đậm hơn cho accent

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = '';
        _isSuccess = false;
      });

      try {
        await _authService.resetPassword(_emailController.text.trim());
        setState(() {
          _message =
              'Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hộp thư của bạn.';
          _isSuccess = true;
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          _message =
              e.code == 'user-not-found'
                  ? 'Không tìm thấy tài khoản với email này.'
                  : 'Có lỗi xảy ra. Vui lòng thử lại sau.';
          _isSuccess = false;
        });
      } catch (e) {
        setState(() {
          _message = 'Có lỗi xảy ra. Vui lòng thử lại sau.';
          _isSuccess = false;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Quên mật khẩu',
          style: TextStyle(color: backgroundWhite, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBrown,
        elevation: 0,
        iconTheme: IconThemeData(color: backgroundWhite),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: backgroundWhite,
          image: DecorationImage(
            image: AssetImage('assets/texture_bg.png'), // Thêm texture nếu có
            opacity: 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_reset, size: 100, color: primaryBrown),
                  const SizedBox(height: 40),
                  Text(
                    'Đặt lại mật khẩu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryBrown,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nhập email của bạn để nhận hướng dẫn đặt lại mật khẩu',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: accentBrown),
                  ),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: accentBrown),
                      hintText: 'Nhập địa chỉ email của bạn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: lightBrown),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: lightBrown, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: primaryBrown, width: 2),
                      ),
                      prefixIcon: Icon(Icons.email, color: primaryBrown),
                      filled: true,
                      fillColor: Colors.brown.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                    ),
                    style: TextStyle(color: accentBrown),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      // Kiểm tra định dạng email
                      final bool emailValid = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      ).hasMatch(value);
                      if (!emailValid) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  if (_message.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color:
                            _isSuccess
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              _isSuccess
                                  ? Colors.green.shade200
                                  : Colors.red.shade200,
                        ),
                      ),
                      child: Text(
                        _message,
                        style: TextStyle(
                          color:
                              _isSuccess
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      foregroundColor: backgroundWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: backgroundWhite,
                                strokeWidth: 2.5,
                              ),
                            )
                            : const Text(
                              'GỬI HƯỚNG DẪN ĐẶT LẠI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: accentBrown,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Quay lại đăng nhập',
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryBrown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Thêm hình trang trí ở dưới
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/logo.png', // Thay bằng asset phù hợp nếu có
                    height: 70,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
