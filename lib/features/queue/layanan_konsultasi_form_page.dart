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
  final _emailController = TextEditingController();
  final _perihalController = TextEditingController();
  final _isiController = TextEditingController();
  final _tanggalController = TextEditingController();

  File? _selectedFile;
  bool _isLoading = false;

  final _service = LayananKonsultasiService();

  @override
  void initState() {
    super.initState();
    _setTanggalServer();
  }

  /// ✅ Set tanggal konsultasi berdasarkan waktu server
  Future<void> _setTanggalServer() async {
    final serverNow = await ServerTimeService.getServerTime();
    if (serverNow != null) {
      _tanggalController.text =
          DateFormat('EEEE, dd-MM-yyyy', 'id').format(serverNow);
    } else {
      final now = DateTime.now();
      _tanggalController.text =
          DateFormat('EEEE, dd-MM-yyyy', 'id').format(now);
    }
    setState(() {});
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      final sizeInMB = file.lengthSync() / (1024 * 1024);

      if (sizeInMB > 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ukuran file maksimal 3MB")),
        );
        return;
      }

      setState(() {
        _selectedFile = file;
      });
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await _service.submitKonsultasiForm(
      context: context,
      nameController: _nameController,
      whatsappController: _whatsappController,
      emailController: _emailController,
      perihalController: _perihalController,
      isiController: _isiController,
      tanggalController: _tanggalController,
      selectedFile: _selectedFile,
    );

    setState(() {
      _selectedFile = null;
      _isLoading = false;
    });

    await _setTanggalServer(); // refresh tanggal server
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GasPulSafeScaffold(
      appBar: const MainAppBar(title: "Form Layanan Konsultasi"),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
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
                          label: "Nomor Whatsapp *",
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.isEmpty
                              ? "Nomor Whatsapp wajib diisi"
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
                          controller: _perihalController,
                          label: "Perihal *",
                          maxLines: 3,
                          validator: (v) =>
                              v == null || v.isEmpty ? "Perihal wajib diisi" : null,
                        ),
                        const SizedBox(height: 12),
                        CustomTextFormField(
                          controller: _isiController,
                          label: "Isi Konsultasi *",
                          maxLines: 3,
                          validator: (v) => v == null || v.isEmpty
                              ? "Isi konsultasi wajib diisi"
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
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => _submitForm(context),
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
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _perihalController.dispose();
    _isiController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }
}
