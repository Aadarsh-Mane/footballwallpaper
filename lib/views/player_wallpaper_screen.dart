import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class PlayerWallpapersScreen extends StatelessWidget {
  final String playerName;
  final int initialIndex;

  PlayerWallpapersScreen(
      {required this.playerName, required this.initialIndex});

  // Method to generate a random rating between 4.2 and 5
  double _generateRandomRating() {
    final random = Random();
    return 4.2 + random.nextDouble() * (5.0 - 4.2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text('$playerName Wallpapers'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('players')
            .doc(playerName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
                child: Text('No wallpapers available for $playerName'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          var wallpapers =
              List<Map<String, dynamic>>.from(data['wallpapers'] ?? []);
          var imageUrls = wallpapers
              .map((wallpaper) => wallpaper['url'] as String)
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.7, // Adjust based on the image aspect ratio
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final rating = _generateRandomRating();
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullscreenImageScreen1(
                          imageUrls: imageUrls, // Pass the list of image URLs
                          initialIndex: index),
                    ),
                  );
                },
                child: Hero(
                  tag: 'image_$index',
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: CachedNetworkImage(
                          imageUrl: imageUrls[index],
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
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
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FullscreenImageScreen1 extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  FullscreenImageScreen1({required this.imageUrls, required this.initialIndex});

  @override
  _FullscreenImageScreen1State createState() => _FullscreenImageScreen1State();
}

class _FullscreenImageScreen1State extends State<FullscreenImageScreen1> {
  int _currentPage = 0;
  List<double> _imageHeights = []; // To store the height of each image
  bool _isFullScreen = false; // To toggle full-screen mode

  @override
  void initState() {
    super.initState();
    _currentPage =
        widget.initialIndex; // Initialize the current page to the initial index
    _fetchImageHeights();
  }

  // Fetch the heights of all images
  void _fetchImageHeights() {
    Future.wait(widget.imageUrls.map((url) async {
      final Completer<ImageInfo> completer = Completer<ImageInfo>();
      final Image image = Image.network(url);
      image.image.resolve(ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo image, bool synchronousCall) {
          completer.complete(image);
        }),
      );
      final ImageInfo imageInfo = await completer.future;
      setState(() {
        _imageHeights.add(imageInfo.image.height.toDouble());
      });
    }));
  }

  Future<String> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      file.writeAsBytesSync(response.bodyBytes);
      return filePath;
    } else {
      throw Exception('Failed to download image');
    }
  }

  // Function to set the current image as wallpaper
  void _setWallpaper(String url) async {
    try {
      final filePath = await _downloadImage(url);
      await WallpaperManager.setWallpaperFromFile(
          filePath, WallpaperManager.HOME_SCREEN);
      print("Wallpaper set successfully.");
    } catch (e) {
      print("Failed to set wallpaper: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _imageHeights.isNotEmpty
              ? CarouselSlider.builder(
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index, realIndex) {
                    return Center(
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrls[index],
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error, color: Colors.white),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: _imageHeights[index], // Set height dynamically
                      ),
                    );
                  },
                  options: CarouselOptions(
                    initialPage: widget.initialIndex,
                    height: MediaQuery.of(context)
                        .size
                        .height, // Use full screen height
                    enableInfiniteScroll: true,
                    autoPlay: false,
                    aspectRatio: MediaQuery.of(context).size.width /
                        _imageHeights[
                            widget.initialIndex], // Maintain aspect ratio
                    viewportFraction: 1.0,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                  ),
                )
              : Center(
                  child:
                      CircularProgressIndicator()), // Show loader while heights are being fetched
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: Icon(
                _isFullScreen ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isFullScreen = !_isFullScreen;
                });
              },
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.imageUrls.asMap().entries.map((entry) {
                int index = entry.key;
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withOpacity(index == _currentPage ? 0.9 : 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_isFullScreen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFullScreen = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrls[_currentPage],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          if (!_isFullScreen)
            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  _setWallpaper(widget.imageUrls[_currentPage]);
                },
                child: Text('Set as Wallpaper'),
              ),
            ),
        ],
      ),
    );
  }
}
