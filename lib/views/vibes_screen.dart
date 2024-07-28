import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:marfootball/controllers/image_controller.dart';
import 'package:marfootball/views/carousel_image_page.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:math';

class VibesWallpaperScreen extends StatefulWidget {
  @override
  _VibesWallpaperScreenState createState() => _VibesWallpaperScreenState();
}

class _VibesWallpaperScreenState extends State<VibesWallpaperScreen>
    with SingleTickerProviderStateMixin {
  final ImageController _imageController = ImageController();
  final ScrollController _scrollController = ScrollController();
  // final BaseCacheManager _customCacheManager = CacheManager(
  //   Config(
  //     "customCache",
  //     stalePeriod: Duration(days: 7),
  //     maxNrOfCacheObjects: 200,
  //   ),
  // );

  List<String> _imageUrls = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _scrollController.addListener(_onScroll);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Method to generate a random rating between 4.2 and 5
  double _generateRandomRating() {
    final random = Random();
    return 4.2 + random.nextDouble() * (5.0 - 4.2);
  }

  Future<void> _fetchImages() async {
    if (_isLoading || _currentPage > _totalPages) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await _imageController.fetchImageUrls('vibes', page: _currentPage);
      setState(() {
        _imageUrls.addAll(result['imageUrls']);
        _totalPages = result['totalPages'];
        _currentPage = result['currentPage'] + 1;
      });
    } catch (e) {
      print('Failed to load images: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'MAR Beyond Football',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      body: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.7,
        ),
        itemCount: _imageUrls.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _imageUrls.length) {
            return Center(
              child: AnimatedBuilder(
                animation: _animationController,
                child: Image.asset('assets/images/foot.png',
                    width: 50, height: 50),
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + 0.3 * _animationController.value,
                    child: Transform.rotate(
                      angle: _animationController.value * 2 * pi,
                      child: child,
                    ),
                  );
                },
              ),
            );
          }

          final rating = _generateRandomRating();
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarouselImagePage(
                    imageUrls: _imageUrls,
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
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedNetworkImage(
                      // cacheManager: _customCacheManager,
                      imageUrl: _imageUrls[index],
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    bottom: 10.0,
                    left: 10.0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
      ),
    );
  }
}
