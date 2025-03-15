// user/pages/home/sections/search_bar.dart
import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  final Function(String)? onSubmitted;

  const HomeSearchBar({Key? key, this.onSubmitted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: Icon(Icons.filter_list, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.brown[300]!, width: 1),
          ),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
