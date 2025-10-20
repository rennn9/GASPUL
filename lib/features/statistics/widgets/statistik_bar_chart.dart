import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatistikBarChart extends StatefulWidget {
  final Map<String, Map<String, double>> data;
  // Format data: {'Bidang A': {'total': 10, 'selesai': 7}, ...}
  const StatistikBarChart({super.key, required this.data});

  @override
  State<StatistikBarChart> createState() => _StatistikBarChartState();
}

class _StatistikBarChartState extends State<StatistikBarChart> {
  int touchedIndex = -1;
  int rotationTurns = 1; // 90° CW rotation

  @override
  Widget build(BuildContext context) {
    final keys = widget.data.keys.toList();

    // Cari max value dari semua total & selesai
    final maxY = widget.data.values
            .map((v) => [v['total'] ?? 0, v['selesai'] ?? 0])
            .expand((e) => e)
            .fold<double>(0, (prev, e) => e > prev ? e : prev) *
        1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ✅ Title Grafik Pelayanan
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            'Grafik Layanan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 1.4,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barGroups: List.generate(keys.length, (index) {
                final bidang = widget.data[keys[index]]!;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: bidang['total'] ?? 0,
                      color: Colors.blue,
                      width: 10,
                    ),
                    BarChartRodData(
                      toY: bidang['selesai'] ?? 0,
                      color: Colors.green,
                      width: 10,
                    ),
                  ],
                  showingTooltipIndicators: touchedIndex == index ? [0, 1] : [],
                );
              }),
              alignment: BarChartAlignment.spaceAround,
              rotationQuarterTurns: rotationTurns,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                bottomTitles: const AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: true, reservedSize: 28)),
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: true),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final label = rodIndex == 0 ? 'Total' : 'Selesai';
                    return BarTooltipItem(
                      '$label: ${rod.toY.toInt()}',
                      const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                touchCallback: (event, response) {
                  if (event.isInterestedForInteractions &&
                      response != null &&
                      response.spot != null) {
                    setState(() {
                      touchedIndex = response.spot!.touchedBarGroupIndex;
                    });
                  } else {
                    setState(() {
                      touchedIndex = -1;
                    });
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Mapping nomor → bidang
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: List.generate(keys.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${index}: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(keys[index]),
              ],
            );
          }),
        ),
        const SizedBox(height: 8),
        // Legend warna
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.square, color: Colors.blue, size: 16),
            SizedBox(width: 4),
            Text('Total'),
            SizedBox(width: 16),
            Icon(Icons.square, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text('Selesai'),
          ],
        ),
      ],
    );
  }
}
