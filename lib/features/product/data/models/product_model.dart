import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required int id,
    required int rating,
    required int stock,
    required int discountRate,
    required String name,
    required double price,
    required String description,
    required List<String> images,
  }) : super(
         id: id,
         name: name,
         stock: stock,
         rating: rating,
         discountRate: discountRate,
         price: price,
         description: description,
         images: images,
       );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      rating: json['rating'],
      stock: json['stock'],
      discountRate: json['discountRate'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      images: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'stock': stock,
      'discountRate': discountRate,
      'name': name,
      'price': price,
      'description': description,
      'images': images,
    };
  }
}
