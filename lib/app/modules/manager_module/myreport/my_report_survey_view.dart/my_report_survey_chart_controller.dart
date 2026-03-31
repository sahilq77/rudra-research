import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/my_report/get_survey_report_response.dart';
import 'package:rudra/app/data/models/my_report/my_report_chart.dart';

class MyReportSurveyChartController extends GetxController {
  var surveyData = <SurveyData>[].obs;
  final RxBool isLoading = true.obs;
  SurveyReportData? reportData;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['data'] != null) {
      reportData = args['data'] as SurveyReportData;
      _loadSurveyData();
    }
  }

  void _loadSurveyData() {
    if (reportData == null) return;
    surveyData.clear();
    // Executive Count
    if (reportData!.executiveInfo.isNotEmpty) {
      surveyData.add(
        SurveyData(
          title: 'Executive Count (${reportData!.executiveCount})',
          sections: reportData!.executiveInfo.asMap().entries.map((e) {
            final colors = [
              Colors.cyan,
              Colors.orange,
              Colors.green,
              Colors.purple,
              Colors.pink,
              Colors.blue
            ];
            return ChartSection(
              value: e.value.peopleDetails.length.toDouble(),
              color: colors[e.key % colors.length],
              label: e.value.name,
            );
          }).toList(),
        ),
      );
    }
    // Gender Count
    if (reportData!.genderDetail.isNotEmpty) {
      final genderMap = {'0': 'Male', '1': 'Female', '2': 'Other'};
      final genderColors = {
        '0': Colors.cyan,
        '1': Colors.pink,
        '2': Colors.orange
      };
      surveyData.add(
        SurveyData(
          title: 'Gender Count (${reportData!.genderCount})',
          sections: reportData!.genderDetail.entries.map((e) {
            return ChartSection(
              value: e.value.length.toDouble(),
              color: genderColors[e.key] ?? Colors.grey,
              label: genderMap[e.key] ?? 'Unknown',
            );
          }).toList(),
        ),
      );
    }
    // Cast Count
    if (reportData!.castDetail.isNotEmpty) {
      surveyData.add(
        SurveyData(
          title: 'Cast Count (${reportData!.castCount})',
          sections: reportData!.castDetail.asMap().entries.map((e) {
            final colors = [
              Colors.cyan,
              Colors.deepPurpleAccent,
              Colors.orange,
              Colors.green,
              Colors.purple
            ];
            return ChartSection(
              value: e.value.peopleDetails.length.toDouble(),
              color: colors[e.key % colors.length],
              label: e.value.castName,
            );
          }).toList(),
        ),
      );
    }
    // Age Count
    if (reportData!.ageDetail.isNotEmpty) {
      surveyData.add(
        SurveyData(
          title: 'Age Count (${reportData!.ageCount})',
          sections: reportData!.ageDetail.entries.map((e) {
            final colors = [
              Colors.cyan,
              Colors.orange,
              Colors.deepPurpleAccent,
              Colors.pink,
              Colors.green
            ];
            return ChartSection(
              value: e.value.length.toDouble(),
              color: colors[int.tryParse(e.key) ?? 0 % colors.length],
              label: 'Age ${e.key}',
            );
          }).toList(),
        ),
      );
    }
    // Lok Sabha Count
    if (reportData!.loksabhaDetail.isNotEmpty) {
      surveyData.add(
        SurveyData(
          title: 'Lok Sabha Count (${reportData!.loksabhaCount})',
          sections: reportData!.loksabhaDetail.asMap().entries.map((e) {
            final colors = [
              Colors.cyan,
              Colors.orange,
              Colors.green,
              Colors.purple
            ];
            return ChartSection(
              value: e.value.peopleDetails.length.toDouble(),
              color: colors[e.key % colors.length],
              label: e.value.loksabhaName,
            );
          }).toList(),
        ),
      );
    }
    // Assembly Count
    if (reportData!.assemblyDetail.isNotEmpty) {
      surveyData.add(
        SurveyData(
          title: 'Assembly Count (${reportData!.assemblyCount})',
          sections: reportData!.assemblyDetail.asMap().entries.map((e) {
            final colors = [
              Colors.green,
              Colors.purple,
              Colors.deepPurpleAccent,
              Colors.blue,
              Colors.orange
            ];
            return ChartSection(
              value: double.tryParse(e.value.responseCount) ?? 0.0,
              color: colors[e.key % colors.length],
              label: e.value.assemblyName,
            );
          }).toList(),
        ),
      );
    }
    // Ward Count
    if (reportData!.wardDetail.isNotEmpty) {
      surveyData.add(
        SurveyData(
          title: 'Ward Count (${reportData!.wardCount})',
          sections: reportData!.wardDetail.asMap().entries.map((e) {
            final colors = [
              Colors.deepPurpleAccent,
              Colors.cyan,
              Colors.orange,
              Colors.green
            ];
            return ChartSection(
              value: double.tryParse(e.value.responseCount) ?? 0.0,
              color: colors[e.key % colors.length],
              label: e.value.wardName,
            );
          }).toList(),
        ),
      );
    }
    // Area Count
    if (reportData!.villageAreaDetail.isNotEmpty) {
      surveyData.add(
        SurveyData(
          title: 'Area Count (${reportData!.villageAreaCount})',
          sections: reportData!.villageAreaDetail.asMap().entries.map((e) {
            final colors = [
              Colors.cyan,
              Colors.deepPurpleAccent,
              Colors.pink,
              Colors.orange,
              Colors.green
            ];
            return ChartSection(
              value: double.tryParse(e.value.responseCount) ?? 0.0,
              color: colors[e.key % colors.length],
              label: e.value.areaName,
            );
          }).toList(),
        ),
      );
    }
  }

  // Method to handle refresh action
  Future<void> refreshData() async {
    // Simulate a network delay or API call
    await Future.delayed(const Duration(seconds: 1));
    _loadSurveyData();
    surveyData.refresh();
  }

  void updateSectionValue(String title, int index, double newValue) {
    final surveyIndex = surveyData.indexWhere((s) => s.title == title);
    if (surveyIndex != -1) {
      surveyData[surveyIndex].sections[index].value = newValue;
      surveyData.refresh();
    }
  }
}
