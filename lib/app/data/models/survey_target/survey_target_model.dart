// lib/app/models/survey_target_model.dart
class SurveyTargetModel {
  final String id;
  final String executorName;
  final String executorImage;
  final bool isAssigned;
  final int todayCompletedTarget;
  final int totalAssignedTarget;
  final int totalCompletedTarget;
  int currentCount;

  SurveyTargetModel({
    required this.id,
    required this.executorName,
    required this.executorImage,
    required this.isAssigned,
    required this.todayCompletedTarget,
    required this.totalAssignedTarget,
    required this.totalCompletedTarget,
    this.currentCount = 1,
  });

  factory SurveyTargetModel.fromJson(Map<String, dynamic> json) {
    return SurveyTargetModel(
      id: json['id'] ?? '',
      executorName: json['executor_name'] ?? '',
      executorImage: json['executor_image'] ?? '',
      isAssigned: json['is_assigned'] ?? false,
      todayCompletedTarget: json['today_completed_target'] ?? 0,
      totalAssignedTarget: json['total_assigned_target'] ?? 0,
      totalCompletedTarget: json['total_completed_target'] ?? 0,
      currentCount: json['current_count'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'executor_name': executorName,
      'executor_image': executorImage,
      'is_assigned': isAssigned,
      'today_completed_target': todayCompletedTarget,
      'total_assigned_target': totalAssignedTarget,
      'total_completed_target': totalCompletedTarget,
      'current_count': currentCount,
    };
  }

  SurveyTargetModel copyWith({
    String? id,
    String? executorName,
    String? executorImage,
    bool? isAssigned,
    int? todayCompletedTarget,
    int? totalAssignedTarget,
    int? totalCompletedTarget,
    int? currentCount,
  }) {
    return SurveyTargetModel(
      id: id ?? this.id,
      executorName: executorName ?? this.executorName,
      executorImage: executorImage ?? this.executorImage,
      isAssigned: isAssigned ?? this.isAssigned,
      todayCompletedTarget: todayCompletedTarget ?? this.todayCompletedTarget,
      totalAssignedTarget: totalAssignedTarget ?? this.totalAssignedTarget,
      totalCompletedTarget: totalCompletedTarget ?? this.totalCompletedTarget,
      currentCount: currentCount ?? this.currentCount,
    );
  }
}
