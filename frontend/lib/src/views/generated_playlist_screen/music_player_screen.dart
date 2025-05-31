// import 'package:audioplayers/audioplayers.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:sound_mind/src/models/spotify_authenticate.dart';
import '../../../constants/color_list.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class MusicPlayerScreen extends StatefulWidget {
  final List<String> musicList;
  final List<String> coverArtistList;
  final List<String> trackNames;
  final List<String> artistNames;
  final List<String> albumNames;
  final List<String> releaseDates;
  final int initialIndex;

  const MusicPlayerScreen({
    super.key,
    required this.musicList,
    required this.coverArtistList,
    required this.trackNames,
    required this.artistNames,
    required this.albumNames,
    required this.releaseDates,
    required this.initialIndex,
  });

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  // final _secureStorage = const FlutterSecureStorage();
  // String? _accessToken;

  // late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  // Duration _duration = Duration.zero;
  // Duration _position = Duration.zero;
  int _currentIndex;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  _MusicPlayerScreenState() : _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // _audioPlayer = AudioPlayer();
    _currentIndex = widget.initialIndex;

    // _audioPlayer.onDurationChanged.listen((d) {
    //   setState(() {
    //     _duration = d;
    //   });
    // });

    // _audioPlayer.onPositionChanged.listen((p) {
    //   setState(() {
    //     _position = p;
    //   });
    // });

    // _audioPlayer.onPlayerComplete.listen((_) {
    //   setState(() {
    //     _isPlaying = false;
    //     _position = Duration.zero;
    //   });
    // });

    _play();
  }

  @override
  void dispose() {
    // _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(int.parse('0xFF$COLOR_OLIVINE'));
    final Color textColor = Color(int.parse('0xFF$COLOR_DARK_PURPLE'));
    final Color lightGreenColor = Color(int.parse('0xFF$COLOR_ASH_GRAY'));

    String releaseYear = widget.releaseDates[_currentIndex].split('-')[0];

    return Scaffold(
      body: Container(
        color: backgroundColor,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center content horizontally
          children: [
            // Album Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Hero(
                tag: 'music $_currentIndex',
                child: Image.network(
                  widget.coverArtistList[_currentIndex],
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),

            Center(
              child: Text(
                widget.artistNames[_currentIndex],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Track Name
            Center(
              child: Text(
                widget.trackNames[_currentIndex],
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Album Name with Year
            Center(
              child: Text(
                '${widget.albumNames[_currentIndex]} ($releaseYear)',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8),

            SizedBox(height: 20),

            // Song Progress Slider
            // Slider(
            //   activeColor: textColor,
            //   inactiveColor: lightGreenColor,
            //   min: 0,
            //   max: _duration.inSeconds.toDouble(),
            //   value: _position.inSeconds.toDouble(),
            //   onChanged: (value) async {
            //     final position = Duration(seconds: value.toInt());
            //     await _audioPlayer.seek(position);
            //     await _audioPlayer.resume();
            //   },
            // ),

            // Time Labels
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(_formatTime(_position),
            //         style: TextStyle(color: textColor)),
            //     Text(_formatTime(_duration),
            //         style: TextStyle(color: textColor)),
            //   ],
            // ),
            SizedBox(height: 20),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _prev,
                  icon: Icon(Icons.skip_previous, size: 36, color: textColor),
                ),
                IconButton(
                  onPressed: () async {
                    if (_isPlaying) {
                      await _pause();
                    } else {
                      await _resume();
                    }
                  },
                  icon: Icon(
                      _isPlaying ? Icons.pause_circle : Icons.play_circle,
                      size: 36,
                      color: textColor),
                ),
                IconButton(
                  onPressed: _next,
                  icon: Icon(Icons.skip_next, size: 36, color: textColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _play() async {
    final accessToken = await getValidAccessToken();
    if (accessToken == null) {
      debugPrint('[ERROR] Token missing or expired.');
      return;
    }

    final deviceId = await _getActiveDeviceId(accessToken);
    debugPrint('[DEBUG] Active device ID: $deviceId');
    if (deviceId == null) {
      debugPrint(
          '[ERROR] No active device found. Is Spotify running on a device?');
      return;
    }

    await http.put(
      Uri.parse('https://api.spotify.com/v1/me/player'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'device_ids': [deviceId],
        'play': true
      }),
    );

    final trackUri = widget.musicList[_currentIndex];
    debugPrint(
        '[DEBUG] Attempting to play URI: $trackUri on device: $deviceId');

    final response = await http.put(
      Uri.parse(
          'https://api.spotify.com/v1/me/player/play?device_id=$deviceId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'uris': [trackUri]
      }),
    );

    if (response.statusCode == 204) {
      setState(() {
        _isPlaying = true;
      });
      debugPrint('[DEBUG] Playback started');
    } else {
      debugPrint(
          '[ERROR] Failed to start playback: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> _pause() async {
    final accessToken = await getValidAccessToken();
    if (accessToken == null) return;

    final deviceId = await _getActiveDeviceId(accessToken);
    debugPrint('[DEBUG] Active device ID: $deviceId');
    if (deviceId == null) {
      debugPrint(
          '[ERROR] No active device found. Is Spotify running on a device?');
      return;
    }

    await http.put(
      Uri.parse('https://api.spotify.com/v1/me/player'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'device_ids': [deviceId],
        'play': true
      }),
    );

    final response = await http.put(
      Uri.parse(
          'https://api.spotify.com/v1/me/player/pause?device_id=$deviceId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      setState(() => _isPlaying = false);
      debugPrint('[DEBUG] Playback paused');
    } else {
      debugPrint(
          '[ERROR] Pause failed: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> _resume() async {
    final accessToken = await getValidAccessToken();
    if (accessToken == null) return;

    final deviceId = await _getActiveDeviceId(accessToken);
    debugPrint('[DEBUG] Active device ID: $deviceId');
    if (deviceId == null) {
      debugPrint(
          '[ERROR] No active device found. Is Spotify running on a device?');
      return;
    }

    await http.put(
      Uri.parse('https://api.spotify.com/v1/me/player'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'device_ids': [deviceId],
        'play': true
      }),
    );

    final playbackStateResponse = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/player'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (playbackStateResponse.statusCode == 200) {
      final playbackState = jsonDecode(playbackStateResponse.body);
      if (playbackState['item'] != null) {
        final response = await http.put(
          Uri.parse(
              'https://api.spotify.com/v1/me/player/play?device_id=$deviceId'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (response.statusCode == 204) {
          setState(() => _isPlaying = true);
          debugPrint('[DEBUG] Playback resumed');
        } else {
          debugPrint(
              '[ERROR] Resume failed: ${response.statusCode} ${response.body}');
        }
      } else {
        await _play();
      }
    } else {
      debugPrint(
          '[ERROR] Failed to retrieve playback state: ${playbackStateResponse.statusCode} ${playbackStateResponse.body}');
    }
  }

  Future<void> _next() async {
    final accessToken = await getValidAccessToken();
    if (accessToken == null) return;

    await http.post(
      Uri.parse('https://api.spotify.com/v1/me/player/next'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (_currentIndex < widget.musicList.length - 1) {
      setState(() => _currentIndex++);
      _carouselController.jumpToPage(_currentIndex);
      await _play();
    }
  }

  Future<void> _prev() async {
    final accessToken = await getValidAccessToken();
    if (accessToken == null) return;

    await http.post(
      Uri.parse('https://api.spotify.com/v1/me/player/previous'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _carouselController.jumpToPage(_currentIndex);
      await _play();
    }
  }

  Future<String?> _getActiveDeviceId(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/player/devices'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final devices = jsonDecode(response.body)['devices'];
      for (var d in devices) {
        if (d['is_active'] == true) return d['id'];
      }
      if (devices.isNotEmpty) return devices[0]['id'];
    }

    debugPrint('[ERROR] Could not fetch devices: ${response.body}');
    return null;
  }

  String _formatTime(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(position.inHours);
    final minutes = twoDigits(position.inMinutes.remainder(60));
    final seconds = twoDigits(position.inSeconds.remainder(60));
    return [if (position.inHours > 0) hours, minutes, seconds].join(':');
  }
}
