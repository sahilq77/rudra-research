class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final DateTime dateTime;
  final bool isRead;
  final NotificationDetails? details;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.dateTime,
    this.isRead = false,
    this.details,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      dateTime:
          DateTime.parse(json['date_time'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      details: json['details'] != null
          ? NotificationDetails.fromJson(json['details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time_ago': timeAgo,
      'date_time': dateTime.toIso8601String(),
      'is_read': isRead,
      'details': details?.toJson(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    DateTime? dateTime,
    bool? isRead,
    NotificationDetails? details,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      dateTime: dateTime ?? this.dateTime,
      isRead: isRead ?? this.isRead,
      details: details ?? this.details,
    );
  }
}

class NotificationDetails {
  final String surveyName;
  final String executiveName;
  final String dateTime;
  final String target;

  NotificationDetails({
    required this.surveyName,
    required this.executiveName,
    required this.dateTime,
    required this.target,
  });

  factory NotificationDetails.fromJson(Map<String, dynamic> json) {
    return NotificationDetails(
      surveyName: json['survey_name'] ?? '',
      executiveName: json['executive_name'] ?? '',
      dateTime: json['date_time'] ?? '',
      target: json['target'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'survey_name': surveyName,
      'executive_name': executiveName,
      'date_time': dateTime,
      'target': target,
    };
  }
}
