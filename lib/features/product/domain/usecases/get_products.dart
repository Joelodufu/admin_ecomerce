import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> call({String? category, String? search}) async {
    return await repository.getProducts(category: category, search: search);
  }
}
