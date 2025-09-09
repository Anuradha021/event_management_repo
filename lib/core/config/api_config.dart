
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001/api/v1';
    } else {
      return 'http://10.0.2.2:3001/api/v1';
    }
  }
}
