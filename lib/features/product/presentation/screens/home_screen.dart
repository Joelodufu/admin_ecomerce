import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:data_table_2/data_table_2.dart';
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
  bool _isLoading = true;
  bool _isGridView = true;

  // Pagination & lazy loading state
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int _totalProducts = 0;
  bool _isFetchingMore = false;
  String _liveSearch = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _liveSearch = searchController.text;
      _currentPage = 0;
    });
    _loadProducts();
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

  Future<void> _loadProducts({bool append = false}) async {
    try {
      final getProducts = GetProducts(
        Provider.of<ProductRepository>(context, listen: false),
      );
      // Simulate backend pagination: fetch all, then slice
      final loadedProducts = await getProducts(
        category: selectedCategory,
        search: _liveSearch.isEmpty ? null : _liveSearch,
      );
      if (mounted) {
        setState(() {
          _totalProducts = loadedProducts.length;
          final start = _currentPage * _rowsPerPage;
          final end = (_currentPage + 1) * _rowsPerPage;
          products = loadedProducts.skip(start).take(_rowsPerPage).toList();
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

  void _onPageChanged(int pageIndex) async {
    setState(() {
      _currentPage = pageIndex;
      _isFetchingMore = true;
    });
    await _loadProducts();
    setState(() {
      _isFetchingMore = false;
    });
  }

  void _onRowsPerPageChanged(int? rows) async {
    if (rows == null) return;
    setState(() {
      _rowsPerPage = rows;
      _currentPage = 0;
      _isFetchingMore = true;
    });
    await _loadProducts();
    setState(() {
      _isFetchingMore = false;
    });
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

  // Show create product dialog
  Future<void> _showCreateProductDialog() async {
    await showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        onSubmit: (product) async {
          try {
            final repo = Provider.of<ProductRepository>(context, listen: false);
            await repo.createProduct(product);
            await _loadProducts();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product created successfully!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create product: $e')),
            );
          }
        },
      ),
    );
  }

  // Show update product dialog
  Future<void> _showUpdateProductDialog(Product product) async {
    await showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        product: product,
        onSubmit: (updatedProduct) async {
          try {
            final repo = Provider.of<ProductRepository>(context, listen: false);
            await repo.updateProduct(updatedProduct);
            await _loadProducts();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product updated successfully!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update product: $e')),
            );
          }
        },
      ),
    );
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final repo = Provider.of<ProductRepository>(context, listen: false);
        await repo.deleteProduct(product.id);
        await _loadProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product: $e')),
        );
      }
    }
  }

  @override
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
    final adsWidth = isMobile ? screenWidth : screenWidth * 0.8;

    // Modular error handler
    ErrorSnackbarHandler(
      categoryError: _categoryError,
      productsError: _productsError,
      carouselError: _carouselError,
      onClearCategoryError: () => setState(() => _categoryError = null),
      onClearProductsError: () => setState(() => _productsError = null),
      onClearCarouselError: () => setState(() => _carouselError = null),
      context: context,
    );

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(
          'Oltron Store',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: isMobile ? 20 : 24),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.table_rows : Icons.grid_view),
            tooltip: _isGridView ? 'Switch to Table View' : 'Switch to Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          SizedBox(
            width: isMobile ? 120 : 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Live Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  isDense: true,
                ),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chat), onPressed: () {}),
        ],
        automaticallyImplyLeading: isMobile,
      ),
      drawer: isMobile
          ? _buildNavigation(
              context,
              isMobile: true,
              isTablet: false,
              isDesktop: false,
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Create Product'),
        onPressed: _showCreateProductDialog,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: _isLoading
                ? Column(
                    children: [
                      _buildCarouselSkeleton(isMobile, adsWidth),
                      _buildCategoriesSkeleton(isMobile),
                      _buildProductGridSkeleton(isMobile, crossAxisCount),
                    ],
                  )
                : Column(
                    children: [
                      CarouselSection(
                        carouselItems: carouselItems,
                        adsWidth: adsWidth,
                        isMobile: isMobile,
                      ),
                      CategoriesSection(
                        categories: categories,
                        selectedCategory: selectedCategory,
                        isMobile: isMobile,
                        onCategoryTap: (category) {
                          setState(() {
                            selectedCategory = selectedCategory == category ? null : category;
                            _currentPage = 0;
                          });
                          _loadProducts();
                        },
                      ),
                      _isGridView
                          ? AdminProductGridSection(
                              products: products,
                              crossAxisCount: crossAxisCount,
                              isMobile: isMobile,
                              onEdit: _showUpdateProductDialog,
                              onDelete: _showDeleteConfirmation,
                            )
                          : AdminProductTableSectionPaginated(
                              products: products,
                              totalProducts: _totalProducts,
                              rowsPerPage: _rowsPerPage,
                              currentPage: _currentPage,
                              onPageChanged: _onPageChanged,
                              onRowsPerPageChanged: _onRowsPerPageChanged,
                              isLoading: _isFetchingMore,
                              onEdit: _showUpdateProductDialog,
                              onDelete: _showDeleteConfirmation,
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

// --- Modular Widgets ---

class CarouselSection extends StatelessWidget {
  final List<CarouselItem> carouselItems;
  final double adsWidth;
  final bool isMobile;

  const CarouselSection({
    super.key,
    required this.carouselItems,
    required this.adsWidth,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (carouselItems.isEmpty) return const SizedBox.shrink();
    return Container(
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
                                      (context) => ProductDetailScreen(
                                        productId: carouselItem.productId!,
                                      ),
                                ),
                              );
                            }
                            : null,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: carouselItem.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          errorWidget:
                              (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
      ),
    );
  }
}

class CategoriesSection extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final bool isMobile;
  final Function(String) onCategoryTap;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.isMobile,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isMobile ? 80 : 100,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 12.0),
              child: GestureDetector(
                onTap: () => onCategoryTap(category),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: isMobile ? 24 : 28,
                      backgroundColor:
                          selectedCategory == category
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey.shade200,
                      child: Icon(
                        category == 'Laptop'
                            ? Icons.computer
                            : category == 'RAM'
                            ? Icons.data_thresholding_rounded
                            : category == 'Processor'
                            ? Icons.memory
                            : category == 'Battery'
                            ? Icons.battery_0_bar
                            : Icons.videocam,
                        color:
                            selectedCategory == category
                                ? Theme.of(context).colorScheme.onSecondary
                                : Colors.grey,
                        size: isMobile ? 20 : 26,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
    );
  }
}

