// import 'dart:convert';
// import 'package:marfootball/models/image_model.dart';
// import 'package:http/http.dart' as http;

// class ImageController {
//   final String baseUrl = 'https://drive.google.com/uc?export=view&id=';

//   Future<List<String>> fetchImageUrls(String category) async {
//     String url;
//     switch (category) {
//       case 'Trending':
//         url = 'https://mydriver.onrender.com/fetch-images';
//         break;
//       case 'Clubs':
//         url = 'https://mydriver.onrender.com/fetch-clubs-images';
//         break;
//       case '4K':
//         url = 'https://mydriver.onrender.com/fetch-4k-images';
//         break;
//       case '8K':
//         url = 'https://mydriver.onrender.com/fetch-8k-images';
//         break;
//       default:
//         url = 'https://mydriver.onrender.com/fetch-images';
//         break;
//     }

//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body)['files'];
//       List<String> imageUrls = data.map((json) {
//         final image = ImageModel.fromJson(json);
//         return '$baseUrl${image.id}';
//       }).toList();
//       return imageUrls;
//     } else {
//       throw Exception('Failed to load images');
//     }
//   }
// }

import 'dart:convert';
import 'package:marfootball/models/image_model.dart';
import 'package:http/http.dart' as http;

class ImageController {
  final String baseUrl = 'https://drive.google.com/uc?export=view&id=';
  final String apiUrl = 'https://mydriver.onrender.com/fetch-images';

  Future<List<String>> fetchImageUrls(String category) async {
    String folderId;

    switch (category) {
      case 'Trending':
        folderId = '1TKlHnawAQCXydSbTEU4bVeJLiHFujjCC';
        break;
      case 'Clubs':
        folderId = '1ggL_nRRH8ivDyk7YcMwYoUUt5zCxRU34';
        break;
      case '4K':
        folderId = 'YOUR_4K_FOLDER_ID';
        break;
      case '8K':
        folderId = '1-LIGnPMg0_t_QoFgdnuZ9LPysmbnUlmW';
        break;
      default:
        folderId = 'YOUR_DEFAULT_FOLDER_ID';
        break;
    }

    final response = await http.get(Uri.parse('$apiUrl?folderId=$folderId'));

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
