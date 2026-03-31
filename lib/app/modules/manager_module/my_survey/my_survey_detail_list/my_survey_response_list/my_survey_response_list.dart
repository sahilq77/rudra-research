import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_detail_list/my_survey_response_list/my_survey_response_controller.dart';
import 'package:rudra/app/utils/app_colors.dart';
import 'package:rudra/app/utils/responsive_utils.dart';
import 'package:rudra/app/widgets/app_style.dart';

import '../../../../../routes/app_routes.dart';
import '../../../../../widgets/custom_shimmer_card.dart';

class MySurveyResponseList extends StatefulWidget {
  const MySurveyResponseList({super.key});

  @override
  State<MySurveyResponseList> createState() => _MySurveyResponseListState();
}

class _MySurveyResponseListState extends State<MySurveyResponseList> {
  final MySurveyResponseController controller = Get.put(
    MySurveyResponseController(),
  );
  final ScrollController _scrollController = ScrollController();

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
          !controller.isLoadingMore.value) {
        controller.fetchMySurveyResponse(
          context: context,
          isPagination: true,
        );
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
                  return ListView.builder(
                    padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (_, __) => const CustomShimmerCard(),
                  );
                }

                // Searching
                if (controller.isSearching.value) {
                  return ListView.builder(
                    padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
                    itemCount: 3,
                    itemBuilder: (_, __) => const CustomShimmerCard(),
                  );
                }

                // Empty state
                if (controller.filteredSurveyList.isEmpty) {
                  return const Center(child: Text('No surveys found'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
                  itemCount: controller.filteredSurveyList.length +
                      (controller.isLoadingMore.value
                          ? 1
                          : (!controller.hasMoreData.value &&
                                  controller.hasPaginated.value
                              ? 1
                              : 0)),
                  itemBuilder: (ctx, i) {
                    if (i == controller.filteredSurveyList.length) {
                      if (controller.isLoadingMore.value) {
                        return Padding(
                          padding: EdgeInsets.all(ResponsiveHelper.spacing(16)),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      } else if (!controller.hasMoreData.value &&
                          controller.hasPaginated.value) {
                        return Padding(
                          padding: EdgeInsets.all(ResponsiveHelper.spacing(16)),
                          child: Center(
                            child: Text(
                              'No more items to load',
                              style: AppStyle.bodySmallPoppinsGrey.responsive,
                            ),
                          ),
                        );
                      }
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
    return Obx(
      () => TextFormField(
        controller: controller.searchController,
        onChanged: controller.searchSurveys,
        decoration: InputDecoration(
          hintText: 'Search....',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel, color: AppColors.grey),
                  onPressed: controller.clearSearch,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyCard(
    MySurveyResponseModel survey,
    MySurveyResponseController controller,
  ) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.surveyDetailsPreview,
          arguments: {
            'surveyId': survey.surveyId,
            'userId': controller.userId,
            'peopleDetailsId': survey.peopleDetailsId,
          },
        );
      },
      child: Card(
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
        'Response Search',
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
