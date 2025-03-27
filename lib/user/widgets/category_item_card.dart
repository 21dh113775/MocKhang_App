import 'package:flutter/material.dart';
import 'package:mockhang_app/admin/data/models/category_model.dart';

import 'dart:io';

class CategoryItemCard extends StatelessWidget {
  final Category category;

  const CategoryItemCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hỗ trợ cả đường dẫn network và local
          category.imageUrl != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    category.imageUrl!.startsWith('http')
                        ? Image.network(
                          category.imageUrl!,
                          fit: BoxFit.cover,
                          height: 60,
                          width: 60,
                        )
                        : Image.file(
                          File(category.imageUrl!),
                          fit: BoxFit.cover,
                          height: 60,
                          width: 60,
                        ),
              )
              : Icon(Icons.category_rounded, size: 40, color: Colors.brown),
          const SizedBox(height: 8),
          Text(
            category.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
