import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_mind/src/views/home_screen/components/wheel.dart';

import '../../../../constants/color_list.dart';

class ActivitySelection extends StatefulWidget {
  const ActivitySelection({Key? key}) : super(key: key);

  @override
  _ActivitySelectionState createState() => _ActivitySelectionState();
}

class _ActivitySelectionState extends State<ActivitySelection> {
  String? selectedActivity;
  final List<String> activites = [
    'Traveling',
    'Exercising',
    'Dancing',
    'Cooking',
    'Cleaning',
    'Driving',
    'Studying',
    'Working',
    'Reading',
    'Painting',
    'Shopping',
    'Running',
    'Relaxing',
    'Gaming',
  ];

  @override
  Widget build(BuildContext context) {
    final wheelController =
        Provider.of<WheelController>(context, listen: false);

    const String backgroundColorHex = SPACE_CADET;
    final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

    const String buttonHex = JORDY_BLUE;
    final Color buttonColor = Color(int.parse('0xFF$buttonHex'));

    const String textColorHex = GHOST_WHITE;
    final Color textColor = Color(int.parse('0xFF$textColorHex'));

    const String secondaryColorHex = OXFORD_BLUE;
    final Color secondaryColor = Color(int.parse('0xFF$secondaryColorHex'));

    return PopupMenuButton<String>(
      color: buttonColor,
      onSelected: (activity) {
        setState(() {
          wheelController.updateActivity(activity);
        });
      },
      itemBuilder: (context) {
        return [
          // Whole 'Select a Genre' item is dark blue
          PopupMenuItem<String>(
            enabled: false,
            child: Container(
              color:
                  buttonColor, // Set the background color of the item to dark blue
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                child: Text(
                  'Select an Activity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: secondaryColor, // Set text color to light green
                  ),
                ),
              ),
            ),
          ),
          PopupMenuItem<String>(
            enabled: false,
            child: Container(
              height: 150,
              width: 300, // Set the height for the dropdown container
              color: buttonColor, // Background color for the dropdown
              child: ListWheelScrollView.useDelegate(
                itemExtent: 50, // Each genre height
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    if (index < activites.length) {
                      return ListTile(
                        title: Text(
                          activites[index],
                          style: TextStyle(
                            color: textColor, // Text color for each item
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(
                              context); // Close the dropdown when a genre is selected
                          setState(() {
                            selectedActivity = activites[index];
                          });
                          wheelController.updateActivity(activites[index]);
                        },
                      );
                    }
                    return null;
                  },
                  childCount: activites.length,
                ),
              ),
            ),
          ),
        ];
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: buttonColor, // Background color for the dropdown button
        ),
        child: Row(
          children: [
            Text(
              selectedActivity ?? 'Choose Activity',
              style: TextStyle(
                fontSize: 16,
                color: secondaryColor,
              ), // Text color for the button
            ),
            Spacer(),
            Icon(
              Icons.arrow_drop_down,
              color: secondaryColor, // Icon color
            ),
          ],
        ),
      ),
    );
  }
}
