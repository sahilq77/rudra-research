import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/myreport/my_report_view/report_form_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/responsive_utils.dart';
import '../../../../widgets/app_button_style.dart';
import '../../../../widgets/app_style.dart';

class MyReportFormView extends StatefulWidget {
  const MyReportFormView({super.key});

  @override
  State<MyReportFormView> createState() => _MyReportFormViewState();
}

class _MyReportFormViewState extends State<MyReportFormView> {
  @override
  Widget build(BuildContext context) {
    final MyReportFormViewController controller = Get.put(
      MyReportFormViewController(),
    );
    ResponsiveHelper.init(context);

    return Scaffold(
      appBar: _buildAppbar('Report Form'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmer();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: ResponsiveHelper.paddingSymmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Column(
                children: [
                  _buildMultiSelectDropdown(
                    context: context,
                    controller: controller,
                    label: 'Select Cast',
                    items: controller.castList,
                    selectedItems: controller.selectedCastIds,
                    itemAsString: (item) => item.castName,
                    itemId: (item) => item.castId,
                  ),
                  _buildMultiSelectDropdown(
                    context: context,
                    controller: controller,
                    label: 'Select Executive',
                    items: controller.executiveList,
                    selectedItems: controller.selectedExecutiveIds,
                    itemAsString: (item) =>
                        '${item.firstName} ${item.lastName}',
                    itemId: (item) => item.executiveId,
                  ),
                  _buildMultiSelectDropdown(
                    context: context,
                    controller: controller,
                    label: 'Select Assembly',
                    items: controller.assemblyList,
                    selectedItems: controller.selectedAssemblyIds,
                    itemAsString: (item) => item.assemblyName,
                    itemId: (item) => item.assemblyId,
                  ),
                  _buildMultiSelectDropdown(
                    context: context,
                    controller: controller,
                    label: 'Select Ward',
                    items: controller.wardList,
                    selectedItems: controller.selectedWardIds,
                    itemAsString: (item) => item.wardName,
                    itemId: (item) => item.wardId,
                  ),
                  _buildMultiSelectDropdown(
                    context: context,
                    controller: controller,
                    label: 'Select Area',
                    items: controller.areaList,
                    selectedItems: controller.selectedAreaIds,
                    itemAsString: (item) => item.areaName,
                    itemId: (item) => item.villageAreaId,
                  ),
                  FormField<bool>(
                    validator: (_) => controller.validateAtLeastOne(),
                    builder: (formFieldState) {
                      return formFieldState.hasError
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                formFieldState.errorText!,
                                style: AppStyle.bodySmallPoppinsBlack.responsive
                                    .copyWith(color: Colors.red),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() => Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed:
                  controller.isLoading.value ? null : controller.submitReport,
              style: AppButtonStyles.elevatedLargeBlack(),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Search',
                        style: AppStyle.buttonTextSmallPoppinsWhite.responsive,
                        maxLines: 1,
                      ),
                    ),
            ),
          )),
    );
  }

  Widget _buildMultiSelectDropdown<T>({
    required BuildContext context,
    required MyReportFormViewController controller,
    required String label,
    required RxList<T> items,
    required RxList<String> selectedItems,
    required String Function(T) itemAsString,
    required String Function(T) itemId,
  }) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppStyle.labelPrimaryPoppinsBlack.responsive),
            const SizedBox(height: 10),
            DropdownSearch<T>.multiSelection(
              items: items,
              selectedItems: items
                  .where((item) => selectedItems.contains(itemId(item)))
                  .toList(),
              itemAsString: itemAsString,
              onChanged: (List<T> selected) {
                selectedItems.value = selected.map((e) => itemId(e)).toList();
                controller.formKey.currentState?.validate();
              },
              dropdownBuilder: (context, selectedItemsList) {
                return Text(
                  selectedItemsList.isEmpty
                      ? 'Select $label'
                      : '${selectedItemsList.length} selected',
                  style: selectedItemsList.isEmpty
                      ? AppStyle.bodySmallPoppinsGrey.responsive
                      : AppStyle.bodyRegularPoppinsBlack.responsive,
                );
              },
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
              ),
              popupProps: PopupPropsMultiSelection.menu(
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
            if (selectedItems.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items
                    .where((item) => selectedItems.contains(itemId(item)))
                    .map((item) => Chip(
                          label: Text(
                            itemAsString(item),
                            style:
                                AppStyle.labelSecondaryPoppinsBlack.responsive,
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 14,
                          ),
                          onDeleted: () {
                            selectedItems.remove(itemId(item));
                            controller.formKey.currentState?.validate();
                          },
                          backgroundColor: AppColors.accentOrangeFaded,
                          deleteIconColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          labelPadding: const EdgeInsets.only(left: 4),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ));
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding:
            ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: List.generate(
            5,
            (index) => Column(
              children: [
                Container(height: 60, color: Colors.white),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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
