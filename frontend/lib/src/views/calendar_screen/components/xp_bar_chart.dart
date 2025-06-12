import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../constants/color_list.dart';

const String backgroundColorHex = SPACE_CADET;
final Color backgroundColor = Color(int.parse('0xFF$backgroundColorHex'));

const String buttonHex = JORDY_BLUE;
final Color buttonColor = Color(int.parse('0xFF$buttonHex'));

const String textColorHex = GHOST_WHITE;
final Color textColor = Color(int.parse('0xFF$textColorHex'));

const String secondaryColorHex = OXFORD_BLUE;
final Color secondaryColor = Color(int.parse('0xFF$secondaryColorHex'));

const String accentColorHex = ROSY_BROWN;
final Color accentColor = Color(int.parse('0xFF$accentColorHex'));

class XpBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Fixed height for proper scrolling
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Enable horizontal scrolling
        child: Container(
          width: 800, // Adjusted for better spacing
          padding: EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              barGroups: _getBarGroups(),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white24,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              groupsSpace: 4, // Bars are closer together
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 10, // Shows every 10 minutes
                    getTitlesWidget: (value, meta) {
                      if (value % 10 == 0 && value >= 0 && value <= 59) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 1.0),
                          child: Text(
                            '${value.toInt()} min',
                            style: TextStyle(fontSize: 12, color: textColor),
                            textAlign: TextAlign.right,
                          ),
                        );
                      }
                      return Container(); // Hide other labels
                    },
                  ),
                ),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1, // Show all hour labels
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatHour(value.toInt()),
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Generates bar groups dynamically
  List<BarChartGroupData> _getBarGroups() {
    //TODO: ADD REAL USER DATA
    List<int> minuteData = [
      15,
      25,
      30,
      40,
      10,
      50,
      35,
      45,
      20,
      55,
      5,
      38,
      42,
      18,
      28,
      33
    ];
    List<BarChartGroupData> bars = [];

    for (int i = 0; i < minuteData.length; i++) {
      bars.add(
        BarChartGroupData(
          x: i,
          barsSpace: 2, // Reduce spacing between bars
          barRods: [
            BarChartRodData(
              toY: minuteData[i].toDouble(),
              color: buttonColor,
              width: 8, // Slightly thinner bars
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return bars;
  }

  /// Formats hours into correct labels
  String _formatHour(int index) {
    List<String> hourLabels = [
      "8:00",
      "9:00",
      "10:00",
      "12:00",
      "13:00",
      "14:00",
      "15:00",
      "16:00",
      "17:00",
      "18:00",
      "19:00",
      "20:00",
      "21:00",
      "22:00",
      "23:00",
      "23:59"
    ];
    return index < hourLabels.length ? hourLabels[index] : '';
  }
}
