import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/adminscreen.dart';
import 'package:mockhang_app/admin/pages/product/product_page.dart';
import 'package:mockhang_app/auth/login_screen.dart';
import 'package:mockhang_app/auth/signup_screen.dart';
import 'package:mockhang_app/user/pages/cart/cart_page.dart';
import 'package:mockhang_app/user/pages/categories_page.dart';
import 'package:mockhang_app/user/pages/consultation_page.dart';
import 'package:mockhang_app/user/pages/discount_page_user.dart';
import 'package:mockhang_app/user/pages/home/home_screen.dart';
import 'package:mockhang_app/user/pages/product_detail_page_user.dart';
import 'package:mockhang_app/user/pages/product_page.dart';

Map<String, WidgetBuilder> appRoutes = {
  "/login": (context) => LoginScreen(),
  "/register": (context) => SignupScreen(),
  "/admin_home": (context) => AdminHomeScreen(),
  "/user_home": (context) => HomeScreen(),
  "/products": (context) => ProductPage(),
  "/products_user": (context) => ProductPageUser(),
  "/categories": (context) => CategoriesPage(),
  "/discount": (context) => DiscountPageUser(),
  "/cart": (context) => CartPage(),
  "/consultation": (context) => ConsultationPage(),
};
