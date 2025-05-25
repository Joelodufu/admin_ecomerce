import '../../domain/entities/carousel_item.dart';

class CarouselItemModel extends CarouselItem {
  CarouselItemModel({
    int? productId, // Nullable int
    required String imageUrl,
  }) : super(productId: productId, imageUrl: imageUrl);

  factory CarouselItemModel.fromJson(Map<String, dynamic> json) {
    // Explicitly handle null and convert to int if possible
    final productId = json['productId'];
    return CarouselItemModel(
      productId: productId == null ? null : productId as int, // Safe cast with null check
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'imageUrl': imageUrl,
    };
  }
}