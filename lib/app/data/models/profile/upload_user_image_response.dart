import 'dart:convert';

List<UploadUserImageResponse> uploadUserImageResponseFromJson(String str) =>
    List<UploadUserImageResponse>.from(
        json.decode(str).map((x) => UploadUserImageResponse.fromJson(x)));

String uploadUserImageResponseToJson(List<UploadUserImageResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UploadUserImageResponse {
  String? status;
  String? message;
  UserData? data;

  UploadUserImageResponse({
    this.status,
    this.message,
    this.data,
  });

  factory UploadUserImageResponse.fromJson(Map<String, dynamic> json) =>
      UploadUserImageResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : UserData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class UserData {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  String? file;
  String? dob;
  String? address;
  String? roleId;
  String? joiningDate;

  UserData({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNo,
    this.file,
    this.dob,
    this.address,
    this.roleId,
    this.joiningDate,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        mobileNo: json["mobile_no"],
        file: json["file"],
        dob: json["dob"],
        address: json["address"],
        roleId: json["role_id"],
        joiningDate: json["joining_date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile_no": mobileNo,
        "file": file,
        "dob": dob,
        "address": address,
        "role_id": roleId,
        "joining_date": joiningDate,
      };
}
