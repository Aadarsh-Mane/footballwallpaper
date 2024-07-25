import 'package:flutter/material.dart';
import 'package:marfootball/controllers/image_controller.dart';
import 'package:marfootball/views/carousel_image_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ClubWallpaperScreen extends StatefulWidget {
  @override
  _ClubWallpaperScreenState createState() => _ClubWallpaperScreenState();
}

class _ClubWallpaperScreenState extends State<ClubWallpaperScreen> {
  final ImageController _imageController = ImageController();
  String? _selectedClub;
  List<String> _clubs = [
    'Real',
    'Manchester City',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Club Wallpapers',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedClub,
            icon: Icon(Icons.arrow_downward, color: Colors.white),
            dropdownColor: Colors.black,
            style: TextStyle(color: Colors.white),
            onChanged: _onClubSelected,
            items: _clubs.map<DropdownMenuItem<String>>((String club) {
              return DropdownMenuItem<String>(
                value: club,
                child: Text(club),
              );
            }).toList(),
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _imageUrls,
        builder: (context, snapshot) {
          // Print statements for debugging
          print('Snapshot connection state: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(
                child: Text('Failed to load images',
                    style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('No images found.');
            return Center(
                child: Text('No images available',
                    style: TextStyle(color: Colors.white)));
          } else {
            final imageUrls = snapshot.data!;
            print('Fetched image URLs: $imageUrls'); // Print URLs for debugging
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[index],
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
