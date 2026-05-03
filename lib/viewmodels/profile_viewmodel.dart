import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String name = "";
  String email = "";
  String imageUrl = "";
  String status = "";
  String message = "";
  bool isLoading = false;
  bool hasError = false;

  Future<void> fetchProfile() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final data = await _apiService.getProfile();

      status = data['status'] ?? "";
      message = data['message'] ?? "";

      if (status == "success") {
        name = data['data']['name'] ?? "No Name";
        email = data['data']['email'] ?? "No Email";
        imageUrl = data['data']['profile_picture'] ?? "";
      } else {
        hasError = true;
      }
    } catch (e) {
      hasError = true;
      status = "Gagal Mengambil Data";
      message = "Gagal Terhubung ke Server";
      name = "                    ";
      email = "                     ";
      imageUrl = "";
    }

    isLoading = false;
    notifyListeners();
  }
}
