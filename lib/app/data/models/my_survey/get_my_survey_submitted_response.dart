// To parse this JSON data, do
//
//     final getMySurveySubmittedResponse = getMySurveySubmittedResponseFromJson(jsonString);

import 'dart:convert';

List<GetMySurveySubmittedResponse> getMySurveySubmittedResponseFromJson(
  String str,
) =>
    List<GetMySurveySubmittedResponse>.from(
      json.decode(str).map((x) => GetMySurveySubmittedResponse.fromJson(x)),
    );

String getMySurveySubmittedResponseToJson(
  List<GetMySurveySubmittedResponse> data,
) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetMySurveySubmittedResponse {
  String status;
  String message;
  ResponseData data;

  GetMySurveySubmittedResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetMySurveySubmittedResponse.fromJson(Map<String, dynamic> json) =>
      GetMySurveySubmittedResponse(
        status: json["status"],
        message: json["message"],
        data: ResponseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class ResponseData {
  SurveyInfo surveyInfo;
  SurveySubmittedBy surveySubmittedBy;
  List<ResponseList> responseLists;

  ResponseData({
    required this.surveyInfo,
    required this.surveySubmittedBy,
    required this.responseLists,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
        surveyInfo: SurveyInfo.fromJson(json["survey_info"]),
        surveySubmittedBy:
            SurveySubmittedBy.fromJson(json["survey_submitted_by"]),
        responseLists: List<ResponseList>.from(
          json["response_lists"].map((x) => ResponseList.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "survey_info": surveyInfo.toJson(),
        "survey_submitted_by": surveySubmittedBy.toJson(),
        "response_lists":
            List<dynamic>.from(responseLists.map((x) => x.toJson())),
      };
}

class ResponseList {
  String peopleDetailsId;
  String surveyAppSideId;
  String name;
  String mobNumber;
  String submittedAt;

  ResponseList({
    required this.peopleDetailsId,
    required this.surveyAppSideId,
    required this.name,
    required this.mobNumber,
    required this.submittedAt,
  });

  factory ResponseList.fromJson(Map<String, dynamic> json) => ResponseList(
        peopleDetailsId: json["people_details_id"] ?? "",
        surveyAppSideId: json["survey_app_side_id"] ?? "",
        name: json["name"] ?? "",
        mobNumber: json["mob_number"] ?? "",
        submittedAt: json["submitted_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "people_details_id": peopleDetailsId,
        "survey_app_side_id": surveyAppSideId,
        "name": name,
        "mob_number": mobNumber,
        "submitted_at": submittedAt,
      };
}

class SurveyInfo {
  String surveyId;
  String surveyTitle;
  DateTime startDate;
  DateTime endDate;
  String totalResponses;

  SurveyInfo({
    required this.surveyId,
    required this.surveyTitle,
    required this.startDate,
    required this.endDate,
    required this.totalResponses,
  });

  factory SurveyInfo.fromJson(Map<String, dynamic> json) => SurveyInfo(
        surveyId: json["survey_id"],
        surveyTitle: json["survey_title"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        totalResponses: json["total_responses"],
      );

  Map<String, dynamic> toJson() => {
        "survey_id": surveyId,
        "survey_title": surveyTitle,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "total_responses": totalResponses,
      };
}

class SurveySubmittedBy {
  String userId;
  String name;
  String mobileNo;
  String teamName;

  SurveySubmittedBy({
    required this.userId,
    required this.name,
    required this.mobileNo,
    required this.teamName,
  });

  factory SurveySubmittedBy.fromJson(Map<String, dynamic> json) =>
      SurveySubmittedBy(
        userId: json["user_id"],
        name: json["name"],
        mobileNo: json["mobile_no"],
        teamName: json["team_name"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "mobile_no": mobileNo,
        "team_name": teamName,
      };
}
