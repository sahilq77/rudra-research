import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/custominputformatters/securetext_input_formatter.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';
import 'validator_submit_remark_controller.dart';

class ValidatorSubmitRemarkView extends StatefulWidget {
  const ValidatorSubmitRemarkView({super.key});

  @override
  State<ValidatorSubmitRemarkView> createState() =>
      _ValidatorSubmitRemarkViewState();
}

class _ValidatorSubmitRemarkViewState extends State<ValidatorSubmitRemarkView> {
  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    final controller = Get.find<ValidatorSubmitRemarkController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.defaultBlack),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Submit Remark',
          style: AppStyle.heading1PoppinsBlack.responsive,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: ResponsiveHelper.paddingSymmetric(
            horizontal: 16,
            vertical: 20,
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please Enter Details',
                  style: AppStyle.headingSmallPoppinsBlack.responsive,
                ),
                SizedBox(height: ResponsiveHelper.spacing(20)),
                Text(
                  'Remark (Optional)',
                  style: AppStyle.labelPrimaryPoppinsBlack.responsive,
                ),
                SizedBox(height: ResponsiveHelper.spacing(8)),
                TextFormField(
                  controller: controller.remarkController,
                  maxLines: 5,
                  inputFormatters: [SecureTextInputFormatter.deny()],
                  decoration: InputDecoration(
                    hintText: 'Enter Remark (Optional)',
                    hintStyle: AppStyle.bodySmallPoppinsGrey.responsive,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.spacing(12),
                      vertical: ResponsiveHelper.spacing(12),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(20)),
                Text(
                  'Select Report',
                  style: AppStyle.labelPrimaryPoppinsBlack.responsive,
                ),
                SizedBox(height: ResponsiveHelper.spacing(8)),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedReport.value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.spacing(12),
                        vertical: ResponsiveHelper.spacing(12),
                      ),
                    ),
                    items: controller.reports.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: AppStyle.bodyRegularPoppinsBlack.responsive,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedReport.value = newValue;
                      }
                    },
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(40)),
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submitFeedback,
                    style: AppButtonStyles.elevatedLargeBlack(),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Submit Feedback',
                            style: AppStyle.buttonTextPoppinsWhite.responsive,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
