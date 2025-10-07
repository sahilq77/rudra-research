import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/my_report/my_report_chart.dart';

class MyReportSurveyChartController extends GetxController {
  var surveyData = <SurveyData>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSurveyData();
  }

  // Method to load or reset survey data
  void _loadSurveyData() {
    surveyData.clear();
    // Executive Count
    surveyData.add(
      SurveyData(
        title: 'Executive Count',
        sections: [
          ChartSection(value: 3.0, color: Colors.cyan, label: 'Pradeep Pathak'),
          ChartSection(value: 2.0, color: Colors.orange, label: 'Amol Naik'),
        ],
      ),
    );
    // Gender Count
    surveyData.add(
      SurveyData(
        title: 'Gender Count',
        sections: [
          ChartSection(value: 2.0, color: Colors.cyan, label: 'Male'),
          ChartSection(
            value: 1.0,
            color: Colors.deepPurpleAccent.withOpacity(0.8),
            label: 'Female',
          ),
          ChartSection(value: 0.0, color: Colors.orange, label: 'Other'),
        ],
      ),
    );
    // Cast Count
    surveyData.add(
      SurveyData(
        title: 'Cast Count',
        sections: [
          ChartSection(value: 2.0, color: Colors.cyan, label: 'OBC'),
          ChartSection(
            value: 1.0,
            color: Colors.deepPurpleAccent.withOpacity(0.8),
            label: 'Open',
          ),
          ChartSection(value: 0.0, color: Colors.orange, label: 'Other'),
        ],
      ),
    );
    // Age Count
    surveyData.add(
      SurveyData(
        title: 'Age Count',
        sections: [
          ChartSection(value: 2.0, color: Colors.cyan, label: '18-25'),
          ChartSection(value: 1.0, color: Colors.orange, label: '26-35'),
          ChartSection(
            value: 1.0,
            color: Colors.deepPurpleAccent.withOpacity(0.8),
            label: '40-59',
          ),
          ChartSection(value: 0.0, color: Colors.pink, label: '60+'),
        ],
      ),
    );
    // Lok Sabha Count
    surveyData.add(
      SurveyData(
        title: 'Lok Sabha Count',
        sections: [ChartSection(value: 4.0, color: Colors.cyan, label: 'Pune')],
      ),
    );
    // Assembly Count
    surveyData.add(
      SurveyData(
        title: 'Assembly Count',
        sections: [
          ChartSection(value: 1.0, color: Colors.green, label: 'Vadgaon Sheri'),
          ChartSection(value: 1.0, color: Colors.purple, label: 'Kasaba Peth'),
          ChartSection(
            value: 1.0,
            color: Colors.deepPurpleAccent.withOpacity(0.8),
            label: 'Kothrud',
          ),
          ChartSection(value: 1.0, color: Colors.blue, label: '210-Kothrud'),
        ],
      ),
    );
    // Ward Count
    surveyData.add(
      SurveyData(
        title: 'Ward Count',
        sections: [
          ChartSection(
            value: 4.0,
            color: Colors.deepPurpleAccent.withOpacity(0.8),
            label: 'Ward No. 1',
          ),
        ],
      ),
    );
    // Area Count
    surveyData.add(
      SurveyData(
        title: 'Area Count',
        sections: [
          ChartSection(
            value: 2.0,
            color: Colors.cyan,
            label: 'Dhanori Gaothan',
          ),
          ChartSection(
            value: 1.0,
            color: Colors.deepPurpleAccent.withOpacity(0.8),
            label: 'Bhimnagar Vasahat',
          ),
          ChartSection(value: 1.0, color: Colors.pink, label: 'Siddharthnagar'),
          ChartSection(
            value: 0.0,
            color: Colors.orange,
            label: 'Khese Park (Port)',
          ),
        ],
      ),
    );
  }

  // Method to handle refresh action
  Future<void> refreshData() async {
    // Simulate a network delay or API call
    await Future.delayed(Duration(seconds: 1));
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


