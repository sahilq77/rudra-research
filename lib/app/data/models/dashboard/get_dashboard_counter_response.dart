import 'dart:convert';

List<GetDashboardCounterResponse> getDashboardCounterResponseFromJson(String str) =>
    List<GetDashboardCounterResponse>.from(
      json.decode(str).map((x) => GetDashboardCounterResponse.fromJson(x)),
    );

String getDashboardCounterResponseToJson(List<GetDashboardCounterResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDashboardCounterResponse {
  String status;
  String message;
  DashboardCounterData data;

  GetDashboardCounterResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetDashboardCounterResponse.fromJson(Map<String, dynamic> json) =>
      GetDashboardCounterResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: DashboardCounterData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class DashboardCounterData {
  String target;
  String dailyAssignTarget;
  String targetCompleted;
  String inProgress;
  String notStartedSurveys;

  DashboardCounterData({
    required this.target,
    required this.dailyAssignTarget,
    required this.targetCompleted,
    required this.inProgress,
    required this.notStartedSurveys,
  });

  factory DashboardCounterData.fromJson(Map<String, dynamic> json) =>
      DashboardCounterData(
        target: json["target"] ?? "0",
        dailyAssignTarget: json["daily_assign_target"] ?? "0",
        targetCompleted: json["target_completed"] ?? "0",
        inProgress: json["in_progress"] ?? "0",
        notStartedSurveys: json["not_started_surveys"] ?? "0",
      );

  Map<String, dynamic> toJson() => {
        "target": target,
        "daily_assign_target": dailyAssignTarget,
        "target_completed": targetCompleted,
        "in_progress": inProgress,
        "not_started_surveys": notStartedSurveys,
      };
}
