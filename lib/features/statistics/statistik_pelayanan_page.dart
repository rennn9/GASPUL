import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:gaspul/features/statistics/widgets/statistik_bar_chart.dart';
import 'package:gaspul/features/statistics/widgets/statistik_table_card.dart';
import 'package:gaspul/features/statistics/widgets/total_pelayanan_card.dart';
import 'package:gaspul/features/home/widgets/main_app_bar.dart';

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

  late ConfettiController _confettiController;
  bool _hasPlayedConfetti = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    fetchStatistik();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => fetchStatistik(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> fetchStatistik() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.21:8000/api/statistik-pelayanan'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetched = json.decode(response.body);
        if (json.encode(fetched) != json.encode(statistik)) {
          setState(() {
            statistik = fetched;
            lastUpdated = DateFormat(
              'dd-MM-yyyy HH:mm:ss',
            ).format(DateTime.now());
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

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);
    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
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

    return Scaffold(
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
                  // ✅ Card Total Pelayanan + Confetti di dalamnya
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: totalPelayananBerhasil.toDouble(),
                    ),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      if (!_hasPlayedConfetti &&
                          value.toInt() >= totalPelayananBerhasil) {
                        _confettiController.play();
                        _hasPlayedConfetti = true;
                      }

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: TotalPelayananCard(total: value.toInt()),
                          ),
                          Positioned(
                            top: 24,
                            left:
                                MediaQuery.of(context).size.width / 2 -
                                20, // posisikan ke tengah
                            child: IgnorePointer(
                              child: ConfettiWidget(
                                confettiController: _confettiController,
                                blastDirectionality:
                                    BlastDirectionality.directional,
                                blastDirection: -pi / 2, // ke atas
                                emissionFrequency: 0.05, // lebih jarang
                                numberOfParticles: 2, // lebih sedikit
                                maxBlastForce: 2, // jarak semburan maksimum
                                minBlastForce: 1, // jarak semburan minimum
                                gravity: 0.4, // partikel cepat jatuh
                                colors: const [
                                  Colors.green,
                                  Colors.blue,
                                  Colors.pink,
                                  Colors.orange,
                                  Colors.purple,
                                ],
                                createParticlePath: drawStar,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                    animatedNumber: (int value) =>
                        TweenAnimationBuilder<double>(
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
