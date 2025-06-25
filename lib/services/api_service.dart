import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor_profile.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/hakeems/profile/";

  static Future<bool> submitDoctorProfile(DoctorProfile profile) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Error: ${response.statusCode}, ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
}
