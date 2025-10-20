import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/core/data/queue_data.dart';
import 'package:gaspul/core/services/queue_service.dart';
import 'package:gaspul/core/widgets/form_widgets.dart'; // widget form custom
import '../home/widgets/main_app_bar.dart';

class QueueFormPage extends ConsumerStatefulWidget {
  final String? initialBidang;

  const QueueFormPage({super.key, this.initialBidang});

  @override
  ConsumerState<QueueFormPage> createState() => _QueueFormPageState();
}

class _QueueFormPageState extends ConsumerState<QueueFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? selectedBidang;
  String? selectedLayanan;
  String? selectedTanggal;

  OverlayEntry? _loadingOverlay;

  @override
  void initState() {
    super.initState();
    selectedBidang = widget.initialBidang;
  }

  List<String> getCurrentLayanan() {
    if (selectedBidang != null && layananPerBidang.containsKey(selectedBidang)) {
      return layananPerBidang[selectedBidang]!;
    }
    return [];
  }

  /// Menghasilkan opsi tanggal: hanya "Hari ini" dan "Besok" (jika keduanya bukan weekend).
  /// Jika hari ini Sabtu/Minggu, mengembalikan list kosong.
  List<Map<String, dynamic>> _generateTanggalOptions() {
    final List<Map<String, dynamic>> options = [];
    final now = DateTime.now();

    // Jika hari ini adalah Sabtu (6) atau Minggu (7) => tidak ada opsi
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return options;
    }

    // Hari ini (Senin - Jumat)
    options.add({"label": "Hari ini", "date": now});

    // Besok
    final tomorrow = now.add(const Duration(days: 1));
    if (tomorrow.weekday >= DateTime.monday && tomorrow.weekday <= DateTime.friday) {
      options.add({"label": "Besok", "date": tomorrow});
    }

    return options;
  }

  /// Menampilkan loading overlay saat submit
  void _showLoadingOverlay() {
    if (_loadingOverlay != null) return;

    _loadingOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.black54)),
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset('assets/lottie/Speed.json'),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_loadingOverlay!);
  }

  /// Menyembunyikan loading overlay
  void _hideLoadingOverlay() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  void _showNoScheduleSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tidak ada jadwal pelayanan hari ini atau besok (weekend).'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Submit form antrian
  void _submitForm() async {
    final tanggalOptions = _generateTanggalOptions();

    // Jika tidak ada opsi (weekend), jangan submit
    if (tanggalOptions.isEmpty) {
      _showNoScheduleSnack();
      return;
    }

    // Jika ada opsi, lanjut validasi form seperti biasa
    if (_formKey.currentState!.validate()) {
      final formData = {
        'nama': _nameController.text,
        'no_hp': _phoneController.text,
        'alamat': _addressController.text,
        'bidang_layanan': selectedBidang,
        'layanan': selectedLayanan,
        'tanggal_daftar': selectedTanggal,
        'keterangan': _notesController.text,
      };

      _showLoadingOverlay();
      try {
        await AntrianService.submitAntrian(
          context: context,
          data: formData,
        );
      } finally {
        _hideLoadingOverlay();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tanggalOptions = _generateTanggalOptions();

    // Jika selectedTanggal tidak ada lagi di opsi (mis. state berubah), reset supaya konsisten
    if (selectedTanggal != null) {
      final exists = tanggalOptions.any((opt) {
        final d = opt['date'] as DateTime;
        final formatted =
            "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
        return formatted == selectedTanggal;
      });
      if (!exists) {
        selectedTanggal = null;
      }
    }

    return Scaffold(
      appBar: const MainAppBar(title: "Form Antrian"),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 26,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== Dropdown Bidang =====
              CustomDropdownFormField<String>(
                value: selectedBidang,
                label: "Bidang Layanan",
                items: bidangLayanan.map((bidang) {
                  return DropdownMenuItem(
                    value: bidang["name"],
                    child: Row(
                      children: [
                        if (bidang["icon"] != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.asset(
                              bidang["icon"]!,
                              height: 24,
                              width: 24,
                              fit: BoxFit.contain,
                            ),
                          ),
                        Flexible(child: Text(bidang["name"] ?? "")),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBidang = value;
                    selectedLayanan = null;
                  });
                },
                validator: (value) =>
                    value == null ? "Bidang layanan wajib dipilih" : null,
              ),
              const SizedBox(height: 12),

              // ===== Dropdown Layanan =====
              CustomDropdownFormField<String>(
                value: selectedLayanan,
                label: "Daftar Layanan",
                items: getCurrentLayanan()
                    .map((layanan) => DropdownMenuItem(
                          value: layanan,
                          child: Text(layanan),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedLayanan = value),
                validator: (value) =>
                    value == null ? "Layanan wajib dipilih" : null,
                menuMaxHeight: 400,
              ),
              const SizedBox(height: 12),

              // ===== Nama =====
              CustomTextFormField(
                controller: _nameController,
                label: "Nama",
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              // ===== No HP =====
              CustomTextFormField(
                controller: _phoneController,
                label: "No HP",
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? "No HP wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              // ===== Alamat =====
              CustomTextFormField(
                controller: _addressController,
                label: "Alamat",
                validator: (value) =>
                    value == null || value.isEmpty ? "Alamat wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              // ===== Dropdown Tanggal =====
              if (tanggalOptions.isEmpty) ...[
                // Jika weekend: tampilkan pesan dan jangan tampilkan dropdown
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.1)),
                  ),
                  child: const Text(
                    'Maaf — tidak ada jadwal pendaftaran untuk hari ini atau besok (Sabtu/Minggu).',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ] else ...[
                CustomDropdownFormField<String>(
                  value: selectedTanggal,
                  label: "Pilihan Tanggal Daftar",
                  items: tanggalOptions.map((item) {
                    final date = item["date"] as DateTime;
                    final formattedDate =
                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    final label = item["label"] as String;
                    return DropdownMenuItem(
                      value: formattedDate,
                      child: Text("$label ($formattedDate)"),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedTanggal = value),
                  validator: (value) =>
                      value == null ? "Tanggal daftar wajib dipilih" : null,
                ),
              ],

              const SizedBox(height: 12),

              // ===== Keterangan =====
              CustomTextFormField(
                controller: _notesController,
                label: "Keterangan",
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // ===== Tombol Submit =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    "Submit",
                    style: theme.textTheme.bodyLarge!.copyWith(
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
    );
  }

  @override
  void dispose() {
    _loadingOverlay?.remove();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lottie/lottie.dart';
// import 'package:gaspul/core/theme/theme.dart';
// import 'package:gaspul/core/data/queue_data.dart';
// import 'package:gaspul/core/services/queue_service.dart';
// import 'package:gaspul/core/widgets/form_widgets.dart'; // widget form custom
// import '../home/widgets/main_app_bar.dart';

// class QueueFormPage extends ConsumerStatefulWidget {
//   final String? initialBidang;

//   const QueueFormPage({super.key, this.initialBidang});

//   @override
//   ConsumerState<QueueFormPage> createState() => _QueueFormPageState();
// }

// class _QueueFormPageState extends ConsumerState<QueueFormPage> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();

//   String? selectedBidang;
//   String? selectedLayanan;
//   String? selectedTanggal;

//   OverlayEntry? _loadingOverlay;

//   @override
//   void initState() {
//     super.initState();
//     selectedBidang = widget.initialBidang;
//   }

//   List<String> getCurrentLayanan() {
//     if (selectedBidang != null && layananPerBidang.containsKey(selectedBidang)) {
//       return layananPerBidang[selectedBidang]!;
//     }
//     return [];
//   }

//   /// Menampilkan loading overlay saat submit
//   void _showLoadingOverlay() {
//     if (_loadingOverlay != null) return;

//     _loadingOverlay = OverlayEntry(
//       builder: (context) => Stack(
//         children: [
//           Positioned.fill(child: Container(color: Colors.black54)),
//           Center(
//             child: SizedBox(
//               width: 200,
//               height: 200,
//               child: Lottie.asset('assets/lottie/Speed.json'),
//             ),
//           ),
//         ],
//       ),
//     );
//     Overlay.of(context).insert(_loadingOverlay!);
//   }

//   /// Menyembunyikan loading overlay
//   void _hideLoadingOverlay() {
//     _loadingOverlay?.remove();
//     _loadingOverlay = null;
//   }

//   /// Submit form antrian
//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       final formData = {
//         'nama': _nameController.text,
//         'no_hp': _phoneController.text,
//         'alamat': _addressController.text,
//         'bidang_layanan': selectedBidang,
//         'layanan': selectedLayanan,
//         'tanggal_daftar': selectedTanggal,
//         'keterangan': _notesController.text,
//       };

//       _showLoadingOverlay();
//       try {
//         await AntrianService.submitAntrian(
//           context: context,
//           data: formData,
//         );
//       } finally {
//         _hideLoadingOverlay();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: const MainAppBar(title: "Form Antrian"), // ✅ Gunakan AppBar reusable
//       body: SingleChildScrollView(
//         padding: EdgeInsets.only(
//           left: 16,
//           right: 16,
//           top: 26,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//         ),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // ===== Dropdown Bidang =====
//               CustomDropdownFormField<String>(
//                 value: selectedBidang,
//                 label: "Bidang Layanan",
//                 items: bidangLayanan.map((bidang) {
//                   return DropdownMenuItem(
//                     value: bidang["name"],
//                     child: Row(
//                       children: [
//                         if (bidang["icon"] != null)
//                           Padding(
//                             padding: const EdgeInsets.only(right: 8),
//                             child: Image.asset(
//                               bidang["icon"]!,
//                               height: 24,
//                               width: 24,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         Flexible(child: Text(bidang["name"] ?? "")),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedBidang = value;
//                     selectedLayanan = null;
//                   });
//                 },
//                 validator: (value) =>
//                     value == null ? "Bidang layanan wajib dipilih" : null,
//               ),
//               const SizedBox(height: 12),

//               // ===== Dropdown Layanan =====
//               CustomDropdownFormField<String>(
//                 value: selectedLayanan,
//                 label: "Daftar Layanan",
//                 items: getCurrentLayanan()
//                     .map((layanan) => DropdownMenuItem(
//                           value: layanan,
//                           child: Text(layanan),
//                         ))
//                     .toList(),
//                 onChanged: (value) => setState(() => selectedLayanan = value),
//                 validator: (value) =>
//                     value == null ? "Layanan wajib dipilih" : null,
//                 menuMaxHeight: 400,
//               ),
//               const SizedBox(height: 12),

//               // ===== Nama =====
//               CustomTextFormField(
//                 controller: _nameController,
//                 label: "Nama",
//                 validator: (value) =>
//                     value == null || value.isEmpty ? "Nama wajib diisi" : null,
//               ),
//               const SizedBox(height: 12),

//               // ===== No HP =====
//               CustomTextFormField(
//                 controller: _phoneController,
//                 label: "No HP",
//                 keyboardType: TextInputType.phone,
//                 validator: (value) =>
//                     value == null || value.isEmpty ? "No HP wajib diisi" : null,
//               ),
//               const SizedBox(height: 12),

//               // ===== Alamat =====
//               CustomTextFormField(
//                 controller: _addressController,
//                 label: "Alamat",
//                 validator: (value) =>
//                     value == null || value.isEmpty ? "Alamat wajib diisi" : null,
//               ),
//               const SizedBox(height: 12),

//               // ===== Dropdown Tanggal =====
//               CustomDropdownFormField<String>(
//                 value: selectedTanggal,
//                 label: "Pilihan Tanggal Daftar",
//                 items: [
//                   {"label": "Hari ini", "date": DateTime.now()},
//                   {
//                     "label": "Besok",
//                     "date": DateTime.now().add(const Duration(days: 1)),
//                   },
//                 ].map((item) {
//                   final date = item["date"] as DateTime;
//                   final formattedDate =
//                       "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//                   return DropdownMenuItem(
//                     value: formattedDate,
//                     child: Text("${item["label"]} ($formattedDate)"),
//                   );
//                 }).toList(),
//                 onChanged: (value) => setState(() => selectedTanggal = value),
//                 validator: (value) =>
//                     value == null ? "Tanggal daftar wajib dipilih" : null,
//               ),
//               const SizedBox(height: 12),

//               // ===== Keterangan =====
//               CustomTextFormField(
//                 controller: _notesController,
//                 label: "Keterangan",
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 20),

//               // ===== Tombol Submit =====
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   onPressed: _submitForm,
//                   child: Text(
//                     "Submit",
//                     style: theme.textTheme.bodyLarge!.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _loadingOverlay?.remove();
//     _nameController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }
// }
