import 'package:flutter/material.dart';

class StatistikTableCard extends StatelessWidget {
  final List<dynamic> data;
  final String? lastUpdated;
  final Widget Function(int value) animatedNumber;

  const StatistikTableCard({
    super.key,
    required this.data,
    required this.animatedNumber,
    this.lastUpdated,
  });

  int parseNumber(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Tabel Layanan
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'Tabel Layanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),

        // Tabel dengan scroll horizontal
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 32,
            ),
            child: DataTable(
              columnSpacing: 12,
              headingRowHeight: 32,
              dataRowHeight: 32,
              columns: const [
                DataColumn(
                  label: Text(
                    'Bidang Pelayanan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Selesai',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Batal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: data.map((item) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        item['bidang_layanan'] ?? '-',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(animatedNumber(parseNumber(item['total']))),
                    DataCell(animatedNumber(parseNumber(item['selesai']))),
                    DataCell(animatedNumber(parseNumber(item['batal']))),
                  ],
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Last updated info
        if (lastUpdated != null)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Last updated: $lastUpdated',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

}
