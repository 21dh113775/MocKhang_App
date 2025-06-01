import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';
import 'dart:io';

class CategoryItemCard extends StatelessWidget {
  final Category category;

  const CategoryItemCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Phần hiển thị hình ảnh
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color:
                  category.imageUrl == null
                      ? Colors.brown.withOpacity(0.1)
                      : Colors.transparent,
            ),
            child: _buildCategoryImage(),
          ),

          const SizedBox(height: 12),

          // Tên danh mục
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.brown[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryImage() {
    // Nếu không có ảnh, hiển thị icon
    if (category.imageUrl == null) {
      return Center(
        child: Icon(Icons.category_rounded, size: 50, color: Colors.brown),
      );
    }

    // Nếu là đường link mạng
    if (category.imageUrl!.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          category.imageUrl!,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: Colors.brown,
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(Icons.error_outline, color: Colors.red, size: 50),
            );
          },
        ),
      );
    }

    // Nếu là file local
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.file(
        File(category.imageUrl!),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.error_outline, color: Colors.red, size: 50),
          );
        },
      ),
    );
  }
}
