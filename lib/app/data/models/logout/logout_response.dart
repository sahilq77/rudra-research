import 'dart:convert';

List<LogoutResponse> logoutResponseFromJson(String str) =>
    List<LogoutResponse>.from(
        json.decode(str).map((x) => LogoutResponse.fromJson(x)));

String logoutResponseToJson(List<LogoutResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LogoutResponse {
  String status;
  String message;

  LogoutResponse({
    required this.status,
    required this.message,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) => LogoutResponse(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