class ProductGridSection extends StatelessWidget {
  final List<Product> products;
  final int crossAxisCount;
  final bool isMobile;

  const ProductGridSection({
    super.key,
    required this.products,
    required this.crossAxisCount,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
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
                    (context) => ProductDetailScreen(productId: product.id),
              ),
            );
          },
        );
      },
    );
  }
}

// --- Admin Product Grid Section ---
class AdminProductGridSection extends StatelessWidget {
  final List<Product> products;
  final int crossAxisCount;
  final bool isMobile;
  final void Function(Product) onEdit;
  final void Function(Product) onDelete;

  const AdminProductGridSection({
    super.key,
    required this.products,
    required this.crossAxisCount,
    required this.isMobile,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final double discount = 0.2;
        final double rating = 3.0;
        final double discountedPrice = product.price * (1 - discount);

        return Stack(
          children: [
            ProductCard(
              product: product,
              discount: discount,
              rating: rating,
              discountedPrice: discountedPrice,
              onTap: () {
                // Optionally show details
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit',
                    onPressed: () => onEdit(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: () => onDelete(product),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- Admin Product Table Section ---
class AdminProductTableSection extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onEdit;
  final void Function(Product) onDelete;

  const AdminProductTableSection({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Actions')),
        ],
        rows:
            products.map((product) {
              return DataRow(
                cells: [
                  DataCell(Text(product.name)),
                  DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                  DataCell(Text(product.stock?.toString() ?? '-')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Edit',
                          onPressed: () => onEdit(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete',
                          onPressed: () => onDelete(product),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

// --- Admin Product Table Section with Pagination & DataTable2 ---
class AdminProductTableSectionPaginated extends StatelessWidget {
  final List<Product> products;
  final int totalProducts;
  final int rowsPerPage;
  final int currentPage;
  final void Function(int) onPageChanged;
  final void Function(int?) onRowsPerPageChanged;
  final bool isLoading;
  final void Function(Product) onEdit;
  final void Function(Product) onDelete;

  const AdminProductTableSectionPaginated({
    super.key,
    required this.products,
    required this.totalProducts,
    required this.rowsPerPage,
    required this.currentPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      children: [
        if (isLoading)
          const LinearProgressIndicator(),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: isMobile ? 700 : 1000),
            child: DataTable2(
              columnSpacing: 16,
              headingRowColor: MaterialStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              columns: const [
                DataColumn2(label: Text('Name'), size: ColumnSize.L),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Discount')),
                DataColumn2(label: Text('Description'), size: ColumnSize.L),
                DataColumn(label: Text('Images')),
                DataColumn(label: Text('Actions')),
              ],
              rows: products.map((product) {
                return DataRow(
                  cells: [
                    DataCell(Text(product.name)),
                    DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                    DataCell(Text(product.stock.toString())),
                    DataCell(Text('${product.discountRate}%')),
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 80,
                        child: product.images.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  product.images.first,
                                  height: 40,
                                  width: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                                ),
                              )
                            : const Icon(Icons.image_not_supported),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit',
                            onPressed: () => onEdit(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () => onDelete(product),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        // Pagination controls
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Rows per page:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: rowsPerPage,
                items: [5, 10, 20, 50].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                onChanged: onRowsPerPageChanged,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
              ),
              Text('${currentPage + 1} / ${((totalProducts - 1) / rowsPerPage).ceil() + 1}'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: (currentPage + 1) * rowsPerPage < totalProducts
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Product Form Dialog (Create/Update) ---
class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final Future<void> Function(Product) onSubmit;

  const ProductFormDialog({super.key, this.product, required this.onSubmit});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountController;
  late TextEditingController _imagesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _discountController = TextEditingController(
      text: widget.product?.discountRate?.toString() ?? '0',
    );
    _imagesController = TextEditingController(
      text: widget.product?.images?.join('\n') ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _imagesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final images =
          _imagesController.text
              .split(RegExp(r'[\n,]'))
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final product = Product(
        id: widget.product?.id ?? 0, // Use 0 for new products
        name: _nameController.text,
        description: _descriptionController.text,
        discountRate: int.tryParse(_discountController.text) ?? 0,
        price: double.tryParse(_priceController.text) ?? 0,
        stock: int.tryParse(_stockController.text) ?? 0,
        images: images,
        rating:
            widget.product?.rating ?? 0, // Or let admin set rating if needed
      );
      widget.onSubmit(product);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Create Product' : 'Update Product'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter name' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  validator:
                      (v) =>
                          v == null || v.isEmpty ? 'Enter description' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter price' : null,
                ),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter stock' : null,
                ),
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount Rate (%)',
                  ),
                  keyboardType: TextInputType.number,
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter discount' : null,
                ),
                TextFormField(
                  controller: _imagesController,
                  decoration: const InputDecoration(
                    labelText: 'Image Links',
                    hintText:
                        'Paste image URLs, one per line or comma separated',
                  ),
                  maxLines: 3,
                  validator:
                      (v) =>
                          v == null || v.isEmpty
                              ? 'Enter at least one image link'
                              : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.product == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}

// Error Snackbar Handler Widget
class ErrorSnackbarHandler {
  ErrorSnackbarHandler({
    required String? categoryError,
    required String? productsError,
    required String? carouselError,
    required VoidCallback onClearCategoryError,
    required VoidCallback onClearProductsError,
    required VoidCallback onClearCarouselError,
    required BuildContext context,
  }) {
    if (categoryError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(categoryError)));
        onClearCategoryError();
      });
    }
    if (productsError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(productsError)));
        onClearProductsError();
      });
    }
    if (carouselError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(carouselError)));
        onClearCarouselError();
      });
    }
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
