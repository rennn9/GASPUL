import 'package:flutter/material.dart';
import 'package:gaspul/core/widgets/form_widgets.dart';
import 'package:gaspul/core/services/survey_service.dart';

class RespondentForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, TextEditingController> controllers;
  final String? jenisKelamin;
  final String? pendidikan;
  final String? pekerjaanSelected;
  final TextEditingController pekerjaanLainController;
  final void Function(String?) onJenisKelaminChanged;
  final void Function(String?) onPendidikanChanged;
  final void Function(String?) onPekerjaanChanged;
  final VoidCallback onSubmit;
  final Map<String, dynamic> respondentData;

  const RespondentForm({
    super.key,
    required this.formKey,
    required this.controllers,
    required this.jenisKelamin,
    required this.pendidikan,
    required this.pekerjaanSelected,
    required this.pekerjaanLainController,
    required this.onJenisKelaminChanged,
    required this.onPendidikanChanged,
    required this.onPekerjaanChanged,
    required this.onSubmit,
    required this.respondentData,
  });

  @override
  State<RespondentForm> createState() => _RespondentFormState();
}

class _RespondentFormState extends State<RespondentForm> {
  List<Map<String, dynamic>> antrianList = [];
  Map<String, dynamic>? selectedAntrian;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAntrianSelesai();
    _loadServerTime();
  }

Future<void> _loadAntrianSelesai() async {
  final data = await SurveyService.fetchAntrianSelesaiHariIni();
  // Filter hanya antrian yang belum ada di tabel survey
  final filtered = data.where((a) => a['sudah_survey'] != true).toList();

  setState(() {
    antrianList = filtered;
    isLoading = false;
  });
}

  Future<void> _loadServerTime() async {
    try {
      final serverTime = await SurveyService.fetchServerTime();
      setState(() {
        widget.controllers["Tanggal"]!.text =
            serverTime.toString().split(" ")[0];
      });
    } catch (_) {}
  }

  void _onAntrianSelected(Map<String, dynamic>? val) {
    if (val != null) {
      final match = antrianList.firstWhere((a) => a['id'] == val['id']);
      setState(() {
        selectedAntrian = match;
        widget.controllers["Nama Responden"]!.text = match['nama_lengkap'] ?? '';
        widget.controllers["Nomor Whatsapp"]!.text = match['no_hp_wa'] ?? '';
        widget.controllers["Bidang"]!.text = match['bidang_layanan'] ?? '';

// Update respondentData supaya SurveyPage tahu antrian dipilih
widget.respondentData['id'] = match['id'];
widget.respondentData['nomor_antrian'] = match['nomor_antrian'];
widget.respondentData['nama_responden'] = match['nama_lengkap'];
widget.respondentData['no_hp_wa'] = match['no_hp_wa'];
widget.respondentData['bidang'] = match['bidang_layanan']; // ❌ ubah key menjadi 'bidang'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Form(
              key: widget.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/Logo KEMENAG.png", width: 70),
                      const SizedBox(width: 20),
                      Image.asset("assets/images/logo_gaspul.png", width: 70),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    "KanWil Kementerian Agama\nProvinsi Sulawesi Barat",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),
                  Divider(
                    color: Colors.grey.shade400,
                    thickness: 1.2,
                    indent: 32,
                    endIndent: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Informasi Responden",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Dropdown nomor antrian hari ini
                  CustomDropdownFormField<Map<String, dynamic>>(
                    value: selectedAntrian,
                    label: "Pilih Nomor Antrian",
                    items: antrianList.map((a) {
                      return DropdownMenuItem(
                        value: a,
                        child: Text("${a['nomor_antrian']} - ${a['nama_lengkap']}"),
                      );
                    }).toList(),
                    onChanged: _onAntrianSelected,
                    validator: (val) {
                      if (val == null || val['id'] == null) {
                        return "Harap pilih nomor antrian";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Nama Responden otomatis
                  CustomTextFormField(
                    controller: widget.controllers["Nama Responden"]!,
                    label: "Nama Responden",
                    readOnly: true,
                    suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Harap pilih nomor antrian terlebih dahulu" : null,
                  ),
                  const SizedBox(height: 12),

                  // Nomor Whatsapp otomatis
                  CustomTextFormField(
                    controller: widget.controllers["Nomor Whatsapp"]!,
                    label: "Nomor Whatsapp",
                    readOnly: true,
                    suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Harap pilih nomor antrian terlebih dahulu" : null,
                  ),
                  const SizedBox(height: 12),

                  // Usia
                  CustomTextFormField(
                    controller: widget.controllers["Usia"]!,
                    label: "Usia",
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? "Harap diisi" : null,
                  ),
                  const SizedBox(height: 12),

                  // Jenis Kelamin
                  CustomDropdownFormField<String>(
                    value: widget.jenisKelamin,
                    label: "Jenis Kelamin",
                    items: ["Laki-laki", "Perempuan"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: widget.onJenisKelaminChanged,
                    validator: (val) => val == null ? "Harap dipilih" : null,
                  ),
                  const SizedBox(height: 12),

                  // Pendidikan
                  CustomDropdownFormField<String>(
                    value: widget.pendidikan,
                    label: "Pendidikan",
                    items: ["SD", "SMP", "SMA", "Diploma", "Sarjana", "Lainnya"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: widget.onPendidikanChanged,
                    validator: (val) => val == null ? "Harap dipilih" : null,
                  ),
                  const SizedBox(height: 12),

                  // Pekerjaan
                  CustomDropdownFormField<String>(
                    value: widget.pekerjaanSelected,
                    label: "Pekerjaan",
                    items: [
                      "Pelajar/Mahasiswa",
                      "PNS",
                      "TNI/POLRI",
                      "Pegawai Swasta",
                      "Wiraswasta",
                      "Petani/Nelayan",
                      "Lainnya",
                    ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: widget.onPekerjaanChanged,
                    validator: (val) => val == null ? "Harap dipilih" : null,
                  ),

                  if (widget.pekerjaanSelected == "Lainnya")
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CustomTextFormField(
                        controller: widget.pekerjaanLainController,
                        label: "Pekerjaan Lainnya",
                        validator: (val) =>
                            val == null || val.isEmpty ? "Harap diisi" : null,
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Bidang otomatis
                  CustomTextFormField(
                    controller: widget.controllers["Bidang"]!,
                    label: "Bidang",
                    readOnly: true,
                    suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                    validator: (val) => val == null || val.isEmpty ? "Harap pilih nomor antrian" : null,
                  ),
                  const SizedBox(height: 12),

                  // Tanggal otomatis
                  CustomTextFormField(
                    controller: widget.controllers["Tanggal"]!,
                    label: "Tanggal",
                    readOnly: true,
                    suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                    validator: (val) => val == null || val.isEmpty ? "Harap pilih tanggal" : null,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      if (widget.formKey.currentState!.validate()) {
                        widget.onSubmit();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Mulai Survey",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
  }
}