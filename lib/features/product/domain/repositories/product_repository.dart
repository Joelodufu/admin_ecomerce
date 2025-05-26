import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({String? category, String? search});
  Future<Product> getProductById(int id);
  Future<List<String>> getCategories();

  // Add CRUD methods
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}
