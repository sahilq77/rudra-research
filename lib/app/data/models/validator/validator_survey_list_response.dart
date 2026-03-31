import 'dart:convert';

List<ValidatorSurveyListResponse> validatorSurveyListResponseFromJson(
        String str) =>
    List<ValidatorSurveyListResponse>.from(
      json.decode(str).map((x) => ValidatorSurveyListResponse.fromJson(x)),
    );

String validatorSurveyListResponseToJson(
        List<ValidatorSurveyListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ValidatorSurveyListResponse {
  String status;
  String message;
  List<ValidatorSurveyItem> data;

  ValidatorSurveyListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ValidatorSurveyListResponse.fromJson(Map<String, dynamic> json) =>
      ValidatorSurveyListResponse(
        status: json["status"],
        message: json["message"],
        data: List<ValidatorSurveyItem>.from(
          json["data"].map((x) => ValidatorSurveyItem.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ValidatorSurveyItem {
  SurveyInfo surveyInfo;
  TeamInfo teamInfo;

  ValidatorSurveyItem({
    required this.surveyInfo,
    required this.teamInfo,
  });

  factory ValidatorSurveyItem.fromJson(Map<String, dynamic> json) =>
      ValidatorSurveyItem(
        surveyInfo: SurveyInfo.fromJson(json["survey_info"]),
        teamInfo: TeamInfo.fromJson(json["team_info"]),
      );

  Map<String, dynamic> toJson() => {
        "survey_info": surveyInfo.toJson(),
        "team_info": teamInfo.toJson(),
      };
}

class SurveyInfo {
  String surveyId;
  String surveyTitle;
  String surveyDateRange;
  int surveyCount;
  String surveyDate;

  SurveyInfo({
    required this.surveyId,
    required this.surveyTitle,
    required this.surveyDateRange,
    required this.surveyCount,
    required this.surveyDate,
  });

  factory SurveyInfo.fromJson(Map<String, dynamic> json) => SurveyInfo(
        surveyId: json["survey_id"] ?? "",
        surveyTitle: json["survey_title"] ?? "",
        surveyDateRange: json["survey_date_range"] ?? "",
        surveyCount: json["survey_count"] ?? 0,
        surveyDate: json["survey_date"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "survey_id": surveyId,
        "survey_title": surveyTitle,
        "survey_date_range": surveyDateRange,
        "survey_count": surveyCount,
        "survey_date": surveyDate,
      };
}

class TeamInfo {
  String teamName;
  String target;
  String managerName;

  TeamInfo({
    required this.teamName,
    required this.target,
    required this.managerName,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) => TeamInfo(
        teamName: json["team_name"] ?? "",
        target: json["target"] ?? "",
        managerName: json["manager_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "team_name": teamName,
        "target": target,
        "manager_name": managerName,
      };
}
