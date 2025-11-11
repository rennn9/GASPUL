import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gaspul/core/services/api_config.dart';

class SurveyService {
  static Future<List<Map<String, dynamic>>> fetchAntrianSelesaiHariIni() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/antrian/selesai-hari-ini');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> submitSurvey(Map<String, dynamic> surveyData) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/survey');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(surveyData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message'] ?? 'Survey berhasil disimpan'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Gagal menyimpan survey'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi ke server: $e'};
    }
  }

  static Future<String> fetchServerTime() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/server-time');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['time']; // misal: "2025-11-11 08:20:00"
      } else {
        return DateTime.now().toString();
      }
    } catch (e) {
      return DateTime.now().toString();
    }
  }
}
