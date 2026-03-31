import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/my_survey/my_surevy_model.dart';
import 'package:rudra/app/modules/executive_module/executive_my_survey/executive_my_survey_controller.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_view.dart';

import '../../../../bottom_navigation/bottom_navigation_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import '../../../widgets/custom_shimmer_card.dart';

class ExecutiveMySurveyView extends StatefulWidget {
  const ExecutiveMySurveyView({super.key});

  @override
  State<ExecutiveMySurveyView> createState() => _ExecutiveMySurveyViewState();
}

class _ExecutiveMySurveyViewState extends State<ExecutiveMySurveyView> {
  final ExecutiveMySurveyController controller = Get.put(
    ExecutiveMySurveyController(),
  );
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
      onWillPop: bottomController.onWillPop,
      child: Scaffold(
        appBar: _buildAppbar(),
        body: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: Column(
            children: [
              Padding(
                padding: ResponsiveHelper.paddingSymmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildSearchField(controller),
              ),
              Expanded(
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

                  if (controller.isSearching.value) {
                    return ListView.builder(
                      padding:
                          ResponsiveHelper.paddingSymmetric(horizontal: 16),
                      itemCount: 3,
                      itemBuilder: (_, __) => const CustomShimmerCard(),
                    );
                  }

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
                            padding:
                                EdgeInsets.all(ResponsiveHelper.spacing(16)),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        } else if (!controller.hasMoreData.value &&
                            controller.hasPaginated.value) {
                          return Padding(
                            padding:
                                EdgeInsets.all(ResponsiveHelper.spacing(16)),
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
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }

  Widget _buildSearchField(ExecutiveMySurveyController controller) {
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
      MySurveyModel survey, ExecutiveMySurveyController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
