import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide ProductRepository
        Provider<ProductRepository>(
          create:
              (_) =>
                  ProductRepositoryImpl(ProductDataSourceImpl(http.Client())),
        ),
        // Provide ProfileRepository
        Provider<ProfileRepository>(
          create:
              (_) =>
                  ProfileRepositoryImpl(ProfileDataSourceImpl(http.Client())),
        ),
        // Provide CartProvider
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        // Provide CarouselRepository
        Provider<CarouselRepository>(
          create:
              (_) =>
                  CarouselRepositoryImpl(CarouselDataSourceImpl(http.Client())),
        ),
      ],
      child: MaterialApp(
        title: 'Oltron Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
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
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
