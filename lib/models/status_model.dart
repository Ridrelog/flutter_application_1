class StatusModel {
  final String status;
  final String message;
  final MaintenanceData data;

  StatusModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: MaintenanceData.fromJson(json['data'] ?? {}),
    );
  }
}

class MaintenanceData {
  final String title;
  final String image;
  final String description;

  MaintenanceData({
    required this.title,
    required this.image,
    required this.description,
  });

  factory MaintenanceData.fromJson(Map<String, dynamic> json) {
    return MaintenanceData(
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
    );
  }
}