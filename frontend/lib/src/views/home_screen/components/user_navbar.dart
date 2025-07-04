import 'package:flutter/material.dart';
import 'package:sound_mind/constants/color_list.dart';
import 'package:sound_mind/constants/image_path.dart';
import 'package:sound_mind/src/views/calendar_screen/calendar_screen.dart';
import 'package:sound_mind/src/views/home_screen/home_screen.dart';
import 'package:sound_mind/src/views/profile_screen/profile_screen.dart';

class UserNavbar extends StatefulWidget {
  const UserNavbar({super.key});

  @override
  State<UserNavbar> createState() => _UserNavbarState();
}

class _UserNavbarState extends State<UserNavbar> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    const String backgroundColorHex = SPACE_CADET;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    const String buttonHex = JORDY_BLUE;
    final Color buttonColor = Color(int.parse('0xFF$buttonHex'));

    const String secondaryHex = OXFORD_BLUE;
    final Color secondaryColor = Color(int.parse('0xFF$secondaryHex'));

    return BottomAppBar(
      color: secondaryColor.withOpacity(0.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                buttonColor,
                BlendMode.srcIn,
              ),
              child: Image.asset(HOME_ICON),
            ),
            onPressed: () {
              setState(() {
                currentPageIndex = 0;
              });

              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                buttonColor,
                BlendMode.srcIn,
              ),
              child: Image.asset(CALENDAR_ICON),
            ),
            onPressed: () {
              setState(() {
                currentPageIndex = 1;
              });

              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                buttonColor,
                BlendMode.srcIn,
              ),
              child: Image.asset(USER_ICON),
            ),
            onPressed: () {
              setState(() {
                currentPageIndex = 4;
              });

              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
