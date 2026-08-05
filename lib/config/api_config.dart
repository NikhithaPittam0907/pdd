import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '846632914864-829ti69uvgqmqt8dav7ij1jmd5vevpem.apps.googleusercontent.com',
  );

  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5000";
    }

    // Use machine's local IP address for physical Android devices over Wi-Fi
    return "http://10.17.207.30:5000";
  }
}
