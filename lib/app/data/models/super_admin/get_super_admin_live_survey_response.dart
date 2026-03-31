import 'dart:convert';

List<GetSuperAdminLiveSurveyListResponse>
    getSuperAdminLiveSurveyListResponseFromJson(String str) =>
        List<GetSuperAdminLiveSurveyListResponse>.from(
          json.decode(str).map(
                (x) => GetSuperAdminLiveSurveyListResponse.fromJson(x),
              ),
        );

String getSuperAdminLiveSurveyListResponseToJson(
  List<GetSuperAdminLiveSurveyListResponse> data,
) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSuperAdminLiveSurveyListResponse {
  String status;
  String message;
  List<SuperAdminLiveSurveyData> data;

  GetSuperAdminLiveSurveyListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetSuperAdminLiveSurveyListResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      GetSuperAdminLiveSurveyListResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: (json["data"] as List<dynamic>?)
                ?.map((x) => SuperAdminLiveSurveyData.fromJson(x))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class SuperAdminLiveSurveyData {
  String surveyId;
  String surveyTitle;
  String teamId;
  String districtName;
  String teamNames;
  String isLive;
  String response;

  SuperAdminLiveSurveyData({
    required this.surveyId,
    required this.surveyTitle,
    required this.teamId,
    required this.districtName,
    required this.teamNames,
    required this.isLive,
    required this.response,
  });

  factory SuperAdminLiveSurveyData.fromJson(Map<String, dynamic> json) =>
      SuperAdminLiveSurveyData(
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
