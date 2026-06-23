class ApiHealth {
  final String status;

  ApiHealth({required this.status});

  factory ApiHealth.fromJson(Map<String, dynamic> json) =>
      ApiHealth(status: json['status'] ?? 'unknown');
}

class GeminiTestResponse {
  final String status;
  final String? message;

  GeminiTestResponse({required this.status, this.message});

  factory GeminiTestResponse.fromJson(Map<String, dynamic> json) =>
      GeminiTestResponse(
        status: json['status'] ?? 'error',
        message: json['message'],
      );
}
