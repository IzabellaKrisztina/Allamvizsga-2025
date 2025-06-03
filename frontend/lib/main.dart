import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_mind/src/controllers/navigation_controller.dart';
import 'package:sound_mind/src/controllers/survey_controller.dart';
import 'package:sound_mind/src/models/auth_provider.dart';
import 'package:sound_mind/src/models/playlist_provider.dart';
import 'package:sound_mind/src/models/registProvider.dart';
import 'package:sound_mind/src/models/survey_provider.dart';
import 'package:sound_mind/src/models/track_provider.dart';
import 'package:sound_mind/src/views/home_screen/components/wheel.dart';
import 'package:sound_mind/src/views/splash_screen/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized

  await dotenv.load(fileName: ".env");

  final prefs =
      await SharedPreferences.getInstance(); // Initialize SharedPreferences

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (context) => SurveyProvider()),
        ChangeNotifierProvider(create: (context) => WheelController()),
        ChangeNotifierProxyProvider<SurveyProvider, SurveyController>(
          create: (context) => SurveyController(
            10,
            Provider.of<SurveyProvider>(context, listen: false),
          ),
          update: (context, surveyProvider, previousController) =>
              SurveyController(10, surveyProvider),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),
        ChangeNotifierProvider(create: (context) => RegistProvider()),
        ChangeNotifierProvider(create: (context) => TrackProvider()),
      ], 
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound Mind',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
