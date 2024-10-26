import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get geminiApiKey {
    // Try to get from .env file
    try {
      return dotenv.get('GEMINI_API_KEY', fallback: const String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''));
    } catch (e) {
      return const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    }
  }
}