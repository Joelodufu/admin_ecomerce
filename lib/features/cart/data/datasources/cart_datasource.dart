import '../model/cart_item_model.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/domain/entities/product.dart';

abstract class CartDataSource {
  Future<void> addToCart(CartItemModel cartItem);
  Future<List<CartItemModel>> getCart();
  Future<void> removeFromCart(int productId);
  Future<void> clearCart();
}

class CartDataSourceImpl implements CartDataSource {
  final List<CartItemModel> _cartItems = [];

  @override
  Future<void> addToCart(CartItemModel cartItem) async {
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.product.id == cartItem.product.id,
    );
    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex] = CartItemModel(
        product:
            cartItem.product
                as ProductModel, // Ensure product is a ProductModel
        quantity: _cartItems[existingItemIndex].quantity + cartItem.quantity,
      );
    } else {
      // If cartItem.product is a Product, convert it to ProductModel
      final productModel =
          cartItem.product is ProductModel
              ? cartItem.product as ProductModel
              : ProductModel(
                id: cartItem.product.id,
                rating: cartItem.product.rating,
                discountRate: cartItem.product.discountRate,
                name: cartItem.product.name,
                price: cartItem.product.price,
                description: cartItem.product.description,
                images: cartItem.product.images,
              );
      _cartItems.add(
        CartItemModel(product: productModel, quantity: cartItem.quantity),
      );
    }
  }

  @override
  Future<List<CartItemModel>> getCart() async {
    return List.unmodifiable(_cartItems);
  }

  @override
  Future<void> removeFromCart(int productId) async {
    _cartItems.removeWhere((item) => item.product.id == productId);
  }

  @override
  Future<void> clearCart() async {
    _cartItems.clear();
  }
}
