import 'package:flutter/material.dart';

class NavigationController {
  void navigateToGuest(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      '/non-user',
    );
  }

  void navigateToUser(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      '/user',
    );
  }

  void navigateToLogout(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      '/logout',
    );
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }
}
