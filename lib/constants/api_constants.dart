// lib/constants/api_constants.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String baseUrl = dotenv.env['API_BASE_URL']!;
  // Endpoint path – adjust to match backend
  static const String registerDoctor = "/v1/doctors";
  static const String sendOtp = "patient/send-otp/";
  static const String verifyOtp = "patient/verify-otp/";
  static const String doctorProfile = "hakeems/profile/";
}
