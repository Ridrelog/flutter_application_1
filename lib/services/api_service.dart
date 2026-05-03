import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/status_model.dart';

class ApiService {
  Future<Map<String, dynamic>> checkStatus() async {
    final response = await http.get(
      Uri.parse(
        'https://api.ppb.widiarrohman.my.id/api/2026/uts/B/kelompok2/check',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load API');
    }
  }

  static Future<StatusModel> getMaintenanceStatus() async {
    final response = await http.get(
      Uri.parse(
        'https://api.ppb.widiarrohman.my.id/api/2026/uts/B/kelompok2/under-maintenance',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return StatusModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load maintenance status');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse(
        'https://api.ppb.widiarrohman.my.id/api/2026/uts/B/kelompok2/user/profile',
      ),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
