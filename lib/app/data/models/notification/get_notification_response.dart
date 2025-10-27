// To parse this JSON data, do
//
//     final getNotificationResponse = getNotificationResponseFromJson(jsonString);

import 'dart:convert';

List<GetNotificationResponse> getNotificationResponseFromJson(String str) => List<GetNotificationResponse>.from(json.decode(str).map((x) => GetNotificationResponse.fromJson(x)));

String getNotificationResponseToJson(List<GetNotificationResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetNotificationResponse {
    String status;
    String message;
    List<NotificationData> data;

    GetNotificationResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetNotificationResponse.fromJson(Map<String, dynamic> json) => GetNotificationResponse(
        status: json["status"],
        message: json["message"],
        data: List<NotificationData>.from(json["data"].map((x) => NotificationData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class NotificationData {
    String id;
    String deviceToken;
    String userId;
    String roleId;
    String title;
    String body;
    String response;
    String responseStatus;
    DateTime sendOn;
    DateTime createdOn;
    String isDeleted;

    NotificationData({
        required this.id,
        required this.deviceToken,
        required this.userId,
        required this.roleId,
        required this.title,
        required this.body,
        required this.response,
        required this.responseStatus,
        required this.sendOn,
        required this.createdOn,
        required this.isDeleted,
    });

    factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
        id: json["id"],
        deviceToken: json["device_token"],
        userId: json["user_id"],
        roleId: json["role_id"],
        title: json["title"],
        body: json["body"],
        response: json["response"],
        responseStatus: json["response_status"],
        sendOn: DateTime.parse(json["send_on"]),
        createdOn: DateTime.parse(json["created_on"]),
        isDeleted: json["is_deleted"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "device_token": deviceToken,
        "user_id": userId,
        "role_id": roleId,
        "title": title,
        "body": body,
        "response": response,
        "response_status": responseStatus,
        "send_on": sendOn.toIso8601String(),
        "created_on": createdOn.toIso8601String(),
        "is_deleted": isDeleted,
    };
}
