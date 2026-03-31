class ValidatorSurveyModel {
  final String surveyId;
  final String title;
  final String subtitle;
  final String dateRange;
  final int surveyCount;
  final String surveyDate;
  final String teamName;
  final String target;
  final String managerName;
  final bool isLive;

  ValidatorSurveyModel({
    required this.surveyId,
    required this.title,
    required this.subtitle,
    required this.dateRange,
    required this.surveyCount,
    required this.surveyDate,
    required this.teamName,
    required this.target,
    required this.managerName,
    this.isLive = true,
  });
}
