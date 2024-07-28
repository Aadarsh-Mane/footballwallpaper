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
    'Bayern Munich',
    'AS Roma',
    'Bayer Leverkusen',
    'Fenerbahce',
    'Atletico Madrid',
    'Inter Milan',
    'Juventus',
    'Tottenham Hotspur',
    'PSG',
    // Add other clubs as needed
  ];
  List<String> _imageUrls = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedClub = _clubs.first;
    _fetchImages();
  }

  Future<void> _fetchImages({bool isInitialLoad = true}) async {
    if (_isLoading || (_currentPage > _totalPages && !isInitialLoad)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _imageController.fetchImageUrls('Club-$_selectedClub',
          page: _currentPage);
      setState(() {
        _imageUrls.addAll(data['imageUrls']);
        _totalPages = data['totalPages'];
        _currentPage++;
      });
    } catch (error) {
      print('Error fetching images: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onClubSelected(String? newValue) {
    setState(() {
      _selectedClub = newValue;
      _imageUrls.clear();
      _currentPage = 1;
      _totalPages = 1;
      _fetchImages();
    });
  }

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
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !_isLoading) {
                  _fetchImages(isInitialLoad: false);
                  return true;
                }
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
                itemCount: _imageUrls.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _imageUrls.length) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final imageUrl = _imageUrls[index];
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
                            borderRadius: BorderRadius.circular(16.0),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) => Shimmer.fromColors(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
