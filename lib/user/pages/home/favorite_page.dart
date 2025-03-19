import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/providers/favorite_provider.dart';
import 'package:mockhang_app/user/pages/product_item_card.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              _showClearConfirmDialog(context);
            },
            tooltip: 'Xóa tất cả',
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          final favoriteItems = favoriteProvider.favoriteItems; // Sửa ở đây

          if (favoriteItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Danh sách yêu thích trống',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy thêm sản phẩm vào danh sách yêu thích',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/user_home');
                    },
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Xem sản phẩm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteItems.length, // Sửa ở đây
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final product = favoriteItems[index]; // Sửa ở đây
              return Dismissible(
                key: Key(product.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await _showDeleteConfirmDialog(context, product.name);
                },
                onDismissed: (direction) {
                  favoriteProvider.toggleFavorite(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.grey.shade800,
                      content: Row(
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Đã xóa ${product.name} khỏi danh sách yêu thích',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: ProductItemCard(product: product),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _showDeleteConfirmDialog(
    BuildContext context,
    String productName,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Xác nhận xóa'),
                content: Text(
                  'Bạn có chắc muốn xóa "$productName" khỏi danh sách yêu thích?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('HỦY'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'XÓA',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _showClearConfirmDialog(BuildContext context) async {
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    if (favoriteProvider.favoriteItems.isEmpty) {
      // Sửa ở đây
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Danh sách yêu thích đã trống')),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa tất cả'),
            content: const Text(
              'Bạn có chắc muốn xóa tất cả sản phẩm khỏi danh sách yêu thích?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('HỦY'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'XÓA TẤT CẢ',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (result == true) {
      favoriteProvider.clearFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.grey.shade800,
          content: const Row(
            children: [
              Icon(Icons.delete_sweep, color: Colors.white),
              SizedBox(width: 10),
              Text('Đã xóa tất cả sản phẩm khỏi danh sách yêu thích'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
