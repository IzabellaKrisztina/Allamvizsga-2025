import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sound_mind/src/models/auth_provider.dart';
import 'package:sound_mind/src/models/registProvider.dart';
import 'package:sound_mind/src/views/home_screen/home_screen.dart';
import 'package:sound_mind/src/views/register_screen/components/register_button.dart';
import 'package:sound_mind/src/views/login_screen/login_screen.dart';

import '../../../constants/color_list.dart';
import '../../../constants/text_field_decoration.dart';
import 'components/register_footer.dart';

class RegisterScreen extends StatefulWidget {
  //static String id = 'registration_page';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String email = "";
  String password = "";
  String userName = "";
  String profilePicture = "";
  bool showSpinner = false;

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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final registProvider = Provider.of<RegistProvider>(context, listen: false);

    final baseUrl = dotenv.env['BASE_URL']!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
              onPressed: () async {
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Row(
                children: [
                  Text(
                    "Skip",
                    style: TextStyle(
                        color: buttonColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_forward, color: buttonColor, size: 25),
                ],
              )),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: backgroundColor,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Sign Up',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: textColor),
              ),
              SizedBox(
                height: 16.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  userName = value;
                },
                decoration: kTextFieldDecoration(
                  hintText: 'Add a username',
                ).copyWith(
                  // filled: true,
                  // fillColor: secondaryColor.withOpacity(0.5),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor, width: 2.0), //
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                style: TextStyle(
                  color: textColor,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration(
                  hintText: 'Enter your email',
                ).copyWith(
                  // filled: true,
                  // fillColor: secondaryColor.withOpacity(0.5),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor, width: 2.0), //
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                style: TextStyle(
                  color: textColor,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration(
                  hintText: 'Enter your password',
                ).copyWith(
                  // filled: true,
                  // fillColor: secondaryColor.withOpacity(0.5),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor, width: 2.0), //
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                style: TextStyle(
                  color: textColor,
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RegisterButton(
                colour: buttonColor,
                textColor: secondaryColor,
                title: 'Register',
                onPress: () async {
                  if (userName.isEmpty || email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All fields are required!')),
                    );
                    return;
                  }

                  if (userName.length < 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Username must be at least 4 characters long!')),
                    );
                    return;
                  }

                  if (!RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                      .hasMatch(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid email format!')),
                    );
                    return;
                  }

                  if (password.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Password must be at least 6 characters long!')),
                    );
                    return;
                  }

                  setState(() {
                    showSpinner = true;
                  });

                  try {
                    var response = await http.post(
                      Uri.parse('$baseUrl/auth/registration'),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "username": userName,
                        "email": email,
                        "password": password,
                        "profile_picture": profilePicture,
                      }),
                    );

                    if (response.statusCode == 200) {
                      var data = jsonDecode(response.body);
                      // print("Registration successful: ${data['message']}");

                      // await authProvider.login(data['access_token']);

                      registProvider.setRegistered(true);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Registration successful!')),
                      );

                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    } else {
                      var data = jsonDecode(response.body);
                      String errorMessage =
                          data['message'] ?? 'Registration failed!';
                      print("Registration unsuccessful: $errorMessage");

                      if (errorMessage.contains("already exists")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User already exists!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage)),
                        );
                      }
                    }
                  } catch (e) {
                    print("Error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Something went wrong!')),
                    );
                  } finally {
                    setState(() {
                      showSpinner = false;
                    });
                  }
                },
              ),
              SizedBox(
                height: 24.0,
              ),
              //TODO: ADD NAVIGATION TO REGISTER_FOOTER
              RegisterFooter(context, buttonColor, textColor),
            ],
          ),
        ),
      ),
    );
  }
}
