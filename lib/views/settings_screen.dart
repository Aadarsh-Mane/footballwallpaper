import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marfootball/views/player_wallpaper_screen.dart';
import 'package:shimmer/shimmer.dart';

const List<String> players = [
  "Lionel Messi",
  "Cristiano Ronaldo",
  "Kylian Mbappe",
  "Erling Haaland",
  "Neymar Jr.",
  "Robert Lewandowski",
  "Kevin De Bruyne",
  "Harry Kane",
  "Mohamed Salah",
  "Virgil van Dijk",
  "Sadio Mane",
  "Karim Benzema",
  "Bruno Fernandes",
  "Romelu Lukaku",
  // Add more player names here
];

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredPlayers = [];

  @override
  void initState() {
    super.initState();
    _filteredPlayers = players;
  }

  void _filterPlayers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPlayers = players;
      } else {
        _filteredPlayers = players
            .where(
                (player) => player.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // appBar: AppBar(
      //   title: Text('Search Players'),
      //   backgroundColor: Colors.blueAccent,
      // ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPlayers,
              decoration: InputDecoration(
                hintText: 'Search for a player...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPlayers.length,
              itemBuilder: (context, index) {
                final player = _filteredPlayers[index];
                return ListTile(
                  title: Text(
                    player,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerWallpapersScreen(
                          playerName: player,
                          initialIndex: 0,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
