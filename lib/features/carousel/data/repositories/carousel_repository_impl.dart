import '../../domain/entities/carousel_item.dart';
import '../../domain/repositories/carousel_repository.dart';
import '../datasources/carousel_datasource.dart';
import '../models/carousel_item_model.dart';

class CarouselRepositoryImpl implements CarouselRepository {
  final CarouselDataSource dataSource;

  CarouselRepositoryImpl(this.dataSource);

  @override
  Future<List<CarouselItem>> getCarouselItems() async {
    final carouselModels = await dataSource.getCarouselItems();
    return carouselModels;
  }
}
