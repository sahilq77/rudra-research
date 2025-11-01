// To parse this JSON data, do
//
//     final getMySurveyListResponse = getMySurveyListResponseFromJson(jsonString);

import 'dart:convert';

List<GetMySurveyListResponse> getMySurveyListResponseFromJson(String str) =>
    List<GetMySurveyListResponse>.from(
      json.decode(str).map((x) => GetMySurveyListResponse.fromJson(x)),
    );

String getMySurveyListResponseToJson(List<GetMySurveyListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetMySurveyListResponse {
  String status;
  String message;
  List<MySurveyData> data;

  GetMySurveyListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetMySurveyListResponse.fromJson(Map<String, dynamic> json) =>
      GetMySurveyListResponse(
        status: json["status"],
        message: json["message"],
        data: List<MySurveyData>.from(json["data"].map((x) => MySurveyData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class MySurveyData {
  String surveyId;
  String surveyTitle;
  String teamId;
  String districtName;
  String teamNames;
  String isLive;
  String response;

  MySurveyData({
    required this.surveyId,
    required this.surveyTitle,
    required this.teamId,
    required this.districtName,
    required this.teamNames,
    required this.isLive,
    required this.response,
  });

  factory MySurveyData.fromJson(Map<String, dynamic> json) => MySurveyData(
    surveyId: json["survey_id"] ?? "",
    surveyTitle: json["survey_title"] ?? "",
    teamId: json["team_id"] ?? "",
    districtName: json["district_name"] ?? "",
    teamNames: json["team_names"] ?? "",
    isLive: json["is_live"] ?? "",
    response: json["response"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "survey_id": surveyId,
    "survey_title": surveyTitle,
    "team_id": teamId,
    "district_name": districtName,
    "team_names": teamNames,
    "is_live": isLive,
    "response": response,
  };
}
