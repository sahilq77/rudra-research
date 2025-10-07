import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rudra/app/modules/myreport/my_report_view/report_form_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/my_report/my_report_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';
import '../my_report_list_controller.dart';

class MyReportFormView extends StatelessWidget {
  const MyReportFormView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final MyReportFormViewController controller = Get.put(
      MyReportFormViewController(),
    );
    ResponsiveHelper.init(context);
    // Retrieve the report from arguments
    final MyReportModel? report = Get.arguments?['report'] as MyReportModel?;

    return Scaffold(
      appBar: _buildAppbar(report?.title ?? 'Report Form'),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: ResponsiveHelper.paddingSymmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Column(
            children: [
              _buildDropdownField(
                label: 'Select Cast',
                value: controller.selectedSonar.value,
                items: controller.sonars,
                onChanged: (value) =>
                    controller.selectedSonar.value = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a cast'
                    : null,
              ),
              _buildDropdownField(
                label: 'Select Executive',
                value: controller.selectedExecutive.value,
                items: controller.executives,
                onChanged: (value) =>
                    controller.selectedExecutive.value = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select an executive'
                    : null,
              ),
              _buildDropdownField(
                label: 'Select Assembly',
                value: controller.selectedAssembly.value,
                items: controller.assemblies,
                onChanged: (value) =>
                    controller.selectedAssembly.value = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select an assembly'
                    : null,
              ),
              _buildDropdownField(
                label: 'Select Ward',
                value: controller.selectedWard.value,
                items: controller.wards,
                onChanged: (value) =>
                    controller.selectedWard.value = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a ward'
                    : null,
              ),
              _buildDropdownField(
                label: 'Select Area',
                value: controller.selectedArea.value,
                items: controller.areas,
                onChanged: (value) =>
                    controller.selectedArea.value = value ?? '',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select an area'
                    : null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {},
          style: AppButtonStyles.elevatedLargeBlack(),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Search',
              style: AppStyle.buttonTextSmallPoppinsWhite.responsive,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.labelPrimaryPoppinsBlack.responsive),
        const SizedBox(height: 10),
        DropdownSearch<String>(
          selectedItem: value.isEmpty ? null : value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: AppStyle.bodySmallPoppinsGrey.responsive,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: true,
              fillColor: AppColors.white,
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: AppStyle.bodySmallPoppinsGrey.responsive,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            containerBuilder: (context, popupWidget) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: popupWidget,
              );
            },
          ),
          dropdownButtonProps: const DropdownButtonProps(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.defaultBlack,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  AppBar _buildAppbar(String title) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        title,
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }
}
