import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_mind/constants/color_list.dart';
import 'package:sound_mind/constants/image_path.dart';
import 'package:sound_mind/src/controllers/navigation_controller.dart';
import 'package:sound_mind/src/views/login_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playIntroMusic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNextScreen();
    });
  }

  Future<void> _playIntroMusic() async {
    await _audioPlayer.play(AssetSource("sounds/intro.mp3"));
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final navController =
            Provider.of<NavigationController>(context, listen: false);
        navController.navigateToPage(context,  LoginScreen());
        //navController.navigateToPage(context,  SurveyScreen());
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String backgroundColorHex = SPACE_CADET;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 5.0, end: 0.0),
          duration: const Duration(seconds: 2),
          builder: (context, blurValue, child) {
            return ImageFiltered(
              imageFilter:
                  ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
              child: child,
            );
          },
          child: SizedBox(
            width: 300,
            height: 300,
            child: Image.asset(LOGO_IMAGE),
          ),
        ),
      ),
    );
  }
}
