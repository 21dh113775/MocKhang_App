// import 'package:flutter/material.dart';
// import 'package:mockhang_app/user/pages/cart/utils/constants.dart';
// import 'package:mockhang_app/user/pages/cart/utils/formatters.dart';
// import 'package:provider/provider.dart';
// import 'package:mockhang_app/admin/data/models/cart_model.dart';
// import 'package:mockhang_app/admin/providers/cart_provider.dart';
// // Đường dẫn chính xác đến hộp thoại xóa sản phẩm
// import 'package:mockhang_app/user/pages/cart/dialog/delete_item_dialog.dart';

// class CartItemTile extends StatelessWidget {
//   final CartItem item;
//   final VoidCallback onSelectionChanged;

//   const CartItemTile({
//     Key? key,
//     required this.item,
//     required this.onSelectionChanged,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final cartProvider = Provider.of<CartProvider>(context);
//     for (var item in cartProvider.items) {
//       print(
//         "CartItemList - Item: ${item.product.name}, ImageURL: ${item.product.imageUrl}",
//       );
//     }
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Checkbox chọn sản phẩm
//             Checkbox(
//               value: item.isSelected,
//               activeColor: AppColors.primaryColor,
//               onChanged: (value) {
//                 cartProvider.toggleItemSelection(item.product.id);
//                 onSelectionChanged();
//               },
//             ),

//             // Hình ảnh sản phẩm
//             _buildProductImage(),

//             const SizedBox(width: 12),

//             // Thông tin sản phẩm
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildProductInfo(),
//                   const SizedBox(height: 8),
//                   _buildQuantityControls(context, cartProvider),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductImage() {
//     print(
//       "Building image for ${item.product.name} with URL: ${item.product.imageUrl}",
//     );
//     print("URL is empty: ${item.product.imageUrl.isEmpty}");
//     print("URL parse result: ${Uri.tryParse(item.product.imageUrl)}");

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(8),
//       child: Image.network(
//         item.product.imageUrl,
//         width: 80,
//         height: 80,
//         fit: BoxFit.cover,
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Container(
//             width: 80,
//             height: 80,
//             color: Colors.grey[200],
//             child: Center(
//               child: CircularProgressIndicator(
//                 value:
//                     loadingProgress.expectedTotalBytes != null
//                         ? loadingProgress.cumulativeBytesLoaded /
//                             loadingProgress.expectedTotalBytes!
//                         : null,
//               ),
//             ),
//           );
//         },
//         errorBuilder: (ctx, err, _) {
//           print("Error loading image: $err");
//           return _placeholderImage();
//         },
//       ),
//     );
//   }

//   /// Ảnh mặc định khi không có hình ảnh sản phẩm
//   Widget _placeholderImage() {
//     return Container(
//       width: 80,
//       height: 80,
//       color: AppColors.accentColor,
//       child: const Icon(Icons.image_not_supported, color: Colors.grey),
//     );
//   }

//   /// Hiển thị thông tin sản phẩm
//   Widget _buildProductInfo() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           item.product.name,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           '${formatCurrency(item.product.price)} đ',
//           style: TextStyle(
//             color: AppColors.primaryColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   /// Điều khiển số lượng sản phẩm
//   Widget _buildQuantityControls(
//     BuildContext context,
//     CartProvider cartProvider,
//   ) {
//     return Row(
//       children: [
//         // Nút giảm số lượng
//         InkWell(
//           onTap:
//               item.quantity > 1
//                   ? () => cartProvider.decreaseQuantity(item.product.id)
//                   : null,
//           child: Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Icon(
//               Icons.remove,
//               size: 16,
//               color: item.quantity > 1 ? AppColors.primaryColor : Colors.grey,
//             ),
//           ),
//         ),

//         // Hiển thị số lượng
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
//           child: Text(
//             '${item.quantity}',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),

//         // Nút tăng số lượng
//         InkWell(
//           onTap: () => cartProvider.increaseQuantity(item.product.id),
//           child: Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Icon(Icons.add, size: 16, color: AppColors.primaryColor),
//           ),
//         ),

//         const Spacer(),

//         // Nút xóa sản phẩm
//         IconButton(
//           icon: const Icon(Icons.delete_outline, color: Colors.red),
//           onPressed: () => showDeleteItemDialog(context, item),
//         ),
//       ],
//     );
//   }
// }
