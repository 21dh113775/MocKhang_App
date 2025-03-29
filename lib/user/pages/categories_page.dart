import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'package:mockhang_app/admin/providers/category_provider.dart';
import 'package:mockhang_app/user/pages/category-products.dart';
import 'package:mockhang_app/user/widgets/category_item_card.dart';
import 'package:provider/provider.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    // Tải danh mục khi trang được load lần đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thanh tiêu đề
      appBar: AppBar(
        title: Text('Danh mục sản phẩm'),
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          // Hiển thị indicator loading khi đang tải danh mục
          if (categoryProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Colors.brown),
            );
          }

          // Hiển thị lỗi nếu có lỗi xảy ra
          if (categoryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Đã xảy ra lỗi khi tải danh mục',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    categoryProvider.error!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  SizedBox(height: 16),
                  // Nút thử lại khi tải danh mục bị lỗi
                  ElevatedButton.icon(
                    onPressed: () => categoryProvider.fetchCategories(),
                    icon: Icon(Icons.refresh),
                    label: Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          // Hiển thị trạng thái rỗng nếu không có danh mục
          if (categoryProvider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    color: Colors.grey[400],
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Không có danh mục nào',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Hiển thị danh mục trong lưới
          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Số cột trong lưới
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8, // Tỷ lệ chiều rộng so với chiều cao
            ),
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              final category = categoryProvider.categories[index];
              return GestureDetector(
                // Chuyển đến trang sản phẩm của danh mục khi nhấn
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CategoryProductsPage(category: category),
                    ),
                  );
                },
                // Hiển thị thẻ danh mục
                child: CategoryItemCard(category: category),
              );
            },
          );
        },
      ),
    );
  }
}
