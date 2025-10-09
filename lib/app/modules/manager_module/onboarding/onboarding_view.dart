// lib\app\modules\onboarding\onboarding_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import 'onboarding_controller.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final OnboardingController controller = Get.find();
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: PageView.builder(
        controller: pageController,
        itemCount: 3,
        onPageChanged: (value) {
          controller.currentPage.value = value;
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              // Top section with image (white background)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).size.height * 0.45,
                child: Center(
                  child: SvgPicture.asset(
                    controller.onboardingImages[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Bottom dark card that overlaps the white section
              Positioned(
                left: ResponsiveHelper.spacing(16),
                right: ResponsiveHelper.spacing(16),
                bottom: ResponsiveHelper.spacing(40),
                top: MediaQuery.of(context).size.height * 0.4,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.spacing(24),
                    ),
                  ),
                  child: Padding(
                    padding: ResponsiveHelper.padding(24),
                    child: Column(
                      children: [
                        SizedBox(height: ResponsiveHelper.spacing(16)),
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: i == controller.currentPage.value
                                    ? ResponsiveHelper.spacing(20)
                                    : ResponsiveHelper.spacing(8),
                                height: ResponsiveHelper.spacing(4),
                                margin: EdgeInsets.symmetric(
                                    horizontal: ResponsiveHelper.spacing(4)),
                                decoration: BoxDecoration(
                                  color: i == controller.currentPage.value
                                      ? AppColors.primary
                                      : AppColors.grey,
                                  borderRadius: BorderRadius.circular(
                                      ResponsiveHelper.spacing(2)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.spacing(24)),
                        ResponsiveHelper.safeText(
                          controller.pageTitles[index],
                          style: AppStyle.headingSmallPoppinsWhite.responsive,
                          textAlign: TextAlign.center,
                        ),
                        ResponsiveHelper.safeText(
                          controller.pageMainTitles[index],
                          style: AppStyle.heading2PoppinsWhite.responsive,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: ResponsiveHelper.spacing(12)),
                        ResponsiveHelper.safeText(
                          controller.pageSubtitles[index],
                          style: AppStyle.bodySmallPoppinsGrey.responsive,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => controller.nextPage(pageController),
                          child: Container(
                            height: ResponsiveHelper.spacing(56),
                            width: ResponsiveHelper.spacing(56),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_forward,
                                color: AppColors.white,
                                size:
                                    ResponsiveHelper.getResponsiveFontSize(24),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.spacing(16)),
                        GestureDetector(
                          onTap: controller.skip,
                          child: ResponsiveHelper.safeText(
                            'Skip',
                            style:
                                AppStyle.buttonTextSmallPoppinsWhite.responsive,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.spacing(16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
