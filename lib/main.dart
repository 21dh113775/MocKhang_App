import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockhang_app/admin/adminscreen.dart';
import 'package:mockhang_app/admin/data/data_sources/category_db.dart';
import 'package:mockhang_app/admin/data/data_sources/product_db.dart';
import 'package:mockhang_app/admin/data/repositories/category_repository.dart';
import 'package:mockhang_app/admin/data/repositories/product_repository.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:mockhang_app/auth/auth_service.dart';
import 'package:mockhang_app/auth/login_screen.dart';
import 'package:mockhang_app/auth/signup_screen.dart';
import 'package:mockhang_app/user/pages/home_screen.dart';
import 'package:mockhang_app/user/pages/categories_page.dart';
import 'package:mockhang_app/user/pages/discount_page_user.dart';
import 'package:mockhang_app/admin/pages/product/product_page.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final productDatabase = ProductDatabase.instance;
  final categoryDatabase = CategoryDatabase.instance;
  await productDatabase.database;
  await categoryDatabase.database;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (context) => ProductProvider(ProductRepository(productDatabase)),
        ),
        ChangeNotifierProvider(
          create:
              (context) =>
                  CategoryProvider(CategoryRepository(categoryDatabase)),
        ),
        ChangeNotifierProvider(create: (context) => DiscountProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mockhang App',
      debugShowCheckedModeBanner: false,
      theme: _customTheme(), // Apply the custom theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/login',
      routes: appRoutes,
    );
  }

  // Custom theme definition
  ThemeData _customTheme() {
    return ThemeData(
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.brown, // Brown button color
        textTheme: ButtonTextTheme.primary, // White text on the button
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.brown, // Text color
        ),
      ),
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.brown,
      ).copyWith(background: Colors.white),
    );
  }
}

Map<String, WidgetBuilder> appRoutes = {
  "/login": (context) => LoginScreen(),
  "/register": (context) => SignupScreen(),
  "/admin_home": (context) => AdminHomeScreen(),
  "/user_home": (context) => HomeScreen(),
  "/products": (context) => ProductPage(),
  "/categories": (context) => CategoriesPage(),
  "/discount": (context) => DiscountPageUser(),
};

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;

          if (user == null) {
            return const LoginScreen();
          }

          if (_authService.isLocalAdminLoggedIn) {
            return AdminHomeScreen();
          }

          return FutureBuilder<bool>(
            future: _authService.isCurrentUserAdmin(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.done) {
                if (adminSnapshot.data == true) {
                  return AdminHomeScreen();
                } else {
                  return const HomeScreen();
                }
              }

              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang tải dữ liệu...'),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang kết nối đến hệ thống...'),
              ],
            ),
          ),
        );
      },
    );
  }
}
