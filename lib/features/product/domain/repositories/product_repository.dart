import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({String? category, String? search});
  Future<Product> getProductById(int id);
  Future<List<String>> getCategories();
}
