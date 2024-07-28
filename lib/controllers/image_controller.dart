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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marfootball/models/ad_model.dart';
import 'package:marfootball/models/image_model.dart';
import 'package:http/http.dart' as http;

class ImageController {
  final String baseUrl = 'https://drive.google.com/uc?export=view&id=';
  final String apiUrl = 'https://mydriver.onrender.com/getImages';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Ad>> fetchAds() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('ads').get();
      return querySnapshot.docs
          .map((doc) => Ad.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching ads: $e');
      return [];
    }
  }

  // Future<List<String>> fetchImageUrls(String category) async {
  Future<Map<String, dynamic>> fetchImageUrls(String category,
      {int page = 1, int limit = 5}) async {
    String folderId;

    switch (category) {
      case 'Trending':
        folderId = '1TKlHnawAQCXydSbTEU4bVeJLiHFujjCC';
        // folderId = '1-7VZ1uAUWjHD-JUu7iq7mAsUXZMmiQhl';
        break;
      case 'Clubs':
        folderId = '1ggL_nRRH8ivDyk7YcMwYoUUt5zCxRU34';
        break;
      case 'Club-Real Madrid':
        folderId = '1TKlHnawAQCXydSbTEU4bVeJLiHFujjCC';
        // folderId = '1-2Sx_72mrzSsZ6W7Qz-J_-_pRaE2Rnj1';
        break;
      case 'Club-Barcelona':
        folderId = '1-sFfcvP9-ZtwG6dvo5fghVkUBfLrioXH';
        break;
      case 'Club-Manchester':
        folderId = '1-qEh1MRO9suk51rBIVsL1y9_rDS9DNUD';
        break;
      case 'Club-Manchester City':
        folderId = '1-fsMDCMd6MulYpldjebXtFuTGAqrJWzJ';
        break;
      case 'Club-Liverpool':
        folderId = '1-eOXBPQymnVih3Z0nJD6qlyx7Ug59Azw';
        break;
      case 'Club-Alhilal':
        folderId = '1-V5jiVzNRompcVoJFG5ULGVzLVYBNdkk';
        break;
      case 'Club-Alnassar':
        folderId = '1-cMbz9Q40QA02VBBJRJ1GafiN1w3iR8K';
        break;
      case 'Club-Bayern Munich':
        folderId = '1-cMbz9Q40QA02VBBJRJ1GafiN1w3iR8K';
        break;
      case 'Club-AS Roma':
        folderId = '10zgeoHHe5RHrfftXCD7x-AAJJqFTgfXE';
        break;
      case 'Club-Bayern Leverkusen':
        folderId = '11BpbIUJ0T4MIxLhPRLatBLJO7Rqf6TOo';
        break;
      case 'Club-Fenerbahche':
        folderId = '10R6CVt6ydyM0GyZUV8hjOXqQNFVJHlD7';
        break;
      case 'Club-Atletico Madrid':
        folderId = '109JtLgtvWOKJlQC-9tIxeiSPvfAXEl13';
        break;
      case 'Club-Juventus':
        folderId = '10UTj_0V90UWHORT1xnhX2q5K_JwJp_Go';
        break;
      case 'Club-Tottenham Hotspur':
        folderId = '10HCUlcI4BEc_wKeL2pvLU_GLQNbewa5H';
        break;
      case 'Club-PSG':
        folderId = '10M9QYjW3wAk89g32wb1yrFr-SzBtkWNj';
        break;
      case '4K':
        folderId = 'YOUR_4K_FOLDER_ID';
        break;
      case '8K':
        folderId = '1-LIGnPMg0_t_QoFgdnuZ9LPysmbnUlmW';
        break;
      case 'League-Premuire League':
        // folderId = '1-Lc8j7JjIQZgVzxwocuxgBgnOxFAgeCp';
        folderId = '1-Lc8j7JjIQZgVzxwocuxgBgnOxFAgeCp';

        break;
      case 'League-Serie League':
        folderId = '1-NPGeHRHBSjGHeM87qQO_nJs9p-hFqXa';
        break;
      case 'League-Saudi League':
        folderId = '1-RNhe-K13BNJYPPQvt7JDPbf0rpcd-tj';
        break;
      case 'League-laliga':
        folderId = '1-MahaNIKpipQhs59lW0f7hIAUWwJVbuk';
        break;
      case 'League-Bundesliga':
        folderId = '1-MahaNIKpipQhs59lW0f7hIAUWwJVbuk';
        break;
      case 'general':
        folderId = '1-7VZ1uAUWjHD-JUu7iq7mAsUXZMmiQhl';
        break;
      case 'vibes':
        folderId = '1-LIGnPMg0_t_QoFgdnuZ9LPysmbnUlmW';
        break;

      default:
        folderId = 'YOUR_DEFAULT_FOLDER_ID';
        break;
    }

    final response = await http
        .get(Uri.parse('$apiUrl?folderId=$folderId&page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'imageUrls': (data['files'] as List)
            .map((file) => '$baseUrl${file['id']}')
            .toList(),
        'totalPages': data['totalPages'],
        'currentPage': data['currentPage'],
      };
    } else {
      throw Exception('Failed to load images');
    }
  }
}
