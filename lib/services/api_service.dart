import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/doctor_profile.dart';
import '../constants/api_constants.dart';

class ApiService {
  static Future<bool> submitDoctorProfile(DoctorProfile profile) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.doctorProfile),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Error: \\${response.statusCode}, \\${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
}

class AuthService {
  static final _storage = FlutterSecureStorage();

  static Future<bool> sendOtp(String phone) async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.sendOtp);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyOtp);
    print('Sending to backend: {"phone": "$phone", "code": "$code"}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );
    print('Response status: \\${response.statusCode}');
    print('Response body: \\${response.body}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['access'] != null) {
      await _storage.write(key: 'bearer_token', value: data['access']);
      return {'success': true, 'token': data['access'], 'response': data};
    } else {
      String errorMsg = '';
      if (data is Map && data.isNotEmpty) {
        errorMsg = data.values.first is List ? data.values.first.first : data.values.first.toString();
      }
      return {'success': false, 'error': errorMsg, 'response': data};
    }
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'bearer_token');
  }
}
