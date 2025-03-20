import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockhang_app/admin/adminscreen.dart';
import 'package:mockhang_app/admin/data/data_sources/category_db.dart';
import 'package:mockhang_app/admin/data/data_sources/product_db.dart';
import 'package:mockhang_app/admin/data/repositories/category_repository.dart';
import 'package:mockhang_app/admin/data/repositories/product_repository.dart';
import 'package:mockhang_app/admin/pages/notifications_page_admin.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:mockhang_app/admin/providers/discount_provider.dart';
import 'package:mockhang_app/admin/providers/favorite_provider.dart';
import 'package:mockhang_app/admin/providers/order_provider.dart';
import 'package:mockhang_app/admin/providers/product_provider.dart';
import 'package:mockhang_app/admin/providers/user_provider.dart';
import 'package:mockhang_app/auth/auth_service.dart';
import 'package:mockhang_app/auth/login_screen.dart';
import 'package:mockhang_app/auth/signup_screen.dart';
import 'package:mockhang_app/user/pages/account_page_user.dart';
import 'package:mockhang_app/user/pages/cart/cart_page.dart';
import 'package:mockhang_app/user/pages/checkout/checkout_page.dart';
import 'package:mockhang_app/user/pages/consultation_page.dart';
import 'package:mockhang_app/user/pages/home/favorite_page.dart';
import 'package:mockhang_app/user/pages/home/home_screen.dart';
import 'package:mockhang_app/user/pages/categories_page.dart';
import 'package:mockhang_app/user/pages/discount/discount_page_user.dart';
import 'package:mockhang_app/admin/pages/product/product_page.dart';
import 'package:mockhang_app/user/pages/notifications_page_user.dart';
import 'package:mockhang_app/user/pages/product_page.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Lazily initialize providers to avoid build-phase issues
Future<void> initializeProviders() async {
  // Initialize database instances first
  final productDatabase = ProductDatabase.instance;
  final categoryDatabase = CategoryDatabase.instance;

  // For ProductDatabase, access the database property
  await productDatabase.database;

  // For CategoryDatabase, there's no need to initialize anything explicitly
  // since it already initializes Firestore in its constructor
  // You could call a lightweight method to ensure it's ready
  await categoryDatabase.fetchCategories();

  // Pre-initialize UserProvider to avoid build-phase issues
  final userProvider = UserProvider();
  await userProvider.initialize();

  return;
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize databases and providers before runApp
  await initializeProviders();

  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (context) =>
                  ProductProvider(ProductRepository(ProductDatabase.instance)),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create:
              (context) => CategoryProvider(
                CategoryRepository(CategoryDatabase.instance),
              ),
        ),
        ChangeNotifierProvider(create: (context) => DiscountProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        // Initialize UserProvider lazily to prevent build-phase notifications
        ChangeNotifierProvider(
          create: (_) {
            final provider = UserProvider();
            // Initialize in the next frame to avoid build-phase notifications
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.initialize();
            });
            return provider;
          },
        ),
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
      theme: _customTheme(),
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
        buttonColor: Colors.brown,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.brown,
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
  "/cart": (context) => CartPage(),
  "/products_user": (context) => ProductPageUser(),
  "/consultation": (context) => ConsultationPage(),
  "/checkout": (context) => CheckoutPage(),
  "/favorite": (context) => FavoritePage(),
  "/account_page":
      (context) => AccountPageUser(), // Fixed route name with slash
  // Thêm route cho các trang Notifications
  "/notifications_admin": (context) => NotificationsPageAdmin(),
  "/notifications": (context) => NotificationsPageUser(),
};

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  // Hàm kiểm tra quyền admin của người dùng
  Future<void> checkAdminStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String? idToken = await user.getIdToken();

        if (idToken != null) {
          // Kiểm tra quyền admin nếu idToken không phải là null
          if (idToken.contains('admin')) {
            print("User is an admin");
          } else {
            print("User is not an admin");
          }
        } else {
          print("ID Token is null");
        }
      }
    } catch (e) {
      print("Error checking admin status: $e");
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    // Access UserProvider with listen: false to avoid rebuild loops
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).initialize();
    });

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
