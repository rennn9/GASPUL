import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:gaspul/core/services/survey_service.dart';
import 'survey_models.dart';

class QuestionStep extends StatefulWidget {
  final int currentQuestion;
  final List<SurveyQuestion> questions;
  final void Function(dynamic answer) nextQuestion;
  final VoidCallback previousQuestion;
  final Map<int, TextEditingController> questionControllers;
  final Map<String, dynamic> respondentData;

  const QuestionStep({
    super.key,
    required this.currentQuestion,
    required this.questions,
    required this.nextQuestion,
    required this.previousQuestion,
    required this.questionControllers,
    required this.respondentData,
  });

  @override
  State<QuestionStep> createState() => _QuestionStepState();
}

class _QuestionStepState extends State<QuestionStep> {
  int current = 0;

  // 🧭 Pemetaan nilai skala untuk semua opsi umum
  final Map<String, int> skalaNilai = {
    'Sangat sesuai': 4,
    'Sesuai': 3,
    'Kurang sesuai': 2,
    'Tidak sesuai': 1,
    'Sangat mudah': 4,
    'Mudah': 3,
    'Kurang mudah': 2,
    'Tidak mudah': 1,
    'Sangat cepat': 4,
    'Cepat': 3,
    'Kurang cepat': 2,
    'Tidak cepat': 1,
    'Gratis': 4,
    'Murah': 3,
    'Cukup mahal': 2,
    'Mahal': 1,
    'Sangat kompeten': 4,
    'Kompeten': 3,
    'Kurang kompeten': 2,
    'Tidak kompeten': 1,
    'Sangat sopan dan ramah': 4,
    'Sopan dan ramah': 3,
    'Kurang sopan': 2,
    'Tidak sopan': 1,
    'Sangat Baik': 4,
    'Baik': 3,
    'Cukup': 2,
    'Kurang': 1,
    'Dikelola dengan baik': 4,
    'Cukup baik': 3,
    'Kurang baik': 2,
    'Tidak baik': 1,
  };

  @override
  void initState() {
    super.initState();
    current = widget.currentQuestion;
    debugPrint("🟢 QuestionStep initialized - Current Question: $current");
    debugPrint("👤 Data responden saat ini:\n${const JsonEncoder.withIndent('  ').convert(widget.respondentData)}");
  }

