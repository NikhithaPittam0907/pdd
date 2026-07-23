import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5000";
    }

    return "http://10.142.96.30:5000";
  }
}