import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/product_model.dart';

abstract class ProductDataSource {
  Future<List<ProductModel>> getProducts({String? category, String? search});
  Future<ProductModel> getProductById(int id);
  Future<List<String>> getCategories();

  // CRUD methods
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(int id);
}

class ProductDataSourceImpl implements ProductDataSource {
  final http.Client client;

  ProductDataSourceImpl(this.client);

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
  }) async {
    final Map<String, String> queryParams = {};
    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/products',
    ).replace(queryParameters: queryParams);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/products/$id');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ProductModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load product with ID $id');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    final uri = Uri.parse('${AppConstants.baseUrl}/products/categories');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.cast<String>();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // --- CRUD IMPLEMENTATIONS ---

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/products');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ProductModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to create product');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/products/${product.id}');
    final response = await client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ProductModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to update product');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/products/$id');
    final response = await client.delete(uri);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }
}
