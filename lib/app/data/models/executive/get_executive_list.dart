// To parse this JSON data, do
//
//     final getExecutiveListResponse = getExecutiveListResponseFromJson(jsonString);

import 'dart:convert';

List<GetExecutiveListResponse> getExecutiveListResponseFromJson(String str) =>
    List<GetExecutiveListResponse>.from(
        json.decode(str).map((x) => GetExecutiveListResponse.fromJson(x)));

String getExecutiveListResponseToJson(List<GetExecutiveListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetExecutiveListResponse {
  String status;
  String message;
  ExecutiveData data;

  GetExecutiveListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetExecutiveListResponse.fromJson(Map<String, dynamic> json) =>
      GetExecutiveListResponse(
        status: json["status"],
        message: json["message"],
        data: ExecutiveData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class ExecutiveData {
  String surveyId;
  String teamId;
  List<Executive> executives;

  ExecutiveData({
    required this.surveyId,
    required this.teamId,
    required this.executives,
  });

  factory ExecutiveData.fromJson(Map<String, dynamic> json) => ExecutiveData(
        surveyId: json["survey_id"],
        teamId: json["team_id"],
        executives: List<Executive>.from(
            json["executives"].map((x) => Executive.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "survey_id": surveyId,
        "team_id": teamId,
        "executives": List<dynamic>.from(executives.map((x) => x.toJson())),
      };
}

class Executive {
  String userId;
  String firstName;
  String lastName;
  String mobileNo;
  String role;
  String file;

  Executive({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.mobileNo,
    required this.role,
    required this.file,
  });

  factory Executive.fromJson(Map<String, dynamic> json) => Executive(
        userId: json["user_id"] ?? "",
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        mobileNo: json["mobile_no"] ?? "",
        role: json["role"] ?? "",
        file: json["file"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "first_name": firstName,
        "last_name": lastName,
        "mobile_no": mobileNo,
        "role": role,
        "file": file,
      };
}
