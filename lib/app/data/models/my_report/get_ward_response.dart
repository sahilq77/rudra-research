import 'dart:convert';

List<GetWardResponse> getWardResponseFromJson(String str) =>
    List<GetWardResponse>.from(
        json.decode(str).map((x) => GetWardResponse.fromJson(x)));

String getWardResponseToJson(List<GetWardResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetWardResponse {
  String status;
  String message;
  WardData data;

  GetWardResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetWardResponse.fromJson(Map<String, dynamic> json) =>
      GetWardResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: WardData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class WardData {
  String wardId;
  String wardName;

  WardData({
    required this.wardId,
    required this.wardName,
  });

  factory WardData.fromJson(Map<String, dynamic> json) => WardData(
        wardId: json["ward_id"] ?? "",
        wardName: json["ward_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "ward_id": wardId,
        "ward_name": wardName,
      };
}
