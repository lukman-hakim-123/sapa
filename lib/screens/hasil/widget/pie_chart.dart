import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SubKategoriPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> subKategoriData;

  const SubKategoriPieChart({super.key, required this.subKategoriData});

  @override
  State<SubKategoriPieChart> createState() => _SubKategoriPieChartState();
}

class _SubKategoriPieChartState extends State<SubKategoriPieChart> {
  final colors = {
    "mampu": Colors.green,
    "bantuan": Colors.orange,
    "belum": Colors.red,
  };

  void _showDetailDialog(Map<String, dynamic> sub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(sub["subKategori"]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text("Mampu:"), Text("${sub["mampu"]}")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text("Bantuan:"), Text("${sub["bantuan"]}")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text("Belum:"), Text("${sub["belum"]}")],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[];
    final double basePortion = 100 / widget.subKategoriData.length;

    for (var sub in widget.subKategoriData) {
      final values = {
        "mampu": sub["mampu"] as int,
        "bantuan": sub["bantuan"] as int,
        "belum": sub["belum"] as int,
      };
      final total = values.values.reduce((a, b) => a + b);

      if (total == 0) {
        sections.add(
          PieChartSectionData(
            value: basePortion,
            color: Colors.grey[400],
            title: sub["subKategori"],
            radius: 70,
          ),
        );
      } else {
        for (var entry in values.entries) {
          if (entry.value > 0) {
            sections.add(
              PieChartSectionData(
                value: basePortion * (entry.value / total),
                color: colors[entry.key],
                title: "",
                radius: 70,
              ),
            );
          }
        }
      }
    }

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 1,
        centerSpaceRadius: 0,
        startDegreeOffset: 270,
        pieTouchData: PieTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (response?.touchedSection == null) return;
            if (event is FlTapUpEvent) {
              final index = response!.touchedSection!.touchedSectionIndex;
              int subIndex = 0;
              int sliceCount = 0;
              for (var i = 0; i < widget.subKategoriData.length; i++) {
                final sub = widget.subKategoriData[i];
                final values = [
                  sub["mampu"] as int,
                  sub["bantuan"] as int,
                  sub["belum"] as int,
                ].where((v) => v > 0).length;
                sliceCount += values;
                if (index < sliceCount) {
                  subIndex = i;
                  break;
                }
              }

              _showDetailDialog(widget.subKategoriData[subIndex]);
            }
          },
        ),
      ),
    );
  }
}
