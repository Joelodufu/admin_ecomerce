class Product {
  final int id;
  final int rating;
  final int discountRate;
  final String name;
  final double price;
  final String description;
  final List<String> images;

  Product({
    required this.id,
    required this.rating,
    required this.discountRate,
    required this.name,
    required this.price,
    required this.description,
    required this.images,
  });
}