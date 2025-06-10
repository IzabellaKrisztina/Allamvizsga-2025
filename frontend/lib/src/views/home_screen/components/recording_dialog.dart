import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sound_mind/src/models/track_provider.dart';
import 'package:sound_mind/src/views/generated_playlist_screen/generated_playlist.dart';

class RecordingDialog extends StatefulWidget {
  @override
  _RecordingDialogState createState() => _RecordingDialogState();
}

class _RecordingDialogState extends State<RecordingDialog> {
  final AudioRecorder _recorder = AudioRecorder();
  final RecorderController _recorderController = RecorderController();
  bool _isRecording = false;
  String? _filePath;
  Timer? _timer;
  int _recordDuration = 0;
  bool _showPostRecordingOptions = false;
  final TextEditingController _fileNameController = TextEditingController();
  bool _isPlaying = false;
  PlayerController? _playerController;
  bool _recordingStarted = false;
  final baseUrl = dotenv.env['BASE_URL']!;

  @override
  void initState() {
    super.initState();
    //_startRecording();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      Navigator.of(context).pop();
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    await _recorderController.record(path: path);

    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        _recordDuration++;
      });
    });

    setState(() {
      _isRecording = true;
      _filePath = path;
      _recordingStarted = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
    await _recorderController.stop();
    await Future.delayed(Duration(milliseconds: 500));
    _timer?.cancel();

    setState(() {
      _isRecording = false;
      _showPostRecordingOptions = true;
      _fileNameController.text = _filePath != null
          ? _filePath!.split('/').last.replaceAll('.wav', '')
          : '';
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _saveRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    final newPath = '${directory.path}/${_fileNameController.text}.wav';
    final recordedFile = File(_filePath!);

    try {
      await recordedFile.rename(newPath);

      final fileToUpload = File(newPath);
      final uri = Uri.parse('$baseUrl/mood/analyze_audio_mood');

      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          fileToUpload.path,
          contentType: MediaType('audio', 'wav'),
          // contentType: MediaType('audio', 'x-wav'), 
        ));

      final response = await request.send();

      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        debugPrint("✅ Audio sent successfully");
        final Map<String, dynamic> responseData = jsonDecode(responseBody.body);
        if (responseData.containsKey("songs") &&
            responseData["songs"] is List) {
          final List<dynamic> playlistsData = responseData["songs"];

          // Save the response to the provider
          final trackProvider =
              Provider.of<TrackProvider>(context, listen: false);
          trackProvider.setTracks(playlistsData.cast<Map<String, dynamic>>());

          debugPrint("Tracks saved successfully");
        } else {
          debugPrint("⚠️ Response: ${responseBody.body}");
          throw Exception("Invalid response format: 'playlists' key not found");
        }
      } else {
        throw Exception("Failed to send data");
      }
    } catch (e) {
      debugPrint("❌ Exception during saving/sending: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GeneratedPlaylist()),
    );
  }

  Future<void> _discardRecording() async {
    final recordedFile = File(_filePath!);
    if (await recordedFile.exists()) {
      await recordedFile.delete();
    }
    Navigator.of(context).pop();
  }

  Future<void> _playRecording() async {
    if (_filePath == null) return;

    _playerController = PlayerController();
    await _playerController!.preparePlayer(path: _filePath!);
    _playerController!.startPlayer();

    setState(() {
      _isPlaying = true;
    });

    _playerController!.onCompletion.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> _stopPlayback() async {
    await _playerController?.stopPlayer();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _recorderController.dispose();
    _recorder.dispose();
    _timer?.cancel();
    _playerController?.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 10,
        right: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 👇 Display instructions BEFORE and DURING recording (but not after)
          if (!_showPostRecordingOptions)
            Column(
              children: [
                Text(
                  'Please say the following sentence out loud:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  '"Kids are talking by the door."',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
              ],
            ),

          // 👇 Show duration and "Recording in progress..." only when recording
          if (_isRecording)
            Column(
              children: [
                Text(
                  'Recording in progress...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  _formatDuration(_recordDuration),
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
                SizedBox(height: 20),
              ],
            ),

          // 👇 Show waveform only during active recording
          if (_isRecording)
            AudioWaveforms(
              enableGesture: false,
              size: Size(MediaQuery.of(context).size.width, 100.0),
              recorderController: _recorderController,
              waveStyle: WaveStyle(
                waveColor: Colors.blue,
                extendWaveform: true,
                showMiddleLine: false,
              ),
            ),

          SizedBox(height: 20),

          // 👇 START & STOP buttons BEFORE recording starts
          if (!_recordingStarted && !_showPostRecordingOptions)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _startRecording,
                  icon: Icon(Icons.mic),
                  label: Text('Start'),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(), // Optional cancel
                  icon: Icon(Icons.close),
                  label: Text('Cancel'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),

          // 👇 STOP button only when actively recording
          if (_isRecording)
            ElevatedButton.icon(
              onPressed: _stopRecording,
              icon: Icon(Icons.stop),
              label: Text('Stop'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),

          // 👇 Post-recording options (rename, play, save, discard)
          if (_showPostRecordingOptions) ...[
            Text(
              'Recorded Duration: ${_formatDuration(_recordDuration)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _fileNameController,
              decoration: InputDecoration(labelText: 'Rename file'),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                ElevatedButton.icon(
                  onPressed: _isPlaying ? _stopPlayback : _playRecording,
                  icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                  label: Text(_isPlaying ? 'Stop' : 'Play'),
                ),
                ElevatedButton.icon(
                  onPressed: _saveRecording,
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                ),
                ElevatedButton.icon(
                  onPressed: _discardRecording,
                  icon: Icon(Icons.delete),
                  label: Text('Discard'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
