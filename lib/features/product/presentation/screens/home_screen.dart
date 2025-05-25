import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/widgets/discount_badge.dart';
import '../../../../core/widgets/rating_widget.dart';
import '../../../carousel/domain/entities/carousel_item.dart';
import '../../../carousel/domain/repositories/carousel_repository.dart';
import '../../../carousel/domain/usecases/get_carousel_items.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_products.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../presentation/screens/products_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

final logger = Logger();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  List<CarouselItem> carouselItems = [];
  List<String> categories = [];
  String? selectedCategory;
  final TextEditingController searchController = TextEditingController();
  bool _isShiftRightPressed = false;
  bool _isRailExpanded = false;
  String? _categoryError;
  String? _productsError;
  String? _carouselError;
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    searchController
        .dispose(); // Dispose of the controller to prevent memory leaks
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.wait([
        _loadCategories(),
        _loadProducts(),
        _loadCarouselItems(),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final getCategories = GetCategories(
        Provider.of<ProductRepository>(context, listen: false),
      );
      final loadedCategories = await getCategories();
      if (mounted) {
        setState(() {
          categories = loadedCategories;
          _categoryError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoryError = 'Error loading categories: $e';
        });
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      final getProducts = GetProducts(
        Provider.of<ProductRepository>(context, listen: false),
      );
      final loadedProducts = await getProducts(
        category: selectedCategory,
        search: searchController.text.isEmpty ? null : searchController.text,
      );
      if (mounted) {
        setState(() {
          products = loadedProducts;
          _productsError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _productsError = 'Error loading products: $e';
        });
      }
    }
  }

  Future<void> _loadCarouselItems() async {
    try {
      final getCarouselItems = GetCarouselItems(
        Provider.of<CarouselRepository>(context, listen: false),
      );
      final loadedCarouselItems = await getCarouselItems();
      if (mounted) {
        setState(() {
          carouselItems = loadedCarouselItems;
          _carouselError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carouselError = 'Error loading carousel items: $e';
        });
      }
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
        isSelected: true,
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
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index != 0) {
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
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
                .toList(),
      );
    }
  }

  // Skeleton widget for the carousel
  Widget _buildCarouselSkeleton(bool isMobile, double adsWidth) {
    return Container(
      width: adsWidth,
      margin: EdgeInsets.all(isMobile ? 8.0 : 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: isMobile ? 150.0 : 200.0,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  // Skeleton widget for the categories
  Widget _buildCategoriesSkeleton(bool isMobile) {
    return SizedBox(
      height: isMobile ? 80 : 100,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5, // Simulate 5 categories
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: isMobile ? 24 : 28,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Container(width: 50, height: 12, color: Colors.grey),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Skeleton widget for the product grid
  Widget _buildProductGridSkeleton(bool isMobile, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isMobile ? 8.0 : 12.0,
        mainAxisSpacing: isMobile ? 8.0 : 12.0,
        childAspectRatio: 0.65,
      ),
      itemCount: crossAxisCount * 2, // Simulate 2 rows of products
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final crossAxisCount =
        isMobile
            ? 2
            : isTablet
            ? 3
            : 4;
    final avatarRadius = isMobile ? 24.0 : 32.0;
    final adsWidth = isMobile ? screenWidth : screenWidth * 0.8;

    if (_categoryError != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_categoryError!)));
        _categoryError = null;
      });
    }
    if (_productsError != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_productsError!)));
        _productsError = null;
      });
    }
    if (_carouselError != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_carouselError!)));
        _carouselError = null;
      });
    }

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(
          'Oltron Store',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontSize: isMobile ? 20 : 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearchDelegate());
            },
          ),
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
            child:
                _isLoading
                    ? Column(
                      children: [
                        // Skeleton for Carousel
                        _buildCarouselSkeleton(isMobile, adsWidth),
                        // Skeleton for Categories
                        _buildCategoriesSkeleton(isMobile),
                        // Skeleton for Product Grid
                        _buildProductGridSkeleton(isMobile, crossAxisCount),
                      ],
                    )
                    : Column(
                      children: [
                        // Carousel Advert Section
                        if (carouselItems.isNotEmpty)
                          Container(
                            width: adsWidth,
                            margin: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: isMobile ? 150.0 : 200.0,
                                enlargeCenterPage: false,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 3),
                                viewportFraction: 0.9,
                                aspectRatio: 16 / 9,
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                scrollDirection: Axis.horizontal,
                              ),
                              items:
                                  carouselItems.map((carouselItem) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return GestureDetector(
                                          onTap:
                                              carouselItem.productId != null
                                                  ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => ProductDetailScreen(
                                                              productId:
                                                                  carouselItem
                                                                      .productId!,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                  : null,
                                          child: Container(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 5.0,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: CachedNetworkImage(
                                                imageUrl: carouselItem.imageUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                placeholder:
                                                    (
                                                      context,
                                                      url,
                                                    ) => const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                        // Categories Section
                        SizedBox(
                          height: isMobile ? 80 : 100,
                          child: Center(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16.0 : 24.0,
                              ),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 8.0 : 12.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedCategory =
                                            selectedCategory == category
                                                ? null
                                                : category;
                                        _loadProducts();
                                      });
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: isMobile ? 24 : 28,
                                          backgroundColor:
                                              selectedCategory == category
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.secondary
                                                  : Colors.grey.shade200,
                                          child: Icon(
                                            category == 'Laptop'
                                                ? Icons.computer
                                                : category == 'RAM'
                                                ? Icons
                                                    .data_thresholding_rounded
                                                : category == 'Processor'
                                                ? Icons.memory
                                                : category == 'Battery'
                                                ? Icons.battery_0_bar
                                                : Icons.videocam,
                                            color:
                                                selectedCategory == category
                                                    ? Theme.of(
                                                      context,
                                                    ).colorScheme.onSecondary
                                                    : Colors.grey,
                                            size: isMobile ? 20 : 26,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          category,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelMedium?.copyWith(
                                            fontSize: isMobile ? 12 : 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Product Grid Section
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: isMobile ? 8.0 : 12.0,
                                mainAxisSpacing: isMobile ? 8.0 : 12.0,
                                childAspectRatio: 0.65,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final double discount = 0.2;
                            final double rating = 3.0;
                            final double discountedPrice =
                                product.price * (1 - discount);

                            return ProductCard(
                              product: product,
                              discount: discount,
                              rating: rating,
                              discountedPrice: discountedPrice,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProductDetailScreen(
                                          productId: product.id,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
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

class ProductSearchDelegate extends SearchDelegate {
  ProductSearchDelegate();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final crossAxisCount =
        isMobile
            ? 2
            : isTablet
            ? 3
            : 4;

    return FutureBuilder<List<Product>>(
      future: GetProducts(
        Provider.of<ProductRepository>(context, listen: false),
      )(search: query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final products = snapshot.data!;
          return GridView.builder(
            padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: isMobile ? 8.0 : 12.0,
              mainAxisSpacing: isMobile ? 8.0 : 12.0,
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final double discount = 0.2;
              final double rating = 3.0;
              final double discountedPrice = product.price * (1 - discount);

              return ProductCard(
                product: product,
                discount: discount,
                rating: rating,
                discountedPrice: discountedPrice,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProductDetailScreen(productId: product.id),
                    ),
                  );
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
