import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../common/custominputformatters/number_input_formatter.dart';
import '../../../common/custominputformatters/securetext_input_formatter.dart';
import '../../../common/customvalidators/text_validator.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';
import 'survey_interviewer_controller.dart';

class SurveyInterviewerView extends StatefulWidget {
  const SurveyInterviewerView({super.key});

  @override
  State<SurveyInterviewerView> createState() => _SurveyInterviewerViewState();
}

class _SurveyInterviewerViewState extends State<SurveyInterviewerView> {
  final SurveyInterviewerController controller = Get.find();
final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
     return PopScope(
      canPop: false, // This disables back navigation
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Optional: Show a confirmation dialog if needed later
        debugPrint('Back navigation blocked');
      },
      child: Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back, color: AppColors.defaultBlack),
          //   onPressed: () => Get.back(),
          // ),
          title: Text(
            'Interviewer Information',
            style: AppStyle.heading1PoppinsBlack.responsive,
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
          surfaceTintColor: AppColors.white,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
          ),
        ),
        backgroundColor: AppColors.white,
        body: Obx(
          () => Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshPage,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: ResponsiveHelper.paddingSymmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Please Enter Details',
                            style: AppStyle.heading1PoppinsBlack.responsive,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            label: 'Name',
                            controller: controller.nameController,
                            validator: TextValidator.isEmpty,
                          ),
                          const SizedBox(height: 20),
                          _buildDropdownField(
                            label: 'Age',
                            selectedValueObs: controller.selectedAgeLabel,
                            items: controller.ageRanges,
                            onChanged: controller.setSelectedAge,
                            validator: TextValidator.isEmpty,
                          ),
                          const SizedBox(height: 20),
                          _buildDropdownField(
                            label: 'Gender',
                            selectedValueObs: controller.selectedGenderLabel,
                            items: controller.genders,
                            onChanged: controller.setSelectedGender,
                            validator: TextValidator.isEmpty,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Phone Number',
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              NumberInputFormatter(),
                              SecureTextInputFormatter.deny(),
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: TextValidator.isMobileNumber,
                          ),
                          const SizedBox(height: 20),
                          // --- CAST DROPDOWN (NOW BINDS NAME + ID) ---
                          _buildDropdownField(
                            label: 'Cast',
                            selectedValueObs: controller.selectedCast,
                            items: controller.getCastNames(),
                            onChanged: (value) {
                              controller.setSelectedCast(value);
                              debugPrint(
                                'Selected Cast: $value  →  ID: ${controller.selectedCastId.value}',
                              );
                            },
                            validator: TextValidator.isEmpty,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom Buttons
              Container(
                padding: ResponsiveHelper.paddingSymmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.discardSurvey,
                        style: AppButtonStyles.outlinedLargeBlack(),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Discard Survey',
                            style:
                                AppStyle.buttonTextSmallPoppinsBlack.responsive,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: // ──────────────────────────────────────────────────────────────
                          // REPLACE ONLY THE ElevatedButton's onPressed (inside bottom buttons)
                          // ──────────────────────────────────────────────────────────────
                          ElevatedButton(
                            onPressed: () async {
                              // Validate form
                              if (!(formKey.currentState?.validate() ??
                                  false))
                                return;
      
                              // Call API
                              final result = await controller.setSurvey(
                                context: context,
                                formKey: formKey
                              );
      
                              // If success, show dialog
                              // if (result != null) {
                              //   _showSuccessDialog(context);
                              // }
                            },
                            style: AppButtonStyles.elevatedLargeBlack(),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Submit Survey',
                                style: AppStyle
                                    .buttonTextSmallPoppinsWhite
                                    .responsive,
                                maxLines: 1,
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  

  // Updated to use RxString
  Widget _buildDropdownField({
    required String label,
    required RxString selectedValueObs,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.labelPrimaryPoppinsBlack.responsive),
        const SizedBox(height: 10),
        Obx(
          () => DropdownSearch<String>(
            selectedItem: selectedValueObs.value.isEmpty
                ? null
                : selectedValueObs.value,
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
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.labelPrimaryPoppinsBlack.responsive),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters ?? [SecureTextInputFormatter.deny()],
          validator: validator,
          style: AppStyle.bodySmallPoppinsBlack.responsive,
          decoration: InputDecoration(
            hintText: 'Enter $label',
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
      ],
    );
  }
}
