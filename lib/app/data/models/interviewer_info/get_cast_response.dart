// To parse this JSON data, do
//
//     final geCastResponse = geCastResponseFromJson(jsonString);

import 'dart:convert';

List<GeCastResponse> geCastResponseFromJson(String str) =>
    List<GeCastResponse>.from(
        json.decode(str).map((x) => GeCastResponse.fromJson(x)));

String geCastResponseToJson(List<GeCastResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GeCastResponse {
  String status;
  String message;
  List<CastData> data;

  GeCastResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GeCastResponse.fromJson(Map<String, dynamic> json) => GeCastResponse(
        status: json["status"],
        message: json["message"],
        data:
            List<CastData>.from(json["data"].map((x) => CastData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class CastData {
  String castId;
  String castName;

  CastData({
    required this.castId,
    required this.castName,
  });

  factory CastData.fromJson(Map<String, dynamic> json) => CastData(
        castId: json["cast_id"] ?? "",
        castName: json["cast_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "cast_id": castId,
        "cast_name": castName,
      };
}
