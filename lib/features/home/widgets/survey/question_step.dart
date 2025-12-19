import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:gaspul/core/services/survey_service.dart';
import 'survey_models.dart';

class QuestionStep extends StatefulWidget {
  final int currentQuestion;
  final void Function(dynamic answer) nextQuestion;
  final VoidCallback previousQuestion;
  final Map<int, TextEditingController> questionControllers;
  final Map<String, dynamic> respondentData;
  final SurveyTemplate? surveyTemplate;

  const QuestionStep({
    super.key,
    required this.currentQuestion,
    required this.nextQuestion,
    required this.previousQuestion,
    required this.questionControllers,
    required this.respondentData,
    this.surveyTemplate,
  });

  @override
  State<QuestionStep> createState() => _QuestionStepState();
}

class _QuestionStepState extends State<QuestionStep> {
  int current = 0;

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap pilih nomor antrian terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.surveyTemplate == null) {
      debugPrint("⛔ Template survey tidak tersedia");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Template survey tidak tersedia"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // NEW FORMAT: Using dynamic template
    debugPrint("🆕 Using NEW format with template: ${widget.surveyTemplate!.nama}");

    final responses = <Map<String, dynamic>>[];
    final templateQuestionsCount = widget.surveyTemplate!.questions.length;

    // Process template questions (tidak termasuk saran)
    for (var i = 0; i < templateQuestionsCount; i++) {
      final question = widget.surveyTemplate!.questions[i];
      final answer = widget.questionControllers[i]?.text ?? "";

      // Jika pertanyaan adalah text input
      if (question.isTextInput) {
        if (answer.isNotEmpty || question.isRequired) {
          responses.add({
            'question_id': question.id,
            'text_answer': answer,
          });
          debugPrint("📝 Q${i + 1} [${question.kodeUnsur}]: ${question.pertanyaan} = '$answer' (text input)");
        }
        continue;
      }

      // Skip if empty and not required
      if (answer.isEmpty && !question.isRequired) {
        continue;
      }

      // Find the selected option
      SurveyQuestionOption? selectedOption;
      for (var option in question.options) {
        if (option.jawabanText == answer) {
          selectedOption = option;
          break;
        }
      }

      if (selectedOption != null) {
        responses.add({
          'question_id': question.id,
          'option_id': selectedOption.id,
          'text_answer': selectedOption.jawabanText,
          'poin': selectedOption.poin,
        });
        debugPrint("📝 Q${i + 1} [${question.kodeUnsur}]: ${question.pertanyaan} = '${answer}' (poin: ${selectedOption.poin})");
      }
    }

    // Get saran from the programmatic final question (index = templateQuestionsCount)
    final saran = widget.questionControllers[templateQuestionsCount]?.text ?? "";
    debugPrint("💬 Saran (pertanyaan terakhir): $saran");

    final surveyData = {
      ...widget.respondentData,
      'survey_template_id': widget.surveyTemplate!.id,
      'responses': responses,
      'saran': saran,
    };

    final jsonPretty = const JsonEncoder.withIndent('  ').convert(surveyData);
    debugPrint("📦 Data lengkap yang dikirim ke backend:\n$jsonPretty");

    try {
      debugPrint("🚀 Mengirim data ke SurveyService...");
      final res = await SurveyService.submitSurvey(surveyData);
      debugPrint("📨 Respon backend: ${jsonEncode(res)}");

      if (!mounted) return;

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
      if (!mounted) return;
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
    if (widget.surveyTemplate == null) {
      return const Center(
        child: Text("Template survey tidak tersedia"),
      );
    }

    // Total questions = questions dari template + 1 (untuk saran)
    final templateQuestionsCount = widget.surveyTemplate!.questions.length;
    final totalQuestions = templateQuestionsCount + 1;

    // Tentukan apakah ini pertanyaan dari template atau saran
    final isSaranQuestion = current >= templateQuestionsCount;

    String questionText;
    List<String> questionOptions;
    bool isTextInput;

    if (isSaranQuestion) {
      // Pertanyaan saran (selalu ada di akhir)
      questionText = "Kritik / Saran";
      questionOptions = [];
      isTextInput = true;
    } else {
      // Pertanyaan dari template
      final templateQuestion = widget.surveyTemplate!.questions[current];
      questionText = templateQuestion.pertanyaan;
      questionOptions = templateQuestion.options.map((o) => o.jawabanText).toList();
      isTextInput = templateQuestion.isTextInput;
    }

    final progress = (current + 1) / totalQuestions;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    debugPrint("📊 Build UI untuk pertanyaan ke-${current + 1} / $totalQuestions ${isSaranQuestion ? '(Saran)' : ''}");

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
                    "Pertanyaan ${current + 1} dari $totalQuestions",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Text(
              questionText,
              style: const TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // ===== Opsi Jawaban =====
            if (isTextInput)
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
                    if (current == totalQuestions - 1)
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

            if (!isTextInput)
              (isLandscape
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: _buildOptionButtons(questionOptions, totalQuestions),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _buildOptionButtons(questionOptions, totalQuestions),
                    )),

            const SizedBox(height: 24),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptionButtons(List<String> options, int totalQuestions) {
    return List.generate(options.length, (index) {
      final option = options[index];
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
            if (current < totalQuestions - 1) {
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
