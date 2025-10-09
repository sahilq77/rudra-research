// lib/app/modules/assign_executive/assign_executive_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/custominputformatters/securetext_input_formatter.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';
import 'assign_executive_controller.dart';

class AssignExecutiveView extends StatefulWidget {
  const AssignExecutiveView({super.key});

  @override
  State<AssignExecutiveView> createState() => _AssignExecutiveViewState();
}

class _AssignExecutiveViewState extends State<AssignExecutiveView> {
  final AssignExecutiveController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          controller.refreshData();
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          return _buildBody();
        }),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.defaultBlack),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Assign Executive',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Divider(
          color: AppColors.grey.withOpacity(0.5),
          // thickness: 2,
          height: 0,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          _buildSearchField(),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          _buildExecutiveList(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller.searchController,
        onChanged: controller.searchExecutives,
        inputFormatters: [SecureTextInputFormatter.deny()],
        decoration: InputDecoration(
          hintText: 'Search.....',
          hintStyle: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(14),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.grey,
            size: ResponsiveHelper.spacing(20),
          ),
          border: InputBorder.none,
          contentPadding: ResponsiveHelper.paddingSymmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(14),
        ),
      ),
    );
  }

  Widget _buildExecutiveList() {
    return Obx(() {
      if (controller.filteredExecutives.isEmpty) {
        return Center(
          child: Padding(
            padding: ResponsiveHelper.padding(40),
            child: Text(
              'No executives found',
              style: AppStyle.bodyRegularPoppinsGrey.responsive.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(14),
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredExecutives.length,
        itemBuilder: (context, index) {
          return _buildExecutiveCard(index);
        },
      );
    });
  }

  Widget _buildExecutiveCard(int index) {
    final executive = controller.filteredExecutives[index];
    final isSelected = executive.isSelected;
    final borderColor = isSelected
        ? AppColors.primary
        : AppColors.lightGrey.withOpacity(0.3);

    return InkWell(
      onTap: () => controller.toggleSelect(executive.id),
      borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(12)),
        padding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
          border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: ResponsiveHelper.spacing(24),
              backgroundColor: AppColors.lightGrey.withOpacity(0.3),
              child: Text(
                executive.name.isNotEmpty
                    ? executive.name[0].toUpperCase()
                    : 'E',
                style: AppStyle.bodyBoldPoppinsBlack.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(18),
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    executive.name,
                    style: AppStyle.headingSmallPoppinsBlack.responsive
                        .copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(4)),
                  Row(
                    children: [
                      SizedBox(
                        width: ResponsiveHelper.spacing(100),
                        child: Text(
                          'Mobile Number',
                          style: AppStyle.bodySmallPoppinsGrey.responsive
                              .copyWith(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(12),
                              ),
                        ),
                      ),
                      Text(
                        ' : ',
                        style: AppStyle.bodySmallPoppinsGrey.responsive
                            .copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                12,
                              ),
                            ),
                      ),
                      Expanded(
                        child: Text(
                          executive.mobile,
                          style: AppStyle.bodySmallPoppinsGrey.responsive
                              .copyWith(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(12),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(2)),
                  Row(
                    children: [
                      SizedBox(
                        width: ResponsiveHelper.spacing(100),
                        child: Text(
                          'Designation',
                          style: AppStyle.bodySmallPoppinsGrey.responsive
                              .copyWith(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(12),
                              ),
                        ),
                      ),
                      Text(
                        ' : ',
                        style: AppStyle.bodySmallPoppinsGrey.responsive
                            .copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                12,
                              ),
                            ),
                      ),
                      Expanded(
                        child: Text(
                          executive.designation,
                          style: AppStyle.bodySmallPoppinsGrey.responsive
                              .copyWith(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(12),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
              color: isSelected ? AppColors.primary : AppColors.grey,
              size: ResponsiveHelper.spacing(20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final selectedCount = controller.filteredExecutives
            .where((e) => e.isSelected)
            .length;
        return ElevatedButton(
          onPressed: selectedCount > 0
              ? () => _showConfirmDialog(selectedCount)
              : null,
          style: AppButtonStyles.elevatedLargeBlack(),
          child: Text(
            'Assign Executive',
            style: AppStyle.buttonTextPoppinsWhite.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(16),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
    );
  }

  void _showConfirmDialog(int selectedCount) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(16)),
        ),
        child: Container(
          padding: ResponsiveHelper.paddingSymmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppImages.thanks,
                width: ResponsiveHelper.spacing(80),
                height: ResponsiveHelper.spacing(80),
              ),
              SizedBox(height: ResponsiveHelper.spacing(16)),
              Text(
                'Confirm Assignment',
                style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(18),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.spacing(8)),
              Text(
                selectedCount > 1
                    ? 'Do you want to assign these $selectedCount executives to the task?'
                    : 'Do you want to assign this executive to the task?',
                style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.spacing(24)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: AppButtonStyles.outlinedMediumBlack(),
                      child: Text(
                        'Cancel',
                        style: AppStyle.buttonTextSmallPoppinsBlack.responsive
                            .copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                14,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.assignExecutives();
                      },
                      style: AppButtonStyles.elevatedMediumBlack(),
                      child: Text(
                        'Yes',
                        style: AppStyle.buttonTextSmallPoppinsWhite.responsive
                            .copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                14,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
