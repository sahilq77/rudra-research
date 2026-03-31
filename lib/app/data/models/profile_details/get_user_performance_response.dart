import 'dart:convert';

class GetUserPerformanceResponse {
  String status;
  String message;
  UserPerformanceData data;

  GetUserPerformanceResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetUserPerformanceResponse.fromJson(Map<String, dynamic> json) {
    return GetUserPerformanceResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: UserPerformanceData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class UserPerformanceData {
  String userId;
  String surveyId;
  String assignedSurveyTarget;
  String completedSurveyTarget;
  List<PeriodData> periodData;

  UserPerformanceData({
    required this.userId,
    required this.surveyId,
    required this.assignedSurveyTarget,
    required this.completedSurveyTarget,
    required this.periodData,
  });

  factory UserPerformanceData.fromJson(Map<String, dynamic> json) {
    return UserPerformanceData(
      userId: json['user_id']?.toString() ?? '',
      surveyId: json['survey_id']?.toString() ?? '',
      assignedSurveyTarget: json['assigned_survey_target']?.toString() ?? '0',
      completedSurveyTarget: json['completed_survey_target']?.toString() ?? '0',
      periodData: (json['period_data'] as List<dynamic>?)
              ?.map((e) => PeriodData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'survey_id': surveyId,
      'assigned_survey_target': assignedSurveyTarget,
      'completed_survey_target': completedSurveyTarget,
      'period_data': periodData.map((e) => e.toJson()).toList(),
    };
  }
}

class PeriodData {
  String label;
  String assigned;
  String completed;

  PeriodData({
    required this.label,
    required this.assigned,
    required this.completed,
  });

  factory PeriodData.fromJson(Map<String, dynamic> json) {
    return PeriodData(
      label: json['label']?.toString() ?? '',
      assigned: json['assigned']?.toString() ?? '0',
      completed: json['completed']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'assigned': assigned,
      'completed': completed,
    };
  }
}

List<GetUserPerformanceResponse> getUserPerformanceResponseFromJson(String str) {
  final jsonData = json.decode(str) as List;
  return jsonData.map((item) => GetUserPerformanceResponse.fromJson(item)).toList();
}

String getUserPerformanceResponseToJson(List<GetUserPerformanceResponse> data) {
  final dyn = data.map((item) => item.toJson()).toList();
  return json.encode(dyn);
}
