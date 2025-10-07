class PerformanceDataModel {
  final String day;
  final double target;
  final double targetCompleted;

  PerformanceDataModel({
    required this.day,
    required this.target,
    required this.targetCompleted,
  });

  factory PerformanceDataModel.fromJson(Map<String, dynamic> json) {
    return PerformanceDataModel(
      day: json['day'] ?? '',
      target: (json['target'] ?? 0).toDouble(),
      targetCompleted: (json['target_completed'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'target': target,
      'target_completed': targetCompleted,
    };
  }
}
