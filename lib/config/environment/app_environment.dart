import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppEnvironment {
  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'] ?? 'https://api.purwa-digital.purwatechsolutions.com';
    return url.trim().replaceAll(RegExp(r'/$'), '');
  }
}
