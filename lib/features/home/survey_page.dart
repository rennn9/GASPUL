import 'package:flutter/material.dart';
import 'widgets/survey/respondent_form.dart';
import 'widgets/survey/question_step.dart';
import 'widgets/survey/survey_models.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    "Nama Responden": TextEditingController(),
    "Nomor Whatsapp": TextEditingController(),
    "Usia": TextEditingController(),
    "Bidang": TextEditingController(),
    "Tanggal": TextEditingController(),
  };

  final TextEditingController pekerjaanLainController = TextEditingController();

  String? jenisKelamin;
  String? pendidikan;
  String? pekerjaanSelected;

  final List<SurveyQuestion> questions = [
    SurveyQuestion(
      label: "Bagaimana pendapat Saudara tentang kesesuaian persyaratan pelayanan dengan jenis pelayanannya?",
      options: ["Tidak sesuai","Kurang sesuai","Sesuai","Sangat sesuai"],
    ),
    SurveyQuestion(
      label: "Bagaimana pemahaman Saudara tentang kemudahan prosedur pelayanan di unit ini?",
      options: ["Tidak mudah","Kurang mudah","Mudah","Sangat mudah"],
    ),
    SurveyQuestion(
      label: "Bagaimana pendapat Saudara tentang kecepatan waktu dalam memberikan pelayanan?",
      options: ["Tidak cepat","Kurang cepat","Cepat","Sangat cepat"],
    ),
    SurveyQuestion(
      label: "Bagaimana pendapat Saudara tentang kewajaran biaya/tarif dalam pelayanan?",
      options: ["Sangat mahal","Cukup mahal","Murah","Gratis"],
    ),
    SurveyQuestion(
      label: "Bagaimana pendapat Saudara tentang kesesuaian produk pelayanan antara yang tercantum dalam standar pelayanan dengan hasil yang diberikan?",
      options: ["Tidak sesuai","Kurang sesuai","Sesuai","Sangat sesuai"],
    ),
    SurveyQuestion(
      label: "Bagaimana pendapat Saudara tentang kompetensi/kemampuan petugas dalam pelayanan?",
      options: ["Tidak kompeten","Kurang kompeten","Kompeten","Sangat kompeten"],
    ),
    SurveyQuestion(
      label: "Bagaimana pendapat Saudara tentang perilaku petugas dalam pelayanan terkait kesopanan dan keramahan?",
      options: ["Tidak sopan dan ramah","Kurang sopan dan ramah","Sopan dan ramah","Sangat sopan dan ramah"],
    ),
    SurveyQuestion(
      label: "Bagaimana pendapat Saudara tentang kualitas sarana dan prasarana?",
      options: ["Buruk","Cukup","Baik","Sangat Baik"],
    ),
    SurveyQuestion(
      label: "Bagaimana pendapat Saudara tentang penanganan pengaduan pengguna layanan?",
      options: ["Tidak ada","Ada tetapi tidak berfungsi","Berfungsi kurang maksimal","Dikelola dengan baik"],
    ),
    SurveyQuestion(label: "Kritik / Saran (isian bebas)", options: []),
  ];

  final Map<int, TextEditingController> questionControllers = {};
  final Map<String, dynamic> respondentData = {};
  int step = 0;

  void _startSurvey() {
    if (respondentData['id'] == null || respondentData['nomor_antrian'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih nomor antrian terlebih dahulu"), backgroundColor: Colors.red),
      );
      return;
    }

final payload = {
  "id": respondentData['id'],
  "nomor_antrian": respondentData['nomor_antrian'],
  "nama_responden": controllers["Nama Responden"]!.text,
  "no_hp_wa": controllers["Nomor Whatsapp"]!.text,
  "usia": controllers["Usia"]!.text,
  "jenis_kelamin": jenisKelamin ?? '',
  "pendidikan": pendidikan ?? '',
  "pekerjaan": pekerjaanSelected == "Lainnya"
      ? pekerjaanLainController.text
      : pekerjaanSelected ?? '',
  "bidang": controllers["Bidang"]!.text, // ❌ sebelumnya 'bidang_layanan', sekarang 'bidang'
  "tanggal": controllers["Tanggal"]!.text,
};


    respondentData.clear();
    respondentData.addAll(payload);

    setState(() {
      step = 1;
    });
  }

  void _backToForm() {
    setState(() {
      step = 0;
    });
  }

  @override
  void dispose() {
    controllers.values.forEach((c) => c.dispose());
    pekerjaanLainController.dispose();
    questionControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Survey Pelayanan')),
      body: SafeArea(
        child: step == 0
            ? RespondentForm(
                formKey: _formKey,
                controllers: controllers,
                jenisKelamin: jenisKelamin,
                pendidikan: pendidikan,
                pekerjaanSelected: pekerjaanSelected,
                pekerjaanLainController: pekerjaanLainController,
                onJenisKelaminChanged: (v) => setState(() => jenisKelamin = v),
                onPendidikanChanged: (v) => setState(() => pendidikan = v),
                onPekerjaanChanged: (v) => setState(() => pekerjaanSelected = v),
                onSubmit: _startSurvey,
                respondentData: respondentData,
              )
            : QuestionStep(
                currentQuestion: 0,
                questions: questions,
                nextQuestion: (answer) {},
                previousQuestion: _backToForm,
                questionControllers: questionControllers,
                respondentData: respondentData,
              ),
      ),
    );
  }
}