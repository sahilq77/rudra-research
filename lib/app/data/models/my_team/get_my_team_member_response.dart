// To parse this JSON data, do
//
//     final getMyTeamMemberResponse = getMyTeamMemberResponseFromJson(jsonString);

import 'dart:convert';

List<GetMyTeamMemberResponse> getMyTeamMemberResponseFromJson(String str) => List<GetMyTeamMemberResponse>.from(json.decode(str).map((x) => GetMyTeamMemberResponse.fromJson(x)));

String getMyTeamMemberResponseToJson(List<GetMyTeamMemberResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetMyTeamMemberResponse {
    String status;
    String message;
    TeamMemberData data;

    GetMyTeamMemberResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetMyTeamMemberResponse.fromJson(Map<String, dynamic> json) => GetMyTeamMemberResponse(
        status: json["status"],
        message: json["message"],
        data: TeamMemberData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
    };
}

class TeamMemberData {
    String teamId;
    String teamName;
    String teamManagerId;
    String teamMembersId;
    ManagerDetails managerDetails;
    List<TeamMembersDetails> teamMembersDetails;

    TeamMemberData({
        required this.teamId,
        required this.teamName,
        required this.teamManagerId,
        required this.teamMembersId,
        required this.managerDetails,
        required this.teamMembersDetails,
    });

    factory TeamMemberData.fromJson(Map<String, dynamic> json) => TeamMemberData(
        teamId: json["team_id"],
        teamName: json["team_name"],
        teamManagerId: json["team_manager_id"],
        teamMembersId: json["team_members_id"],
        managerDetails: ManagerDetails.fromJson(json["manager_details"]),
        teamMembersDetails: List<TeamMembersDetails>.from(json["team_members_details"].map((x) => TeamMembersDetails.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "team_id": teamId,
        "team_name": teamName,
        "team_manager_id": teamManagerId,
        "team_members_id": teamMembersId,
        "manager_details": managerDetails.toJson(),
        "team_members_details": List<dynamic>.from(teamMembersDetails.map((x) => x.toJson())),
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

class TeamMembersDetails {
    String memberId;
    String memberFirstName;
    String memberLastName;
    String memberMobileNo;
    String role;

    TeamMembersDetails({
        required this.memberId,
        required this.memberFirstName,
        required this.memberLastName,
        required this.memberMobileNo,
        required this.role,
    });

    factory TeamMembersDetails.fromJson(Map<String, dynamic> json) => TeamMembersDetails(
        memberId: json["member_id"],
        memberFirstName: json["member_first_name"],
        memberLastName: json["member_last_name"],
        memberMobileNo: json["member_mobile_no"],
        role: json["role"],
    );

    Map<String, dynamic> toJson() => {
        "member_id": memberId,
        "member_first_name": memberFirstName,
        "member_last_name": memberLastName,
        "member_mobile_no": memberMobileNo,
        "role": role,
    };
}
