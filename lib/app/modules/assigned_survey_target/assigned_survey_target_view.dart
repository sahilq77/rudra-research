// lib/app/modules/assigned_survey_target/assigned_survey_target_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../common/custominputformatters/number_input_formatter.dart';
import '../../common/custominputformatters/securetext_input_formatter.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/app_button_style.dart';
import '../../widgets/app_style.dart';
import 'assigned_survey_target_controller.dart';

class AssignedSurveyTargetView extends StatefulWidget {
  const AssignedSurveyTargetView({super.key});

  @override
  State<AssignedSurveyTargetView> createState() =>
      _AssignedSurveyTargetViewState();
}

class _AssignedSurveyTargetViewState extends State<AssignedSurveyTargetView> {
  final AssignedSurveyTargetController controller = Get.find();

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
        'Assigned Survey Target',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.add, color: AppColors.defaultBlack),
          onSelected: (value) {
            if (value == 'assign') {
              Get.toNamed(AppRoutes.assignExecutive);
            } else {
              Get.toNamed(AppRoutes.addExecutive);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'assign',
              child: Text('Assign Executive'),
            ),
            const PopupMenuItem(value: 'add', child: Text('Add Executive')),
          ],
        ),
      ],
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
          _buildSummaryCards(),
          SizedBox(height: ResponsiveHelper.spacing(20)),
          _buildExecutorList(),
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
        onChanged: controller.searchExecutors,
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

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: ResponsiveHelper.paddingSymmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    '${controller.surveyTarget.value}',
                    style: AppStyle.heading2PoppinsBlack.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(25),
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                Text(
                  'Survey Target',
                  style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(12),
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(12)),
        Expanded(
          child: Container(
            padding: ResponsiveHelper.paddingSymmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    '${controller.surveyCompleted.value}',
                    style: AppStyle.heading2PoppinsBlack.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(25),
                      fontWeight: FontWeight.w700,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                Text(
                  'Survey Completed',
                  style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(12),
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExecutorList() {
    return Obx(() {
      if (controller.filteredExecutorList.isEmpty) {
        return Center(
          child: Padding(
            padding: ResponsiveHelper.padding(40),
            child: Text(
              'No executors found',
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
        itemCount: controller.filteredExecutorList.length,
        itemBuilder: (context, index) {
          return _buildExecutorCard(index);
        },
      );
    });
  }

  Widget _buildExecutorCard(int index) {
    final executor = controller.filteredExecutorList[index];
    final countController = TextEditingController(
      text: '${executor.currentCount}',
    );

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(12)),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: ResponsiveHelper.paddingSymmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: ResponsiveHelper.spacing(20),
                  backgroundColor: AppColors.lightGrey.withOpacity(0.3),
                  child: Text(
                    executor.executorName.isNotEmpty
                        ? executor.executorName[0].toUpperCase()
                        : 'E',
                    style: AppStyle.bodyBoldPoppinsBlack.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.spacing(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        executor.executorName,
                        style: AppStyle.bodyBoldPoppinsBlack.responsive
                            .copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                15,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(2)),
                      Text(
                        'Status : ${executor.isAssigned ? "Assigned" : "Not Assign"}',
                        style: AppStyle.bodySmallPoppinsPrimary.responsive
                            .copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                11,
                              ),
                              color: executor.isAssigned
                                  ? Colors.green
                                  : AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: ResponsiveHelper.spacing(30),
                  height: ResponsiveHelper.spacing(30),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.defaultBlack,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.phone,
                      color: AppColors.white,
                      size: ResponsiveHelper.spacing(20),
                    ),
                    onPressed: () => controller.makeCall(executor.id),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          Container(
            padding: ResponsiveHelper.paddingSymmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                _buildTargetInfo(
                  'Today Completed Target',
                  executor.todayCompletedTarget,
                ),
                SizedBox(height: ResponsiveHelper.spacing(5)),
                _buildTargetInfo(
                  'Total Assigned Target',
                  executor.totalAssignedTarget,
                ),
                SizedBox(height: ResponsiveHelper.spacing(5)),
                _buildTargetInfo(
                  'Total Completed Target',
                  executor.totalAssignedTarget,
                ),
                SizedBox(height: ResponsiveHelper.spacing(5)),
                _buildCounterRow(index, countController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetInfo(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(12),
            color: AppColors.grey,
          ),
        ),
        Text(
          value.toString().padLeft(2, '0'),
          style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(12),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCounterRow(int index, TextEditingController countController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildCounterButton(
          icon: Icons.remove,
          onPressed: () => controller.decrementCount(index),
          color: AppColors.grey,
        ),
        SizedBox(width: ResponsiveHelper.spacing(16)),
        SizedBox(
          width: ResponsiveHelper.spacing(60),
          child: TextFormField(
            controller: countController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              NumberInputFormatter(),
            ],
            onChanged: (value) {
              final count = int.tryParse(value) ?? 0;
              controller.updateCount(index, count);
            },
            decoration: InputDecoration(
              contentPadding: ResponsiveHelper.paddingSymmetric(
                horizontal: 8,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.spacing(8),
                ),
                borderSide: BorderSide(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.spacing(8),
                ),
                borderSide: BorderSide(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.spacing(8),
                ),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(16)),
        _buildCounterButton(
          icon: Icons.add,
          onPressed: () => controller.incrementCount(index),
          color: AppColors.defaultBlack,
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: ResponsiveHelper.spacing(25),
      height: ResponsiveHelper.spacing(25),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(6)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          color: AppColors.white,
          size: ResponsiveHelper.spacing(18),
        ),
        onPressed: onPressed,
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
      child: ElevatedButton(
        onPressed: () => _showConfirmDialog(),
        style: AppButtonStyles.elevatedLargeBlack(),
        child: Text(
          'Assign Target',
          style: AppStyle.buttonTextPoppinsWhite.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(16),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog() {
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
                fit: BoxFit.contain,
              ),
              SizedBox(height: ResponsiveHelper.spacing(16)),
              Text(
                'Confirm Your Request',
                style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(18),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.spacing(8)),
              Text(
                'Are you sure you want to assign\ntarget',
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
                        'No',
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
                        controller.assignTarget();
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
