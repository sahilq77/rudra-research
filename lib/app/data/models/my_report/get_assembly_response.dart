import 'dart:convert';

List<GetAssemblyResponse> getAssemblyResponseFromJson(String str) =>
    List<GetAssemblyResponse>.from(
        json.decode(str).map((x) => GetAssemblyResponse.fromJson(x)));

String getAssemblyResponseToJson(List<GetAssemblyResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAssemblyResponse {
  String status;
  String message;
  AssemblyData data;

  GetAssemblyResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAssemblyResponse.fromJson(Map<String, dynamic> json) =>
      GetAssemblyResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: AssemblyData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class AssemblyData {
  String assemblyId;
  String assemblyName;

  AssemblyData({
    required this.assemblyId,
    required this.assemblyName,
  });

  factory AssemblyData.fromJson(Map<String, dynamic> json) => AssemblyData(
        assemblyId: json["assembly_id"] ?? "",
        assemblyName: json["assembly_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "assembly_id": assemblyId,
        "assembly_name": assemblyName,
      };
}
