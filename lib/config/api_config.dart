import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5000";
    } else {
      // Android emulator
      return "http://192.168.1.6:5000";
    }
  }
}// TODO Implement this library.