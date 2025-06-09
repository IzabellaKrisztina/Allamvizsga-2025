import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sound_mind/src/models/auth_provider.dart';
import 'package:sound_mind/src/views/home_screen/home_screen.dart';
import 'package:sound_mind/src/views/login_screen/components/login_button.dart';
import 'package:sound_mind/src/views/survey_screen/survey_screen.dart';
import '../../../constants/color_list.dart';
import '../../../constants/text_field_decoration.dart';
import 'components/login_footer.dart';

class LoginScreen extends StatefulWidget {
  //static String id = 'login_page';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String userName;
  late String password;
  bool showSpinner = false;
  final baseUrl = dotenv.env['BASE_URL']!;

  @override
  Widget build(BuildContext context) {
    const String backgroundColorHex = COLOR_OLIVINE;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    const String buttonHex = COLOR_CHARCOAL;
    final Color buttonColor = Color(int.parse('0xFF$buttonHex'));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
              onPressed: () {
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
                'Sign In',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  //keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    userName = value;
                  },
                  decoration: kTextFieldDecoration(
                    hintText: 'Enter your username',
                  )),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration(hintText: 'Enter password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              LoginButton(
                colour: buttonColor,
                title: 'Log in',
                onPress: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    var response = await http.post(
                      Uri.parse(
                          '$baseUrl/auth/login'),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "username": userName,
                        "password": password,
                      }),
                    );

                    if (response.statusCode == 200) {
                      var data = jsonDecode(response.body);
                      print("Login successful: ${data['access_token']}");

                      await authProvider.login(data['access_token']);
                     
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SurveyScreen(),
                        ),
                      );
                    } else {
                      print("Login failed: ${response.body}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid username or password'),
                        ),
                      );
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
              LoginFooter(context, buttonColor)
            ],
          ),
        ),
      ),
    );
  }
}
