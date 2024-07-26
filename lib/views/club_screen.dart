import 'package:flutter/material.dart';
import 'package:marfootball/controllers/image_controller.dart';
import 'package:marfootball/views/carousel_image_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';

class ClubWallpaperScreen extends StatefulWidget {
  @override
  _ClubWallpaperScreenState createState() => _ClubWallpaperScreenState();
}

class _ClubWallpaperScreenState extends State<ClubWallpaperScreen> {
  final ImageController _imageController = ImageController();
  String? _selectedClub;
  List<String> _clubs = [
    'Real Madrid',
    'Manchester City',
    'Liverpool',
    'Alhilal',
    'Alnassar',

    // Add other clubs as needed
  ];
  late Future<List<String>> _imageUrls;

  @override
  void initState() {
    super.initState();
    _selectedClub = _clubs.first;
    _imageUrls = _imageController.fetchImageUrls('Club-$_selectedClub');
  }

  void _onClubSelected(String? newValue) {
    setState(() {
      _selectedClub = newValue;
      _imageUrls = _imageController.fetchImageUrls('Club-$_selectedClub');
    });
  }

  // Method to generate a random rating between 4.2 and 5
  double _generateRandomRating() {
    final random = Random();
    return 4.2 + random.nextDouble() * (5.0 - 4.2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Club Wallpapers',
          style: TextStyle(
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedClub,
                // icon: Icon(Icons.arrow_downward, color: Colors.white),
                dropdownColor: Colors.black,
                style: TextStyle(color: Colors.white, fontSize: 16.0),
                onChanged: _onClubSelected,
                items: _clubs.map<DropdownMenuItem<String>>((String club) {
                  return DropdownMenuItem<String>(
                    value: club,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.sports_soccer,
                              color: Colors.white, size: 20.0),
                          SizedBox(width: 8.0),
                          Text(
                            club,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _imageUrls,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[700]!,
                    highlightColor: Colors.grey[600]!,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: 10, // Placeholder count
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.grey[800],
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Failed to load images',
                          style: TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No images available',
                          style: TextStyle(color: Colors.white)));
                } else {
                  final imageUrls = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      final rating = _generateRandomRating();
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarouselImagePage(
                                imageUrls: imageUrls,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'image_$index',
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrls[index],
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey[700]!,
                                    highlightColor: Colors.grey[600]!,
                                    child: Container(
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error, color: Colors.red),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 10.0,
                                left: 10.0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 14.0,
                                      ),
                                      SizedBox(width: 4.0),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8.0,
                                left: 8.0,
                                child: Container(
                                  color: Colors.red,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Text(
                                    '$_selectedClub',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
