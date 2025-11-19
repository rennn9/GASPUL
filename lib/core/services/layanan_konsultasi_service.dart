import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as Path;
import 'package:gaspul/core/widgets/pdf_popup.dart';
import 'api_config.dart';

class LayananKonsultasiService {
  final Dio _dio = Dio();

  Future<void> submitKonsultasiForm({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController whatsappController,
    required TextEditingController alamatController,
    required TextEditingController emailController,
    required TextEditingController perihalController,
    required TextEditingController asalInstansiController, // ✅ baru
    required TextEditingController tanggalController,
    File? selectedFile,
  }) async {
    try {
      // 🔹 Siapkan data form sesuai kolom di Laravel
      final formData = FormData.fromMap({
        'nama_lengkap': nameController.text.trim(),
        'no_hp_wa': whatsappController.text.trim(),
        'alamat': alamatController.text.trim(),
        'email': emailController.text.trim(),
        'perihal': perihalController.text.trim(),
        'asal_instansi': asalInstansiController.text.trim(), // ✅ baru
        'tanggal_layanan': tanggalController.text.trim(),
        if (selectedFile != null)
          'dokumen': await MultipartFile.fromFile(
            selectedFile.path,
            filename: Path.basename(selectedFile.path),
          ),
      });

      // 🔹 Kirim request ke endpoint KonsultasiController
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/konsultasi/store',
        data: formData,
        options: Options(
          headers: {"Accept": "application/json"},
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint("Response data: ${response.data}");

      // 🔹 Cek status respons
      if (response.statusCode == 200 && response.data != null) {
        _clearFields(
          nameController,
          whatsappController,
          alamatController,
          emailController,
          perihalController,
          asalInstansiController, // ✅ reset instansi
        );

        final data = response.data['data'] ?? response.data;

        final pdfUrl = data['pdf_url'] ?? data['pdf'] ?? '';
        final nomor = data['nomor']?.toString() ?? '---';

        if (pdfUrl.isNotEmpty) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => PdfPopup(
              pdfUrl: pdfUrl,
              nomor: nomor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gagal memuat tiket konsultasi PDF dari server."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengirim form: ${response.statusMessage}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Dio error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔹 Reset field setelah submit sukses
  void _clearFields(
    TextEditingController nameController,
    TextEditingController whatsappController,
    TextEditingController alamatController,
    TextEditingController emailController,
    TextEditingController perihalController,
    TextEditingController asalInstansiController,
  ) {
    nameController.clear();
    whatsappController.clear();
    alamatController.clear();
    emailController.clear();
    perihalController.clear();
    asalInstansiController.clear();
  }
}
