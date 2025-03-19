import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mockhang_app/user/pages/home/productsection/product_detail_page_user.dart'; // Import trang chi tiết sản phẩm
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Thêm cached network image để tải ảnh

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra và yêu cầu quyền truy cập bộ nhớ
    _requestPermissions();

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng'), elevation: 0),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            return _buildEmptyCart(context);
          }
          return Column(
            children: [
              _buildSelectAllSection(context, cartProvider),
              Expanded(child: _buildCartItemsList(context, cartProvider)),
              _buildCartSummary(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  // Hàm yêu cầu quyền truy cập bộ nhớ
  Future<void> _requestPermissions() async {
    // Yêu cầu quyền truy cập bộ nhớ
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      print("Permission granted");
    } else {
      print("Permission denied");
    }
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Giỏ hàng trống', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng của bạn',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/user_home");
            },
            child: const Text('Tiếp tục mua sắm'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectAllSection(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    bool allSelected = cartProvider.items.every((item) => item.isSelected);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            onChanged: (value) {
              cartProvider.selectAll(value ?? false);
            },
          ),
          const Text('Chọn tất cả'),
          const Spacer(),
          TextButton.icon(
            onPressed:
                cartProvider.items.isEmpty
                    ? null
                    : () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Xác nhận'),
                              content: const Text(
                                'Bạn có muốn xóa tất cả sản phẩm đã chọn?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    for (var item in List.from(
                                      cartProvider.items,
                                    )) {
                                      if (item.isSelected) {
                                        cartProvider.removeItem(
                                          item.product.id,
                                        );
                                      }
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                      );
                    },
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text('Xóa đã chọn'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(BuildContext context, CartProvider cartProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: cartProvider.items.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final cartItem = cartProvider.items[index];
            return _buildResponsiveCartItemTile(
              context,
              cartItem,
              cartProvider,
              constraints.maxWidth,
            );
          },
        );
      },
    );
  }

  Widget _buildResponsiveCartItemTile(
    BuildContext context,
    CartItem cartItem,
    CartProvider cartProvider,
    double availableWidth,
  ) {
    bool isNarrow = availableWidth < 360;

    if (isNarrow) {
      return _buildCompactCartItemTile(context, cartItem, cartProvider);
    } else {
      return _buildCartItemTile(context, cartItem, cartProvider);
    }
  }

  Widget _buildCompactCartItemTile(
    BuildContext context,
    CartItem cartItem,
    CartProvider cartProvider,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: cartItem.product),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: cartItem.isSelected,
              onChanged: (value) {
                cartProvider.toggleItemSelection(cartItem.product.id);
              },
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(6),
                ),
                child:
                    cartItem.product.imageUrl.isNotEmpty
                        ? Image.file(
                          File(
                            cartItem.product.imageUrl,
                          ), // Hiển thị ảnh từ tệp
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                            );
                          },
                        )
                        : const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Danh mục: ${cartItem.product.category}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 18,
              ),
              onPressed: () {
                cartProvider.removeItem(cartItem.product.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemTile(
    BuildContext context,
    CartItem cartItem,
    CartProvider cartProvider,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: cartItem.product),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: cartItem.isSelected,
                onChanged: (value) {
                  cartProvider.toggleItemSelection(cartItem.product.id);
                },
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(6),
                ),
                child:
                    cartItem.product.imageUrl.isNotEmpty
                        ? Image.file(
                          File(
                            cartItem.product.imageUrl,
                          ), // Hiển thị ảnh từ tệp
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                            );
                          },
                        )
                        : const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
              ),
            ),

            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Danh mục: ${cartItem.product.category}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${cartItem.product.price.toStringAsFixed(0)} VNĐ',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (cartItem.quantity > 1) {
                                cartProvider.decreaseQuantity(
                                  cartItem.product.id,
                                );
                              }
                            },
                          ),
                          Text(
                            '${cartItem.quantity}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              cartProvider.increaseQuantity(
                                cartItem.product.id,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () {
                cartProvider.removeItem(cartItem.product.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tạm tính'),
              Text('${cartProvider.subtotal.toStringAsFixed(0)} VNĐ'),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                cartProvider.hasSelectedItems
                    ? () {
                      // Sử dụng Future.microtask để đảm bảo việc điều hướng xảy ra sau khi build hoàn tất
                      Future.microtask(() {
                        Navigator.pushNamed(context, '/checkout');
                      });
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Mua ngay'),
          ),
        ],
      ),
    );
  }
}
