// lib/app/modules/add_executive/add_executive_view.dart
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../common/custominputformatters/number_input_formatter.dart';
import '../../common/custominputformatters/securetext_input_formatter.dart';
import '../../common/customvalidators/text_validator.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/app_button_style.dart';
import '../../widgets/app_style.dart';
import 'add_executive_controller.dart';

class AddExecutiveView extends StatefulWidget {
  const AddExecutiveView({super.key});

  @override
  State<AddExecutiveView> createState() => _AddExecutiveViewState();
}

class _AddExecutiveViewState extends State<AddExecutiveView> {
  final AddExecutiveController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: ResponsiveHelper.paddingSymmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please Enter Executive Details',
                  style: AppStyle.heading1PoppinsGrey.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(24)),
                _buildTextFormField(
                  controller: controller.firstNameController,
                  label: 'First Name',
                  validator: (value) => TextValidator.combineValidators(value, [
                    TextValidator.isEmpty,
                    TextValidator.isAlphabetic,
                  ]),
                  inputFormatters: [SecureTextInputFormatter.deny()],
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                _buildTextFormField(
                  controller: controller.lastNameController,
                  label: 'Last Name',
                  validator: (value) => TextValidator.combineValidators(value, [
                    TextValidator.isEmpty,
                    TextValidator.isAlphabetic,
                  ]),
                  inputFormatters: [SecureTextInputFormatter.deny()],
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                _buildTextFormField(
                  controller: controller.emailController,
                  label: 'Email',
                  validator: TextValidator.isEmail,
                  inputFormatters: [SecureTextInputFormatter.deny()],
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                _buildTextFormField(
                  controller: controller.mobileController,
                  label: 'Phone Number',
                  validator: TextValidator.isMobileNumber,
                  inputFormatters: [
                    NumberInputFormatter(),
                    SecureTextInputFormatter.deny(),
                  ],
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                _buildDateField(label: 'Date of Birth', isDob: true),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                _buildTextFormField(
                  controller: controller.addressController,
                  label: 'Address',
                  validator: TextValidator.isEmpty,
                  inputFormatters: [SecureTextInputFormatter.deny()],
                  keyboardType: TextInputType.streetAddress,
                  maxLines: 3,
                ),
                SizedBox(height: ResponsiveHelper.spacing(24)),
                Text(
                  'Other Details',
                  style: AppStyle.heading1PoppinsGrey.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                _buildImageUpload(),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                _buildDateField(label: 'Joining Date', isDob: false),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                _buildRoleDropdown(),
                SizedBox(height: ResponsiveHelper.spacing(32)),
              ],
            ),
          ),
        ),
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
        'Add Executive',
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(12),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
          borderSide: BorderSide(
            color: AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
          borderSide: BorderSide(
            color: AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
        fontSize: ResponsiveHelper.getResponsiveFontSize(14),
      ),
    );
  }

  Widget _buildDateField({required String label, required bool isDob}) {
    final controller = isDob
        ? this.controller.dobController
        : this.controller.joiningDateController;
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => this.controller.pickDate(isDob),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(12),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
          borderSide: BorderSide(
            color: AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
          borderSide: BorderSide(
            color: AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: AppColors.grey),
          onPressed: () => this.controller.pickDate(isDob),
        ),
      ),
      style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
        fontSize: ResponsiveHelper.getResponsiveFontSize(14),
      ),
    );
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Profile Image',
          style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(12),
          ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(8)),
        GestureDetector(
          onTap: controller.showImageSourceBottomSheet,
          child: Obx(
            () => Container(
              width: double.infinity,
              height: ResponsiveHelper.spacing(120),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.spacing(8),
                ),
              ),
              child: controller.selectedImage.value != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.spacing(8),
                      ),
                      child: Image.file(
                        controller.selectedImage.value!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: ResponsiveHelper.spacing(40),
                          color: AppColors.grey,
                        ),
                        SizedBox(height: ResponsiveHelper.spacing(8)),
                        Text(
                          'Upload Image',
                          style: AppStyle.bodyRegularPoppinsGrey.responsive
                              .copyWith(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(14),
                              ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Obx(
      () => DropdownSearch<int>(
        selectedItem: controller.selectedRole.value,
        items: List.generate(controller.roles.length, (index) => index),
        itemAsString: (item) => controller.roles[item],
        onChanged: (value) {
          controller.selectedRole.value = value ?? 0;
        },
        validator: (value) => value == null ? 'Please select a role' : null,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Role',
            labelStyle: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
              borderSide: BorderSide(
                color: AppColors.lightGrey.withOpacity(0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
              borderSide: BorderSide(
                color: AppColors.lightGrey.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: ResponsiveHelper.paddingSymmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: 'Search role',
              border: InputBorder.none,
            ),
          ),
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
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.addExecutive,
          style: AppButtonStyles.elevatedLargeBlack(),
          child: controller.isLoading.value
              ? SizedBox(
                  height: ResponsiveHelper.spacing(20),
                  width: ResponsiveHelper.spacing(20),
                  child: const CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Add Executive',
                  style: AppStyle.buttonTextPoppinsWhite.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
