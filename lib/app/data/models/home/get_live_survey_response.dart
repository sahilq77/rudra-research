// To parse this JSON data, do
//
//     final getLiveSurveyListResponse = getLiveSurveyListResponseFromJson(jsonString);

import 'dart:convert';

List<GetLiveSurveyListResponse> getLiveSurveyListResponseFromJson(String str) =>
    List<GetLiveSurveyListResponse>.from(
      json.decode(str).map((x) => GetLiveSurveyListResponse.fromJson(x)),
    );

String getLiveSurveyListResponseToJson(List<GetLiveSurveyListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLiveSurveyListResponse {
  String status;
  String message;
  List<LiveSurveyData> data;

  GetLiveSurveyListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetLiveSurveyListResponse.fromJson(Map<String, dynamic> json) =>
      GetLiveSurveyListResponse(
        status: json["status"],
        message: json["message"],
        data: List<LiveSurveyData>.from(json["data"].map((x) => LiveSurveyData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class LiveSurveyData {
  String surveyId;
  String surveyTitle;

  LiveSurveyData({required this.surveyId, required this.surveyTitle});

  factory LiveSurveyData.fromJson(Map<String, dynamic> json) => LiveSurveyData(
    surveyId: json["survey_id"] ?? "",
    surveyTitle: json["survey_title"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "survey_id": surveyId,
    "survey_title": surveyTitle,
  };
}
