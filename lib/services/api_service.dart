import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/status_model.dart';

class ApiService {

  // 🔹 API LAMA (RAW - tetap ada)
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

  // 🔹 API BARU (pakai model - untuk UI maintenance)
  static Future<StatusModel> getMaintenanceStatus() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.ppb.widiarrohman.my.id/api/2026/uts/B/kelompok2/check',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return StatusModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load API');
      }
    } catch (e) {
      return StatusModel(
        status: "error",
        message: "Tidak bisa terhubung ke server",
        data: MaintenanceData(
          title: "Error",
          image: "",
          description: "Cek koneksi internet",
        ),
      );
    }
  }

  // 🔹 PROFILE (tidak diubah)
  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse(
        'https://api.ppb.widiarrohman.my.id/api/2026/uts/B/kelompok2/user/profile',
      ),
      headers: {
        "Content-Type": "application/json",
        // "Authorization": "Bearer TOKEN"
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }
}