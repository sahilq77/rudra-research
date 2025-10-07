import 'package:flutter/material.dart';

class ChartSection {
  double value; // Removed 'final' to allow modification
  Color color;
  String label;

  ChartSection({required this.value, required this.color, required this.label});
}

class SurveyData {
  String title;
  List<ChartSection> sections;

  SurveyData({required this.title, required this.sections});
}