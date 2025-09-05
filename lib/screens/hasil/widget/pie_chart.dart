import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class JawabanPieChart extends StatelessWidget {
  final Map<String, dynamic> jawaban;

  const JawabanPieChart({super.key, required this.jawaban});

  @override
  Widget build(BuildContext context) {
    final count = {"mampu": 0, "bantuan": 0, "belum": 0};

    for (final ans in jawaban.values) {
      if (ans == 3) {
        count["mampu"] = count["mampu"]! + 1;
      } else if (ans == 2) {
        count["bantuan"] = count["bantuan"]! + 1;
      } else if (ans == 1) {
        count["belum"] = count["belum"]! + 1;
      }
    }

    final total = count.values.reduce((a, b) => a + b);

    final sections = [
      PieChartSectionData(
        value: count["mampu"]!.toDouble(),
        color: Colors.green,
        title: total > 0 ? "${count["mampu"]}" : '',
        radius: 60,
      ),
      PieChartSectionData(
        value: count["bantuan"]!.toDouble(),
        color: Colors.orange,
        title: total > 0 ? "${count["bantuan"]}" : '',
        radius: 60,
      ),
      PieChartSectionData(
        value: count["belum"]!.toDouble(),
        color: Colors.red,
        title: total > 0 ? "${count["belum"]}" : '',
        radius: 60,
      ),
    ];

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 1,
        centerSpaceRadius: 0,
        startDegreeOffset: 270,
      ),
    );
  }
}
