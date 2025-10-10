import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rudra/app/modules/executive_module/executive_home/executive_home_view.dart';
import 'package:rudra/app/modules/manager_module/survey_detail_multiple/survey_details_multiple_view.dart';
import 'app/routes/app_routes.dart';
import 'app/utils/app_colors.dart';
import 'app/utils/app_utility.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppUtility.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.white,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.white,
          primary: AppColors.primary,
        ),
        appBarTheme: AppBarTheme(
          scrolledUnderElevation: 0.0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.defaultBlack,
          iconTheme: const IconThemeData(color: AppColors.defaultBlack),
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          bodyMedium: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.defaultBlack,
          ),
          headlineSmall: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.defaultBlack,
          ),
          bodyLarge: GoogleFonts.poppins(color: AppColors.defaultBlack),
          bodySmall: GoogleFonts.poppins(color: AppColors.defaultBlack),
          headlineLarge: GoogleFonts.poppins(color: AppColors.defaultBlack),
          headlineMedium: GoogleFonts.poppins(color: AppColors.defaultBlack),
          titleLarge: GoogleFonts.poppins(color: AppColors.defaultBlack),
          titleMedium: GoogleFonts.poppins(color: AppColors.defaultBlack),
          titleSmall: GoogleFonts.poppins(color: AppColors.defaultBlack),
          labelLarge: GoogleFonts.poppins(color: AppColors.defaultBlack),
          labelMedium: GoogleFonts.poppins(color: AppColors.defaultBlack),
          labelSmall: GoogleFonts.poppins(color: AppColors.defaultBlack),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.grey),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.red),
          ),
          prefixIconColor: AppColors.primary,
          labelStyle: GoogleFonts.poppins(color: AppColors.grey),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: const BorderSide(color: Colors.black, width: 1.0),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: AppColors.grey.withOpacity(0.5)),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
      ),

      initialRoute: AppRoutes.validatorProfileDetail,
      getPages: AppRoutes.routes,
      builder: (context, child) {
        return ColorfulSafeArea(
          color: AppColors.primary,
          top: true,
          bottom: true,
          left: false,
          right: false,
          child: child ?? Container(),
        );
      },
    );
  }
}
