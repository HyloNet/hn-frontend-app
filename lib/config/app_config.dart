import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '') ?? 30;

  static int get cacheDurationHours =>
      int.tryParse(dotenv.env['CACHE_DURATION_HOURS'] ?? '') ?? 12;

  static String? get geminiApiKey => dotenv.env['GEMINI_API_KEY'];
}
