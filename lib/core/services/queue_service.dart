import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../widgets/pdf_popup.dart';

class AntrianService {
  static const String baseUrl = 'http://192.168.1.21:8000/api';

  static bool _isJson(String str) {
    try {
      jsonDecode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool _looksLikeHtml(String str) {
    return str.trimLeft().startsWith('<!DOCTYPE html>') ||
        str.trimLeft().startsWith('<html');
  }

static Future<void> submitAntrian({
  required BuildContext context,
  required Map<String, dynamic> data,
  double popupHeightFactor = 0.53,
  VoidCallback? onSuccess, // ✨ callback untuk reset form
}) async {
  final url = Uri.parse('$baseUrl/antrian/submit');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    final body = response.body;

    if (_isJson(body)) {
      final result = jsonDecode(body);

      if (result['success'] == true) {
        final pdfUrl = result['pdf_url'] ?? '';
        final nomor = result['nomor_antrian']?.toString() ?? '(Nomor tidak diketahui)';

        // ✅ Panggil PdfPopup
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => PdfPopup(
            pdfUrl: pdfUrl,
            nomor: nomor,
            popupHeightFactor: popupHeightFactor,
          ),
        ).then((_) {
          // 🔹 setelah popup ditutup, reset form
          if (onSuccess != null) onSuccess();
        });
      } else {
        _showErrorDialog(context, 'Server Error', body);
      }
    } else if (_looksLikeHtml(body) && response.statusCode == 200) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PdfPopup(
          pdfUrl: '',
          nomor: '(Nomor tidak diketahui)',
          popupHeightFactor: popupHeightFactor,
        ),
      ).then((_) {
        if (onSuccess != null) onSuccess();
      });
    } else {
      _showErrorDialog(context, 'Invalid Response', body);
    }
  } catch (e, stack) {
    _showErrorDialog(context, e.toString(), stack.toString());
  }
}


  static void _showErrorDialog(BuildContext context, String title, String log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('❌ $title'),
        content: SingleChildScrollView(child: SelectableText(log)),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: log));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Log error berhasil disalin 📋')),
              );
            },
            child: const Text('Copy Log'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
