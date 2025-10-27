// To parse this JSON data, do
//
//     final getMyTeamMemberDetailResponse = getMyTeamMemberDetailResponseFromJson(jsonString);

import 'dart:convert';

List<GetMyTeamMemberDetailResponse> getMyTeamMemberDetailResponseFromJson(
  String str,
) => List<GetMyTeamMemberDetailResponse>.from(
  json.decode(str).map((x) => GetMyTeamMemberDetailResponse.fromJson(x)),
);

String getMyTeamMemberDetailResponseToJson(
  List<GetMyTeamMemberDetailResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetMyTeamMemberDetailResponse {
  String status;
  String message;
  TeamMemberDetail data;

  GetMyTeamMemberDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetMyTeamMemberDetailResponse.fromJson(Map<String, dynamic> json) =>
      GetMyTeamMemberDetailResponse(
        status: json["status"],
        message: json["message"],
        data: TeamMemberDetail.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class TeamMemberDetail {
  String memberId;
  String firstName;
  String lastName;
  String email;
  String mobileNo;
  dynamic otp;
  String file;
  DateTime dob;
  String address;
  String roleId;
  DateTime joiningDate;
  dynamic assignedBy;
  dynamic updatedBy;
  String status;
  String flag;
  dynamic updatedFlagReason;

  String role;

  TeamMemberDetail({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNo,
    required this.otp,
    required this.file,
    required this.dob,
    required this.address,
    required this.roleId,
    required this.joiningDate,
    required this.assignedBy,
    required this.updatedBy,
    required this.status,
    required this.flag,
    required this.updatedFlagReason,

    required this.role,
  });

  factory TeamMemberDetail.fromJson(Map<String, dynamic> json) =>
      TeamMemberDetail(
        memberId: json["member_id"] ?? "",
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        email: json["email"] ?? "",
        mobileNo: json["mobile_no"] ?? "",
        otp: json["otp"] ?? "",
        file: json["file"] ?? "",
        dob: DateTime.parse(json["dob"]),
        address: json["address"] ?? "",
        roleId: json["role_id"] ?? "",
        joiningDate: DateTime.parse(json["joining_date"]),
        assignedBy: json["assigned_by"] ?? "",
        updatedBy: json["updated_by"] ?? "",
        status: json["status"] ?? "",
        flag: json["flag"] ?? "",
        updatedFlagReason: json["updated_flag_reason"] ?? "",

        role: json["role"],
      );

  Map<String, dynamic> toJson() => {
    "member_id": memberId,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "mobile_no": mobileNo,
    "otp": otp,
    "file": file,
    "dob":
        "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}",
    "address": address,
    "role_id": roleId,
    "joining_date":
        "${joiningDate.year.toString().padLeft(4, '0')}-${joiningDate.month.toString().padLeft(2, '0')}-${joiningDate.day.toString().padLeft(2, '0')}",
    "assigned_by": assignedBy,
    "updated_by": updatedBy,
    "status": status,
    "flag": flag,
    "updated_flag_reason": updatedFlagReason,

    "role": role,
  };
}
