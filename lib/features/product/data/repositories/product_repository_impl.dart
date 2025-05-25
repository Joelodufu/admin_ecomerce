import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Future<List<Product>> getProducts({String? category, String? search}) async {
    final productModels = await dataSource.getProducts(
      category: category,
      search: search,
    );
    return productModels;
  }

  @override
  Future<Product> getProductById(int id) async {
    final productModel = await dataSource.getProductById(id);
    return productModel;
  }

  @override
  Future<List<String>> getCategories() async {
    return await dataSource.getCategories();
  }
}
