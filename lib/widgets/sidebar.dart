import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Sidebar extends StatelessWidget {
  final Function(String) onMenuItemClicked;

  Sidebar({required this.onMenuItemClicked});

  // URL to launch
  final Uri _url =
      Uri.parse('https://www.yourwebsite.com'); // Replace with your URL

  Future<void> _launchURL() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: <Widget>[
          DrawerHeader(
            child: Row(
              children: <Widget>[
                Image.asset(
                  'assets/images/marlogo.png', // Replace with your logo's asset path
                  height: 40.0,
                  width: 40.0,
                ),
                SizedBox(width: 16.0),
                Text(
                  'MAR 4K Wallpaper',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.black,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  title: Text(
                    'Home',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onMenuItemClicked('/home');
                  },
                ),
                ListTile(
                  title: Text(
                    'Players',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onMenuItemClicked('/settings');
                  },
                ),
                ListTile(
                  title: Text(
                    'Requests',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onMenuItemClicked('/profile');
                  },
                ),
                ListTile(
                  title: Text(
                    'About',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onMenuItemClicked('/about');
                  },
                ),
                ListTile(
                  title: Text(
                    'Clubs',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onMenuItemClicked('/clubs');
                  },
                ),
                ListTile(
                  title: Text(
                    'League',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onMenuItemClicked('/league');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/20logo.png', // Replace with your company logo's asset path
                      height: 30.0,
                      width: 30.0,
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: _launchURL,
                        child: Text(
                          '''© 2024 20's Developers
All rights reserved. DM us .''',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
