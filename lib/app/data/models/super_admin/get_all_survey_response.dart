import 'dart:convert';

List<GetAllSurveyResponse> getAllSurveyResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return List<GetAllSurveyResponse>.from(
    jsonData.map((x) => GetAllSurveyResponse.fromJson(x)),
  );
}

class GetAllSurveyResponse {
  String status;
  String message;
  List<AllSurveyData> data;

  GetAllSurveyResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAllSurveyResponse.fromJson(Map<String, dynamic> json) {
    return GetAllSurveyResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => AllSurveyData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AllSurveyData {
  String surveyId;
  String surveyTitle;
  String teamId;
  String districtName;
  String teamNames;
  String isLive;
  String response;

  AllSurveyData({
    required this.surveyId,
    required this.surveyTitle,
    required this.teamId,
    required this.districtName,
    required this.teamNames,
    required this.isLive,
    required this.response,
  });

  factory AllSurveyData.fromJson(Map<String, dynamic> json) {
    return AllSurveyData(
      surveyId: json['survey_id']?.toString() ?? '',
      surveyTitle: json['survey_title'] ?? '',
      teamId: json['team_id']?.toString() ?? '',
      districtName: json['district_name'] ?? '',
      teamNames: json['team_names'] ?? '',
      isLive: json['is_live']?.toString() ?? '0',
      response: json['response']?.toString() ?? '0',
    );
  }
}
