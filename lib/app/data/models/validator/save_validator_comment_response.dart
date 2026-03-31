import 'dart:convert';

List<SaveValidatorCommentResponse> saveValidatorCommentResponseFromJson(
        String str) =>
    List<SaveValidatorCommentResponse>.from(
      json.decode(str).map((x) => SaveValidatorCommentResponse.fromJson(x)),
    );

class SaveValidatorCommentResponse {
  String status;
  String message;

  SaveValidatorCommentResponse({
    required this.status,
    required this.message,
  });

  factory SaveValidatorCommentResponse.fromJson(Map<String, dynamic> json) =>
      SaveValidatorCommentResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
