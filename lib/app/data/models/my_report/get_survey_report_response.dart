import 'dart:convert';

class GetSurveyReportResponse {
  String status;
  String message;
  SurveyReportData data;

  GetSurveyReportResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetSurveyReportResponse.fromJson(Map<String, dynamic> json) {
    return GetSurveyReportResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: SurveyReportData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class SurveyReportData {
  String totalResponses;
  String executiveCount;
  List<ExecutiveInfo> executiveInfo;
  String genderCount;
  Map<String, List<PersonDetail>> genderDetail;
  String castCount;
  List<CastDetail> castDetail;
  String ageCount;
  Map<String, List<PersonDetail>> ageDetail;
  String loksabhaCount;
  List<LoksabhaDetail> loksabhaDetail;
  String assemblyCount;
  List<AssemblyDetail> assemblyDetail;
  String wardCount;
  List<WardDetail> wardDetail;
  String villageAreaCount;
  List<VillageAreaDetail> villageAreaDetail;
  List<LocationHierarchy> locationHierarchy;

  SurveyReportData({
    required this.totalResponses,
    required this.executiveCount,
    required this.executiveInfo,
    required this.genderCount,
    required this.genderDetail,
    required this.castCount,
    required this.castDetail,
    required this.ageCount,
    required this.ageDetail,
    required this.loksabhaCount,
    required this.loksabhaDetail,
    required this.assemblyCount,
    required this.assemblyDetail,
    required this.wardCount,
    required this.wardDetail,
    required this.villageAreaCount,
    required this.villageAreaDetail,
    required this.locationHierarchy,
  });

  factory SurveyReportData.fromJson(Map<String, dynamic> json) {
    Map<String, List<PersonDetail>> parseGenderDetail(dynamic data) {
      if (data == null) return {};
      final map = <String, List<PersonDetail>>{};
      (data as Map<String, dynamic>).forEach((key, value) {
        map[key] =
            (value as List).map((e) => PersonDetail.fromJson(e)).toList();
      });
      return map;
    }

    return SurveyReportData(
      totalResponses: json['total_responses']?.toString() ?? '0',
      executiveCount: json['executive_count']?.toString() ?? '0',
      executiveInfo: (json['executive_info'] as List?)
              ?.map((e) => ExecutiveInfo.fromJson(e))
              .toList() ??
          [],
      genderCount: json['gender_count']?.toString() ?? '0',
      genderDetail: parseGenderDetail(json['gender_detail']),
      castCount: json['cast_count']?.toString() ?? '0',
      castDetail: (json['cast_detail'] as List?)
              ?.map((e) => CastDetail.fromJson(e))
              .toList() ??
          [],
      ageCount: json['age_count']?.toString() ?? '0',
      ageDetail: parseGenderDetail(json['age_detail']),
      loksabhaCount: json['loksabha_count']?.toString() ?? '0',
      loksabhaDetail: (json['loksabha_detail'] as List?)
              ?.map((e) => LoksabhaDetail.fromJson(e))
              .toList() ??
          [],
      assemblyCount: json['assembly_count']?.toString() ?? '0',
      assemblyDetail: (json['assembly_detail'] as List?)
              ?.map((e) => AssemblyDetail.fromJson(e))
              .toList() ??
          [],
      wardCount: json['ward_count']?.toString() ?? '0',
      wardDetail: (json['ward_detail'] as List?)
              ?.map((e) => WardDetail.fromJson(e))
              .toList() ??
          [],
      villageAreaCount: json['village_area_count']?.toString() ?? '0',
      villageAreaDetail: (json['village_area_detail'] as List?)
              ?.map((e) => VillageAreaDetail.fromJson(e))
              .toList() ??
          [],
      locationHierarchy: (json['location_hierarchy'] as List?)
              ?.map((e) => LocationHierarchy.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_responses': totalResponses,
      'executive_count': executiveCount,
      'executive_info': executiveInfo.map((e) => e.toJson()).toList(),
      'gender_count': genderCount,
      'gender_detail': genderDetail
          .map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'cast_count': castCount,
      'cast_detail': castDetail.map((e) => e.toJson()).toList(),
      'age_count': ageCount,
      'age_detail': ageDetail
          .map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'loksabha_count': loksabhaCount,
      'loksabha_detail': loksabhaDetail.map((e) => e.toJson()).toList(),
      'assembly_count': assemblyCount,
      'assembly_detail': assemblyDetail.map((e) => e.toJson()).toList(),
      'ward_count': wardCount,
      'ward_detail': wardDetail.map((e) => e.toJson()).toList(),
      'village_area_count': villageAreaCount,
      'village_area_detail': villageAreaDetail.map((e) => e.toJson()).toList(),
      'location_hierarchy': locationHierarchy.map((e) => e.toJson()).toList(),
    };
  }
}

class PersonDetail {
  String id;
  String name;
  String age;
  String gender;
  String mobNumber;
  String castId;

  PersonDetail({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.mobNumber,
    required this.castId,
  });

  factory PersonDetail.fromJson(Map<String, dynamic> json) {
    return PersonDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      age: json['age']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      mobNumber: json['mob_number']?.toString() ?? '',
      castId: json['cast_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'mob_number': mobNumber,
      'cast_id': castId,
    };
  }
}

class ExecutiveInfo {
  String executiveId;
  String name;
  List<PersonDetail> peopleDetails;

  ExecutiveInfo({
    required this.executiveId,
    required this.name,
    required this.peopleDetails,
  });

  factory ExecutiveInfo.fromJson(Map<String, dynamic> json) {
    return ExecutiveInfo(
      executiveId: json['executive_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      peopleDetails: (json['people_details'] as List?)
              ?.map((e) => PersonDetail.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'executive_id': executiveId,
      'name': name,
      'people_details': peopleDetails.map((e) => e.toJson()).toList(),
    };
  }
}

class CastDetail {
  String castId;
  String castName;
  List<PersonDetail> peopleDetails;

  CastDetail({
    required this.castId,
    required this.castName,
    required this.peopleDetails,
  });

  factory CastDetail.fromJson(Map<String, dynamic> json) {
    return CastDetail(
      castId: json['cast_id']?.toString() ?? '',
      castName: json['cast_name']?.toString() ?? '',
      peopleDetails: (json['people_details'] as List?)
              ?.map((e) => PersonDetail.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cast_id': castId,
      'cast_name': castName,
      'people_details': peopleDetails.map((e) => e.toJson()).toList(),
    };
  }
}

class LoksabhaDetail {
  String loksabhaId;
  String loksabhaName;
  List<PersonDetail> peopleDetails;

  LoksabhaDetail({
    required this.loksabhaId,
    required this.loksabhaName,
    required this.peopleDetails,
  });

  factory LoksabhaDetail.fromJson(Map<String, dynamic> json) {
    return LoksabhaDetail(
      loksabhaId: json['loksabha_id']?.toString() ?? '',
      loksabhaName: json['loksabha_name']?.toString() ?? '',
      peopleDetails: (json['people_details'] as List?)
              ?.map((e) => PersonDetail.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loksabha_id': loksabhaId,
      'loksabha_name': loksabhaName,
      'people_details': peopleDetails.map((e) => e.toJson()).toList(),
    };
  }
}

class AssemblyDetail {
  String assemblyId;
  String assemblyName;
  String responseCount;

  AssemblyDetail({
    required this.assemblyId,
    required this.assemblyName,
    required this.responseCount,
  });

  factory AssemblyDetail.fromJson(Map<String, dynamic> json) {
    return AssemblyDetail(
      assemblyId: json['assembly_id']?.toString() ?? '',
      assemblyName: json['assembly_name']?.toString() ?? '',
      responseCount: json['response_count']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assembly_id': assemblyId,
      'assembly_name': assemblyName,
      'response_count': responseCount,
    };
  }
}

class WardDetail {
  String wardId;
  String wardName;
  String responseCount;

  WardDetail({
    required this.wardId,
    required this.wardName,
    required this.responseCount,
  });

  factory WardDetail.fromJson(Map<String, dynamic> json) {
    return WardDetail(
      wardId: json['ward_id']?.toString() ?? '',
      wardName: json['ward_name']?.toString() ?? '',
      responseCount: json['response_count']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ward_id': wardId,
      'ward_name': wardName,
      'response_count': responseCount,
    };
  }
}

class VillageAreaDetail {
  String villageAreaId;
  String areaName;
  String responseCount;

  VillageAreaDetail({
    required this.villageAreaId,
    required this.areaName,
    required this.responseCount,
  });

  factory VillageAreaDetail.fromJson(Map<String, dynamic> json) {
    return VillageAreaDetail(
      villageAreaId: json['village_area_id']?.toString() ?? '',
      areaName: json['area_name']?.toString() ?? '',
      responseCount: json['response_count']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'village_area_id': villageAreaId,
      'area_name': areaName,
      'response_count': responseCount,
    };
  }
}

List<GetSurveyReportResponse> getSurveyReportResponseFromJson(String str) {
  final jsonData = json.decode(str) as List;
  return jsonData
      .map((item) => GetSurveyReportResponse.fromJson(item))
      .toList();
}

String getSurveyReportResponseToJson(List<GetSurveyReportResponse> data) {
  final dyn = data.map((item) => item.toJson()).toList();
  return json.encode(dyn);
}

class VillageHierarchy {
  String villageAreaId;
  String areaName;
  String villageResponseCount;

  VillageHierarchy({
    required this.villageAreaId,
    required this.areaName,
    required this.villageResponseCount,
  });

  factory VillageHierarchy.fromJson(Map<String, dynamic> json) =>
      VillageHierarchy(
        villageAreaId: json['village_area_id']?.toString() ?? '',
        areaName: json['area_name']?.toString() ?? '',
        villageResponseCount:
            json['village_response_count']?.toString() ?? '0',
      );

  Map<String, dynamic> toJson() => {
        'village_area_id': villageAreaId,
        'area_name': areaName,
        'village_response_count': villageResponseCount,
      };
}

class WardHierarchy {
  String wardId;
  String wardName;
  String wardResponseCount;
  List<VillageHierarchy> villages;

  WardHierarchy({
    required this.wardId,
    required this.wardName,
    required this.wardResponseCount,
    required this.villages,
  });

  factory WardHierarchy.fromJson(Map<String, dynamic> json) => WardHierarchy(
        wardId: json['ward_id']?.toString() ?? '',
        wardName: json['ward_name']?.toString() ?? '',
        wardResponseCount: json['ward_response_count']?.toString() ?? '0',
        villages: (json['villages'] as List?)
                ?.map((e) => VillageHierarchy.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'ward_id': wardId,
        'ward_name': wardName,
        'ward_response_count': wardResponseCount,
        'villages': villages.map((e) => e.toJson()).toList(),
      };
}

class LocationHierarchy {
  String assemblyId;
  String assemblyName;
  String assemblyResponseCount;
  List<WardHierarchy> wards;

  LocationHierarchy({
    required this.assemblyId,
    required this.assemblyName,
    required this.assemblyResponseCount,
    required this.wards,
  });

  factory LocationHierarchy.fromJson(Map<String, dynamic> json) =>
      LocationHierarchy(
        assemblyId: json['assembly_id']?.toString() ?? '',
        assemblyName: json['assembly_name']?.toString() ?? '',
        assemblyResponseCount:
            json['assembly_response_count']?.toString() ?? '0',
        wards: (json['wards'] as List?)
                ?.map((e) => WardHierarchy.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'assembly_id': assemblyId,
        'assembly_name': assemblyName,
        'assembly_response_count': assemblyResponseCount,
        'wards': wards.map((e) => e.toJson()).toList(),
      };
}
