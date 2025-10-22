import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart'; // 👈 PdfViewPinch
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart' as pw; // alias pw untuk PdfDocument

class PdfPopup extends StatefulWidget {
  final String pdfUrl;
  final String nomor;
  final double popupHeightFactor; // ✨ 0.0 - 1.0, default 0.75

  const PdfPopup({
    super.key,
    required this.pdfUrl,
    required this.nomor,
    this.popupHeightFactor = 0.75,
  });

  @override
  State<PdfPopup> createState() => _PdfPopupState();
}

class _PdfPopupState extends State<PdfPopup> {
  Uint8List? pdfData;
  String? errorMessage;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf({int retryCount = 3}) async {
    if (widget.pdfUrl.isEmpty) {
      setState(() {
        loading = false;
        errorMessage = 'URL PDF tidak tersedia';
      });
      return;
    }

    for (int i = 0; i < retryCount; i++) {
      try {
        final response = await http.get(Uri.parse(widget.pdfUrl));
        if (response.statusCode == 200) {
          setState(() {
            pdfData = response.bodyBytes;
            loading = false;
          });
          return;
        } else {
          throw Exception('HTTP ${response.statusCode} saat memuat PDF');
        }
      } catch (e) {
        if (i == retryCount - 1) {
          setState(() {
            loading = false;
            errorMessage = e.toString();
          });
        } else {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
  }

  /// 🖨 Print / Save PDF dengan ukuran Government Letter Landscape
  Future<void> _printPdf() async {
    if (pdfData == null) return;

    try {
      final backendFileName = p.basename(widget.pdfUrl);

      // Parse tanggal & nomor dari nama file backend
      String tanggal = '';
      String nomor = widget.nomor;
      final regex = RegExp(r'(\d{4}-\d{2}-\d{2})-(\d+)\.pdf');
      final match = regex.firstMatch(backendFileName);
      if (match != null) {
        tanggal = match.group(1)!;
        nomor = match.group(2)!;
      }

      final fileName = 'tiket-antrian-$nomor-tgl-$tanggal.pdf';

      const double inch = 72.0;
      final pw.PdfPageFormat governmentLetterLandscape = pw.PdfPageFormat(
        8 * inch,
        10.5 * inch,
      ).landscape;

      await Printing.layoutPdf(
        name: fileName,
        format: governmentLetterLandscape,
        onLayout: (_) => pdfData!,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal print PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * widget.popupHeightFactor,
        child: Column(
          children: [
            // 📄 PDF Viewer / Loading / Error
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : pdfData != null
                      ? PdfViewPinch(
                          controller: PdfControllerPinch(
                            document: PdfDocument.openData(pdfData!),
                          ),
                        )
                      : Center(
                          child: Text(
                            'PDF gagal dimuat.\n$errorMessage',
                            textAlign: TextAlign.center,
                          ),
                        ),
            ),

            // ⚠️ Peringatan Save PDF
            if (!loading && pdfData != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '⚠️ Pastikan sudah menyimpan / print PDF sebelum menutup pop-up!',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // 🖨 / ❌ Tombol di bawah
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _printPdf,
                    icon: const Icon(Icons.print),
                    label: const Text('Print / Save PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Tutup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
