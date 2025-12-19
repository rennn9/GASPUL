import 'package:flutter/material.dart';
import 'widgets/survey/respondent_form.dart';
import 'widgets/survey/question_step.dart';
import 'widgets/survey/survey_models.dart';
import 'package:gaspul/features/home/widgets/main_app_bar.dart';
import 'package:gaspul/core/services/survey_service.dart';

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

  // Dynamic template data
  SurveyTemplate? surveyTemplate;
  bool isLoadingTemplate = true;
  String? templateError;

  final Map<int, TextEditingController> questionControllers = {};
  final Map<String, dynamic> respondentData = {};
  int step = 0;

  @override
  void initState() {
    super.initState();
    _loadSurveyTemplate();
  }

  Future<void> _loadSurveyTemplate() async {
    setState(() {
      isLoadingTemplate = true;
      templateError = null;
    });

    try {
      final templateData = await SurveyService.fetchActiveTemplate();

      if (templateData != null) {
        setState(() {
          surveyTemplate = SurveyTemplate.fromJson(templateData);
          isLoadingTemplate = false;
        });
        debugPrint("✅ Survey template loaded: ${surveyTemplate!.nama} v${surveyTemplate!.versi}");
        debugPrint("📋 Total questions: ${surveyTemplate!.questions.length}");
      } else {
        setState(() {
          isLoadingTemplate = false;
          templateError = "Template tidak ditemukan, menggunakan format lama";
        });
        debugPrint("⚠️ No active template found, using legacy format");
      }
    } catch (e) {
      setState(() {
        isLoadingTemplate = false;
        templateError = "Gagal memuat template: $e";
      });
      debugPrint("❌ Error loading template: $e");
    }
  }

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
  "bidang": controllers["Bidang"]!.text, // ✅ pastikan konsisten dgn kolom di tabel
  "tanggal": respondentData['tanggal'], // ✅ ambil langsung dari data antrian (tanggal_layanan)
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
      appBar: const MainAppBar(title: "Survey Pelayanan"),
      body: SafeArea(
        child: isLoadingTemplate
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Memuat template survey..."),
                  ],
                ),
              )
            : surveyTemplate == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 80,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Template Survey Tidak Tersedia",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            templateError ?? "Tidak ada template survey yang aktif. Silakan hubungi administrator.",
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              _loadSurveyTemplate();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Coba Lagi"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : step == 0
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
                        nextQuestion: (answer) {},
                        previousQuestion: _backToForm,
                        questionControllers: questionControllers,
                        respondentData: respondentData,
                        surveyTemplate: surveyTemplate,
                      ),
      ),
    );
  }
}