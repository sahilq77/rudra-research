import 'dart:convert';

List<GetValidatorMySurveyDetailResponse>
    getValidatorMySurveyDetailResponseFromJson(String str) =>
        List<GetValidatorMySurveyDetailResponse>.from(
          json
              .decode(str)
              .map((x) => GetValidatorMySurveyDetailResponse.fromJson(x)),
        );

String getValidatorMySurveyDetailResponseToJson(
        List<GetValidatorMySurveyDetailResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetValidatorMySurveyDetailResponse {
  String status;
  String message;
  List<ValidatorSurveyDetailData> data;

  GetValidatorMySurveyDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetValidatorMySurveyDetailResponse.fromJson(
          Map<String, dynamic> json) =>
      GetValidatorMySurveyDetailResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: List<ValidatorSurveyDetailData>.from(
          json["data"].map((x) => ValidatorSurveyDetailData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ValidatorSurveyDetailData {
  SurveyInfo surveyInfo;
  TeamInfo teamInfo;

  ValidatorSurveyDetailData({
    required this.surveyInfo,
    required this.teamInfo,
  });

  factory ValidatorSurveyDetailData.fromJson(Map<String, dynamic> json) =>
      ValidatorSurveyDetailData(
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
