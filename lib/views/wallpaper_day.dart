import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'carousel_image_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

class UserIdentifier {
  static Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      userId = Uuid().v4();
      await prefs.setString('userId', userId);
    }
    return userId;
  }
}

class WallpaperDay extends StatefulWidget {
  @override
  _WallpaperDayState createState() => _WallpaperDayState();
}

class _WallpaperDayState extends State<WallpaperDay> {
  double _generateRandomRating() {
    final random = Random();
    return 9.0 + random.nextDouble() * (10.0 - 9.2);
  }

  bool _isLoading = false;
  String _loadingMessage = '';

  Future<void> _handlePurchase(BuildContext context, String wallpaperId) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Processing your purchase...';
    });

    final userId = await UserIdentifier.getUserId();
    final response = await http.post(
      Uri.parse('https://paypalintegration.onrender.com/purchase'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'wallpaperId': wallpaperId, 'userId': userId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final approvalUrl = data['forwardLink'];

      try {
        await _launchURL(approvalUrl);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error launching URL')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Payment error')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<bool> _isPurchased(String wallpaperId) async {
    final userId = await UserIdentifier.getUserId();
    final doc = await FirebaseFirestore.instance
        .collection('userPurchases')
        .doc(userId)
        .get();
    return doc.exists && doc.data()![wallpaperId] == true;
  }

  void _checkPaymentStatus() async {
    // Logic to check the payment status from your backend
    // You can use a SharedPreferences flag to determine if payment was successful
    // Show a success or failure message accordingly
  }

  Future<void> _refreshWallpapers() async {
    setState(() {});
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.bodyBytes));
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wallpaper saved to gallery')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save wallpaper to gallery')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download wallpaper')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading wallpaper')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
    _secureScreen();
  }

  void _secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void dispose() {
    FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Long press to download image',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.refresh),
          //   onPressed: _refreshWallpapers,
          // ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('wallpaperOfTheDay')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No wallpapers available'));
              }

              var wallpapers = snapshot.data!.docs;
              var imageUrls =
                  wallpapers.map((doc) => doc['imageURL'] as String).toList();
              var wallpaperIds =
                  wallpapers.map((doc) => doc.id as String).toList();
              var isLocks =
                  wallpapers.map((doc) => doc['isLock'] as bool).toList();

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
                  final isLock = isLocks[index];

                  return FutureBuilder<bool>(
                    future: _isPurchased(wallpaperIds[index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final isPurchased = snapshot.data ?? false;

                      return GestureDetector(
                        onTap: () {
                          if (isLock && !isPurchased) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.confirm,
                              title: 'Confirm Purchase',
                              text:
                                  'Do you really want to purchase this wallpaper?',
                              confirmBtnText: 'Yes',
                              cancelBtnText: 'No',
                              onConfirmBtnTap: () {
                                Navigator.of(context).pop();
                                _handlePurchase(context, wallpaperIds[index]);
                              },
                            );
                            // _handlePurchase(context, wallpaperIds[index]);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarouselImagePage1(
                                  imageUrls: imageUrls,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          }
                        },
                        onLongPress: () {
                          if (!isLock || isPurchased) {
                            _downloadImage(imageUrls[index]);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Unlock wallpaper to download')),
                            );
                          }
                        },
                        child: Hero(
                          tag: 'image_$index',
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    (isLock && !isPurchased)
                                        ? Colors.black.withOpacity(0.6)
                                        : Colors.transparent,
                                    BlendMode.darken,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrls[index],
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
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
                              ),
                              if (isLock && !isPurchased)
                                Center(
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 40.0,
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
              );
            },
          ),
          if (_isLoading)
            Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16.0),
                    Text(
                      _loadingMessage,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _refreshWallpapers,
        icon: Icon(Icons.touch_app),
        label: Text('Tap to see the unlocked image after purchase'),
      ),
    );
  }
}

class CarouselImagePage1 extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  CarouselImagePage1({required this.imageUrls, required this.initialIndex});

  @override
  _CarouselImagePage1State createState() => _CarouselImagePage1State();
}

class _CarouselImagePage1State extends State<CarouselImagePage1> {
  int _currentPage = 0;
  List<double> _imageHeights = []; // To store the height of each image
  bool _isFullScreen = false; // To toggle full-screen mode
  bool _isSettingWallpaper = false; // To manage loading state
  String? _wallpaperMessage; // To show success or failure message

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _fetchImageHeights();
    _secureScreen();
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
      _imageHeights.add(imageInfo.image.height.toDouble());
      if (_imageHeights.length == widget.imageUrls.length) {
        setState(() {}); // Trigger rebuild when all heights are fetched
      }
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

  void _secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void dispose() {
    FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _imageHeights.length == widget.imageUrls.length
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
                        fit: BoxFit.contain,
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
            if (_wallpaperMessage != null)
              Positioned(
                bottom: 80,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _wallpaperMessage!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
