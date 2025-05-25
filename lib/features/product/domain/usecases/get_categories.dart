import '../repositories/product_repository.dart';

class GetCategories {
  final ProductRepository repository;

  GetCategories(this.repository);

  Future<List<String>> call() async {
    return await repository.getCategories();
  }
}
