// lib/constants/api_constants.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    // Use .env if loaded, otherwise fallback to hardcoded URL
    final envUrl = dotenv.isInitialized ? dotenv.env['API_BASE_URL'] : null;
    return envUrl ?? 'http://192.168.1.41:8000'; // <-- Replace with your actual API URL
  }
  // Endpoint path – adjust to match backend
  static const String registerDoctor = "/v1/doctors";
  static const String sendOtp = "/api/patient/send-otp/";
  static const String verifyOtp = "/api/patient/verify-otp/";
  static const String doctorProfile = "/api/hakeems/profile/";
}
