import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey/validator_start_survey_list_controller.dart';
import 'package:rudra/app/routes/app_routes.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import '../../../widgets/custom_shimmer_card.dart';

class ValidatorStartSurveyListView extends StatefulWidget {
  const ValidatorStartSurveyListView({super.key});

  @override
  State<ValidatorStartSurveyListView> createState() =>
      _ValidatorStartSurveyListViewState();
}

class _ValidatorStartSurveyListViewState
    extends State<ValidatorStartSurveyListView> {
  late final ValidatorStartSurveyListController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<ValidatorStartSurveyListController>();
    _scrollController.addListener(_loadMore);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMore() {
    if (controller.hasMoreData.value &&
        !controller.isLoading.value &&
        !controller.isLoadingMore.value &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9) {
      controller.loadMoreResponses(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Scaffold(
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Obx(() {
          if (controller.isLoading.value && controller.surveyList.isEmpty) {
            return Column(
              children: [
                Padding(
                  padding: ResponsiveHelper.paddingSymmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: _buildSerachField(controller),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (_, __) => const CustomShimmerCard(),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              Padding(
                padding: ResponsiveHelper.paddingSymmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: _buildSerachField(controller),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isSearching.value) {
                    return ListView.builder(
                      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
                      itemCount: 3,
                      itemBuilder: (_, __) => const CustomShimmerCard(),
                    );
                  }

                  if (controller.filteredSurveyList.isEmpty) {
                    return const Center(child: Text('No reports found'));
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: ResponsiveHelper.paddingSymmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    itemCount: controller.filteredSurveyList.length +
                        (controller.isLoadingMore.value ? 1 : (!controller.hasMoreData.value && controller.hasPaginated.value ? 1 : 0)),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == controller.filteredSurveyList.length) {
                        if (controller.isLoadingMore.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        } else if (!controller.hasMoreData.value && controller.hasPaginated.value) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No more items to load',
                                style: AppStyle.bodySmallPoppinsGrey.responsive,
                              ),
                            ),
                          );
                        }
                      }
                          final report = controller.filteredSurveyList[index];
                          return GestureDetector(
                            onTap: () => Get.toNamed(
                              AppRoutes.validatorStartSurveyDetail,
                              arguments: {
                                'report': report,
                                'survey_id': controller.surveyId ?? '',
                                'response_id': report.id,
                              },
                            ),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          report.surveyId,
                                          style: AppStyle
                                              .reportCardTitle.responsive
                                              .copyWith(
                                            fontSize: ResponsiveHelper
                                                .getResponsiveFontSize(
                                              16,
                                            ),
                                          ),
                                        ),
                                        // SizedBox(
                                        //   height: ResponsiveHelper.spacing(5),
                                        // ),
                                        // Text(
                                        //   report.subtitle,
                                        //   style: AppStyle
                                        //       .reportCardSubTitle
                                        //       .responsive
                                        //       .copyWith(
                                        //         fontSize:
                                        //             ResponsiveHelper.getResponsiveFontSize(
                                        //               13,
                                        //             ),
                                        //       ),
                                        // ),
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
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Name',
                                                style: AppStyle
                                                    .reportCardRowTitle
                                                    .responsive
                                                    .copyWith(
                                                  fontSize: ResponsiveHelper
                                                      .getResponsiveFontSize(
                                                    13,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  report.title,
                                                  style: AppStyle
                                                      .reportCardRowCount
                                                      .responsive
                                                      .copyWith(
                                                    fontSize: ResponsiveHelper
                                                        .getResponsiveFontSize(
                                                      13,
                                                    ),
                                                  ),
                                                  textAlign: TextAlign.end,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: ResponsiveHelper.spacing(1),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Submitted At',
                                                style:
                                                    AppStyle.reportCardRowTitle,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  report.responseCount,
                                                  style: AppStyle
                                                      .reportCardRowCount,
                                                  textAlign: TextAlign.end,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSerachField(
    ValidatorStartSurveyListController controller,
  ) {
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
