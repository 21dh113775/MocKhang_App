import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockhang_app/admin/adminscreen.dart';
import 'package:mockhang_app/auth/auth_service.dart';
import 'package:mockhang_app/auth/forgot_password_screen.dart';
import 'package:mockhang_app/auth/signup_screen.dart';
import 'package:mockhang_app/user/pages/home_screen.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart'; // Thêm thư viện animated_snack_bar

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';
  bool _databaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    setState(() {
      _isLoading = true;
      _errorMessage = 'Đang khởi tạo dữ liệu...';
    });

    try {
      // Khởi tạo DB và đảm bảo có tài khoản admin
      await _authService.dbHelper.database;

      // Debug: Lấy danh sách admin
      List<Map<String, dynamic>> admins =
          await _authService.dbHelper.getAllAdmins();
      debugPrint('Admin accounts available: $admins');

      setState(() {
        _databaseInitialized = true;
        _errorMessage = '';
      });
    } catch (e) {
      debugPrint('Error initializing database: $e');
      setState(() {
        _errorMessage = 'Lỗi khởi tạo: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _navigateToAppropriateScreen() async {
    try {
      if (_authService.isLocalAdminLoggedIn) {
        debugPrint('Đăng nhập thành công với vai trò admin (local)');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminHomeScreen()),
          (route) => false,
        );
        return;
      }

      bool isAdmin = await _authService.isCurrentUserAdmin();
      if (isAdmin) {
        debugPrint('Đăng nhập thành công với vai trò admin');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminHomeScreen()),
          (route) => false,
        );
      } else {
        debugPrint('Đăng nhập thành công với vai trò người dùng');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi chuyển hướng: $e');
      _showErrorSnackBar('Có lỗi xảy ra khi tải dữ liệu. Vui lòng thử lại.');
    }
  }

  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'operation-not-allowed':
        return 'Đăng nhập bằng email và mật khẩu không được bật.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
      default:
        return 'Đăng nhập thất bại. Vui lòng thử lại.';
    }
  }

  void _showErrorSnackBar(String message) {
    AnimatedSnackBar.material(
      message,
      type: AnimatedSnackBarType.error,
      duration: const Duration(seconds: 3),
    ).show(context);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_databaseInitialized) {
      _showErrorSnackBar('Hệ thống đang khởi tạo. Vui lòng thử lại sau.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      debugPrint('Attempting login with: $email');

      if (email == 'admin@gmail.com') {
        debugPrint('Admin login attempt detected');

        if (kDebugMode) {
          debugPrint('Admin credentials: Email=$email, Password=$password');
        }

        bool success = await _authService.signInAsLocalAdmin(email, password);
        debugPrint('Admin login result: $success');

        if (success) {
          if (mounted) {
            await _navigateToAppropriateScreen();
          }
          return;
        }
      }

      await _authService.signInWithEmailAndPassword(email, password);
      if (mounted) {
        await _navigateToAppropriateScreen();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Lỗi FirebaseAuth: ${e.code}');
      setState(() {
        _errorMessage = _getMessageFromErrorCode(e.code);
      });
      _showErrorSnackBar(_errorMessage);
    } catch (e) {
      debugPrint('Lỗi không xác định: $e');
      setState(() {
        _errorMessage = 'Đăng nhập thất bại: ${e.toString()}';
      });
      _showErrorSnackBar(_errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    // Chuyển đến trang ForgotPasswordScreen thay vì xử lý trực tiếp
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  // Sử dụng logo nếu có
                  child: Image.asset('assets/logo-mockhang.png', height: 220),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mộc Khang Xin Chào!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Nhập email của bạn',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    hintText: 'Nhập mật khẩu của bạn',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: const Text('Quên mật khẩu?'),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.brown, // Chữ màu trắng
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Text(
                            'ĐĂNG NHẬP',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
                const SizedBox(height: 16),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text('Đăng ký'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