  Color _getOptionColorByIndex(int index) {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getOptionEmojiByIndex(int index) {
    switch (index) {
      case 0:
        return "😞";
      case 1:
        return "😐";
      case 2:
        return "🙂";
      case 3:
        return "😃";
      default:
        return "😶";
    }
  }

  void _showSuccessPopup(BuildContext context) {
    debugPrint("🎉 Menampilkan popup sukses pengiriman survey...");
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          debugPrint("📐 Orientasi tampilan: ${isLandscape ? "Lanskap" : "Potret"}");

          return Dialog(
            backgroundColor: Colors.black.withOpacity(0.6),
            insetPadding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 100 : 32,
              vertical: isLandscape ? 24 : 80,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/lottie/Success_Send.json',
                      width: isLandscape ? 150 : 200,
                      height: isLandscape ? 150 : 200,
                      repeat: false,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Survey berhasil dikirim!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        debugPrint("🔚 Tombol 'Tutup' ditekan — kembali ke halaman awal");
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Tutup",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitSurvey() async {
    debugPrint("📤 Mulai proses submit survey...");

    if (widget.respondentData['id'] == null) {
      debugPrint("⛔ Gagal submit: respondentData['id'] null");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap pilih nomor antrian terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🧩 Gabungkan jawaban + nilai skala
    final Map<String, dynamic> jawabanDenganSkala = {};

    for (var i = 0; i < widget.questions.length; i++) {
      final pertanyaan = widget.questions[i].label;
      final jawaban = widget.questionControllers[i]?.text ?? "";
      final nilai = skalaNilai[jawaban] ?? 0;

      jawabanDenganSkala[pertanyaan] = {
        'jawaban': jawaban,
        'nilai': nilai,
      };

      debugPrint("📝 Q${i + 1}: $pertanyaan = '$jawaban' (nilai: $nilai)");
    }

    final saran = widget.questionControllers[widget.questions.length - 1]?.text ?? "";
    final surveyData = {
      ...widget.respondentData,
      'jawaban': jawabanDenganSkala,
      'saran': saran,
    };

    final jsonPretty = const JsonEncoder.withIndent('  ').convert(surveyData);
    debugPrint("📦 Data lengkap yang dikirim ke backend:\n$jsonPretty");

    try {
      debugPrint("🚀 Mengirim data ke SurveyService...");
      final res = await SurveyService.submitSurvey(surveyData);
      debugPrint("📨 Respon backend: ${jsonEncode(res)}");

      if (res['success'] == true) {
        debugPrint("✅ SurveyService response success: ${res.toString()}");
        try {
          final cb = widget.respondentData['removeAntrianCallback'];
          if (cb != null && cb is Function) {
            debugPrint("🧹 Memanggil callback removeAntrianCallback...");
            cb(widget.respondentData['id']);
          }
        } catch (err) {
          debugPrint("⚠️ Gagal memanggil callback: $err");
        }
        _showSuccessPopup(context);
      } else {
        debugPrint("❌ SurveyService response gagal: ${res['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Gagal mengirim survey"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("💥 Exception saat submit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan saat submit: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[current];
    final progress = (current + 1) / widget.questions.length;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    debugPrint("📊 Build UI untuk pertanyaan ke-${current + 1} / ${widget.questions.length}");

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===== Progress bar =====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pertanyaan ${current + 1} dari ${widget.questions.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Text(
              question.label,
              style: const TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // ===== Opsi Jawaban =====
            if (question.options.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: widget.questionControllers[current] ??= TextEditingController(),
                      maxLines: 10,
                      minLines: 8,
                      decoration: const InputDecoration(
                        labelText: "Jawaban Anda",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => debugPrint("⌨️ Input jawaban teks: '$val'"),
                    ),
                    const SizedBox(height: 16),
                    if (current == widget.questions.length - 1)
                      ElevatedButton.icon(
                        onPressed: () async {
                          debugPrint("📮 Tombol Kirim ditekan");
                          await _submitSurvey();
                        },
                        icon: const Icon(Icons.send),
                        label: const Text("Kirim"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            if (question.options.isNotEmpty)
              (isLandscape
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: _buildOptionButtons(question),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _buildOptionButtons(question),
                    )),

            const SizedBox(height: 24),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptionButtons(SurveyQuestion question) {
    return List.generate(question.options.length, (index) {
      final option = question.options[index];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _getOptionColorByIndex(index), width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          onPressed: () {
            debugPrint("🖱️ Opsi '$option' dipilih pada pertanyaan ${current + 1}");
            widget.questionControllers[current] ??= TextEditingController();
            widget.questionControllers[current]!.text = option;
            if (current < widget.questions.length - 1) {
              setState(() => current += 1);
            } else {
              debugPrint("🏁 Pertanyaan terakhir, memanggil submitSurvey()");
              _submitSurvey();
            }
          },
          child: Text(
            "${_getOptionEmojiByIndex(index)}  $option",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }

  Widget _buildBackButton() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        width: 200,
        child: OutlinedButton(
          onPressed: () {
            if (current == 0) {
              widget.previousQuestion();
            } else {
              setState(() => current -= 1);
            }
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            "Kembali",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:gaspul/core/services/survey_service.dart';
// import 'survey_models.dart';

// class QuestionStep extends StatefulWidget {
//   final int currentQuestion;
//   final List<SurveyQuestion> questions;
//   final void Function(dynamic answer) nextQuestion;
//   final VoidCallback previousQuestion;
//   final Map<int, TextEditingController> questionControllers;
//   final Map<String, dynamic> respondentData;

//   const QuestionStep({
//     super.key,
//     required this.currentQuestion,
//     required this.questions,
//     required this.nextQuestion,
//     required this.previousQuestion,
//     required this.questionControllers,
//     required this.respondentData,
//   });

//   @override
//   State<QuestionStep> createState() => _QuestionStepState();
// }

// class _QuestionStepState extends State<QuestionStep> {
//   int current = 0;

//   @override
//   void initState() {
//     super.initState();
//     current = widget.currentQuestion;
//     debugPrint("🟢 QuestionStep initialized - Current Question: $current");
//     debugPrint("👤 Data responden saat ini:\n${const JsonEncoder.withIndent('  ').convert(widget.respondentData)}");
//   }

//   Color _getOptionColorByIndex(int index) {
//     switch (index) {
//       case 0:
//         return Colors.red;
//       case 1:
//         return Colors.orange;
//       case 2:
//         return Colors.green;
//       case 3:
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getOptionEmojiByIndex(int index) {
//     switch (index) {
//       case 0:
//         return "😞";
//       case 1:
//         return "😐";
//       case 2:
//         return "🙂";
//       case 3:
//         return "😃";
//       default:
//         return "😶";
//     }
//   }

//   void _showSuccessPopup(BuildContext context) {
//     debugPrint("🎉 Menampilkan popup sukses pengiriman survey...");
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (_) => LayoutBuilder(
//         builder: (context, constraints) {
//           final isLandscape = constraints.maxWidth > constraints.maxHeight;
//           debugPrint("📐 Orientasi tampilan: ${isLandscape ? "Lanskap" : "Potret"}");

//           return Dialog(
//             backgroundColor: Colors.black.withOpacity(0.6),
//             insetPadding: EdgeInsets.symmetric(
//               horizontal: isLandscape ? 100 : 32,
//               vertical: isLandscape ? 24 : 80,
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Lottie.asset(
//                       'assets/lottie/Success_Send.json',
//                       width: isLandscape ? 150 : 200,
//                       height: isLandscape ? 150 : 200,
//                       repeat: false,
//                     ),
//                     const SizedBox(height: 12),
//                     const Text(
//                       "Survey berhasil dikirim!",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         color: Colors.black,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         debugPrint("🔚 Tombol 'Tutup' ditekan — kembali ke halaman awal");
//                         Navigator.of(context).popUntil((route) => route.isFirst);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text(
//                         "Tutup",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _submitSurvey() async {
//     debugPrint("📤 Mulai proses submit survey...");

//     if (widget.respondentData['id'] == null) {
//       debugPrint("⛔ Gagal submit: respondentData['id'] null");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Harap pilih nomor antrian terlebih dahulu"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final allAnswers = <String, String>{};
//     for (var i = 0; i < widget.questions.length; i++) {
//       final answer = widget.questionControllers[i]?.text ?? "";
//       allAnswers[widget.questions[i].label] = answer;
//       debugPrint("📝 Jawaban Q${i + 1}: '${widget.questions[i].label}' = '$answer'");
//     }

//     final saran = widget.questionControllers[widget.questions.length - 1]?.text ?? "";
//     final surveyData = {
//       ...widget.respondentData,
//       'jawaban': allAnswers,
//       'saran': saran,
//     };

//     // Cetak payload yang dikirim ke backend
//     final jsonPretty = const JsonEncoder.withIndent('  ').convert(surveyData);
//     debugPrint("📦 Data lengkap yang dikirim ke backend:\n$jsonPretty");

//     try {
//       debugPrint("🚀 Mengirim data ke SurveyService...");
//       final res = await SurveyService.submitSurvey(surveyData);
//       debugPrint("📨 Respon backend: ${jsonEncode(res)}");

//       if (res['success'] == true) {
//         debugPrint("✅ SurveyService response success: ${res.toString()}");
//         try {
//           final cb = widget.respondentData['removeAntrianCallback'];
//           if (cb != null && cb is Function) {
//             debugPrint("🧹 Memanggil callback removeAntrianCallback...");
//             cb(widget.respondentData['id']);
//           }
//         } catch (err) {
//           debugPrint("⚠️ Gagal memanggil callback: $err");
//         }
//         _showSuccessPopup(context);
//       } else {
//         debugPrint("❌ SurveyService response gagal: ${res['message']}");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(res['message'] ?? "Gagal mengirim survey"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint("💥 Exception saat submit: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Terjadi kesalahan saat submit: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final question = widget.questions[current];
//     final progress = (current + 1) / widget.questions.length;
//     final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

//     debugPrint("📊 Build UI untuk pertanyaan ke-${current + 1} / ${widget.questions.length}");

//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // ===== Progress bar =====
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               child: Column(
//                 children: [
//                   LinearProgressIndicator(
//                     value: progress,
//                     backgroundColor: Colors.grey[300],
//                     color: Colors.green,
//                     minHeight: 10,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Pertanyaan ${current + 1} dari ${widget.questions.length}",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 12),
//             Text(
//               question.label,
//               style: const TextStyle(fontSize: 25),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),

//             // ===== Opsi Jawaban =====
//             if (question.options.isEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: widget.questionControllers[current] ??=
//                           TextEditingController(),
//                       maxLines: 10,
//                       minLines: 8,
//                       decoration: const InputDecoration(
//                         labelText: "Jawaban Anda",
//                         border: OutlineInputBorder(),
//                       ),
//                       onChanged: (val) {
//                         debugPrint("⌨️ Input jawaban teks: '$val'");
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     if (current == widget.questions.length - 1)
//                       ElevatedButton.icon(
//                         onPressed: () async {
//                           debugPrint("📮 Tombol Kirim ditekan");
//                           await _submitSurvey();
//                         },
//                         icon: const Icon(Icons.send),
//                         label: const Text("Kirim"),
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: const Size.fromHeight(50),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),

//             if (question.options.isNotEmpty)
//               isLandscape
//                   ? Wrap(
//                       alignment: WrapAlignment.center,
//                       spacing: 10,
//                       runSpacing: 10,
//                       children: List.generate(question.options.length, (index) {
//                         final option = question.options[index];
//                         return OutlinedButton(
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(
//                               color: _getOptionColorByIndex(index),
//                               width: 2,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             foregroundColor: Colors.black,
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 16,
//                               horizontal: 20,
//                             ),
//                           ),
//                           onPressed: () {
//                             debugPrint("🖱️ Opsi '$option' dipilih pada pertanyaan ${current + 1}");
//                             widget.questionControllers[current] ??= TextEditingController();
//                             widget.questionControllers[current]!.text = option;
//                             if (current < widget.questions.length - 1) {
//                               setState(() {
//                                 current += 1;
//                                 debugPrint("➡️ Lanjut ke pertanyaan ke-${current + 1}");
//                               });
//                             } else {
//                               debugPrint("🏁 Pertanyaan terakhir, memanggil submitSurvey()");
//                               _submitSurvey();
//                             }
//                           },
//                           child: Text(
//                             "${_getOptionEmojiByIndex(index)} $option",
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         );
//                       }),
//                     )
//                   : Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: List.generate(question.options.length, (index) {
//                         final option = question.options[index];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 6),
//                           child: OutlinedButton(
//                             style: OutlinedButton.styleFrom(
//                               side: BorderSide(
//                                 color: _getOptionColorByIndex(index),
//                                 width: 2,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               foregroundColor: Colors.black,
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 16,
//                                 horizontal: 24,
//                               ),
//                             ),
//                             onPressed: () {
//                               debugPrint("🖱️ Opsi '$option' dipilih pada pertanyaan ${current + 1}");
//                               widget.questionControllers[current] ??= TextEditingController();
//                               widget.questionControllers[current]!.text = option;
//                               if (current < widget.questions.length - 1) {
//                                 setState(() {
//                                   current += 1;
//                                   debugPrint("➡️ Lanjut ke pertanyaan ke-${current + 1}");
//                                 });
//                               } else {
//                                 debugPrint("🏁 Pertanyaan terakhir, memanggil submitSurvey()");
//                                 _submitSurvey();
//                               }
//                             },
//                             child: Text(
//                               "${_getOptionEmojiByIndex(index)}  $option",
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 20,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         );
//                       }),
//                     ),

//             const SizedBox(height: 24),
//             Center(
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 32),
//                 width: 200,
//                 child: OutlinedButton(
//                   onPressed: () {
//                     if (current == 0) {
//                       debugPrint("⬅️ Kembali ke halaman sebelumnya (dari pertanyaan pertama)");
//                       widget.previousQuestion();
//                     } else {
//                       setState(() {
//                         current -= 1;
//                         debugPrint("⬅️ Mundur ke pertanyaan ke-${current + 1}");
//                       });
//                     }
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.grey, width: 1.5),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Kembali",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
