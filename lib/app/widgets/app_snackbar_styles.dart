// lib/app/widgets/app_snackbar_styles.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import 'app_style.dart';

class AppSnackbarStyles {
  static const Duration _durationMedium = Duration(seconds: 3);

  static const double _radiusMedium = 8.0;

  // Snackbar Margins (added top margin for spacing from SafeArea)
  static const EdgeInsets _margin =
      EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8);

  // Snackbar Padding (reduced for smaller size)
  static const EdgeInsets _padding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);

  // ============ SUCCESS SNACKBAR ============

  static void showSuccess({
    required String title,
    required String message,
    Duration? duration,
    double? borderRadius,
  }) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.lightGreen,
      duration: duration ?? _durationMedium,
      margin: _margin,
      padding: EdgeInsets.zero,
      borderRadius: borderRadius ?? _radiusMedium,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      titleText: const SizedBox.shrink(),
      messageText: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.darkGreen,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$title : ',
                      style: AppStyle.headingSmallPoppinsBlack.copyWith(
                        color: AppColors.darkGreen,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: message,
                      style: AppStyle.bodySmallPoppinsBlack.copyWith(
                        color: AppColors.darkGreen,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ ERROR SNACKBAR ============

  static void showError({
    required String title,
    required String message,
    Duration? duration,
    double? borderRadius,
  }) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.lightRed,
      duration: duration ?? _durationMedium,
      margin: _margin,
      padding: EdgeInsets.zero,
      borderRadius: borderRadius ?? _radiusMedium,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      titleText: const SizedBox.shrink(),
      messageText: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$title : ',
                      style: AppStyle.headingSmallPoppinsBlack.copyWith(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: message,
                      style: AppStyle.bodySmallPoppinsBlack.copyWith(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ WARNING SNACKBAR ============

  static void showWarning({
    required String title,
    required String message,
    Duration? duration,
    double? borderRadius,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.shade600,
      colorText: AppColors.white,
      duration: duration ?? _durationMedium,
      margin: _margin,
      padding: _padding,
      borderRadius: borderRadius ?? _radiusMedium,
      icon: const Icon(
        Icons.warning_rounded,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      titleText: Text(
        title,
        style: AppStyle.heading1PoppinsWhite,
      ),
      messageText: Text(
        message,
        style: AppStyle.subheading1PoppinsWhite,
      ),
    );
  }

  // ============ INFO SNACKBAR ============

  static void showInfo({
    required String title,
    required String message,
    Duration? duration,
    double? borderRadius,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade600,
      colorText: AppColors.white,
      duration: duration ?? _durationMedium,
      margin: _margin,
      padding: _padding,
      borderRadius: borderRadius ?? _radiusMedium,
      icon: const Icon(
        Icons.info_rounded,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      titleText: Text(
        title,
        style: AppStyle.heading1PoppinsWhite,
      ),
      messageText: Text(
        message,
        style: AppStyle.subheading1PoppinsWhite,
      ),
    );
  }

  // ============ PRIMARY SNACKBAR ============

  static void showPrimary({
    required String title,
    required String message,
    Duration? duration,
    double? borderRadius,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: AppColors.white,
      duration: duration ?? _durationMedium,
      margin: _margin,
      padding: _padding,
      borderRadius: borderRadius ?? _radiusMedium,
      icon: const Icon(
        Icons.notifications_rounded,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      titleText: Text(
        title,
        style: AppStyle.heading1PoppinsWhite,
      ),
      messageText: Text(
        message,
        style: AppStyle.subheading1PoppinsWhite,
      ),
    );
  }

  // ============ DARK SNACKBAR ============

  static void showDark({
    required String title,
    required String message,
    Duration? duration,
    double? borderRadius,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.defaultBlack,
      colorText: AppColors.white,
      duration: duration ?? _durationMedium,
      margin: _margin,
      padding: _padding,
      borderRadius: borderRadius ?? _radiusMedium,
      icon: const Icon(
        Icons.notifications_rounded,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      titleText: Text(
        title,
        style: AppStyle.heading1PoppinsWhite,
      ),
      messageText: Text(
        message,
        style: AppStyle.subheading1PoppinsWhite,
      ),
    );
  }

  // ============ CUSTOM SNACKBAR ============

  static void showCustom({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
    double? borderRadius,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor ?? AppColors.primary,
      colorText: textColor ?? AppColors.white,
      duration: duration ?? _durationMedium,
      margin: _margin,
      padding: _padding,
      borderRadius: borderRadius ?? _radiusMedium,
      icon: icon != null
          ? Icon(
              icon,
              color: textColor ?? Colors.white,
              size: 28,
            )
          : null,
      shouldIconPulse: true,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      titleText: Text(
        title,
        style: titleStyle ??
            (textColor == AppColors.defaultBlack
                ? AppStyle.heading1PoppinsBlack
                : textColor == AppColors.primary
                    ? AppStyle.heading1PoppinsPrimary
                    : AppStyle.heading1PoppinsWhite),
      ),
      messageText: Text(
        message,
        style: messageStyle ??
            (textColor == AppColors.defaultBlack
                ? AppStyle.subheading1PoppinsBlack
                : textColor == AppColors.primary
                    ? AppStyle.subheading1PoppinsPrimary
                    : AppStyle.subheading1PoppinsWhite),
      ),
    );
  }
}
