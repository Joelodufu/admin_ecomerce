import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../product/presentation/screens/home_screen.dart';
import '../../../product/presentation/screens/products_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isRailExpanded = false;

  void _buyAll(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.cartItems;

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty!')));
      return;
    }

    final String phoneNumber = AppConstants.whatsappNumber;
    String message = 'Hello, I want to buy the following items:\n\n';

    for (var cartItem in cartItems) {
      message +=
          'Product: ${cartItem.product.name}\n'
          'REF: ${cartItem.product.id}\n'
          'Price: ₦${cartItem.product.price}\n'
          'Quantity: ${cartItem.quantity}\n'
          'Description: ${cartItem.product.description}\n'
          'Image: ${cartItem.product.images.isNotEmpty ? cartItem.product.images[0] : 'No image available'}\n\n\n';
    }

    message +=
        'Total: ₦${cartProvider.totalPrice.toStringAsFixed(2)}\n\nPlease confirm the order!';

    final String encodedMessage = Uri.encodeComponent(message);
    final String whatsappUrl =
        'https://wa.me/$phoneNumber?text=$encodedMessage';

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  Widget _buildNavigation(
    BuildContext context, {
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final destinations = [
      NavigationDestination(
        icon: Icons.home,
        label: 'Home',
        route: const HomeScreen(),
        isSelected: false,
      ),
      NavigationDestination(
        icon: Icons.store,
        label: 'Products',
        route: const ProductsScreen(),
        isSelected: false,
      ),
      NavigationDestination(
        icon: Icons.shopping_cart,
        label: 'Cart',
        route: const CartScreen(),
        isSelected: true,
      ),
      NavigationDestination(
        icon: Icons.person,
        label: 'Profile',
        route: const ProfileScreen(),
        isSelected: false,
      ),
    ];

    if (isMobile) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.computer,
                    size: 40,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Oltron Store',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ...destinations.map(
              (dest) => ListTile(
                leading: Icon(dest.icon),
                title: Text(
                  dest.label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                selected: dest.isSelected,
                onTap: () {
                  Navigator.pop(context);
                  if (!dest.isSelected) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => dest.route),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return NavigationRail(
        extended: isDesktop || (isTablet && _isRailExpanded),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index != 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => destinations[index].route,
              ),
            );
          }
        },
        leading: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.computer,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  if (isDesktop || _isRailExpanded) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Oltron Store',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isTablet)
              IconButton(
                icon: Icon(
                  _isRailExpanded ? Icons.arrow_left : Icons.arrow_right,
                ),
                onPressed: () {
                  setState(() {
                    _isRailExpanded = !_isRailExpanded;
                  });
                },
              ),
          ],
        ),
        destinations:
            destinations
                .map(
                  (dest) => NavigationRailDestination(
                    icon: Icon(dest.icon),
                    label: Text(dest.label),
                    selectedIcon: Icon(
                      dest.icon,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                )
                .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontSize: isMobile ? 20 : 24),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chat), onPressed: () {}),
        ],
        automaticallyImplyLeading: isMobile,
      ),
      drawer:
          isMobile
              ? _buildNavigation(
                context,
                isMobile: true,
                isTablet: false,
                isDesktop: false,
              )
              : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                if (cartItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Your cart is empty!',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                else
                  Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartItems[index];
                          return Card(
                            margin: EdgeInsets.all(isMobile ? 8.0 : 12.0),
                            child: ListTile(
                              leading: CachedNetworkImage(
                                imageUrl:
                                    cartItem.product.images.isNotEmpty
                                        ? cartItem.product.images[0]
                                        : 'https://via.placeholder.com/50',
                                width: isMobile ? 50 : 70,
                                height: isMobile ? 50 : 70,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error),
                              ),
                              title: Text(
                                cartItem.product.name,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontSize: isMobile ? 14 : 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '₦${cartItem.product.price} x ${cartItem.quantity}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                  Text(
                                    'Total: ₦${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  cartProvider.removeFromCart(
                                    cartItem.product.id,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontSize: isMobile ? 18 : 20),
                                ),
                                Text(
                                  '₦${cartProvider.totalPrice.toStringAsFixed(2)}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontSize: isMobile ? 18 : 20,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _buyAll(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      'Buy All',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        fontSize: isMobile ? 14 : 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      cartProvider.clearCart();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Cart cleared!'),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      'Clear Cart',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        fontSize: isMobile ? 14 : 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );

    return isMobile
        ? scaffold
        : Row(
          children: [
            _buildNavigation(
              context,
              isMobile: false,
              isTablet: isTablet,
              isDesktop: isDesktop,
            ),
            Expanded(child: scaffold),
          ],
        );
  }
}

class NavigationDestination {
  final IconData icon;
  final String label;
  final Widget route;
  final bool isSelected;

  NavigationDestination({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
  });
}
