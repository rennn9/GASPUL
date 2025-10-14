//gaspul\lib\features\queue\queue_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/core/data/queue_data.dart';
import '../home/widgets/menu_button.dart';
import '../home/widgets/accessibility_menu.dart';
import '../home/home_providers.dart';
import 'package:gaspul/core/services/queue_service.dart';
import 'package:gaspul/core/widgets/form_widgets.dart'; // <- import custom widgets

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

  OverlayEntry? _accessibilityOverlay;
  OverlayEntry? _loadingOverlay;

  @override
  void initState() {
    super.initState();
    selectedBidang = widget.initialBidang;
  }

  List<String> getCurrentLayanan() =>
      selectedBidang != null && layananPerBidang.containsKey(selectedBidang)
          ? layananPerBidang[selectedBidang]!
          : [];

  void _showAccessibilityMenu() {
    if (_accessibilityOverlay != null) return;
    _accessibilityOverlay = OverlayEntry(
      builder: (context) => AccessibilityMenu(
        top: 28,
        right: 12,
        bottom: null,
        onClose: _removeAccessibilityMenu,
      ),
    );
    Overlay.of(context).insert(_accessibilityOverlay!);
  }

  void _removeAccessibilityMenu() {
    _accessibilityOverlay?.remove();
    _accessibilityOverlay = null;
    ref.read(accessibilityMenuProvider.notifier).state = false;
  }

  void _showLoadingOverlay() {
    if (_loadingOverlay != null) return;

    _loadingOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black54),
          ),
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

  void _submitForm() async {
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
        await AntrianService.submitAntrian(context: context, data: formData);
      } finally {
        _hideLoadingOverlay();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          "Form Antrian",
          style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
        ),
        backgroundColor: isHighContrast ? Colors.black : AppColors.primary,
        centerTitle: false,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: MenuButton(
              onTap: () {
                final isOpen = ref.read(accessibilityMenuProvider);
                if (isOpen) {
                  _removeAccessibilityMenu();
                } else {
                  _showAccessibilityMenu();
                  ref.read(accessibilityMenuProvider.notifier).state = true;
                }
              },
            ),
          ),
        ],
        bottom: isHighContrast
            ? const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: Colors.white),
              )
            : null,
      ),
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

              // Dropdown Layanan (tinggi lebih)
              CustomDropdownFormField<String>(
                value: selectedLayanan,
                label: "Daftar Layanan",
                items: getCurrentLayanan()
                    .map(
                      (layanan) => DropdownMenuItem(
                        value: layanan,
                        child: Text(layanan),
                      ),
                    )
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
                label: "Nama",
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              // No HP
              CustomTextFormField(
                controller: _phoneController,
                label: "No HP",
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? "No HP wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              // Alamat
              CustomTextFormField(
                controller: _addressController,
                label: "Alamat",
                validator: (value) => value == null || value.isEmpty
                    ? "Alamat wajib diisi"
                    : null,
              ),
              const SizedBox(height: 12),

              // Dropdown Tanggal
              CustomDropdownFormField<String>(
                value: selectedTanggal,
                label: "Pilihan Tanggal Daftar",
                items: [
                  {"label": "Hari ini", "date": DateTime.now()},
                  {
                    "label": "Besok",
                    "date": DateTime.now().add(const Duration(days: 1)),
                  },
                ].map((item) {
                  final date = item["date"] as DateTime;
                  final formattedDate =
                      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  return DropdownMenuItem(
                    value: formattedDate,
                    child: Text("${item["label"]} ($formattedDate)"),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedTanggal = value),
                validator: (value) =>
                    value == null ? "Tanggal daftar wajib dipilih" : null,
              ),
              const SizedBox(height: 12),

              // Keterangan
              CustomTextFormField(
                controller: _notesController,
                label: "Keterangan",
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Submit Button
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
    _accessibilityOverlay?.remove();
    _loadingOverlay?.remove();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
