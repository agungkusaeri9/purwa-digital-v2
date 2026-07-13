import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppEnvironment {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
}
