// To parse this JSON data, do
//
//     final getAddExcecutiveResponse = getAddExcecutiveResponseFromJson(jsonString);

import 'dart:convert';

List<GetAddExcecutiveResponse> getAddExcecutiveResponseFromJson(String str) => List<GetAddExcecutiveResponse>.from(json.decode(str).map((x) => GetAddExcecutiveResponse.fromJson(x)));

String getAddExcecutiveResponseToJson(List<GetAddExcecutiveResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAddExcecutiveResponse {
    String status;
    String message;
    Data data;

    GetAddExcecutiveResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetAddExcecutiveResponse.fromJson(Map<String, dynamic> json) => GetAddExcecutiveResponse(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String userId;
    String firstName;
    String lastName;
    String email;
    String mobileNo;
    String roleId;
    String isActive;
    String profileImage;
    DateTime dob;
    DateTime joiningDate;
    String address;

    Data({
        required this.userId,
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.mobileNo,
        required this.roleId,
        required this.isActive,
        required this.profileImage,
        required this.dob,
        required this.joiningDate,
        required this.address,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["user_id"]??"",
        firstName: json["first_name"]??"",
        lastName: json["last_name"],
        email: json["email"]??"",
        mobileNo: json["mobile_no"]??"",
        roleId: json["role_id"]??"",
        isActive: json["is_active"]??"",
        profileImage: json["profile_image"]??"",
        dob: DateTime.parse(json["dob"]),
        joiningDate: DateTime.parse(json["joining_date"]),
        address: json["address"]??"",
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile_no": mobileNo,
        "role_id": roleId,
        "is_active": isActive,
        "profile_image": profileImage,
        "dob": "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}",
        "joining_date": "${joiningDate.year.toString().padLeft(4, '0')}-${joiningDate.month.toString().padLeft(2, '0')}-${joiningDate.day.toString().padLeft(2, '0')}",
        "address": address,
    };
}
