import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:marfootball/controllers/image_controller.dart';
import 'package:marfootball/views/carousel_image_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<String> bannerUrls = [
    'https://c4.wallpaperflare.com/wallpaper/348/390/445/cristiano-ronaldo-kiev-ukraine-uefa-wallpaper-preview.jpg',
    'https://c4.wallpaperflare.com/wallpaper/874/671/650/soccer-cristiano-ronaldo-portuguese-wallpaper-preview.jpg',
    'https://c4.wallpaperflare.com/wallpaper/176/475/818/cristiano-madrid-portugal-real-wallpaper-preview.jpg',
  ];

  final ImageController _imageController = ImageController();
  late TabController _tabController;
  late Future<List<String>> _imageUrls;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_loadImages);
    _loadImages(); // Load initial images
  }

  void _loadImages() {
    setState(() {
      _imageUrls = _imageController.fetchImageUrls(_tabController.index == 0
          ? 'Trending'
          : _tabController.index == 1
              ? 'Clubs'
              : _tabController.index == 2
                  ? '4K'
                  : '8K');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight:
                MediaQuery.of(context).size.height * 0.3, // Adjusted height
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(
                    bottom: 48.0), // Padding to separate from tab bar
                child: CarouselSlider.builder(
                  itemCount: bannerUrls.length,
                  itemBuilder: (context, index, realIndex) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CachedNetworkImage(
                        imageUrl: bannerUrls[index],
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
              // title: Text('Trending Wallpapers'),
              centerTitle: true,
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Trending'),
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
                _buildImageGrid(),
                _buildImageGrid(),
                _buildImageGrid(),
                _buildImageGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return FutureBuilder<List<String>>(
      future: _imageUrls,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
                  ));
            },
          );
        }
      },
    );
  }
}
