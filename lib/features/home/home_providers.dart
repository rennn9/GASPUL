import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Menyimpan apakah popup menu aksesibilitas sedang terbuka atau tidak
final accessibilityMenuProvider = StateProvider<bool>((ref) => false);