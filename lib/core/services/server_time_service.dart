import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServerTimeService {
  static const String baseUrl = 'http://192.168.1.21:8000/api';

  /// Mengambil waktu server dari backend
  static Future<DateTime?> getServerTime() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/server-time'));
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
