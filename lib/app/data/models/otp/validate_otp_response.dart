import 'dart:convert';

List<ValidateOtpResponse> validateOtpResponseFromJson(String str) =>
    List<ValidateOtpResponse>.from(
      json.decode(str).map((x) => ValidateOtpResponse.fromJson(x)),
    );

String validateOtpResponseToJson(List<ValidateOtpResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ValidateOtpResponse {
  String status;
  String message;
  ValidateOtpData data;

  ValidateOtpResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ValidateOtpResponse.fromJson(Map<String, dynamic> json) =>
      ValidateOtpResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: ValidateOtpData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class ValidateOtpData {
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
  String image;

  ValidateOtpData({
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
    required this.image,
  });

  factory ValidateOtpData.fromJson(Map<String, dynamic> json) =>
      ValidateOtpData(
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
        image: json["image"] ?? "",
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
        "image": image,
      };
}
