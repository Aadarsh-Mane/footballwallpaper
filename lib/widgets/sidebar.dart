import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final Function(String) onMenuItemClicked;

  Sidebar({required this.onMenuItemClicked});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Sidebar Header'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              onMenuItemClicked('/home');
            },
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              onMenuItemClicked('/settings');
            },
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () {
              onMenuItemClicked('/profile');
            },
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              onMenuItemClicked('/about');
            },
          ),
          ListTile(
            title: Text('New'),
            onTap: () {
              onMenuItemClicked('/new');
            },
          ),
        ],
      ),
    );
  }
}
