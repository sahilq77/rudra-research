import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/my_survey/my_surevy_model.dart';
import 'package:rudra/app/modules/manager_module/myreport/my_report_list_controller.dart';
import 'package:rudra/app/routes/app_routes.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_controller.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_view.dart'
    show CustomBottomBar;

import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import '../../../widgets/custom_shimmer_card.dart';

class MyReportListView extends StatefulWidget {
  const MyReportListView({super.key});

  @override
  State<MyReportListView> createState() => _MyReportListViewState();
}

class _MyReportListViewState extends State<MyReportListView> {
  final MyReportListController controller = Get.put(MyReportListController());
  final BottomNavigationController bottomController = Get.put(
    BottomNavigationController(),
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
        controller.fetchMySurveys(
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

    return WillPopScope(
      onWillPop: () => bottomController.onWillPop(),
      child: Scaffold(
        appBar: _buildAppbar(),
        body: Column(
          children: [
            Padding(
              padding: ResponsiveHelper.paddingSymmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: _buildSearchField(controller),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.mySurveyList.isEmpty) {
                    return ListView.builder(
                      padding:
                          ResponsiveHelper.paddingSymmetric(horizontal: 16),
                      itemCount: 5,
                      itemBuilder: (_, __) => const CustomShimmerCard(),
                    );
                  }

                  if (controller.filteredSurveyList.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: Center(
                          child: Text(
                            'No surveys found',
                            style: AppStyle.bodyRegularPoppinsGrey.responsive
                                .copyWith(
                              fontSize:
                                  ResponsiveHelper.getResponsiveFontSize(14),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding:
                          ResponsiveHelper.paddingSymmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ...controller.filteredSurveyList.map((survey) {
                            return _buildSurveyCard(survey, controller);
                          }),
                          if (controller.isLoadingMore.value)
                            Padding(
                              padding:
                                  EdgeInsets.all(ResponsiveHelper.spacing(16)),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          if (!controller.hasMoreData.value &&
                              controller.hasPaginated.value &&
                              controller.filteredSurveyList.isNotEmpty)
                            Padding(
                              padding:
                                  EdgeInsets.all(ResponsiveHelper.spacing(16)),
                              child: Text(
                                'No more surveys to load',
                                style: AppStyle.bodySmallPoppinsGrey.responsive
                                    .copyWith(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          12),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // UI helpers
  // -----------------------------------------------------------------------
  Widget _buildSearchField(MyReportListController controller) {
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
    MySurveyModel survey,
    MyReportListController controller,
  ) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.myreportform,
        arguments: {'survey_id': survey.surveyId},
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title + subtitle
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    survey.title,
                    style: AppStyle.reportCardTitle.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(5)),
                  Text(
                    survey.subtitle,
                    style: AppStyle.reportCardSubTitle.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                    ),
                  ),
                ],
              ),
            ),
            // Footer
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
                        'Survey ID',
                        style: AppStyle.reportCardRowTitle.responsive.copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                        ),
                      ),
                      Text(
                        survey.surveyId,
                        style: AppStyle.reportCardRowCount.responsive.copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Response',
                        style: AppStyle.reportCardRowTitle.responsive.copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                        ),
                      ),
                      Text(
                        survey.responseCount,
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
        'My Report',
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

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
