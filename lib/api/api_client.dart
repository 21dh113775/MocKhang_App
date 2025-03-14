// // api_client.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:mockhang_app/admin/data/models/product_model.dart';

// class ApiClient {
//   final String baseUrl;

//   ApiClient({required this.baseUrl});

//   Future<List<Product>> fetchProducts() async {
//     final response = await http.get(Uri.parse('$baseUrl/api/products'));

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       return data.map((json) => Product.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load products');
//     }
//   }

//   Future<Product> getProduct(int id) async {
//     final response = await http.get(Uri.parse('$baseUrl/api/products/$id'));

//     if (response.statusCode == 200) {
//       return Product.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to load product');
//     }
//   }

//   Future<Product> createProduct(Product product) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/api/products'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(product.toJson()),
//     );

//     if (response.statusCode == 201) {
//       return Product.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to create product');
//     }
//   }

//   Future<bool> updateProduct(Product product) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/api/products/${product.id}'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(product.toJson()),
//     );

//     return response.statusCode == 204;
//   }

//   Future<bool> deleteProduct(int id) async {
//     final response = await http.delete(Uri.parse('$baseUrl/api/products/$id'));
//     return response.statusCode == 204;
//   }

//   Future<bool> updateStock(int id, int stock, int sold, int imported) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/api/products/$id/stock'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'stock': stock,
//         'soldQuantity': sold,
//         'importedQuantity': imported,
//       }),
//     );

//     return response.statusCode == 204;
//   }

//   Future<String?> uploadImage(File image) async {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$baseUrl/api/products/upload'),
//     );

//     request.files.add(await http.MultipartFile.fromPath('file', image.path));

//     var response = await request.send();

//     if (response.statusCode == 200) {
//       final respStr = await response.stream.bytesToString();
//       final jsonData = json.decode(respStr);
//       return jsonData['imageUrl'];
//     }
//     return null;
//   }
// }
