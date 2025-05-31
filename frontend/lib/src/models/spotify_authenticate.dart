import 'package:flutter/cupertino.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final storage = FlutterSecureStorage();

Future<void> authenticateWithSpotify() async {
  try {
    final clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;
    final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!;
    final redirectUri = dotenv.env['SPOTIFY_REDIRECT_URI']!;
    final scopes = 'user-read-playback-state user-modify-playback-state';

    final authUrl =
        'https://accounts.spotify.com/authorize?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&scope=$scopes';

    final result = await FlutterWebAuth.authenticate(
        url: authUrl, callbackUrlScheme: 'soundmind');

    final code = Uri.parse(result).queryParameters['code'];

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code!,
        'redirect_uri': redirectUri,
      },
    );

    final responseData = json.decode(response.body);
    final accessToken = responseData['access_token'];
    final refreshToken = responseData['refresh_token'];
    final expiresIn = responseData['expires_in'];

    final expiryTime =
        DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();

    debugPrint('[DEBUG] Access token: $accessToken');
    debugPrint('[DEBUG] Refresh token: $refreshToken');

    await storage.write(key: 'spotify_access_token', value: accessToken);
    await storage.write(key: 'spotify_refresh_token', value: refreshToken);
    await storage.write(key: 'spotify_token_expiry', value: expiryTime);
  } catch (e) {
    debugPrint('Authentication error: $e');
  }
}

Future<void> refreshSpotifyAccessToken() async {
  try {
    final clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;
    final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!;
    final refreshToken = await storage.read(key: 'spotify_refresh_token') ?? '';

    if (refreshToken.isEmpty) {
      debugPrint('No refresh token found.');
      return;
    }

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
      },
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
    );

    final responseData = json.decode(response.body);
    final newAccessToken = responseData['access_token'];
    final expiresIn = responseData['expires_in']; // in seconds

    final newExpiryTime =
        DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();

    debugPrint('[DEBUG] New access token: $newAccessToken');

    await storage.write(key: 'spotify_access_token', value: newAccessToken);
    await storage.write(key: 'spotify_token_expiry', value: newExpiryTime);
  } catch (e) {
    debugPrint('Token refresh error: $e');
  }
}

Future<String?> getValidAccessToken() async {
  final accessToken = await storage.read(key: 'spotify_access_token');
  final expiryString = await storage.read(key: 'spotify_token_expiry');

  if (accessToken == null || expiryString == null) {
    return null;
  }

  final expiryTime = DateTime.parse(expiryString);
  if (DateTime.now().isAfter(expiryTime)) {
    await refreshSpotifyAccessToken();
    return await storage.read(key: 'spotify_access_token');
  }

  return accessToken;
}

//this is how to use get a valid token before making any spotify api calls
// final accessToken = await getValidAccessToken();
// if (accessToken != null) {
//   // Proceed with API calls using the accessToken
// } else {
//   // Handle the case where authentication is required
// }




// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:oauth2_client/oauth2_client.dart';
// import 'package:oauth2_client/oauth2_helper.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter/foundation.dart';

// final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

// final redirectUri = dotenv.env['SPOTIFY_REDIRECT_URL']!;
// final customUriScheme = dotenv.env['SPOTIFY_SCHEME']!;
// final clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;
// final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!;

// class SpotifyOAuth2Client extends OAuth2Client {
//   SpotifyOAuth2Client(
//       {required String redirectUri, required String customUriScheme})
//       : super(
//           authorizeUrl: 'https://accounts.spotify.com/authorize',
//           tokenUrl: 'https://accounts.spotify.com/api/token',
//           redirectUri: redirectUri,
//           customUriScheme: customUriScheme,
//         );
// }

// final client = SpotifyOAuth2Client(
//   redirectUri: redirectUri,
//   customUriScheme: customUriScheme,
// );

// final helper = OAuth2Helper(
//   client,
//   clientId: clientId,
//   clientSecret: clientSecret,
//   scopes: [
//     'user-read-playback-state',
//     'user-modify-playback-state',
//     'user-read-currently-playing'
//   ],
// );

// Future<void> authenticate() async {
//   debugPrint('[DEBUG] Starting Spotify authentication...');
//   try {
//     final tokenResponse = await helper.getToken();
//     debugPrint('[DEBUG] Token response: $tokenResponse');

//     if (tokenResponse != null && tokenResponse.accessToken != null) {
//       final accessToken = tokenResponse.accessToken!;
//       await _secureStorage.write(
//           key: 'spotify_access_token', value: accessToken);
//       debugPrint('[DEBUG] Access token saved successfully.');
//     } else {
//       debugPrint('[ERROR] Authentication failed: No access token obtained.');
//     }
//   } catch (e) {
//     debugPrint('[ERROR] Authentication error: $e');
//   }
// }
