import 'package:flutter/material.dart';
import '../models/status_model.dart';
import '../services/api_service.dart';

class UnderMaintenanceViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;

  String status = "loading";
  String title = "Maintenance Info";
  String description = "We are working to make everything better.";
  String message = "Please check your connection and try again.";
  String image = "maintenance.png";

  Future<void> fetchMaintenanceStatus() async {
    isLoading = true;
    isError = false;
    notifyListeners();

    try {
      final StatusModel result = await ApiService.getMaintenanceStatus();

      status = result.status;
      title = result.data.title;
      description = result.data.description;
      message = result.message;
      image = result.data.image.isNotEmpty
          ? result.data.image
          : "maintenance.png";

      isError = false;
    } catch (e) {
      isError = true;

      status = "Connection Lost";
      title = "Error";
      description = "Please check your connection and try again.";
      message = "Tidak ada koneksi internet.";
      image = "maintenance.png";
    }

    isLoading = false;
    notifyListeners();
  }

  void retry() {
    fetchMaintenanceStatus();
  }
}
