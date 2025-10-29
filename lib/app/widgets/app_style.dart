import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

class AppStyle {
  // Common sizes: 16 and 18, range: 10 to 20
  static const double _fontSize10 = 10.0;
  static const double _fontSize12 = 12.0;
  static const double _fontSize13 = 13.0;
  static const double _fontSize14 = 14.0;
  static const double _fontSize16 = 16.0; // Common
  static const double _fontSize18 = 18.0; // Common
  static const double _fontSize20 = 20.0;

  // Heading Styles (Poppins - Black)
  static TextStyle get heading1PoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    color: AppColors.defaultBlack,
  );

  static TextStyle get heading2PoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.defaultBlack,
  );

  static TextStyle get headingSmallPoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    color: AppColors.defaultBlack,
  );

  // Heading Styles (Poppins - Primary)
  static TextStyle get heading1PoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get heading2PoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get headingSmallPoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // Heading Styles (Poppins - White)
  static TextStyle get heading1PoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle get heading2PoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle get headingSmallPoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  // Heading Styles (Poppins - Grey)
  static TextStyle get heading1PoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    color: AppColors.grey,
  );

  static TextStyle get heading2PoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.grey,
  );

  static TextStyle get headingSmallPoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    color: AppColors.grey,
  );

  // Subheading Styles (Poppins - Black)
  static TextStyle get subheading1PoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w400,
    color: AppColors.defaultBlack,
  );

  static TextStyle get subheading2PoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w400,
    color: AppColors.defaultBlack,
  );

  // Subheading Styles (Poppins - Primary)
  static TextStyle get subheading1PoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  static TextStyle get subheading2PoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  // Subheading Styles (Poppins - White)
  static TextStyle get subheading1PoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  static TextStyle get subheading2PoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  // Subheading Styles (Poppins - Grey)
  static TextStyle get subheading1PoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );

  static TextStyle get subheading2PoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );

  // Body Text Styles (Poppins - Black)
  static TextStyle get bodyRegularPoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w500,
    color: AppColors.defaultBlack,
  );

  static TextStyle get bodyBoldPoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.defaultBlack,
  );

  static TextStyle get bodySmallPoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w500,
    color: AppColors.defaultBlack,
  );

  // Body Text Styles (Poppins - Primary)
  static TextStyle get bodyRegularPoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  static TextStyle get bodyBoldPoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get bodySmallPoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  // Body Text Styles (Poppins - White)
  static TextStyle get bodyRegularPoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  static TextStyle get bodyBoldPoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle get bodySmallPoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  // Body Text Styles (Poppins - Grey)
  static TextStyle get bodyRegularPoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );

  static TextStyle get bodyBoldPoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.grey,
  );

  static TextStyle get bodySmallPoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );

  // Label/Field Styles (Poppins - Black)
  static TextStyle get labelPrimaryPoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    color: AppColors.defaultBlack,
  );

  static TextStyle get labelSecondaryPoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize10,
    fontWeight: FontWeight.w400,
    color: AppColors.defaultBlack,
  );

  // Label/Field Styles (Poppins - Primary)
  static TextStyle get labelPrimaryPoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get labelSecondaryPoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize10,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  // Label/Field Styles (Poppins - White)
  static TextStyle get labelPrimaryPoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle get labelSecondaryPoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize10,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  // Label/Field Styles (Poppins - Grey)
  static TextStyle get labelPrimaryPoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    color: AppColors.grey,
  );

  static TextStyle get labelSecondaryPoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize10,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );

  // Button Text Styles (Poppins - Black)
  static TextStyle get buttonTextPoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.defaultBlack,
  );

  static TextStyle get buttonTextSmallPoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    color: AppColors.defaultBlack,
  );

  // Button Text Styles (Poppins - Primary)
  static TextStyle get buttonTextPoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get buttonTextSmallPoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // Button Text Styles (Poppins - White)
  static TextStyle get buttonTextPoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle get buttonTextSmallPoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Button Text Styles (Poppins - Grey)
  static TextStyle get buttonTextPoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    color: AppColors.grey,
  );

  static TextStyle get buttonTextSmallPoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    color: AppColors.grey,
  );

  // Accent Styles (Poppins - Black)
  static TextStyle get accentPrimaryPoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize20,
    fontWeight: FontWeight.w600,
    color: AppColors.defaultBlack,
  );

  static TextStyle get accentSecondaryPoppinsBlack => GoogleFonts.poppins(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w500,
    color: AppColors.defaultBlack,
  );

  // Accent Styles (Poppins - Primary)
  static TextStyle get accentPrimaryPoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize20,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get accentSecondaryPoppinsPrimary => GoogleFonts.poppins(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // Accent Styles (Poppins - White)
  static TextStyle get accentPrimaryPoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize20,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle get accentSecondaryPoppinsWhite => GoogleFonts.poppins(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  // Accent Styles (Poppins - Grey)
  static TextStyle get accentPrimaryPoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize20,
    fontWeight: FontWeight.w600,
    color: AppColors.grey,
  );

  static TextStyle get accentSecondaryPoppinsGrey => GoogleFonts.poppins(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w500,
    color: AppColors.grey,
  );
  //Report card text style
  static TextStyle get reportCardTitle => GoogleFonts.inter(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    color: AppColors.defaultBlack,
  );
  static TextStyle get reportCardSubTitle => GoogleFonts.inter(
    fontSize: _fontSize13,
    fontWeight: FontWeight.w600,
    color: AppColors.grey,
  );
  static TextStyle get reportCardRowTitle => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );
  static TextStyle get reportCardRowCount => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    color: AppColors.defaultBlack,
  );

  //my team card text style
  static TextStyle get myTeamCardTitle => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w600,
    color: AppColors.defaultBlack,
  );
  static TextStyle get myTeamRowCount => GoogleFonts.poppins(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  //my team card text style
  static TextStyle get myteamCardRowTitle => GoogleFonts.inter(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w500,
    color: AppColors.grey,
  );
}
