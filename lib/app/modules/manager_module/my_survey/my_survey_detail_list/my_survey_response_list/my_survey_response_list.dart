import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rudra/app/data/models/my_survey/my_surevy_model.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_detail_list/my_survey_response_list/my_survey_response_controller.dart';
import 'package:rudra/app/routes/app_routes.dart';
import 'package:rudra/app/utils/app_colors.dart';
import 'package:rudra/app/utils/responsive_utils.dart';
import 'package:rudra/app/widgets/app_style.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_controller.dart';
import 'package:shimmer/shimmer.dart';

class MySurveyResponseList extends StatelessWidget {
  const MySurveyResponseList({super.key});

  @override
  Widget build(BuildContext context) {
    // ---- Bind the correct controller ------------------------------------------------
    final MySurveyResponseController controller = Get.put(
      MySurveyResponseController(),
    );

    // Bottom navigation is optional – keep if you need it elsewhere
    Get.put(BottomNavigationController());

    ResponsiveHelper.init(context);

    return Scaffold(
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Column(
          children: [
            // ---- Search -------------------------------------------------
            Padding(
              padding: ResponsiveHelper.paddingSymmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: _buildSearchField(controller),
            ),

            // ---- List ---------------------------------------------------
            Expanded(
              child: Obx(() {
                // Loading (first page)
                if (controller.isLoading.value &&
                    controller.mySurveyList.isEmpty) {
                  return _buildShimmerEffect();
                }

                // Empty state
                if (controller.filteredSurveyList.isEmpty) {
                  return const Center(child: Text('No surveys found'));
                }

                return ListView.builder(
                  padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
                  itemCount:
                      controller.filteredSurveyList.length +
                      (controller.hasMoreData.value ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    // ---- Load-more placeholder (currently never shown) ----
                    if (i == controller.filteredSurveyList.length) {
                      controller.loadMoreIfNeeded(i);
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final survey = controller.filteredSurveyList[i];
                    return _buildSurveyCard(survey, controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // UI helpers
  // -------------------------------------------------------------------------
  Widget _buildSearchField(MySurveyResponseController controller) {
    return TextFormField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search....',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSurveyCard(
    MySurveyResponseModel survey,
    MySurveyResponseController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ---- Title + subtitle -------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  survey.subtitle,
                  style: AppStyle.reportCardTitle.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                  ),
                ),
              ],
            ),
          ),

          // ---- Footer -----------------------------------------------------------
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Name',
                      style: AppStyle.reportCardRowTitle.responsive.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                      ),
                    ),
                    Text(
                      survey.title,
                      style: AppStyle.reportCardRowCount.responsive.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Submitted At',
                      style: AppStyle.reportCardRowTitle.responsive.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                      ),
                    ),
                    Text(
                      controller.formatDateTime(survey.submittedAt),
                      style: AppStyle.reportCardRowCount.responsive.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Shimmer
  // -------------------------------------------------------------------------
  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (_, __) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 100, height: 16, color: Colors.white),
                      Container(width: 50, height: 16, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 100, height: 16, color: Colors.white),
                      Container(width: 50, height: 16, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'My Survey',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }
}
