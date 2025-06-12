import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_mind/constants/color_list.dart';
import 'package:sound_mind/src/models/playlist_provider.dart';

class Playlists extends StatefulWidget {
  @override
  _PlaylistsState createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists> {
  @override
  void initState() {
    super.initState();

    // Load saved playlists when the widget is first created
    Future.microtask(() =>
        Provider.of<PlaylistProvider>(context, listen: false).loadPlaylists());
  }

  @override
  Widget build(BuildContext context) {
    final playlists = Provider.of<PlaylistProvider>(context).playlists;

    const String backgroundColorHex = SPACE_CADET;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    const String buttonHex = JORDY_BLUE;
    final Color buttonColor = Color(int.parse('0xFF$buttonHex'));

    const String textColorHex = GHOST_WHITE;
    final Color textColor = Color(int.parse('0xFF$textColorHex'));

    const String secondaryColorHex = OXFORD_BLUE;
    final Color secondaryColor = Color(int.parse('0xFF$secondaryColorHex'));

    const String accentColorHex = ROSY_BROWN;
    final Color accentColor = Color(int.parse('0xFF$accentColorHex'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recommended Playlists",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: buttonColor,
          ),
        ),
        const SizedBox(height: 10),
        playlists.isEmpty
            ? Center(
                child: Text(
                  "No playlists found",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              )
            : Column(
                children: playlists.map((playlist) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent
                          .withOpacity(0.3), // same as your reference
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: secondaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          playlist["image_url"],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        playlist["name"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: buttonColor,
                        ),
                      ),
                      subtitle: Text(
                        playlist["description"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                      onTap: () {
                        // TODO: Handle tap (e.g., open playlist URL)
                      },
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
