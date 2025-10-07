import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../data/models/my_team/my_team_member_model.dart';

class MyTeamDetailListController extends GetxController {
  var isLoading = true.obs;
  var allReports = <TeamMember>[].obs; // Store all team members
  var filteredReportList = <TeamMember>[].obs; // Filtered list for display
  var searchQuery = ''.obs;
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    // Listen to searchController changes for debouncing
    searchController.addListener(() {
      _onSearchChanged(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  // Simulate fetching data (replace with your API call)
  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      // Simulate API call or local data
      List<TeamMember> data = [
        TeamMember(
          name: 'Darade Vaibhav',
          phoneNumber: '9874563210',
          email: 'vaibhav123@gmail.com',
          address: 'Dwarkadham, Panchvati Nashik',
          designation: 'Manager',
          joiningDate: 'Sep 16, 2025',
          dob: 'Mar 16, 2000',
        ),
        TeamMember(
          name: 'Mithun Kumar',
          phoneNumber: '9874563210',
          email: 'mithun@example.com',
          address: 'Sample Address, Mumbai',
          designation: 'Manager',
          joiningDate: 'Oct 01, 2025',
          dob: 'Jan 15, 1998',
        ),
      ];
      allReports.assignAll(data);
      filteredReportList.assignAll(data); // Initialize filtered list
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchData();
  }

  // Debounced search
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchReports(query);
    });
  }

  // Search functionality
  void searchReports(String query) {
    searchQuery.value = query.toLowerCase().trim();
    if (searchQuery.value.isEmpty) {
      filteredReportList.assignAll(allReports); // Reset to full list
    } else {
      filteredReportList.assignAll(allReports.where((report) =>
          report.name.toLowerCase().contains(searchQuery.value) ||
          report.phoneNumber.toLowerCase().contains(searchQuery.value) ||
          report.email.toLowerCase().contains(searchQuery.value) ||
          report.designation.toLowerCase().contains(searchQuery.value) ||
          report.address.toLowerCase().contains(searchQuery.value)));
    }
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filteredReportList.assignAll(allReports);
  }
}