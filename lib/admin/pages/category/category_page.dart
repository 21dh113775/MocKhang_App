import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'add_category_page.dart';
import 'edit_category_page.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // Màu sắc chủ đạo mới
  final Color primaryColor = Color(0xFF2C3E50);
  final Color secondaryColor = Color(0xFF34495E);
  final Color accentColor = Color(0xFF3498DB);
  final Color backgroundColor = Color(0xFFF5F5F5);
  final Color textColor = Color(0xFF2C3E50);

  // Debounce cho tìm kiếm
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tải danh mục với microtask để tránh làm chậm khởi tạo UI
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });

    // Theo dõi thay đổi tìm kiếm với debounce
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Debounce tìm kiếm để tránh quá nhiều rebuild
  void _onSearchChanged() {
    if (!_isSearching) {
      _isSearching = true;
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _searchQuery = _searchController.text;
            _isSearching = false;
          });
        }
      });
    }
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
            tooltip: 'Lọc danh mục',
          ),
        ],
      ),

      // Nền gradient tinh tế
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.05), backgroundColor],
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
                  if (categoryProvider.isLoading) {
                    return _buildLoadingIndicator();
                  }

                  // Sử dụng computed value để tránh tính toán lại khi rebuild
                  final filteredCategories = _getFilteredCategories(
                    categoryProvider.categories,
                  );

                  if (filteredCategories.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Sử dụng ListView.builder có key để tránh rebuild không cần thiết
                  return ListView.builder(
                    key: PageStorageKey('category_list'),
                    padding: EdgeInsets.all(16),
                    itemCount: filteredCategories.length,
                    // Tối ưu render với cacheExtent
                    cacheExtent: 100,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      // Tối ưu bằng cách thêm key cho mỗi card
                      return _buildCategoryCard(
                        category,
                        context,
                        key: ValueKey(category.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Nút thêm danh mục với hiệu ứng nổi bật
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddCategory(context),
        icon: Icon(Icons.add_circle_outline, color: Colors.white),
        label: Text(
          'Thêm Danh Mục',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: accentColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Tối ưu tìm kiếm bằng computed value
  List<Category> _getFilteredCategories(List<Category> categories) {
    if (_searchQuery.isEmpty) return categories;

    return categories
        .where(
          (category) =>
              category.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  // Thanh tìm kiếm với hiệu ứng cải tiến
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          // Thêm shadow nhẹ
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
        ),
        style: TextStyle(color: textColor),
        cursorColor: accentColor,
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
    );
  }

  // Hiệu ứng tải được cải tiến
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            strokeWidth: 3,
          ).animate().scale(duration: 500.ms, curve: Curves.easeInOut),
          SizedBox(height: 16),
          Text(
            'Đang tải danh mục...',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  // Trạng thái khi không có danh mục - cải tiến
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 100,
            color: primaryColor.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            'Không có danh mục nào',
            style: TextStyle(
              fontSize: 22,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Bạn chưa có danh mục nào. Hãy thêm danh mục đầu tiên bằng nút bên dưới.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddCategory(context),
            icon: Icon(Icons.add_circle),
            label: Text('Thêm Danh Mục Mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card danh mục với thiết kế hiện đại và tối ưu
  Widget _buildCategoryCard(
    Category category,
    BuildContext context, {
    Key? key,
  }) {
    return Card(
      key: key,
      elevation: 4,
      shadowColor: primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToEditCategory(context, category),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar danh mục
              Hero(
                tag: 'category_image_${category.id}',
                child: _buildCategoryAvatar(category),
              ),
              SizedBox(width: 16),

              // Thông tin danh mục
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID: ${category.id}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  _buildActionButton(
                    icon: Icons.edit,
                    color: accentColor,
                    tooltip: 'Chỉnh sửa',
                    onPressed: () => _navigateToEditCategory(context, category),
                  ),
                  // Delete button
                  _buildActionButton(
                    icon: Icons.delete,
                    color: Colors.redAccent,
                    tooltip: 'Xóa danh mục',
                    onPressed: () => _confirmDeleteCategory(context, category),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05);
  }

  // Widget nút hành động được tối ưu hóa
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }

  // Avatar danh mục được cải tiến với CachedNetworkImage
  Widget _buildCategoryAvatar(Category category) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor.withOpacity(0.1),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child:
            category.imageUrl != null
                ? category.imageUrl!.startsWith('http')
                    ? CachedNetworkImage(
                      imageUrl: category.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildAvatarPlaceholder(),
                      errorWidget: (context, url, error) => _buildAvatarError(),
                    )
                    : Image.file(
                      File(category.imageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => _buildAvatarError(),
                    )
                : _buildAvatarPlaceholder(),
      ),
    );
  }

  // Placeholder khi không có hình ảnh
  Widget _buildAvatarPlaceholder() {
    return Container(
      color: primaryColor.withOpacity(0.1),
      child: Icon(Icons.category_rounded, color: primaryColor, size: 35),
    );
  }

  // Hiển thị khi lỗi hình ảnh
  Widget _buildAvatarError() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.broken_image_rounded,
        color: Colors.grey[600],
        size: 30,
      ),
    );
  }

  // Dialog xác nhận xóa được cải tiến
  void _confirmDeleteCategory(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text('Xóa Danh Mục'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bạn có chắc muốn xóa danh mục:'),
                SizedBox(height: 8),
                Text(
                  '"${category.name}"',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 12),
                Text(
                  'Hành động này không thể hoàn tác.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy', style: TextStyle(color: Colors.grey[800])),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Xóa danh mục
                  Provider.of<CategoryProvider>(
                    context,
                    listen: false,
                  ).deleteCategory(category.id!);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.delete_outline),
                label: Text('Xóa'),
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

  // Bottom sheet lọc được cải tiến
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.filter_list, color: primaryColor),
                    SizedBox(width: 10),
                    Text(
                      'Lọc Danh Mục',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(),
                _buildFilterOption(
                  icon: Icons.sort_by_alpha,
                  title: 'Sắp xếp theo tên',
                  onTap: () {
                    // Xử lý sắp xếp ở đây
                    Navigator.pop(context);
                  },
                ),
                _buildFilterOption(
                  icon: Icons.calendar_today,
                  title: 'Sắp xếp theo ngày tạo',
                  onTap: () {
                    // Xử lý sắp xếp ở đây
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Reset filter
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Áp dụng'),
                ),
              ],
            ),
          ),
    );
  }

  // Widget tùy chọn lọc
  Widget _buildFilterOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
