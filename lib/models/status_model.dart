class StatusModel {
  final bool success;
  final String message;

  StatusModel({required this.success, required this.message});

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
