import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:rudra/app/widgets/app_button_style.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import 'otp_controller.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> with CodeAutoFill {
  final OtpController controller = Get.find();

  @override
  void initState() {
    super.initState();
    listenForCode();
    SmsAutoFill().getAppSignature.then((signature) {
      AppLogger.d('App Signature: $signature');
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.focusNode.requestFocus();
    });
  }

  @override
  void codeUpdated() {
    controller.otpController.text = code ?? '';
  }

  @override
  void dispose() {
    cancel();
    unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: controller.formKey,
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
                  'Verify Your Code',
                  style: AppStyle.heading2PoppinsBlack.responsive,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                Text(
                  'Please enter the 6 digit security code we just sent you at ${controller.maskedPhone}',
                  style: AppStyle.bodyRegularPoppinsBlack.responsive,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                ),
                SizedBox(height: ResponsiveHelper.spacing(32)),
                Pinput(
                  length: 6,
                  controller: controller.otpController,
                  focusNode: controller.focusNode,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  defaultPinTheme: PinTheme(
                    width: ResponsiveHelper.spacing(45),
                    height: ResponsiveHelper.spacing(45),
                    textStyle: TextStyle(
                      fontSize: ResponsiveHelper.spacing(20),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xFFE0E0E0), width: 1.5),
                      borderRadius:
                          BorderRadius.circular(ResponsiveHelper.spacing(8)),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: ResponsiveHelper.spacing(45),
                    height: ResponsiveHelper.spacing(45),
                    textStyle: TextStyle(
                      fontSize: ResponsiveHelper.spacing(20),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius:
                          BorderRadius.circular(ResponsiveHelper.spacing(8)),
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: ResponsiveHelper.spacing(45),
                    height: ResponsiveHelper.spacing(45),
                    textStyle: TextStyle(
                      fontSize: ResponsiveHelper.spacing(20),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xFFE0E0E0), width: 1.5),
                      borderRadius:
                          BorderRadius.circular(ResponsiveHelper.spacing(8)),
                    ),
                  ),
                  errorPinTheme: PinTheme(
                    width: ResponsiveHelper.spacing(45),
                    height: ResponsiveHelper.spacing(45),
                    textStyle: TextStyle(
                      fontSize: ResponsiveHelper.spacing(20),
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.red, width: 1.5),
                      borderRadius:
                          BorderRadius.circular(ResponsiveHelper.spacing(8)),
                    ),
                  ),
                  onCompleted: (value) {
                    controller.verify();
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                SizedBox(height: ResponsiveHelper.spacing(40)),
                Obx(
                  () => SizedBox(
                    height: ResponsiveHelper.spacing(45),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : controller.verify,
                      style: AppButtonStyles.elevatedMediumPrimary(),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Verify Code',
                              style: AppStyle
                                  .buttonTextSmallPoppinsWhite.responsive,
                            ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(24)),
                // Countdown Timer and Resend
                Obx(() {
                  final canResend = controller.canResend.value;
                  final countdown = controller.countdown.value;

                  if (canResend) {
                    return GestureDetector(
                      onTap: controller.resend,
                      child: Text(
                        "Didn't receive the code? Resend",
                        style: AppStyle.bodyRegularPoppinsBlack.responsive,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                      ),
                    );
                  } else {
                    return Text(
                      "Didn't receive the code? Resend in ${countdown}s",
                      style: AppStyle.bodyRegularPoppinsBlack.responsive,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    );
                  }
                }),
                SizedBox(height: ResponsiveHelper.spacing(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
