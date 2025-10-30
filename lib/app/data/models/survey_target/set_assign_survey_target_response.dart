// To parse this JSON data, do
//
//     final seAssignSurveyTargetResponse = seAssignSurveyTargetResponseFromJson(jsonString);

import 'dart:convert';

List<SeAssignSurveyTargetResponse> seAssignSurveyTargetResponseFromJson(
  String str,
) => List<SeAssignSurveyTargetResponse>.from(
  json.decode(str).map((x) => SeAssignSurveyTargetResponse.fromJson(x)),
);

String seAssignSurveyTargetResponseToJson(
  List<SeAssignSurveyTargetResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SeAssignSurveyTargetResponse {
  String status;
  String message;
  Data data;

  SeAssignSurveyTargetResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SeAssignSurveyTargetResponse.fromJson(Map<String, dynamic> json) =>
      SeAssignSurveyTargetResponse(
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
  String surveyId;
  String teamId;
  String assignedBy;

  Data({
    required this.surveyId,
    required this.teamId,
    required this.assignedBy,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    surveyId: json["survey_id"] ?? "",
    teamId: json["team_id"] ?? "",
    assignedBy: json["assigned_by"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "survey_id": surveyId,
    "team_id": teamId,
    "assigned_by": assignedBy,
  };
}
