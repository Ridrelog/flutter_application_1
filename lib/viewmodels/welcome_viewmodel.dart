import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class WelcomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String title = "Preparing your experience";
  String statusText = "Loading...";
  bool isFinished = false;

  String apiTitle = "";
  String apiMessage = "";

  Future<void> fetchTitle() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.ppb.widiarrohman.my.id/api/2026/uts/B/kelompok2/check',
        ),
      );

      if (response.statusCode == 200) {
        final body = response.body;

        try {
          final jsonData = jsonDecode(body);

          apiTitle = jsonData['data']?['title'] ?? "";
          apiMessage = jsonData['message'] ?? "";
        } catch (e) {
          apiTitle = body;
          apiMessage = "";
        }
      }
    } catch (e) {
      debugPrint("ERROR API CHECK: $e");
    }

    notifyListeners();
  }

  Future<void> fetchStatus() async {
    try {
      final data = await _apiService.checkStatus();

      if (data['success'] == true) {
        title = data['message'] ?? "Ready";
        statusText = "Ready to go 🚀";
        isFinished = true;
      } else {
        title = data['message'] ?? "Still processing";
        statusText = "Loading...";
      }
    } catch (e) {
      title = "Server error";
      statusText = "Try again later";
    }

    notifyListeners();
  }
}
