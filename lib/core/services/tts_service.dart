import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();

  TTSService._internal() {
    _flutterTts.setLanguage("id-ID"); // ✅ Bahasa Indonesia
    _flutterTts.setSpeechRate(0.4);   // ✅ Kecepatan bicara
    _flutterTts.setPitch(1.0);        // ✅ Pitch suara
  }

  Future<void> speak(String text) async {
    await _flutterTts.stop();  // hentikan dulu biar tidak numpuk
    await _flutterTts.speak(text);
  }
}
