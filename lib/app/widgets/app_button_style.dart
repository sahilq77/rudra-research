// lib/app/widgets/app_button_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

class AppButtonStyles {
  // Button Heights
  static const double _heightLarge = 48.0;
  static const double _heightMedium = 40.0;
  static const double _heightSmall = 36.0;
  static const double _heightExtraSmall = 32.0;

  // Button Border Radius
  static const double _radiusLarge = 8.0;
  static const double _radiusMedium = 8.0;
  static const double _radiusSmall = 6.0;
  static const double _radiusExtraSmall = 4.0;

  // ============ ELEVATED BUTTON STYLES ============

  // Large Elevated Button (Primary)
  static ButtonStyle elevatedLargePrimary() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, _heightLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusLarge),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  // Large Elevated Button (Black)
  static ButtonStyle elevatedLargeBlack() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.defaultBlack,
      foregroundColor: AppColors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, _heightLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusLarge),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  // Medium Elevated Button (Primary)
  static ButtonStyle elevatedMediumPrimary() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, _heightMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusMedium),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  // Medium Elevated Button (Black)
  static ButtonStyle elevatedMediumBlack() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.defaultBlack,
      foregroundColor: AppColors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, _heightMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusMedium),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  // Small Elevated Button (Primary)
  static ButtonStyle elevatedSmallPrimary() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, _heightSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusSmall),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Small Elevated Button (Black)
  static ButtonStyle elevatedSmallBlack() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.defaultBlack,
      foregroundColor: AppColors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, _heightSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusSmall),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Extra Small Elevated Button (Primary)
  static ButtonStyle elevatedExtraSmallPrimary() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, _heightExtraSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusExtraSmall),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  // Extra Small Elevated Button (Black)
  static ButtonStyle elevatedExtraSmallBlack() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.defaultBlack,
      foregroundColor: AppColors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, _heightExtraSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusExtraSmall),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  // ============ OUTLINED BUTTON STYLES ============

  // Large Outlined Button (Primary)
  static ButtonStyle outlinedLargePrimary() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      minimumSize: const Size(double.infinity, _heightLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusLarge),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  // Large Outlined Button (Black)
  static ButtonStyle outlinedLargeBlack() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.defaultBlack,
      side: const BorderSide(color: AppColors.defaultBlack, width: 1.5),
      minimumSize: const Size(double.infinity, _heightLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusLarge),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  // Medium Outlined Button (Primary)
  static ButtonStyle outlinedMediumPrimary() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      minimumSize: const Size(double.infinity, _heightMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusMedium),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  // Medium Outlined Button (Black)
  static ButtonStyle outlinedMediumBlack() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.defaultBlack,
      side: const BorderSide(color: AppColors.defaultBlack, width: 1.5),
      minimumSize: const Size(double.infinity, _heightMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusMedium),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  // Small Outlined Button (Primary)
  static ButtonStyle outlinedSmallPrimary() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1),
      minimumSize: const Size(double.infinity, _heightSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusSmall),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Small Outlined Button (Black)
  static ButtonStyle outlinedSmallBlack() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.defaultBlack,
      side: const BorderSide(color: AppColors.defaultBlack, width: 1),
      minimumSize: const Size(double.infinity, _heightSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusSmall),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Extra Small Outlined Button (Primary)
  static ButtonStyle outlinedExtraSmallPrimary() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1),
      minimumSize: const Size(double.infinity, _heightExtraSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusExtraSmall),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  // Extra Small Outlined Button (Black)
  static ButtonStyle outlinedExtraSmallBlack() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.defaultBlack,
      side: const BorderSide(color: AppColors.defaultBlack, width: 1),
      minimumSize: const Size(double.infinity, _heightExtraSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusExtraSmall),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  // ============ TEXT BUTTON STYLES ============

  // Large Text Button (Primary)
  static ButtonStyle textLargePrimary() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size(double.infinity, _heightLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusLarge),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  // Large Text Button (Black)
  static ButtonStyle textLargeBlack() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.defaultBlack,
      minimumSize: const Size(double.infinity, _heightLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusLarge),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  // Medium Text Button (Primary)
  static ButtonStyle textMediumPrimary() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size(double.infinity, _heightMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusMedium),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  // Medium Text Button (Black)
  static ButtonStyle textMediumBlack() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.defaultBlack,
      minimumSize: const Size(double.infinity, _heightMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusMedium),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  // Small Text Button (Primary)
  static ButtonStyle textSmallPrimary() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size(double.infinity, _heightSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusSmall),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Small Text Button (Black)
  static ButtonStyle textSmallBlack() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.defaultBlack,
      minimumSize: const Size(double.infinity, _heightSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusSmall),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // ============ BUTTON TEXT STYLES ============

  // Large Button Text
  static TextStyle buttonTextLarge({Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: color ?? AppColors.white,
    );
  }

  // Medium Button Text
  static TextStyle buttonTextMedium({Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: color ?? AppColors.white,
    );
  }

  // Small Button Text
  static TextStyle buttonTextSmall({Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: color ?? AppColors.white,
    );
  }

  // Extra Small Button Text
  static TextStyle buttonTextExtraSmall({Color? color}) {
    return GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: color ?? AppColors.white,
    );
  }
}
