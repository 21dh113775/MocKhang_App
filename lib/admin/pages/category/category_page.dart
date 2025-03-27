import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'add_category_page.dart';
import 'edit_category_page.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // Định nghĩa bảng màu sắc chủ đạo
  final Color primaryColor = Color.fromARGB(255, 103, 66, 6); // Màu tím chính
  final Color secondaryColor = Color.fromARGB(190, 139, 81, 5); // Màu xanh mint
  final Color backgroundColor = Color(0xFFF5F5F5); // Màu nền nhạt
  final Color textColor = Color.fromARGB(255, 0, 0, 0); // Màu văn bản chính

  // Trạng thái tìm kiếm và lọc
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Tải danh mục ngay khi trang được khởi tạo
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thanh ứng dụng với thiết kế hiện đại
      appBar: AppBar(
        title: Text(
          'Quản Lý Danh Mục',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded),
            onPressed: _showFilterOptions,
          ),
        ],
      ),

      // Nền gradient mềm mại
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.1), backgroundColor],
          ),
        ),
        child: Column(
          children: [
            // Thanh tìm kiếm với hiệu ứng
            _buildSearchBar(),

            // Danh sách danh mục
            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  // Xử lý trạng thái tải và hiển thị
                  if (categoryProvider.isLoading) {
                    return _buildLoadingIndicator();
                  }

                  // Lọc danh mục theo từ khóa tìm kiếm
                  final filteredCategories =
                      categoryProvider.categories
                          .where(
                            (category) => category.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();

                  // Hiển thị danh sách rỗng nếu không có kết quả
                  if (filteredCategories.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Danh sách danh mục với hiệu ứng animation
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      return _buildCategoryCard(category, context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Nút thêm danh mục nổi bật
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddCategory(context),
        icon: Icon(Icons.add_circle_outline, color: Colors.white),
        label: Text('Thêm Danh Mục', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 10,
      ),
    );
  }

  // Thanh tìm kiếm với hiệu ứng
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm danh mục...',
          prefixIcon: Icon(Icons.search, color: primaryColor),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: primaryColor),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
    );
  }

  // Hiệu ứng tải
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          SizedBox(height: 16),
          Text('Đang tải danh mục...', style: TextStyle(color: textColor)),
        ],
      ),
    );
  }

  // Trạng thái khi không có danh mục
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 100,
            color: primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'Không có danh mục nào',
            style: TextStyle(
              fontSize: 18,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hãy thêm danh mục đầu tiên của bạn',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  // Card danh mục với thiết kế chi tiết
  Widget _buildCategoryCard(Category category, BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: _buildCategoryAvatar(category),
        title: Text(
          category.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        // subtitle: Text(
        //   'Số lượng sản phẩm: ${category.productCount ?? 0}', // Giả sử có trường này
        //   style: TextStyle(color: Colors.grey),
        // ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nút chỉnh sửa
            IconButton(
              icon: Icon(Icons.edit, color: secondaryColor),
              onPressed: () => _navigateToEditCategory(context, category),
            ),
            // Nút xóa
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteCategory(context, category),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }

  // Avatar danh mục linh hoạt
  Widget _buildCategoryAvatar(Category category) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
        image:
            category.imageUrl != null
                ? DecorationImage(
                  image:
                      category.imageUrl!.startsWith('http')
                          ? NetworkImage(category.imageUrl!)
                          : FileImage(File(category.imageUrl!))
                              as ImageProvider,
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child:
          category.imageUrl == null
              ? Icon(Icons.category, color: primaryColor, size: 30)
              : null,
    );
  }

  // Hiển thị dialog xác nhận xóa
  void _confirmDeleteCategory(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xóa Danh Mục'),
            content: Text('Bạn có chắc muốn xóa danh mục "${category.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  // Xóa danh mục
                  Provider.of<CategoryProvider>(
                    context,
                    listen: false,
                  ).deleteCategory(category.id!);
                  Navigator.pop(context);
                },
                child: Text('Xóa'),
              ),
            ],
          ),
    );
  }

  // Các phương thức điều hướng
  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCategoryPage()),
    );
  }

  void _navigateToEditCategory(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryPage(category: category),
      ),
    );
  }

  // Hiển thị các tùy chọn lọc
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lọc Danh Mục',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Thêm các tùy chọn lọc ở đây
              ],
            ),
          ),
    );
  }
}
