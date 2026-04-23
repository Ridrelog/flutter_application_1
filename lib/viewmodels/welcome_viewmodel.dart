import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WelcomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String title = "Preparing your experience";
  String statusText = "Loading...";
  bool isFinished = false;

  Future<void> fetchStatus() async {
    try {
      final data = await _apiService.checkStatus();

      // ⚠️ sesuaikan dengan response API
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
