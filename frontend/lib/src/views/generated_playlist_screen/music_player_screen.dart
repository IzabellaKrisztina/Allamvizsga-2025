import 'package:audioplayers/audioplayers.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';

import 'package:flutter/material.dart';

import '../../../constants/color_list.dart';

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
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentIndex;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  _MusicPlayerScreenState() : _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentIndex = widget.initialIndex;
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });

    _play();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
            Slider(
              activeColor: textColor,
              inactiveColor: lightGreenColor,
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await _audioPlayer.seek(position);
                await _audioPlayer.resume();
              },
            ),

            // Time Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(_position),
                    style: TextStyle(color: textColor)),
                Text(_formatTime(_duration),
                    style: TextStyle(color: textColor)),
              ],
            ),
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
                  onPressed: _isPlaying ? _pause : _play,
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

  void _play() async {
    await _audioPlayer.play(UrlSource(widget.musicList[_currentIndex]));
    setState(() {
      _isPlaying = true;
    });
  }

  void _pause() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  void _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });
  }

  void _next() {
    if (_currentIndex < widget.musicList.length - 1) {
      _currentIndex++;
      _carouselController.jumpToPage(_currentIndex);
      _play();
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _carouselController.jumpToPage(_currentIndex);
      _play();
    }
  }

  String _formatTime(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(position.inHours);
    final minutes = twoDigits(position.inMinutes.remainder(60));
    final seconds = twoDigits(position.inSeconds.remainder(60));
    return [if (position.inHours > 0) hours, minutes, seconds].join(':');
  }
}
