// lib/app/modules/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/home/get_live_survey_response.dart';
import 'package:rudra/app/modules/executive_module/executive_home/executive_home_controller.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_view.dart';

import '../../../../bottom_navigation/bottom_navigation_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_snackbar_styles.dart';
import '../../../widgets/app_style.dart';

class ExecutiveHomeView extends StatefulWidget {
  const ExecutiveHomeView({super.key});

  @override
  State<ExecutiveHomeView> createState() => _ExecutiveHomeViewState();
}

class _ExecutiveHomeViewState extends State<ExecutiveHomeView> {
  final ExecutiveHomeController controller = Get.find();
  final BottomNavigationController bottomController = Get.put(
    BottomNavigationController(),
  );
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
  }

  void _loadMore() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (controller.hasMoreData.value &&
          !controller.isLoading.value &&
          !controller.isLoadingMore.value &&
          !_isLoadingMore) {
        _isLoadingMore = true;
        controller
            .fetchLiveSurveys(
          context: context,
          isPagination: true,
        )
            .then((_) {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return WillPopScope(
      onWillPop: () => bottomController.onWillPop(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Obx(() => _buildBody(context)),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.currentIndex.value != 0) {
      return const Center(child: Text('Coming Soon'));
    }
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          controller.refresSurveyhData();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: ResponsiveHelper.paddingSymmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              SizedBox(height: ResponsiveHelper.spacing(12)),
              Divider(
                color: AppColors.grey.withOpacity(0.5),
                // thickness: 2,
                height: 0,
              ),
              SizedBox(height: ResponsiveHelper.spacing(12)),
              // Show Dashboard Overview only for Manager and Executive
              if (!controller.isValidator) ...[
                ResponsiveHelper.safeText(
                  'Dashboard Overview',
                  style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(17),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                _buildDashboardGrid(),
                SizedBox(height: ResponsiveHelper.spacing(24)),
              ],
              _buildLiveSurveysHeader(),
              SizedBox(height: ResponsiveHelper.spacing(16)),
              _buildLiveSurveysList(),
              SizedBox(height: ResponsiveHelper.spacing(24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: ResponsiveHelper.spacing(44),
          height: ResponsiveHelper.spacing(44),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Image.asset(
              AppImages.appLogo,
              height: ResponsiveHelper.spacing(24),
              width: ResponsiveHelper.spacing(24),
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveHelper.safeText(
                controller.userName,
                style: AppStyle.bodyBoldPoppinsBlack.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
              ResponsiveHelper.safeText(
                controller.userRoleText,
                style: AppStyle.bodySmallPoppinsPrimary.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                  color: AppColors.primary,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(12)),
        Container(
          width: ResponsiveHelper.spacing(40),
          height: ResponsiveHelper.spacing(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
              AppImages.autoRefresh,
              width: ResponsiveHelper.spacing(20),
              height: ResponsiveHelper.spacing(20),
              fit: BoxFit.contain,
            ),
            onPressed: () async {
              await Future.delayed(const Duration(seconds: 1));
              //  controller.refreshData();
            },
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(8)),
        Obx(
          () => Stack(
            children: [
              Container(
                width: ResponsiveHelper.spacing(40),
                height: ResponsiveHelper.spacing(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  border: Border.all(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.cloud_upload_outlined,
                    size: ResponsiveHelper.spacing(20),
                    color: AppColors.defaultBlack,
                  ),
                  onPressed: () async {
                    await controller.fetchPendingSubmissionsCount();
                    if (controller.pendingSubmissionsCount.value > 0) {
                      AppSnackbarStyles.showInfo(
                        title: 'Pending Uploads',
                        message:
                            '${controller.pendingSubmissionsCount.value} survey(s) waiting to be uploaded',
                      );
                    } else {
                      AppSnackbarStyles.showSuccess(
                        title: 'All Synced',
                        message: 'No pending surveys to upload',
                      );
                    }
                  },
                ),
              ),
              if (controller.pendingSubmissionsCount.value > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveHelper.spacing(4)),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: ResponsiveHelper.spacing(18),
                      minHeight: ResponsiveHelper.spacing(18),
                    ),
                    child: Center(
                      child: Text(
                        controller.pendingSubmissionsCount.value > 99
                            ? '99+'
                            : controller.pendingSubmissionsCount.value
                                .toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(9),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(8)),
        Container(
          width: ResponsiveHelper.spacing(40),
          height: ResponsiveHelper.spacing(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
              AppImages.myNotification,
              width: ResponsiveHelper.spacing(20),
              height: ResponsiveHelper.spacing(20),
              fit: BoxFit.contain,
            ),
            onPressed: () {
              Get.toNamed(AppRoutes.executiveNotification);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid() {
    // Get stats based on role
    final stats = controller.dashboardStats;

    // If no stats to show (Validator), return empty container
    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.35,
        crossAxisSpacing: ResponsiveHelper.spacing(12),
        mainAxisSpacing: ResponsiveHelper.spacing(12),
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildDashboardCard(stat);
      },
    );
  }

  Widget _buildDashboardCard(Map<String, dynamic> stat) {
    return Container(
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: stat['color'],
        borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(16)),
        border: Border.all(
          color: stat['borderColor'],
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            ///  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ResponsiveHelper.safeText(
                  stat['value'],
                  style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
                    color: stat['textColor'],
                    fontSize: ResponsiveHelper.getResponsiveFontSize(20),
                    fontWeight: FontWeight.w600,
                    // height: 1.1,
                  ),
                  maxLines: 1,
                ),
              ),
              Container(
                width: ResponsiveHelper.spacing(50),
                height: ResponsiveHelper.spacing(50),
                decoration: BoxDecoration(
                  // color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.spacing(12),
                  ),
                ),
                padding: EdgeInsets.all(ResponsiveHelper.spacing(8)),
                child: Image.asset(stat['imagePath'], fit: BoxFit.contain),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(8)),
          ResponsiveHelper.safeText(
            stat['title'],
            style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
              color: stat['textColor'],
              fontSize: ResponsiveHelper.getResponsiveFontSize(12),
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSurveysHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ResponsiveHelper.safeText(
          'Live Surveys',
          style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(17),
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          width: ResponsiveHelper.spacing(32),
          height: ResponsiveHelper.spacing(32),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
              AppImages.autoRefresh,
              width: ResponsiveHelper.spacing(16),
              height: ResponsiveHelper.spacing(16),
              fit: BoxFit.contain,
            ),
            onPressed: () async {
              await Future.delayed(const Duration(seconds: 1));
              controller.refresSurveyhData();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveSurveysList() {
    return Obx(() {
      // Show empty state when no surveys and not loading
      if (controller.liveSurveysList.isEmpty && !controller.isLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.spacing(40),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppImages.onboarding1,
                  width: ResponsiveHelper.spacing(120),
                  height: ResponsiveHelper.spacing(120),
                ),
                SizedBox(height: ResponsiveHelper.spacing(16)),
                ResponsiveHelper.safeText(
                  'No Surveys Available',
                  style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(8)),
                ResponsiveHelper.safeText(
                  'There are no live surveys at the moment',
                  style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // Calculate item count: surveys + loading indicator + end message
      int itemCount = controller.liveSurveysList.length;
      if (controller.isLoadingMore.value) {
        itemCount += 1; // Add loading indicator
      } else if (!controller.hasMoreData.value &&
          controller.liveSurveysList.isNotEmpty) {
        itemCount += 1; // Add end message
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Show loading indicator while paginating
          if (index == controller.liveSurveysList.length &&
              controller.isLoadingMore.value) {
            return Padding(
              padding: EdgeInsets.all(ResponsiveHelper.spacing(16)),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          }

          // Show end of list message
          if (index == controller.liveSurveysList.length &&
              !controller.hasMoreData.value) {
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.spacing(16),
              ),
              child: Center(
                child: ResponsiveHelper.safeText(
                  'No more surveys to load',
                  style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                  ),
                ),
              ),
            );
          }

          final survey = controller.liveSurveysList[index];
          print(survey.surveyId);
          return _buildSurveyCard(survey, index);
        },
      );
    });
  }

  Widget _buildSurveyCard(LiveSurveyData survey, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(12)),
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveHelper.safeText(
                      survey.surveyTitle,
                      style: AppStyle.bodyBoldPoppinsBlack.responsive.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(4)),
                    ResponsiveHelper.safeText(
                      survey.districtName,
                      style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(12),
                        color: AppColors.grey,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              if (survey.isLive == "1") ...[
                SizedBox(width: ResponsiveHelper.spacing(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.spacing(10),
                    vertical: ResponsiveHelper.spacing(5),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E5),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.spacing(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: ResponsiveHelper.spacing(6),
                        height: ResponsiveHelper.spacing(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF4444),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(4)),
                      ResponsiveHelper.safeText(
                        'Live',
                        style: AppStyle.bodySmallPoppinsPrimary.responsive
                            .copyWith(
                          color: const Color(0xFFFF4444),
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            11,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          ElevatedButton(
            onPressed: () {
              Get.toNamed(
                AppRoutes.executiveSurveyDetail,
                arguments: {'survey_id': survey.surveyId},
              );
            },
            style: AppButtonStyles.elevatedLargeBlack(),
            child: Text(
              'Start Survey',
              style: AppStyle.buttonTextSmallPoppinsWhite.responsive.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
