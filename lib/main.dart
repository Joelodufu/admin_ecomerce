import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:device_preview/device_preview.dart'; // Device Preview import
import 'package:provider/single_child_widget.dart';

import 'core/providers/cart_provider.dart';
import 'features/carousel/data/datasources/carousel_datasource.dart';
import 'features/carousel/data/repositories/carousel_repository_impl.dart';
import 'features/carousel/domain/repositories/carousel_repository.dart';
import 'features/product/data/datasources/product_datasource.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/presentation/screens/home_screen.dart';
import 'features/profile/data/datasources/profile_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';

void main() {
  // Wrap the app with DevicePreview for device simulation
  runApp(
    DevicePreview(
      enabled: true, // Always enabled for development
      // Set default device to a mobile device (e.g., Pixel 5)
      defaultDevice: Devices.android.smallPhone,
      builder: (context) => const MyApp(),
    ),
  );
}

/// Main App Widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Modular method to provide all app-wide providers
  List<SingleChildWidget> _buildProviders() {
    return [
      Provider<ProductRepository>(
        create:
            (_) => ProductRepositoryImpl(ProductDataSourceImpl(http.Client())),
      ),
      Provider<ProfileRepository>(
        create:
            (_) => ProfileRepositoryImpl(ProfileDataSourceImpl(http.Client())),
      ),
      ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
      Provider<CarouselRepository>(
        create:
            (_) =>
                CarouselRepositoryImpl(CarouselDataSourceImpl(http.Client())),
      ),
    ];
  }

  // Modular method for app theme
  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.orange,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        labelMedium: TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _buildProviders(),
      child: MaterialApp(
        title: 'Oltron Store',
        debugShowCheckedModeBanner: false,
        // Enable DevicePreview for mobile simulation
        builder: DevicePreview.appBuilder,
        useInheritedMediaQuery: true, // Ensures correct sizing for preview
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
