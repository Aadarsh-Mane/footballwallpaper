import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marfootball/services/cache_service.dart';
import 'package:marfootball/views/general_wallpaper.dart';
import 'package:marfootball/views/vibes_screen.dart';
import 'package:marfootball/views/wallpaper_day.dart';
import 'package:marfootball/views/home_screen.dart';
import 'package:marfootball/views/club_screen.dart';
import 'package:marfootball/views/league_screen.dart';
import 'package:marfootball/views/request_screen.dart';
import 'package:marfootball/views/settings_screen.dart';
import 'package:marfootball/widgets/bottom_nav_bar.dart';
import 'package:marfootball/widgets/sidebar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await CacheService().initializeCache(); // Initialize the cache service

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MVC App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SettingsScreen(),
    RequestScreen(),
    WallpaperDay(),
    // NewScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '4K Wallpaper ',
        ),
        foregroundColor: Colors.white,
      ),
      drawer: Sidebar(
        onMenuItemClicked: (route) {
          setState(() {
            switch (route) {
              case '/home':
                _selectedIndex = 0;
                break;
              case '/settings':
                _selectedIndex = 1;
                break;
              case '/profile':
                _selectedIndex = 2;
                break;
              case '/about':
                _selectedIndex = 3;
                break;
              case '/clubs':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ClubWallpaperScreen()),
                );
                break;
              case '/league':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LeagueWallpaperScreen()),
                );
                break;
              case '/beyond':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VibesWallpaperScreen()),
                );
              case '/marchoice':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GeneralWallpaper()),
                );
                break;
            }
            if (route != '/clubs' &&
                route != '/league' &&
                route != '/beyond' &&
                route != '/marchoice')
              Navigator.pop(
                  context); // Close the drawer if not navigating to 'NewScreen'
          });
        },
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
