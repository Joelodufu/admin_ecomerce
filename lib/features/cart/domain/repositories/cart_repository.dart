import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<void> addToCart(CartItem cartItem);
  Future<List<CartItem>> getCart();
  Future<void> removeFromCart(int productId);
  Future<void> clearCart();
}
