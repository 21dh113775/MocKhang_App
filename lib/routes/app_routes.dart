import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/adminscreen.dart';
import 'package:mockhang_app/admin/pages/product/product_page.dart';
import 'package:mockhang_app/auth/login_screen.dart';
import 'package:mockhang_app/auth/signup_screen.dart';
import 'package:mockhang_app/user/pages/account_page_user.dart';
import 'package:mockhang_app/user/pages/cart/cart_page.dart';
import 'package:mockhang_app/user/pages/categories_page.dart';
import 'package:mockhang_app/user/pages/checkout/checkout_page.dart';
import 'package:mockhang_app/user/pages/checkout/order/order_history_page.dart';
import 'package:mockhang_app/user/pages/consultation_page.dart';
import 'package:mockhang_app/user/pages/discount/discount_page_user.dart';
import 'package:mockhang_app/user/pages/home/widget/favorite_page.dart';
import 'package:mockhang_app/user/pages/home/home_screen.dart';
import 'package:mockhang_app/user/pages/notifications_page_user.dart';
import 'package:mockhang_app/user/pages/product_page.dart';

Map<String, WidgetBuilder> appRoutes = {
  "/login": (context) => LoginScreen(),
  "/register": (context) => SignupScreen(),
  "/admin_home": (context) => AdminHomeScreen(),
  "/user_home": (context) => HomeScreen(),
  "/products": (context) => ProductPageAdmin(),
  "/categories": (context) => CategoriesPage(),
  "/discount": (context) => DiscountPageUser(),
  "/cart": (context) => CartPage(),
  "/products_user": (context) => ProductPageUser(),
  "/consultation": (context) => ConsultationPage(),
  "/checkout": (context) => CheckoutPage(),
  "/favorite": (context) => FavoritePage(), // Đảm bảo đã đăng ký route này
  "/account_page": (context) => AccountPageUser(),
  "/notifications": (context) => NotificationsPageUser(),
  "/order-history": (context) => OrderHistoryPage(),
};
