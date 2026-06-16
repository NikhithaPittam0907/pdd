import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5000";
    }
    // PC LAN IP — run `ipconfig`, use IPv4 of your Wi-Fi adapter.
    // Android emulator: use http://10.0.2.2:5000 instead.
    return "http://10.70.200.30:5000";
  }
}
