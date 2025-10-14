import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart'; // 👈 ini tetap untuk PdfViewPinch
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart' as pw; // 👈 pakai alias 'pw' untuk hindari bentrok PdfDocument

class PdfPopup extends StatefulWidget {
  final String pdfUrl;
  final String nomor;

  const PdfPopup({
    super.key,
    required this.pdfUrl,
    required this.nomor,
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
      final backendFileName = p.basename(widget.pdfUrl); // contoh: 2025-10-14-016.pdf

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

      // ✅ Ukuran government letter dalam point (1 inch = 72 pt)
      const double inch = 72.0;
      final pw.PdfPageFormat governmentLetterLandscape = pw.PdfPageFormat(
        8 * inch,     // lebar 8 inch
        10.5 * inch,  // tinggi 10.5 inch
      ).landscape;    // orientasi landscape

      await Printing.layoutPdf(
        name: fileName,
        format: governmentLetterLandscape, // ✅ atur format di sini
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
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // 🟦 Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiket Antrian #${widget.nomor}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 📄 PDF Viewer / Loading / Error
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : pdfData != null
                      ? PdfViewPinch(
                          controller: PdfControllerPinch(
                            document: PdfDocument.openData(pdfData!), // ini milik pdfx
                          ),
                        )
                      : Center(
                          child: Text(
                            'PDF gagal dimuat.\n$errorMessage',
                            textAlign: TextAlign.center,
                          ),
                        ),
            ),

            // 🖨 Tombol Print PDF
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _printPdf,
                    icon: const Icon(Icons.print),
                    label: const Text('Print / Save as PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
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
