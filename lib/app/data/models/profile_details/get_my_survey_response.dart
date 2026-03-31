import 'dart:convert';

class GetMySurveyResponse {
  String status;
  String message;
  List<SurveyData> data;

  GetMySurveyResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetMySurveyResponse.fromJson(Map<String, dynamic> json) {
    return GetMySurveyResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => SurveyData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class SurveyData {
  String surveyId;
  String surveyTitle;
  String teamId;
  String districtName;
  String teamNames;
  String response;

  SurveyData({
    required this.surveyId,
    required this.surveyTitle,
    required this.teamId,
    required this.districtName,
    required this.teamNames,
    required this.response,
  });

  factory SurveyData.fromJson(Map<String, dynamic> json) {
    return SurveyData(
      surveyId: json['survey_id']?.toString() ?? '',
      surveyTitle: json['survey_title']?.toString() ?? '',
      teamId: json['team_id']?.toString() ?? '',
      districtName: json['district_name']?.toString() ?? '',
      teamNames: json['team_names']?.toString() ?? '',
      response: json['response']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'survey_id': surveyId,
      'survey_title': surveyTitle,
      'team_id': teamId,
      'district_name': districtName,
      'team_names': teamNames,
      'response': response,
    };
  }
}

List<GetMySurveyResponse> getMySurveyResponseFromJson(String str) {
  final jsonData = json.decode(str) as List;
  return jsonData.map((item) => GetMySurveyResponse.fromJson(item)).toList();
}

String getMySurveyResponseToJson(List<GetMySurveyResponse> data) {
  final dyn = data.map((item) => item.toJson()).toList();
  return json.encode(dyn);
}
