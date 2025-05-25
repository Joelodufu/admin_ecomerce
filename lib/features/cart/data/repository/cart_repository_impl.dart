import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_datasource.dart';
import '../model/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartDataSource dataSource;

  CartRepositoryImpl(this.dataSource);

  @override
  Future<void> addToCart(CartItem cartItem) async {
    await dataSource.addToCart(cartItem as CartItemModel);
  }

  @override
  Future<List<CartItem>> getCart() async {
    return await dataSource.getCart();
  }

  @override
  Future<void> removeFromCart(int productId) async {
    await dataSource.removeFromCart(productId);
  }

  @override
  Future<void> clearCart() async {
    await dataSource.clearCart();
  }
}
