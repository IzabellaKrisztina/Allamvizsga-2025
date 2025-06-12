import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_mind/src/models/spotify_authenticate.dart';
import 'package:sound_mind/src/models/track_provider.dart';

import '../../../constants/color_list.dart';
import 'music_player_screen.dart';

class GeneratedPlaylist extends StatefulWidget {
  @override
  State<GeneratedPlaylist> createState() => _GeneratedPlaylistState();
}

class _GeneratedPlaylistState extends State<GeneratedPlaylist> {
  @override
  void initState() {
    super.initState();
    authenticateWithSpotify().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: SafeArea(
          child: Consumer<TrackProvider>(
            builder: (context, trackProvider, child) {
              final tracks = trackProvider.tracks;

              if (tracks.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.transparent.withOpacity(0.3),
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
                        child: Hero(
                          tag: 'music $index',
                          child: Image.network(
                            track["album_cover_url"],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        track["track_name"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: buttonColor,
                        ),
                      ),
                      subtitle: Text(
                        track["artist_name"],
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.play_arrow,
                        color: buttonColor,
                        size: 28,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MusicPlayerScreen(
                              musicList: tracks
                                  .map<String>((track) => track["track_uri"])
                                  .toList(),
                              coverArtistList: tracks
                                  .map<String>(
                                      (track) => track["album_cover_url"])
                                  .toList(),
                              trackNames: tracks
                                  .map<String>((track) => track["track_name"])
                                  .toList(),
                              artistNames: tracks
                                  .map<String>((track) => track["artist_name"])
                                  .toList(),
                              albumNames: tracks
                                  .map<String>((track) => track["album_name"])
                                  .toList(),
                              releaseDates: tracks
                                  .map<String>((track) => track["release_date"])
                                  .toList(),
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
