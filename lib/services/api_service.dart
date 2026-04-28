import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse(
        'https://api.ppb.widiarrohman.my.id/api/2026/uts/B/kelompok2/user/profile',
      ),
      headers: {
        "Content-Type": "application/json",
        // kalau butuh token tambahin di sini
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
