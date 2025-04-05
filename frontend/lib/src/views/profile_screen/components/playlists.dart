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

    const String boxHex = COLOR_ASH_GRAY;
    final Color boxColor = Color(int.parse('0xFF$boxHex'));

    const String textHex = COLOR_CHARCOAL;
    final Color textColor = Color(int.parse('0xFF$textHex'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recommended Playlists",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        playlists.isEmpty
            ? const Center(child: Text("No playlists found"))
            : Column(
                children: playlists.map((playlist) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: boxColor,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded image corners
                        child: Image.network(
                          playlist["image_url"],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        playlist["name"],
                        maxLines: 2, // Limits to 2 lines
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor, // Title color
                        ),
                      ),
                      subtitle: Text(
                        playlist["description"],
                        maxLines: 2, // Limits to 2 lines
                        overflow: TextOverflow.ellipsis, // Truncates with "..."
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor, // Slightly dimmed text
                        ),
                      ),
                      onTap: () {
                        // Open playlist URL
                        // You can use url_launcher package for this
                      },
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
