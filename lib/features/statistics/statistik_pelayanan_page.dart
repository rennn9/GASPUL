// lib/features/statistics/statistik_pelayanan_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:gaspul/features/statistics/widgets/statistik_bar_chart.dart';
import 'package:gaspul/features/statistics/widgets/statistik_table_card.dart';
import 'package:gaspul/features/statistics/widgets/total_pelayanan_card.dart';
import 'package:gaspul/features/home/widgets/main_app_bar.dart';
import 'package:gaspul/core/widgets/gaspul_safe_scaffold.dart';
import 'package:gaspul/core/services/api_config.dart'; // <-- import ApiConfig

class StatistikPelayananPage extends StatefulWidget {
  const StatistikPelayananPage({super.key});

  @override
  State<StatistikPelayananPage> createState() => _StatistikPelayananPageState();
}

class _StatistikPelayananPageState extends State<StatistikPelayananPage> {
  List<dynamic> statistik = [];
  bool loading = true;
  String? error;
  String? lastUpdated;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchStatistik();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => fetchStatistik(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchStatistik() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/statistik-pelayanan'), // <-- pakai ApiConfig.baseUrl
      );
      if (response.statusCode == 200) {
        final List<dynamic> fetched = json.decode(response.body);
        if (json.encode(fetched) != json.encode(statistik)) {
          setState(() {
            statistik = fetched;
            lastUpdated = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
            loading = false;
            error = null;
          });
        } else {
          setState(() {
            loading = false;
          });
        }
      } else {
        setState(() {
          error = 'Gagal memuat data (${response.statusCode})';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Map<String, Map<String, double>> chartData = {
      for (var item in statistik)
        if (item['bidang_layanan'] != null)
          item['bidang_layanan'].toString(): {
            'total': double.tryParse(item['total'].toString()) ?? 0.0,
            'selesai': double.tryParse(item['selesai'].toString()) ?? 0.0,
          },
    };

    final int totalPelayananBerhasil = statistik.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item['selesai'].toString()) ?? 0),
    );

    return GasPulSafeScaffold(
      appBar: const MainAppBar(title: 'Statistik Pelayanan'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text('❌ $error', style: const TextStyle(fontSize: 16)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ✅ Card Total Pelayanan
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: TotalPelayananCard(total: totalPelayananBerhasil),
                      ),
                      const SizedBox(height: 12),

                      // Chart
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: StatistikBarChart(data: chartData),
                      ),

                      // Tabel
                      StatistikTableCard(
                        data: statistik,
                        lastUpdated: lastUpdated,
                        animatedNumber: (int value) => TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: value.toDouble()),
                          duration: const Duration(seconds: 1),
                          builder: (context, val, child) {
                            return Text(
                              val.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
