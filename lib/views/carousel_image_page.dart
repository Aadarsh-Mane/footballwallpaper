import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';

class CarouselImagePage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  CarouselImagePage({required this.imageUrls, required this.initialIndex});

  @override
  _CarouselImagePageState createState() => _CarouselImagePageState();
}

class _CarouselImagePageState extends State<CarouselImagePage> {
  int _currentPage = 0;
  List<double> _imageHeights = []; // To store the height of each image
  bool _isFullScreen = false; // To toggle full-screen mode

  @override
  void initState() {
    super.initState();
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
      // Set the wallpaper to the home screen
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
