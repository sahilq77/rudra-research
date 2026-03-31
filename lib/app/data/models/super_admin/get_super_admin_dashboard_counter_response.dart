import 'dart:convert';

List<GetSuperAdminDashboardCounterResponse>
    getSuperAdminDashboardCounterResponseFromJson(String str) =>
        List<GetSuperAdminDashboardCounterResponse>.from(
          json.decode(str).map(
                (x) => GetSuperAdminDashboardCounterResponse.fromJson(x),
              ),
        );

String getSuperAdminDashboardCounterResponseToJson(
  List<GetSuperAdminDashboardCounterResponse> data,
) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSuperAdminDashboardCounterResponse {
  String status;
  String message;
  SuperAdminDashboardCounterData data;

  GetSuperAdminDashboardCounterResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetSuperAdminDashboardCounterResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      GetSuperAdminDashboardCounterResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: SuperAdminDashboardCounterData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class SuperAdminDashboardCounterData {
  String? target;
  String? dailyAssignTarget;
  String? targetCompleted;
  String? inProgress;
  String? notStartedSurveys;
  String? completeSurvey;
  String? incompleteSurvey;
  String? teamCount;
  String? stopedSurvey;
  SuperAdminDashboardCounterData({
    this.target,
    this.dailyAssignTarget,
    this.targetCompleted,
    this.inProgress,
    this.notStartedSurveys,
    this.completeSurvey,
    this.incompleteSurvey,
    this.teamCount,
    this.stopedSurvey,
  });

  factory SuperAdminDashboardCounterData.fromJson(Map<String, dynamic> json) =>
      SuperAdminDashboardCounterData(
        target: json["target"] ?? "0",
        dailyAssignTarget: json["daily_assign_target"] ?? "0",
        targetCompleted: json["target_completed"] ?? "0",
        inProgress: json["in_progress"] ?? "0",
        notStartedSurveys: json["not_started_surveys"] ?? "0",
        completeSurvey: json["complete_survey"] ?? "0",
        incompleteSurvey: json["incomplete_survey"] ?? "0",
        teamCount: json["team_count"],
        stopedSurvey: json["stoped_survey"] ?? "0",
      );

  Map<String, dynamic> toJson() => {
        "target": target,
        "daily_assign_target": dailyAssignTarget,
        "target_completed": targetCompleted,
        "in_progress": inProgress,
        "not_started_surveys": notStartedSurveys,
        "complete_survey": completeSurvey,
        "incomplete_survey": incompleteSurvey,
        "team_count": teamCount,
        "stoped_survey": stopedSurvey,
      };
}
