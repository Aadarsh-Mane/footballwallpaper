import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildIcon('football.png', 'Home'),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('football.png', 'Settings'),
          label: 'Players',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('marlogo.png', 'Profile'),
          label: 'Request',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('football.png', 'About'),
          label: 'Wallpaper of the day',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: onTap,
    );
  }

  // Widget _buildIcon(String imagePath, String label) {
  //   return Container(
  //     padding: const EdgeInsets.all(4.0), // Add some padding around the icon
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle,
  //       color: Colors.white, // Background color if needed
  //       // boxShadow: [
  //       //   BoxShadow(
  //       //     // color: Colors.black26,
  //       //     blurRadius: 8.0,
  //       //     offset: Offset(0, 2), // Shadow position
  //       //   ),
  //       // ],
  //     ),
  //     child: ClipOval(
  //       child: Image.asset(
  //         'assets/images/$imagePath',
  //         color: Colors.black, // Change color if needed
  //         width: 24,
  //         height: 24,
  //         fit: BoxFit.cover, // Ensures the image fits the circle
  //       ),
  //     ),
  //   );
  // }
  Widget _buildIcon(String imagePath, String label) {
    return Container(
      padding: const EdgeInsets.all(4.0), // Add some padding around the icon
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // color: Colors.white, // Background color if needed
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 2), // Shadow position
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/$imagePath',
          width: 24,
          height: 24,
          fit: BoxFit.cover, // Ensures the image fits the circle
        ),
      ),
    );
  }
}
