import 'dart:convert';

List<FinalSubmitValidatorResponse> finalSubmitValidatorResponseFromJson(
        String str) =>
    List<FinalSubmitValidatorResponse>.from(
      json.decode(str).map((x) => FinalSubmitValidatorResponse.fromJson(x)),
    );

class FinalSubmitValidatorResponse {
  String status;
  String message;

  FinalSubmitValidatorResponse({
    required this.status,
    required this.message,
  });

  factory FinalSubmitValidatorResponse.fromJson(Map<String, dynamic> json) =>
      FinalSubmitValidatorResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
