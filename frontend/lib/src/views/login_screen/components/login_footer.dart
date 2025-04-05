import 'package:flutter/material.dart';
import 'package:sound_mind/src/views/register_screen/register_screen.dart';

Row LoginFooter(BuildContext context, Color buttonColor) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Don\'t have an account?',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(
        width: 10,
      ),
      GestureDetector(
        onTap: () async {
          await Future.delayed(Duration(seconds: 2));
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          );
        },
        child: Text(
          'Register now!',
          style: TextStyle(
            color: buttonColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
