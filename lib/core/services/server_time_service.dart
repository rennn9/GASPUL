// lib/core/services/server_time_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart'; // <-- import ApiConfig

class ServerTimeService {
  /// Mengambil waktu server dari backend
  static Future<DateTime?> getServerTime() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/server-time'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DateTime.parse(data['server_time']);
      } else {
        debugPrint('❌ Gagal ambil waktu server: Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Gagal ambil waktu server: $e');
    }

    return null;
  }
}
