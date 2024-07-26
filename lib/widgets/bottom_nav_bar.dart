import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon('football.png'),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon('football.png'),
          label: 'Players',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon('marlogo.png'),
          label: 'Request',
        ),
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon('football.png'),
          label: 'Wallpaper of the day',
        ),
      ],
      currentIndex: widget.currentIndex,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: widget.onTap,
      selectedFontSize: 14.0,
      unselectedFontSize: 12.0,
    );
  }

  Widget _buildAnimatedIcon(String imagePath) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159, // Rotate 360 degrees
          child: _buildIcon(imagePath),
        );
      },
    );
  }

  Widget _buildIcon(String imagePath) {
    return Container(
      padding: const EdgeInsets.all(8.0), // Increased padding for touch area
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2), // Semi-transparent background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
