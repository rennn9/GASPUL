import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/core/data/queue_data.dart';
import 'package:gaspul/core/services/queue_service.dart';
import 'package:gaspul/core/services/server_time_service.dart';
import 'package:gaspul/core/widgets/form_widgets.dart';
import '../home/widgets/main_app_bar.dart';
import 'package:gaspul/core/widgets/gaspul_safe_scaffold.dart';

class QueueFormPage extends ConsumerStatefulWidget {
  final String? initialBidang;

  const QueueFormPage({super.key, this.initialBidang});

  @override
  ConsumerState<QueueFormPage> createState() => _QueueFormPageState();
}

class _QueueFormPageState extends ConsumerState<QueueFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // ✅ email opsional
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

  List<Map<String, dynamic>> generateTanggalOptions(DateTime serverNow) {
    final List<Map<String, dynamic>> options = [];

    if (serverNow.weekday == DateTime.saturday || serverNow.weekday == DateTime.sunday) {
      return options;
    }

    options.add({"label": "Hari ini", "date": serverNow});

    final tomorrow = serverNow.add(const Duration(days: 1));
    if (tomorrow.weekday >= DateTime.monday && tomorrow.weekday <= DateTime.friday) {
      options.add({"label": "Besok", "date": tomorrow});
    }

    return options;
  }

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

  void _submitForm() async {
    final serverNow = await ServerTimeService.getServerTime();
    if (serverNow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal ambil waktu server")),
      );
      return;
    }

    final tanggalOptions = generateTanggalOptions(serverNow);
    if (tanggalOptions.isEmpty) {
      _showNoScheduleSnack();
      return;
    }

    if (_formKey.currentState!.validate()) {
      final formData = {
        'nama_lengkap': _nameController.text,
        'email': _emailController.text.isEmpty ? null : _emailController.text, // ✅ opsional
        'no_hp_wa': _phoneController.text,
        'alamat': _addressController.text,
        'bidang_layanan': selectedBidang,
        'layanan': selectedLayanan,
        'tanggal_layanan': selectedTanggal,
        'keterangan': _notesController.text,
      };

      _showLoadingOverlay();
      try {
        await AntrianService.submitAntrian(
          context: context,
          data: formData,
          popupHeightFactor: 0.53,
          onSuccess: () {
            _formKey.currentState!.reset();
            _nameController.clear();
            _emailController.clear();
            _phoneController.clear();
            _addressController.clear();
            _notesController.clear();
            setState(() {
              selectedBidang = null;
              selectedLayanan = null;
              selectedTanggal = null;
            });
          },
        );
      } finally {
        _hideLoadingOverlay();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GasPulSafeScaffold(
      appBar: const MainAppBar(title: "Form Antrian"),
      body: FutureBuilder<DateTime?>(
        future: ServerTimeService.getServerTime(),
        builder: (context, snapshotTime) {
          if (snapshotTime.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshotTime.hasData) {
            return const Center(child: Text("Gagal memuat waktu server"));
          }

          final serverNow = snapshotTime.data!;
          final tanggalOptions = generateTanggalOptions(serverNow);

          if (selectedTanggal != null) {
            final exists = tanggalOptions.any((opt) {
              final d = opt['date'] as DateTime;
              final formatted =
                  "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
              return formatted == selectedTanggal;
            });
            if (!exists) selectedTanggal = null;
          }

          return SingleChildScrollView(
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
                  // Dropdown Bidang
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

                  // Dropdown Layanan
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

                  // Nama
                  CustomTextFormField(
                    controller: _nameController,
                    label: "Nama Lengkap",
                    validator: (value) =>
                        value == null || value.isEmpty ? "Nama wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),

                  // ✅ Email (opsional)
                  CustomTextFormField(
                    controller: _emailController,
                    label: "Email (opsional)",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return "Format email tidak valid";
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // No HP
                  CustomTextFormField(
                    controller: _phoneController,
                    label: "No. HP/WA",
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value == null || value.isEmpty ? "No HP wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),

                  // Alamat
                  CustomTextFormField(
                    controller: _addressController,
                    label: "Alamat",
                    validator: (value) =>
                        value == null || value.isEmpty ? "Alamat wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),

                  // Dropdown Tanggal
                  if (tanggalOptions.isEmpty) ...[
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

                  // Keterangan
                  CustomTextFormField(
                    controller: _notesController,
                    label: "Keterangan (Opsional)",
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Tombol Submit
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _loadingOverlay?.remove();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
