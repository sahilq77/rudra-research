// Updated lib/app/modules/login/login_view.dart
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../common/custominputformatters/number_input_formatter.dart';
import '../../common/custominputformatters/securetext_input_formatter.dart';
import '../../common/customvalidators/text_validator.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/app_style.dart';
import 'login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: ResponsiveHelper.paddingSymmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: ResponsiveHelper.spacing(60)),
                Image.asset(
                  AppImages.appLogo,
                  height: ResponsiveHelper.spacing(80),
                  width: ResponsiveHelper.spacing(80),
                ),
                SizedBox(height: ResponsiveHelper.spacing(40)),
                ResponsiveHelper.safeText(
                  'User Login',
                  style: AppStyle.heading2PoppinsBlack.responsive,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveHelper.spacing(48)),
                // Phone number field
                Align(
                  alignment: Alignment.centerLeft,
                  child: ResponsiveHelper.safeText(
                    'Enter your phone number',
                    style: AppStyle.bodyRegularPoppinsBlack.responsive,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                TextFormField(
                  key: controller.phoneFieldKey,
                  controller: controller.phoneController,
                  focusNode: controller.phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  validator: (value) => TextValidator.isMobileNumber(value),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(10),
                    NumberInputFormatter(),
                    SecureTextInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.phone,
                      color: AppColors.primary,
                      size: ResponsiveHelper.getResponsiveFontSize(20),
                    ),
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.spacing(12),
                      ),
                      borderSide: const BorderSide(color: AppColors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.spacing(12),
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: ResponsiveHelper.paddingSymmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(24)),
                // User type dropdown
                Align(
                  alignment: Alignment.centerLeft,
                  child: ResponsiveHelper.safeText(
                    'Select User*',
                    style: AppStyle.bodyRegularPoppinsBlack.responsive,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                Obx(
                  () => DropdownSearch<int>(
                    selectedItem: controller.selectedRole.value,
                    items: List.generate(
                      controller.userTypes.length,
                      (index) => index,
                    ),
                    itemAsString: (item) => controller.userTypes[item],
                    onChanged: (value) {
                      controller.selectedRole.value = value ?? 0;
                    },
                    validator: (value) =>
                        value == null ? 'Please select a user type' : null,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.spacing(12),
                          ),
                          borderSide: const BorderSide(color: AppColors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.spacing(12),
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: ResponsiveHelper.paddingSymmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search user type',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(48)),
                // Login button
                SizedBox(
                  height: ResponsiveHelper.spacing(50),
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              controller.login(
                                mobile: controller.phoneController.text,
                                password: "",
                                deviceToken: "",
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.spacing(12),
                          ),
                        ),
                        padding:
                            ResponsiveHelper.paddingSymmetric(vertical: 16),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: ResponsiveHelper.spacing(20),
                              width: ResponsiveHelper.spacing(20),
                              child: const CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : ResponsiveHelper.safeText(
                              'Login',
                              style: AppStyle.buttonTextPoppinsWhite.responsive,
                            ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.phoneFocusNode.dispose();
    super.dispose();
  }
}
