import 'dart:convert';

import 'package:marfootball/models/image_model.dart';
import 'package:http/http.dart' as http;

class ImageController {
  final String baseUrl = 'https://drive.google.com/uc?export=view&id=';

  Future<List<String>> fetchImageUrls() async {
    final response =
        await http.get(Uri.parse('https://mydriver.onrender.com/fetch-images'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['files'];
      List<String> imageUrls = data.map((json) {
        final image = ImageModel.fromJson(json);
        return '$baseUrl${image.id}';
      }).toList();
      return imageUrls;
    } else {
      throw Exception('Failed to load images');
    }
  }
}
