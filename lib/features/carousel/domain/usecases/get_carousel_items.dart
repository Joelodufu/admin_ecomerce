import '../entities/carousel_item.dart';
import '../repositories/carousel_repository.dart';

class GetCarouselItems {
  final CarouselRepository repository;

  GetCarouselItems(this.repository);

  Future<List<CarouselItem>> call() async {
    return await repository.getCarouselItems();
  }
}
