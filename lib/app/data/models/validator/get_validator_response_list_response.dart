import 'dart:convert';

List<GetValidatorResponseListResponse> getValidatorResponseListResponseFromJson(
  String str,
) =>
    List<GetValidatorResponseListResponse>.from(
      json.decode(str).map((x) => GetValidatorResponseListResponse.fromJson(x)),
    );

String getValidatorResponseListResponseToJson(
  List<GetValidatorResponseListResponse> data,
) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetValidatorResponseListResponse {
  String status;
  String message;
  ValidatorResponseData data;

  GetValidatorResponseListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetValidatorResponseListResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      GetValidatorResponseListResponse(
        status: json["status"],
        message: json["message"],
        data: ValidatorResponseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class ValidatorResponseData {
  SurveyInfoDetail surveyInfo;
  dynamic surveySubmittedBy;
  List<ResponseGroup> responseLists;

  ValidatorResponseData({
    required this.surveyInfo,
    required this.surveySubmittedBy,
    required this.responseLists,
  });

  factory ValidatorResponseData.fromJson(Map<String, dynamic> json) {
    return ValidatorResponseData(
      surveyInfo: SurveyInfoDetail.fromJson(json["survey_info"]),
      surveySubmittedBy: json["survey_submitted_by"] is String
          ? null
          : json["survey_submitted_by"] != null
              ? SurveySubmittedBy.fromJson(json["survey_submitted_by"])
              : null,
      responseLists: json["response_lists"] != null
          ? List<ResponseGroup>.from(
              json["response_lists"].map((x) => ResponseGroup.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "survey_info": surveyInfo.toJson(),
        "survey_submitted_by": surveySubmittedBy is SurveySubmittedBy
            ? (surveySubmittedBy as SurveySubmittedBy).toJson()
            : "",
        "response_lists":
            List<dynamic>.from(responseLists.map((x) => x.toJson())),
      };
}

class ResponseGroup {
  String responseId;
  String surveyId;
  String surveyTitle;
  String respondentName;
  String mobileNo;
  String email;
  String teamName;
  List<ResponseItem> responseList;

  ResponseGroup({
    required this.responseId,
    required this.surveyId,
    required this.surveyTitle,
    required this.respondentName,
    required this.mobileNo,
    required this.email,
    required this.teamName,
    required this.responseList,
  });

  factory ResponseGroup.fromJson(Map<String, dynamic> json) => ResponseGroup(
        responseId: json["response_id"] ?? "",
        surveyId: json["survey_id"] ?? "",
        surveyTitle: json["survey_title"] ?? "",
        respondentName: json["respondent_name"] ?? "",
        mobileNo: json["mobile_no"] ?? "",
        email: json["email"] ?? "",
        teamName: json["team_name"] ?? "",
        responseList: json["response_list"] != null
            ? List<ResponseItem>.from(
                json["response_list"].map((x) => ResponseItem.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "response_id": responseId,
        "survey_id": surveyId,
        "survey_title": surveyTitle,
        "respondent_name": respondentName,
        "mobile_no": mobileNo,
        "email": email,
        "team_name": teamName,
        "response_list":
            List<dynamic>.from(responseList.map((x) => x.toJson())),
      };
}

class SurveyInfoDetail {
  String surveyId;
  String surveyTitle;
  String startDate;
  String endDate;
  String totalResponses;

  SurveyInfoDetail({
    required this.surveyId,
    required this.surveyTitle,
    required this.startDate,
    required this.endDate,
    required this.totalResponses,
  });

  factory SurveyInfoDetail.fromJson(Map<String, dynamic> json) =>
      SurveyInfoDetail(
        surveyId: json["survey_id"] ?? "",
        surveyTitle: json["survey_title"] ?? "",
        startDate: json["start_date"] ?? "",
        endDate: json["end_date"] ?? "",
        totalResponses: json["total_responses"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "survey_id": surveyId,
        "survey_title": surveyTitle,
        "start_date": startDate,
        "end_date": endDate,
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

class ResponseItem {
  String peopleDetailsId;
  String surveyAppSideId;
  String name;
  String mobNumber;
  String submittedAt;

  ResponseItem({
    required this.peopleDetailsId,
    required this.surveyAppSideId,
    required this.name,
    required this.mobNumber,
    required this.submittedAt,
  });

  factory ResponseItem.fromJson(Map<String, dynamic> json) => ResponseItem(
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
