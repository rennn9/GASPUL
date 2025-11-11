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

  @override
  void initState() {
    super.initState();
    current = widget.currentQuestion;
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
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Lottie.asset('assets/lottie/Success_Send.json', width: 200, height: 200, repeat: false),
            const SizedBox(height: 12),
            const Text(
              "Survey berhasil dikirim!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Tutup"),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _submitSurvey() async {
    if (widget.respondentData['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Harap pilih nomor antrian terlebih dahulu"), backgroundColor: Colors.red),
      );
      return;
    }

    // ✅ Debug: log respondentData
    debugPrint("=== respondentData sebelum submit ===");
    widget.respondentData.forEach((k, v) => debugPrint("$k: $v"));

    // collect all answers
    final allAnswers = <String, String>{};
    for (var i = 0; i < widget.questions.length; i++) {
      allAnswers[widget.questions[i].label] = widget.questionControllers[i]?.text ?? "";
    }

    // debug: log jawaban semua pertanyaan
    debugPrint("=== jawaban semua pertanyaan ===");
    allAnswers.forEach((k, v) => debugPrint("$k: $v"));

    final saran = widget.questionControllers[widget.questions.length - 1]?.text ?? "";

    final surveyData = {
      ...widget.respondentData,
      'jawaban': allAnswers,
      'saran': saran,
    };

    // debug: log payload final
    debugPrint("=== payload surveyData yang dikirim ===");
    surveyData.forEach((k, v) => debugPrint("$k: $v"));

    try {
      final res = await SurveyService.submitSurvey(surveyData);

      debugPrint("=== response server ===");
      debugPrint(res.toString());

      if (res['success'] == true) {
        try {
          final cb = widget.respondentData['removeAntrianCallback'];
          if (cb != null && cb is Function) {
            cb(widget.respondentData['id']);
          }
        } catch (_) {}

        _showSuccessPopup(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(res['message'] ?? "Gagal mengirim survey"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e, st) {
      // log error lengkap jika koneksi / json error
      debugPrint("=== ERROR saat submit ===");
      debugPrint(e.toString());
      debugPrint(st.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan saat submit: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[current];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Pertanyaan ${current + 1} dari ${widget.questions.length}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(question.label, style: const TextStyle(fontSize: 25), textAlign: TextAlign.center),
          const SizedBox(height: 16),

          if (question.options.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                TextField(
                  controller: widget.questionControllers[current] ??= TextEditingController(),
                  maxLines: 10,
                  minLines: 8,
                  decoration: const InputDecoration(
                      labelText: "Jawaban Anda", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                if (current == widget.questions.length - 1)
                  ElevatedButton.icon(
                    onPressed: () async {
                      debugPrint("Tombol KIRIM ditekan");
                      await _submitSurvey();
                    },
                    icon: const Icon(Icons.send),
                    label: const Text("Kirim"),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
              ]),
            ),

          if (question.options.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(question.options.length, (index) {
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
                      widget.questionControllers[current] ??= TextEditingController();
                      widget.questionControllers[current]!.text = option;
                      if (current < widget.questions.length - 1) {
                        setState(() => current += 1);
                      } else {
                        debugPrint("Jawaban terakhir dipilih: $option");
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
              }),
            ),

          const SizedBox(height: 24),

          // Back button
          Center(
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Kembali",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
