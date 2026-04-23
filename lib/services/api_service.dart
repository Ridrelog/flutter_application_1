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
}
