import 'dart:convert';

List<DeviceInfoResponse> deviceInfoResponseFromJson(String str) =>
    List<DeviceInfoResponse>.from(
      json.decode(str).map((x) => DeviceInfoResponse.fromJson(x)),
    );

String deviceInfoResponseToJson(List<DeviceInfoResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeviceInfoResponse {
  String status;
  String message;

  DeviceInfoResponse({
    required this.status,
    required this.message,
  });

  factory DeviceInfoResponse.fromJson(Map<String, dynamic> json) =>
      DeviceInfoResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
