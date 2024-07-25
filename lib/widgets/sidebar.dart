import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final Function(String) onMenuItemClicked;

  Sidebar({required this.onMenuItemClicked});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Row(
              children: <Widget>[
                // Logo
                Image.asset(
                  'assets/images/marlogo.png', // Replace with your logo's asset path
                  height: 40.0, // Adjust size as needed
                  width: 40.0,
                ),
                SizedBox(width: 16.0), // Space between logo and text
                Text(
                  'MAR 4K Wallpaper',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0, // Adjust text size as needed
                    fontWeight: FontWeight.bold, // Optional styling
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.black,
            ),
          ),
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
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              onMenuItemClicked('/settings');
            },
          ),
          ListTile(
            title: Text(
              'Profile',
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
              'clubs',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              onMenuItemClicked('/clubs');
            },
          ),
          ListTile(
            title: Text(
              'league',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              onMenuItemClicked('/league');
            },
          ),
          // Spacer(),
          Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                '© 2024 Your Company Name. All rights reserved.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              )),
        ],
      ),
    );
  }
}
