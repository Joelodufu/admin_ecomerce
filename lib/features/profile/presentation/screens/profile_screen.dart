import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../product/presentation/screens/home_screen.dart';
import '../../../product/presentation/screens/products_screen.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile? profile;
  bool _isRailExpanded = false;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    // Defer the loading until after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    try {
      final getProfile = GetProfile(
        Provider.of<ProfileRepository>(context, listen: false),
      );
      final loadedProfile = await getProfile();
      setState(() {
        profile = loadedProfile;
        _profileError = null;
      });
    } catch (e) {
      setState(() {
        _profileError = 'Error loading profile: $e';
      });
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
        isSelected: false,
      ),
      NavigationDestination(
        icon: Icons.person,
        label: 'Profile',
        route: const ProfileScreen(),
        isSelected: true,
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
        selectedIndex: 3,
        onDestinationSelected: (index) {
          if (index != 3) {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    // Show snackbar for error if it exists
    if (_profileError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_profileError!)));
        _profileError = null; // Reset error after showing
      });
    }

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontSize: isMobile ? 20 : 24),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout), onPressed: () {}),
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
      body:
          profile == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: isMobile ? 50 : 70,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          size: isMobile ? 50 : 70,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: isMobile ? 20 : 24),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${profile!.name}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontSize: isMobile ? 16 : 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Email: ${profile!.email}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontSize: isMobile ? 16 : 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Phone: ${profile!.phone}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontSize: isMobile ? 16 : 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Implement edit profile functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: isMobile ? 14 : 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
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
