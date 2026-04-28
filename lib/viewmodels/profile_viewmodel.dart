import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String name = "";
  String email = "";
  String imageUrl = "";
  bool isLoading = false;

  Future<void> fetchProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.getProfile();

      if (data['status'] == "success") {
        name = data['data']['name'] ?? "No Name";
        email = data['data']['email'] ?? "No Email";
        imageUrl = data['data']['profile_picture'] ?? "";
      }
    } catch (e) {
      name = "Error";
      email = "Failed to load";
    }

    isLoading = false;
    notifyListeners();
  }
}
