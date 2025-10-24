// lib/core/services/layanan_konsultasi_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as Path;
import 'package:gaspul/core/theme/theme.dart';
import 'api_config.dart'; // <-- import ApiConfig

class LayananKonsultasiService {
  final Dio _dio = Dio();

  Future<void> submitKonsultasiForm({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController whatsappController,
    required TextEditingController emailController,
    required TextEditingController perihalController,
    required TextEditingController isiController,
    required TextEditingController tanggalController,
    File? selectedFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'nama_lengkap': nameController.text,
        'no_hp': whatsappController.text,
        'email': emailController.text,
        'perihal': perihalController.text,
        'isi_konsultasi': isiController.text,
        'dokumen': selectedFile != null
            ? await MultipartFile.fromFile(
                selectedFile.path,
                filename: Path.basename(selectedFile.path),
              )
            : null,
      });

      final response = await _dio.post(
        '${ApiConfig.baseUrl}/konsultasi/store', // <-- gunakan ApiConfig.baseUrl
        data: formData,
        options: Options(
          headers: {"Accept": "application/json"},
          contentType: 'multipart/form-data',
        ),
      );

      print("Response data: ${response.data}");

      if (response.statusCode == 200) {
        _clearFields(
          nameController,
          whatsappController,
          emailController,
          perihalController,
          isiController,
        );

        _showSuccessDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengirim form: ${response.statusMessage}"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Dio error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  void _clearFields(
    TextEditingController nameController,
    TextEditingController whatsappController,
    TextEditingController emailController,
    TextEditingController perihalController,
    TextEditingController isiController,
  ) {
    nameController.clear();
    whatsappController.clear();
    emailController.clear();
    perihalController.clear();
    isiController.clear();
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/Success_Send.json',
              width: 150,
              height: 150,
              repeat: false,
            ),
            const SizedBox(height: 16),
            const Text(
              "Permohonan Layanan Konsultasi Berhasil Dikirim!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Silahkan Mengunjungi Kantor Wilayah Kementerian Agama Provinsi Sulawesi Barat.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
