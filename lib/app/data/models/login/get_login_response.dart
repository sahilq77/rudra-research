// To parse this JSON data, do
//
//     final getLoginResponse = getLoginResponseFromJson(jsonString);

import 'dart:convert';

List<GetLoginResponse> getLoginResponseFromJson(String str) =>
    List<GetLoginResponse>.from(
      json.decode(str).map((x) => GetLoginResponse.fromJson(x)),
    );

String getLoginResponseToJson(List<GetLoginResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLoginResponse {
  String status;
  String message;
  Data data;

  GetLoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetLoginResponse.fromJson(Map<String, dynamic> json) =>
      GetLoginResponse(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  String userId;
  String firstName;
  String lastName;
  String email;
  String mobileNo;
  String roleId;
  String role;
  String roleValue;
  String status;
  String deviceToken;
  String teamId;

  Data({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNo,
    required this.roleId,
    required this.role,
    required this.roleValue,
    required this.status,
    required this.deviceToken,
    required this.teamId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["user_id"] ?? "",
    firstName: json["first_name"] ?? "",
    lastName: json["last_name"] ?? "",
    email: json["email"] ?? "",
    mobileNo: json["mobile_no"] ?? "",
    roleId: json["role_id"] ?? "",
    role: json["role"] ?? "",
    roleValue: json["role_value"] ?? "",
    status: json["status"] ?? "",
    deviceToken: json["device_token"] ?? "",
    teamId: json["team_id"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "mobile_no": mobileNo,
    "role_id": roleId,
    "role": role,
    "role_value": roleValue,
    "status": status,
    "device_token": deviceToken,
    "team_id": teamId,
  };
}
