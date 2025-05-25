import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/carousel_item_model.dart';

final logger = Logger();

abstract class CarouselDataSource {
  Future<List<CarouselItemModel>> getCarouselItems();
}

class CarouselDataSourceImpl implements CarouselDataSource {
  final http.Client client;

  CarouselDataSourceImpl(this.client);

  @override
  Future<List<CarouselItemModel>> getCarouselItems() async {
    final uri = Uri.parse('${AppConstants.baseUrl}/carousel');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      logger.d('Raw JSON data: $jsonData'); // Log the raw data for debugging
      return jsonData.map((json) {
        if (json is! Map<String, dynamic>) {
          throw Exception('Invalid JSON format: $json');
        }
        return CarouselItemModel.fromJson(json);
      }).toList();
    } else {
      throw Exception('Failed to load carousel items: ${response.statusCode}');
    }
  }
}
