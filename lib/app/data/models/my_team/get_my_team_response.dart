// To parse this JSON data, do
//
//     final getMyTeamResponse = getMyTeamResponseFromJson(jsonString);

import 'dart:convert';

List<GetMyTeamResponse> getMyTeamResponseFromJson(String str) => List<GetMyTeamResponse>.from(json.decode(str).map((x) => GetMyTeamResponse.fromJson(x)));

String getMyTeamResponseToJson(List<GetMyTeamResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetMyTeamResponse {
    String status;
    String message;
    List<TeamData> data;

    GetMyTeamResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetMyTeamResponse.fromJson(Map<String, dynamic> json) => GetMyTeamResponse(
        status: json["status"],
        message: json["message"],
        data: List<TeamData>.from(json["data"].map((x) => TeamData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class TeamData {
    String teamId;
    String teamName;
    String teamManagerId;
    String teamMembersId;
    ManagerDetails managerDetails;
    int teamMembersCount;

    TeamData({
        required this.teamId,
        required this.teamName,
        required this.teamManagerId,
        required this.teamMembersId,
        required this.managerDetails,
        required this.teamMembersCount,
    });

    factory TeamData.fromJson(Map<String, dynamic> json) => TeamData(
        teamId: json["team_id"],
        teamName: json["team_name"],
        teamManagerId: json["team_manager_id"],
        teamMembersId: json["team_members_id"],
        managerDetails: ManagerDetails.fromJson(json["manager_details"]),
        teamMembersCount: json["team_members_count"],
    );

    Map<String, dynamic> toJson() => {
        "team_id": teamId,
        "team_name": teamName,
        "team_manager_id": teamManagerId,
        "team_members_id": teamMembersId,
        "manager_details": managerDetails.toJson(),
        "team_members_count": teamMembersCount,
    };
}

class ManagerDetails {
    String managerId;
    String managerFirstName;
    String managerLastName;
    String managerMobileNo;
    String role;

    ManagerDetails({
        required this.managerId,
        required this.managerFirstName,
        required this.managerLastName,
        required this.managerMobileNo,
        required this.role,
    });

    factory ManagerDetails.fromJson(Map<String, dynamic> json) => ManagerDetails(
        managerId: json["manager_id"],
        managerFirstName: json["manager_first_name"],
        managerLastName: json["manager_last_name"],
        managerMobileNo: json["manager_mobile_no"],
        role: json["role"],
    );

    Map<String, dynamic> toJson() => {
        "manager_id": managerId,
        "manager_first_name": managerFirstName,
        "manager_last_name": managerLastName,
        "manager_mobile_no": managerMobileNo,
        "role": role,
    };
}
