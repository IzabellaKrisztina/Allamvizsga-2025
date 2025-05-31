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
    final Color backgroundColor = Color(int.parse('0xFF$COLOR_OLIVINE'));

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

                  return Card(
                    color: Color(int.parse('0xFF$COLOR_ASH_GRAY')),
                    elevation: 6,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
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
                          color: Color(int.parse('0xFF$COLOR_DARK_PURPLE')),
                        ),
                      ),
                      subtitle: Text(
                        track["artist_name"],
                        style: TextStyle(
                          color: Color(int.parse('0xFF$COLOR_DARK_PURPLE')),
                        ),
                      ),
                      trailing: Icon(
                        Icons.play_arrow,
                        color: Color(int.parse('0xFF$COLOR_DARK_PURPLE')),
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
