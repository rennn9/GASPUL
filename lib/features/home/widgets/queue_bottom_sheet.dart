import 'package:flutter/material.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/core/data/queue_data.dart';
import '../../queue/queue_form_page.dart';
import '../../queue/layanan_konsultasi_form_page.dart';

class QueueBottomSheet extends StatelessWidget {
  const QueueBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.brightness == Brightness.dark;

    final backgroundColor = isHighContrast ? Colors.black : Colors.white;
    final textColor = isHighContrast ? Colors.white : Colors.black;
    final containerBorderColor =
        isHighContrast ? Colors.white : Colors.transparent;

    // tinggi sheet responsif
    final size = MediaQuery.of(context).size;
    final heightFactor = _calculateHeightFactor(context);

    // pastikan sheet tidak lebih tinggi dari layar
    final sheetHeight = (size.height * heightFactor).clamp(0.0, size.height);

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: containerBorderColor,
          width: isHighContrast ? 2 : 0,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color:
                          isHighContrast ? Colors.grey[600] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Pilih Bidang Layanan",
                    style: theme.textTheme.titleLarge!.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.grey),

            // 🔹 List bidang scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  24 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: bidangLayanan.map((bidang) {
                    final buttonColor =
                        isHighContrast ? Colors.black : AppColors.primary;
                    final buttonTextColor = Colors.white;
                    final buttonBorder = isHighContrast
                        ? const BorderSide(color: Colors.white, width: 2)
                        : BorderSide.none;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            side: buttonBorder,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);

                            if (bidang["name"] == "Layanan Konsultasi") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const LayananKonsultasiFormPage(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QueueFormPage(
                                    initialBidang: bidang["name"]!,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                              Flexible(
                                child: Text(
                                  bidang["name"] ?? "",
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: buttonTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Mengatur tinggi bottom sheet secara responsif
  double _calculateHeightFactor(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isWideScreen = size.width > 600; // misal tablet / layar besar

    if (isLandscape || isWideScreen) {
      return 2; // lebih tinggi di lanskap / tablet
    } else {
      return 1.2; // default portrait / HP normal
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:gaspul/core/theme/theme.dart';
// import 'package:gaspul/core/data/queue_data.dart';
// import '../../queue/queue_form_page.dart';
// import '../../queue/layanan_konsultasi_form_page.dart';

// class QueueBottomSheet extends StatelessWidget {
//   const QueueBottomSheet({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isHighContrast = theme.brightness == Brightness.dark;

//     final backgroundColor = isHighContrast ? Colors.black : Colors.white;
//     final textColor = isHighContrast ? Colors.white : Colors.black;
//     final containerBorderColor =
//         isHighContrast ? Colors.white : Colors.transparent;

//     // tinggi sheet responsif
//     final screenHeight = MediaQuery.of(context).size.height;
//     final sheetHeight = screenHeight * 0.85; // 85% tinggi layar

//     return Container(
//       height: sheetHeight,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         border: Border.all(
//           color: containerBorderColor,
//           width: isHighContrast ? 2 : 0,
//         ),
//       ),
//       child: SafeArea(
//         top: false,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // 🔹 Header
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               child: Column(
//                 children: [
//                   Container(
//                     width: 50,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color:
//                           isHighContrast ? Colors.grey[600] : Colors.grey[400],
//                       borderRadius: BorderRadius.circular(2.5),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "Pilih Bidang Layanan",
//                     style: theme.textTheme.titleLarge!.copyWith(
//                       color: textColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const Divider(height: 1, color: Colors.grey),

//             // 🔹 List bidang scrollable
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.fromLTRB(
//                   16,
//                   4,
//                   16,
//                   24 + MediaQuery.of(context).padding.bottom,
//                 ),
//                 child: Column(
//                   children: bidangLayanan.map((bidang) {
//                     final buttonColor =
//                         isHighContrast ? Colors.black : AppColors.primary;
//                     final buttonTextColor = Colors.white;
//                     final buttonBorder = isHighContrast
//                         ? const BorderSide(color: Colors.white, width: 2)
//                         : BorderSide.none;

//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 6),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: buttonColor,
//                             side: buttonBorder,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 12,
//                               horizontal: 8,
//                             ),
//                           ),
//                           onPressed: () {
//                             Navigator.pop(context);

//                             if (bidang["name"] == "Layanan Konsultasi") {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) =>
//                                       const LayananKonsultasiFormPage(),
//                                 ),
//                               );
//                             } else {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => QueueFormPage(
//                                     initialBidang: bidang["name"]!,
//                                   ),
//                                 ),
//                               );
//                             }
//                           },
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               if (bidang["icon"] != null)
//                                 Padding(
//                                   padding: const EdgeInsets.only(right: 8),
//                                   child: Image.asset(
//                                     bidang["icon"]!,
//                                     height: 24,
//                                     width: 24,
//                                     fit: BoxFit.contain,
//                                   ),
//                                 ),
//                               Flexible(
//                                 child: Text(
//                                   bidang["name"] ?? "",
//                                   style: theme.textTheme.bodyLarge!.copyWith(
//                                     color: buttonTextColor,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
