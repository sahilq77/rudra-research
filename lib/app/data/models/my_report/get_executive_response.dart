import 'dart:convert';

List<GetExecutiveResponse> getExecutiveResponseFromJson(String str) =>
    List<GetExecutiveResponse>.from(
        json.decode(str).map((x) => GetExecutiveResponse.fromJson(x)));

String getExecutiveResponseToJson(List<GetExecutiveResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetExecutiveResponse {
  String status;
  String message;
  List<ExecutiveData> data;

  GetExecutiveResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetExecutiveResponse.fromJson(Map<String, dynamic> json) =>
      GetExecutiveResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: List<ExecutiveData>.from(
            json["data"].map((x) => ExecutiveData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ExecutiveData {
  String executiveId;
  String firstName;
  String lastName;
  String mobileNo;
  String email;
  String role;

  ExecutiveData({
    required this.executiveId,
    required this.firstName,
    required this.lastName,
    required this.mobileNo,
    required this.email,
    required this.role,
  });

  factory ExecutiveData.fromJson(Map<String, dynamic> json) => ExecutiveData(
        executiveId: json["executive_id"] ?? "",
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        mobileNo: json["mobile_no"] ?? "",
        email: json["email"] ?? "",
        role: json["role"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "executive_id": executiveId,
        "first_name": firstName,
        "last_name": lastName,
        "mobile_no": mobileNo,
        "email": email,
        "role": role,
      };
}
