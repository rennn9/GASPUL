import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gaspul/features/home/home_providers.dart';
import 'package:gaspul/features/home/widgets/menu_button.dart';
import 'package:gaspul/features/home/widgets/accessibility_menu.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // untuk Clipboard

class PengaduanPelayananForm extends ConsumerStatefulWidget {
  const PengaduanPelayananForm({super.key});

  @override
  ConsumerState<PengaduanPelayananForm> createState() =>
      _PengaduanPelayananFormState();
}

class _PengaduanPelayananFormState
    extends ConsumerState<PengaduanPelayananForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _penjelasanController = TextEditingController();

  String? _fileName;
  PlatformFile? _pickedFile;

  bool get _isFormValid {
    return _namaController.text.isNotEmpty &&
        _nipController.text.isNotEmpty &&
        _penjelasanController.text.isNotEmpty;
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
          _fileName = _pickedFile!.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih file: $e')));
    }
  }

  Future<void> _submitFormPelayanan() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {}); // supaya error langsung tampil
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/api/pengaduan-pelayanan');
    var request = http.MultipartRequest('POST', url);

    request.fields['nama'] = _namaController.text;
    request.fields['nip'] = _nipController.text;
    request.fields['penjelasan'] = _penjelasanController.text;

    if (_pickedFile != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _pickedFile!.bytes!,
          filename: _pickedFile!.name,
        ),
      );
    }

    request.headers['Accept'] = 'application/json';

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengaduan pelayanan berhasil dikirim")),
        );
        _formKey.currentState?.reset();
        setState(() {
          _pickedFile = null;
          _fileName = null;
        });
      } else {
        _showErrorDialog(
          "Gagal mengirim laporan",
          "Status Code: ${response.statusCode}\nResponse: $respStr",
        );
      }
    } catch (e, stackTrace) {
      _showErrorDialog(
        "Error saat mengirim laporan",
        "$e\n\nStackTrace:\n$stackTrace",
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error copied to clipboard")),
              );
            },
            child: const Text("Copy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nipController.dispose();
    _penjelasanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMenuOpen = ref.watch(accessibilityMenuProvider);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Pengaduan Pelayanan"),
            backgroundColor: theme.primaryColor,
            actions: const [
              Padding(padding: EdgeInsets.only(right: 12), child: MenuButton()),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              onChanged: () => setState(() {}),
              child: ListView(
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: "Nama *",
                      hintText: "Isi Nama Anda",
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Nama wajib diisi"
                        : null,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nipController,
                    decoration: const InputDecoration(
                      labelText: "NIP *",
                      hintText: "Isi NIP Anda",
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? "NIP wajib diisi"
                        : null,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _penjelasanController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: "Penjelasan *",
                      hintText: "Berikan penjelasan Anda",
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Penjelasan wajib diisi"
                        : null,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.brightness == Brightness.dark
                              ? Colors.grey[700]
                              : Colors.grey[300],
                          foregroundColor: theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: Text(
                          _fileName == null ? "Choose file" : "Change file",
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _fileName ?? "No file chosen",
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFormValid ? _submitFormPelayanan : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? theme.primaryColor
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "Kirim",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isMenuOpen)
          AccessibilityMenu(
            onClose: () {
              ref.read(accessibilityMenuProvider.notifier).state = false;
            },
            top: 30,
            right: 10,
          ),
      ],
    );
  }
}
