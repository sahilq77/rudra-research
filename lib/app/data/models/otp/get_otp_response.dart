import 'dart:convert';

List<GetOtpResponse> getOtpResponseFromJson(String str) =>
    List<GetOtpResponse>.from(
      json.decode(str).map((x) => GetOtpResponse.fromJson(x)),
    );

String getOtpResponseToJson(List<GetOtpResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetOtpResponse {
  String status;
  String message;
  OtpData data;

  GetOtpResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetOtpResponse.fromJson(Map<String, dynamic> json) => GetOtpResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: OtpData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class OtpData {
  String userId;
  String mobileNo;
  String otp;
  String otpExpiry;

  OtpData({
    required this.userId,
    required this.mobileNo,
    required this.otp,
    required this.otpExpiry,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) => OtpData(
        userId: json["user_id"] ?? "",
        mobileNo: json["mobile_no"] ?? "",
        otp: json["otp"] ?? "",
        otpExpiry: json["otp_expiry"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "mobile_no": mobileNo,
        "otp": otp,
        "otp_expiry": otpExpiry,
      };
}
