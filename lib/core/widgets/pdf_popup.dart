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
  int currentAttempt = 0;
  int maxRetries = 3;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    if (widget.pdfUrl.isEmpty) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = 'URL PDF tidak tersedia';
      });
      return;
    }

    // Reset state
    if (!mounted) return;
    setState(() {
      loading = true;
      errorMessage = null;
      currentAttempt = 0;
    });

    while (currentAttempt < maxRetries) {
      currentAttempt++;
      if (!mounted) return;
      setState(() {}); // Update UI with new attempt number

      debugPrint('📥 Attempt $currentAttempt/$maxRetries - Downloading PDF: ${widget.pdfUrl}');

      try {
        // Use persistent connection with custom headers
        final client = http.Client();
        try {
          final request = http.Request('GET', Uri.parse(widget.pdfUrl));
          request.headers['Connection'] = 'keep-alive';
          request.headers['Accept'] = 'application/pdf,*/*';

          final streamedResponse = await client.send(request).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('⏱️ Request timeout (30 detik) - Server tidak merespons');
            },
          );

          if (streamedResponse.statusCode == 200) {
            // Read response in chunks to handle connection properly
            final bytes = await streamedResponse.stream.toBytes();
            debugPrint('✅ PDF downloaded successfully (${bytes.length} bytes)');

            if (!mounted) return;
            setState(() {
              pdfData = bytes;
              pdfController = PdfController(document: PdfDocument.openData(pdfData!));
              loading = false;
            });
            return; // Success, exit function
          } else {
            throw Exception('HTTP ${streamedResponse.statusCode}: ${streamedResponse.reasonPhrase}');
          }
        } finally {
          client.close();
        }
      } catch (e) {
        debugPrint('❌ Attempt $currentAttempt failed: $e');

        if (currentAttempt >= maxRetries) {
          // Final attempt failed
          if (!mounted) return;
          setState(() {
            loading = false;
            errorMessage = _buildErrorMessage(e, currentAttempt);
          });
          return;
        }

        // Wait before retry (exponential backoff: 1s, 2s, 4s)
        final delaySeconds = currentAttempt * currentAttempt;
        debugPrint('⏳ Waiting ${delaySeconds}s before retry...');
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
  }

  String _buildErrorMessage(dynamic error, int attempts) {
    String message = error.toString();

    if (message.contains('SocketException') || message.contains('Connection closed')) {
      return 'Koneksi terputus saat mengunduh PDF.\n\n'
          'Kemungkinan penyebab:\n'
          '• Koneksi internet tidak stabil\n'
          '• Server sedang sibuk\n'
          '• File PDF terlalu besar\n\n'
          'Sudah dicoba $attempts kali.\n\n'
          'Solusi: Cek koneksi internet Anda atau coba beberapa saat lagi.';
    } else if (message.contains('timeout')) {
      return 'Waktu tunggu habis (timeout).\n\n'
          'Server membutuhkan waktu lebih dari 30 detik.\n'
          'Sudah dicoba $attempts kali.\n\n'
          'Solusi: Coba lagi nanti atau hubungi administrator.';
    } else if (message.contains('HTTP 404')) {
      return 'File PDF tidak ditemukan di server (404).\n\n'
          'URL: ${widget.pdfUrl}\n\n'
          'Hubungi administrator untuk melaporkan masalah ini.';
    } else if (message.contains('HTTP 500')) {
      return 'Server mengalami error (500).\n\n'
          'Terjadi kesalahan di sisi server saat membuat PDF.\n\n'
          'Hubungi administrator untuk melaporkan masalah ini.';
    }

    return 'Gagal memuat PDF setelah $attempts percobaan.\n\n'
        'Error: $message\n\n'
        'Hubungi administrator jika masalah berlanjut.';
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
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(
        Navigator.of(dialogContext, rootNavigator: true).context,
      );
      messenger.showSnackBar(
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
              ? _buildLoadingIndicator()
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

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Mengunduh PDF...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Percobaan $currentAttempt dari $maxRetries',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mohon tunggu hingga 30 detik...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'PDF Gagal Dimuat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              errorMessage ?? 'Terjadi kesalahan tidak diketahui',
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  loadPdf(); // Retry
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  if (mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Tutup'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
