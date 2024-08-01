import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marfootball/controllers/image_controller.dart';
import 'package:marfootball/views/carousel_image_page.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<String> bannerUrls = [
    'https://c4.wallpaperflare.com/wallpaper/348/390/445/cristiano-ronaldo-kiev-ukraine-uefa-wallpaper-preview.jpg',
    'https://c4.wallpaperflare.com/wallpaper/874/671/650/soccer-cristiano-ronaldo-portuguese-wallpaper-preview.jpg',
    'https://c4.wallpaperflare.com/wallpaper/176/475/818/cristiano-madrid-portugal-real-wallpaper-preview.jpg',
  ];

  final ImageController _imageController = ImageController();
  late TabController _tabController;
  List<String> adsUrls = [];
  Map<String, List<String>> imageCache = {};
  Map<String, int> pageCache = {};
  Map<String, bool> loadingCache = {};
  Map<String, bool> endOfListCache = {};
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild the widget tree when the tab changes
    });
    _fetchAdsImages();
    _initCaches();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _initCaches() {
    for (final tab in ['Trending', 'Clubs', '4K', '8K']) {
      imageCache[tab] = [];
      pageCache[tab] = 1;
      loadingCache[tab] = false;
      endOfListCache[tab] = false;
      _fetchImages(tab);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAdsImages() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('ads').get();
      List<String> fetchedAdsUrls = querySnapshot.docs.map((doc) {
        String url = doc['urlimage'] as String;
        print('Fetched URL: $url');
        return url;
      }).toList();
      setState(() {
        adsUrls = fetchedAdsUrls;
      });
    } catch (e, stackTrace) {
      print('Error fetching ads images: $e');
      print(stackTrace); // Print the stack trace for more details
    }
  }

  Future<void> _fetchImages(String category, {bool loadMore = false}) async {
    if (loadingCache[category]!) return;
    setState(() {
      loadingCache[category] = true;
    });

    try {
      int page = loadMore ? pageCache[category]! + 1 : 1;
      final data = await _imageController.fetchImageUrls(category, page: page);

      setState(() {
        if (loadMore) {
          imageCache[category]!.addAll(data['imageUrls']);
          pageCache[category] = page;
        } else {
          imageCache[category] = data['imageUrls'];
          pageCache[category] = 1;
        }
        endOfListCache[category] = page >= data['totalPages'];
      });
    } catch (e) {
      print('Error fetching images: $e');
    }

    setState(() {
      loadingCache[category] = false;
    });
  }

  // Method to generate a random rating between 4.2 and 5
  double _generateRandomRating() {
    final random = Random();
    return 4.2 + random.nextDouble() * (5.0 - 4.2);
  }

  // Method to handle pagination and load more images when scrolling down
  void _onScrollNotification(
      String category, ScrollNotification scrollNotification) {
    if (scrollNotification is ScrollEndNotification) {
      if (scrollNotification.metrics.pixels ==
          scrollNotification.metrics.maxScrollExtent) {
        if (!loadingCache[category]! && !endOfListCache[category]!) {
          _fetchImages(category, loadMore: true);
        }
      }
    }
  }

  // Build method for image grid with scroll notification
  Widget _buildImageGrid(String category) {
    if (loadingCache[category] == true && imageCache[category]!.isEmpty) {
      return Center(
        child: AnimatedBuilder(
          animation: _animationController,
          child: Image.asset('assets/images/foot.png', width: 50, height: 50),
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
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        _onScrollNotification(category, scrollNotification);
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.7,
        ),
        itemCount:
            imageCache[category]!.length + (loadingCache[category]! ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == imageCache[category]!.length &&
              loadingCache[category]!) {
            return Center(
              child: AnimatedBuilder(
                animation: _animationController,
                child: Container(
                  width: 70, // Slightly larger than the image
                  height: 70, // Slightly larger than the image
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        Colors.black, // Background color to ensure visibility
                  ),
                  child: Image.asset(
                    'assets/images/foot.png',
                    width: 50,
                    height: 50,
                  ),
                ),
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
          final imageUrl = imageCache[category]![index];
          final rating = _generateRandomRating();
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarouselImagePage(
                    imageUrls: imageCache[category]!,
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
                      imageUrl: imageUrl,
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
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⭐ ${rating.toStringAsFixed(1)}',
                        style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    List<String> combinedBannerUrls = [...bannerUrls, ...adsUrls];
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: MediaQuery.of(context).size.height * 0.3,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: CarouselSlider.builder(
                  itemCount: combinedBannerUrls.length,
                  itemBuilder: (context, index, realIndex) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CachedNetworkImage(
                        imageUrl: combinedBannerUrls[index],
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error, color: Colors.white),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      ),
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                  ),
                ),
              ),
              centerTitle: true,
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Latest'),
                Tab(text: 'Clubs'),
                Tab(text: '4K'),
                Tab(text: '8K'),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildImageGrid('Trending'),
                _buildImageGrid('Clubs'),
                _buildImageGrid('4K'),
                _buildImageGrid('8K'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
