import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart' as pw;

Future<void> showPdfPopup(
  BuildContext context, {
  required String pdfUrl,
  required String nomor,
}) {
  return showGeneralDialog(
    context: context,
    barrierLabel: "PDF Popup",
    barrierDismissible: true,
    barrierColor: Colors.black54,
    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: PdfPopup(pdfUrl: pdfUrl, nomor: nomor),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}

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
  bool loading = true;
  String? errorMessage;
  PdfController? pdfController;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    if (widget.pdfUrl.isEmpty) {
      setState(() {
        loading = false;
        errorMessage = 'URL PDF tidak tersedia';
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        pdfData = response.bodyBytes;
        pdfController = PdfController(document: PdfDocument.openData(pdfData!));
        setState(() => loading = false);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _printPdf(BuildContext dialogContext) async {
    if (pdfData == null) return;
    try {
      final backendFileName = p.basename(widget.pdfUrl);
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
      final pw.PdfPageFormat format =
          pw.PdfPageFormat(8 * inch, 10.5 * inch).landscape;

      await Printing.layoutPdf(
        name: fileName,
        format: format,
        onLayout: (_) => pdfData!,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        Navigator.of(dialogContext, rootNavigator: true).context,
      ).showSnackBar(
        SnackBar(content: Text('❌ Gagal print PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final screen = MediaQuery.of(context).size;

    // 🔹 Faktor scaling keseluruhan
    const double scaleFactor = 0.85;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screen.height * 0.02,
            horizontal: screen.width * 0.03,
          ),
          child: loading
              ? const CircularProgressIndicator()
              : pdfData == null
                  ? _errorBox()
                  : FutureBuilder<PdfPageImage?>(
                      future: _getPageSizePreview(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final pdfPage = snapshot.data!;
                        final pdfRatio =
                            (pdfPage.width ?? 1) / (pdfPage.height ?? 1);

                        // 🔹 Hitung ukuran popup yang aman dengan scale
                        final double maxWidth = screen.width * 0.9 * scaleFactor;
                        final double maxHeight = screen.height * 0.8 * scaleFactor;

                        double width = maxWidth;
                        double height = width / pdfRatio;

                        if (height > maxHeight) {
                          height = maxHeight;
                          width = height * pdfRatio;
                        }

                        return SingleChildScrollView(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Material(
                              color: Colors.white,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: width,
                                  maxHeight: height + 120, // space untuk tombol
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 🔹 PDF tampilan utama
                                    SizedBox(
                                      width: width,
                                      height: height,
                                      child: PdfView(
                                        controller: pdfController!,
                                        pageSnapping: false,
                                        physics: const NeverScrollableScrollPhysics(),
                                      ),
                                    ),

                                    // 🔹 Teks peringatan
                                    Container(
                                      width: double.infinity,
                                      color: Colors.amber[50],
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.info_outline,
                                              size: 18, color: Colors.deepOrange),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              'Silakan unduh atau cetak tiket PDF sebelum menutup pop-up ini.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.deepOrange,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 🔹 Tombol aksi
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () => _printPdf(context),
                                            icon: const Icon(Icons.print, size: 18),
                                            label: const Text('Print / Save'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
                                              textStyle: const TextStyle(fontSize: 13),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              if (mounted) Navigator.pop(context);
                                            },
                                            icon: const Icon(Icons.close, size: 18),
                                            label: const Text('Tutup'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
                                              textStyle: const TextStyle(fontSize: 13),
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
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  /// Ambil halaman pertama untuk tahu ukuran PDF
  Future<PdfPageImage?> _getPageSizePreview() async {
    final doc = await PdfDocument.openData(pdfData!);
    final page = await doc.getPage(1);
    final image = await page.render(
      width: page.width,
      height: page.height,
      format: PdfPageImageFormat.png,
    );
    await page.close();
    return image;
  }

  Widget _errorBox() => Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'PDF gagal dimuat.\n$errorMessage',
            textAlign: TextAlign.center,
          ),
        ),
      );
}
