import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    try {
      return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';
    } catch (e) {
      return 'http://10.0.2.2:8000';
    }
  }

  static int get apiTimeout {
    try {
      return int.tryParse(dotenv.env['API_TIMEOUT'] ?? '') ?? 30;
    } catch (e) {
      return 30;
    }
  }

  static int get cacheDurationHours {
    try {
      return int.tryParse(dotenv.env['CACHE_DURATION_HOURS'] ?? '') ?? 12;
    } catch (e) {
      return 12;
    }
  }

  static String? get geminiApiKey {
    try {
      return dotenv.env['GEMINI_API_KEY'];
    } catch (e) {
      return null;
    }
  }
}
