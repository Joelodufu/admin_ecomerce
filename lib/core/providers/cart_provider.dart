import 'package:flutter/material.dart';
import '../../features/cart/domain/entities/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  double get totalPrice => _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  void addToCart(CartItem cartItem) {
    final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == cartItem.product.id);
    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex] = CartItem(
        product: cartItem.product,
        quantity: _cartItems[existingItemIndex].quantity + cartItem.quantity,
      );
    } else {
      _cartItems.add(cartItem);
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}