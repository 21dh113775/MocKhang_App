import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm package để định dạng tiền
import 'package:permission_handler/permission_handler.dart';
import 'package:mockhang_app/user/pages/home/productsection/product_detail_page_user.dart';
import 'package:provider/provider.dart';
import 'package:mockhang_app/admin/data/models/cart_model.dart';
import 'package:mockhang_app/admin/providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  // Hàm định dạng tiền tệ
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return "${formatter.format(amount)} ₫";
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra và yêu cầu quyền truy cập bộ nhớ
    _requestPermissions();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
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
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng của bạn',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/user_home");
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Tiếp tục mua sắm'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Theme(
            data: ThemeData(
              checkboxTheme: CheckboxThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            child: Checkbox(
              value: allSelected,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                cartProvider.selectAll(value ?? false);
              },
            ),
          ),
          const Text(
            'Chọn tất cả',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
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
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProductDetailPage(product: cartItem.product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: cartItem.isSelected,
                activeColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (value) {
                  cartProvider.toggleItemSelection(cartItem.product.id);
                },
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      cartItem.product.imageUrl.isNotEmpty
                          ? Image.file(
                            File(cartItem.product.imageUrl),
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
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(cartItem.product.price),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
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
      ),
    );
  }

  Widget _buildCartItemTile(
    BuildContext context,
    CartItem cartItem,
    CartProvider cartProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProductDetailPage(product: cartItem.product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: cartItem.isSelected,
                  activeColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (value) {
                    cartProvider.toggleItemSelection(cartItem.product.id);
                  },
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      cartItem.product.imageUrl.isNotEmpty
                          ? (cartItem.product.imageUrl.startsWith('http')
                              ? CachedNetworkImage(
                                imageUrl: cartItem.product.imageUrl,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                              )
                              : Image.file(
                                File(cartItem.product.imageUrl),
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
                              ))
                          : const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                ),
              ),

              const SizedBox(width: 12),
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
                    const SizedBox(height: 4),
                    Text(
                      'Danh mục: ${cartItem.product.category}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatCurrency(cartItem.product.price),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (cartItem.quantity > 1) {
                                    cartProvider.decreaseQuantity(
                                      cartItem.product.id,
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(Icons.remove, size: 16),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  cartProvider.increaseQuantity(
                                    cartItem.product.id,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(Icons.add, size: 16),
                                ),
                              ),
                            ],
                          ),
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
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tạm tính:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                formatCurrency(cartProvider.subtotal),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                cartProvider.hasSelectedItems
                    ? () {
                      Future.microtask(() {
                        Navigator.pushNamed(context, '/checkout');
                      });
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Mua ngay',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
