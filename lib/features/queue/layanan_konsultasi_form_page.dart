// lib/features/queue/layanan_konsultasi_form_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../home/widgets/main_app_bar.dart';
import 'package:gaspul/core/widgets/form_widgets.dart';
import 'package:gaspul/core/services/layanan_konsultasi_service.dart';
import 'package:gaspul/core/services/server_time_service.dart';
import 'package:gaspul/core/widgets/gaspul_safe_scaffold.dart';
import 'package:lottie/lottie.dart';

class LayananKonsultasiFormPage extends ConsumerStatefulWidget {
  const LayananKonsultasiFormPage({super.key});

  @override
  ConsumerState<LayananKonsultasiFormPage> createState() =>
      _LayananKonsultasiFormPageState();
}

class _LayananKonsultasiFormPageState
    extends ConsumerState<LayananKonsultasiFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _alamatController = TextEditingController();
  final _emailController = TextEditingController();
  final _perihalController = TextEditingController();
  final _asalInstansiController = TextEditingController();
  final _tanggalController = TextEditingController();

  File? _selectedFile;
  bool _isLoading = false;

  final _service = LayananKonsultasiService();

  @override
  void initState() {
    super.initState();
    debugPrint("[INIT] LayananKonsultasiFormPage loaded");
    _setTanggalServer();
  }

  /// -------------------------------------------------------------
  /// 🔧  Mendapatkan waktu server + log detail
  /// -------------------------------------------------------------
  Future<void> _setTanggalServer() async {
    debugPrint("[TANGGAL] Mengambil waktu server...");

    final serverNow = await ServerTimeService.getServerTime();

    if (serverNow != null) {
      debugPrint("[TANGGAL] Server time berhasil didapat: $serverNow");
      _tanggalController.text =
          DateFormat('EEEE, dd-MM-yyyy', 'id').format(serverNow);
    } else {
      final now = DateTime.now();
      debugPrint("[TANGGAL] Gagal ambil server time. Pakai lokal: $now");
      _tanggalController.text =
          DateFormat('EEEE, dd-MM-yyyy', 'id').format(now);
    }

    setState(() {});
  }

  /// -------------------------------------------------------------
  /// 📂  File Picker + log detail
  /// -------------------------------------------------------------
  Future<void> _pickFile() async {
    debugPrint("[FILE] Membuka FilePicker...");

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      debugPrint("[FILE] User membatalkan pemilihan file.");
      return;
    }

    final file = File(result.files.single.path!);
    final sizeInMB = file.lengthSync() / (1024 * 1024);

    debugPrint("[FILE] File dipilih: ${file.path}");
    debugPrint("[FILE] Ukuran file: ${sizeInMB.toStringAsFixed(2)} MB");

    if (sizeInMB > 3) {
      debugPrint("[FILE] ERROR → File lebih besar dari 3MB!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ukuran file maksimal 3MB")),
      );
      return;
    }

    setState(() {
      _selectedFile = file;
    });

    debugPrint("[FILE] File berhasil disimpan ke state.");
  }

  /// -------------------------------------------------------------
  /// 📤  Submit Form + log super lengkap
  /// -------------------------------------------------------------
  Future<void> _submitForm(BuildContext context) async {
    debugPrint("[SUBMIT] Validasi form dimulai...");

    if (!_formKey.currentState!.validate()) {
      debugPrint("[SUBMIT] ❌ Validasi gagal. Form tidak lengkap.");
      return;
    }

    debugPrint("[SUBMIT] ✔ Validasi berhasil.");
    debugPrint("[SUBMIT] Mengirim data...");

    setState(() => _isLoading = true);

    debugPrint("""
[PAYLOAD] Data yang akan dikirim:
-------------------------------------------------
Nama             : ${_nameController.text}
WA               : ${_whatsappController.text}
Alamat           : ${_alamatController.text}
Email            : ${_emailController.text}
Asal Instansi    : ${_asalInstansiController.text}
Perihal          : ${_perihalController.text}
Tanggal          : ${_tanggalController.text}
File             : ${_selectedFile?.path ?? "(NULL)"}
-------------------------------------------------
""");

    try {
      await _service.submitKonsultasiForm(
        context: context,
        nameController: _nameController,
        whatsappController: _whatsappController,
        alamatController: _alamatController,
        emailController: _emailController,
        perihalController: _perihalController,
        asalInstansiController: _asalInstansiController,
        tanggalController: _tanggalController,
        selectedFile: _selectedFile,
      );

      debugPrint("[SUBMIT] ✔ Form berhasil dikirim ke server.");

    } catch (e, s) {
      debugPrint("[SUBMIT] ❌ ERROR saat submit: $e");
      debugPrint("[STACKTRACE]\n$s");
    }

    setState(() {
      debugPrint("[SUBMIT] Reset state setelah submit.");
      _selectedFile = null;
      _isLoading = false;
    });

    await _setTanggalServer(); // Refresh tanggal
  }

  /// -------------------------------------------------------------
  /// UI
  /// -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    debugPrint("[UI] Build dipanggil. Loading: $_isLoading");

    final theme = Theme.of(context);

    return GasPulSafeScaffold(
      appBar: const MainAppBar(title: "Form Layanan Konsultasi"),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextFormField(
                              controller: _nameController,
                              label: "Nama Lengkap *",
                              validator: (v) =>
                                  v == null || v.isEmpty ? "Nama wajib diisi" : null,
                            ),
                            const SizedBox(height: 12),

                            CustomTextFormField(
                              controller: _whatsappController,
                              label: "No. HP/WA *",
                              keyboardType: TextInputType.phone,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Nomor HP/WA wajib diisi"
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            CustomTextFormField(
                              controller: _alamatController,
                              label: "Alamat *",
                              maxLines: 2,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Alamat wajib diisi"
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            CustomTextFormField(
                              controller: _emailController,
                              label: "Email (Opsional)",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),

                            CustomTextFormField(
                              controller: _asalInstansiController,
                              label: "Asal Instansi *",
                              validator: (v) => v == null || v.isEmpty
                                  ? "Asal instansi wajib diisi"
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            CustomTextFormField(
                              controller: _perihalController,
                              label: "Perihal *",
                              maxLines: 3,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Perihal wajib diisi"
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            CustomTextFormField(
                              controller: _tanggalController,
                              label: "Tanggal Konsultasi",
                              readOnly: true,
                              suffixIcon: Tooltip(
                                message: "Tanggal otomatis, tidak bisa diubah",
                                child: const Icon(Icons.lock),
                              ),
                              backgroundColor: Colors.grey[200],
                              helperText: "Tanggal otomatis, tidak bisa diubah",
                            ),
                            const SizedBox(height: 12),

                            OutlinedButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(Icons.upload_file),
                              label: Text(
                                _selectedFile != null
                                    ? "File terpilih: ${_selectedFile!.path.split('/').last}"
                                    : "Upload File PDF (Opsional, Maks 3MB)",
                              ),
                            ),

                            const SizedBox(height: 24),

                            ElevatedButton(
                              onPressed:
                                  _isLoading ? null : () => _submitForm(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Kirim",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /// Lottie Loading
                if (_isLoading)
                  Container(
                    color: Colors.black45,
                    child: Center(
                      child: SizedBox(
                        height: 150,
                        width: 150,
                        child: Lottie.asset(
                          'assets/lottie/Speed.json',
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint("[DISPOSE] Membersihkan controller...");
    _nameController.dispose();
    _whatsappController.dispose();
    _alamatController.dispose();
    _emailController.dispose();
    _perihalController.dispose();
    _asalInstansiController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }
}
