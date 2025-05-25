class CarouselItem {
  final int? productId; // Nullable int
  final String imageUrl;

  CarouselItem({
    required this.productId, // Updated to accept int?
    required this.imageUrl,
  });
}
