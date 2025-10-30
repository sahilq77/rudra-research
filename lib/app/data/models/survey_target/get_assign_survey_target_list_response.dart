// To parse this JSON data, do
//
//     final getAssignSurveyTargetListResponse = getAssignSurveyTargetListResponseFromJson(jsonString);

import 'dart:convert';

List<GetAssignSurveyTargetListResponse>
getAssignSurveyTargetListResponseFromJson(String str) =>
    List<GetAssignSurveyTargetListResponse>.from(
      json
          .decode(str)
          .map((x) => GetAssignSurveyTargetListResponse.fromJson(x)),
    );

String getAssignSurveyTargetListResponseToJson(
  List<GetAssignSurveyTargetListResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAssignSurveyTargetListResponse {
  String status;
  String message;
  AssignSurveyData data;

  GetAssignSurveyTargetListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAssignSurveyTargetListResponse.fromJson(
    Map<String, dynamic> json,
  ) => GetAssignSurveyTargetListResponse(
    status: json["status"],
    message: json["message"],
    data: AssignSurveyData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class AssignSurveyData {
  String surveyId;
  String surveyTitle;
  String totalSurveys;
  String completedSurveys;
  List<User> users;

  AssignSurveyData({
    required this.surveyId,
    required this.surveyTitle,
    required this.totalSurveys,
    required this.completedSurveys,
    required this.users,
  });

  factory AssignSurveyData.fromJson(Map<String, dynamic> json) =>
      AssignSurveyData(
        surveyId: json["survey_id"] ?? "",
        surveyTitle: json["survey_title"] ?? "",
        totalSurveys: json["total_surveys"] ?? "",
        completedSurveys: json["completed_surveys"] ?? "",
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "survey_id": surveyId,
    "survey_title": surveyTitle,
    "total_surveys": totalSurveys,
    "completed_surveys": completedSurveys,
    "users": List<dynamic>.from(users.map((x) => x.toJson())),
  };
}

class User {
  String userId;
  String firstName;
  String lastName;
  String mobileNo;
  String roleId;
  String role;
  String totalCompletedTarget;
  String todayCompletedTarget;
  String assignSurveyTarget;
  String teamId;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.mobileNo,
    required this.roleId,
    required this.role,
    required this.totalCompletedTarget,
    required this.todayCompletedTarget,
    required this.assignSurveyTarget,
    required this.teamId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json["user_id"] ?? "",
    firstName: json["first_name"] ?? "",
    lastName: json["last_name"] ?? "",
    mobileNo: json["mobile_no"] ?? "",
    roleId: json["role_id"] ?? "",
    role: json["role"] ?? "",
    totalCompletedTarget: json["total_completed_target"] ?? "",
    todayCompletedTarget: json["today_completed_target"] ?? "",
    assignSurveyTarget: json["assign_survey_target"] ?? "",
    teamId: json["team_id"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "first_name": firstName,
    "last_name": lastName,
    "mobile_no": mobileNo,
    "role_id": roleId,
    "role": role,
    "total_completed_target": totalCompletedTarget,
    "today_completed_target": todayCompletedTarget,
    "assign_survey_target": assignSurveyTarget,
    "team_id": teamId,
  };
}
