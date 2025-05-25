import '../entities/carousel_item.dart';

abstract class CarouselRepository {
  Future<List<CarouselItem>> getCarouselItems();
}
