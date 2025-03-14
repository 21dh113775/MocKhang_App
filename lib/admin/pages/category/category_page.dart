import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'add_category_page.dart';
import 'edit_category_page.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // Định nghĩa các màu nâu để sử dụng trong ứng dụng
  final Color primaryBrown = Color(0xFF8D6E63); // Màu nâu chính
  final Color darkBrown = Color(0xFF5D4037); // Màu nâu đậm
  final Color lightBrown = Color(0xFFD7CCC8); // Màu nâu nhạt
  final Color accentBrown = Color(0xFFA1887F); // Màu nâu nhấn

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Quản lý Danh mục",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: darkBrown,
            elevation: 2,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, lightBrown.withOpacity(0.3)],
              ),
            ),
            child:
                categoryProvider.categories.isEmpty
                    ? Center(
                      child: Text(
                        "Không có danh mục nào.",
                        style: TextStyle(
                          fontSize: 16,
                          color: darkBrown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: categoryProvider.categories.length,
                      itemBuilder: (context, index) {
                        final category = categoryProvider.categories[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: accentBrown, width: 1),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: darkBrown,
                                fontSize: 16,
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: primaryBrown,
                              child: Text(
                                category.name.isNotEmpty
                                    ? category.name
                                        .substring(0, 1)
                                        .toUpperCase()
                                    : "?",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: primaryBrown),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EditCategoryPage(
                                              category: category,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red[700],
                                  ),
                                  onPressed: () {
                                    // Kiểm tra xem id có tồn tại không trước khi xử lý
                                    if (category.id != null) {
                                      // Sử dụng toán tử ! vì đã kiểm tra null
                                      _confirmDelete(
                                        context,
                                        categoryProvider,
                                        category
                                            .id!, // Thêm ! để chuyển từ int? sang int
                                      );
                                    } else {
                                      // Hiển thị thông báo lỗi nếu id là null
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Không thể xóa: ID danh mục không hợp lệ',
                                          ),
                                          backgroundColor: Colors.red[700],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCategoryPage()),
              );
            },
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: primaryBrown,
            tooltip: "Thêm danh mục",
            elevation: 4,
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CategoryProvider provider,
    int categoryId, // Giữ là int không nullable
  ) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Xóa danh mục",
              style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Bạn có chắc muốn xóa danh mục này không?",
              style: TextStyle(color: Colors.black87),
            ),
            backgroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Hủy", style: TextStyle(color: accentBrown)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.deleteCategory(categoryId);
                  Navigator.pop(context, true);

                  // Hiển thị thông báo xóa thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa danh mục thành công'),
                      backgroundColor: primaryBrown,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text("Xóa"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
    );
  }
}
