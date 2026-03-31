import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../bottom_navigation/bottom_navigation_controller.dart';
import '../../../../bottom_navigation/bottom_navigation_view.dart';
import '../../../common/custominputformatters/securetext_input_formatter.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import '../../../widgets/custom_shimmer_card.dart';
import 'super_admin_report_controller.dart';

class SuperAdminReportView extends StatefulWidget {
  const SuperAdminReportView({super.key});

  @override
  State<SuperAdminReportView> createState() => _SuperAdminReportViewState();
}

class _SuperAdminReportViewState extends State<SuperAdminReportView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final controller = Get.find<SuperAdminReportController>();
      if (controller.hasMoreData.value &&
          !controller.isLoading.value &&
          !controller.isLoadingMore.value) {
        controller.fetchAllSurveys(isPagination: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    final controller = Get.put(SuperAdminReportController());
    final bottomController = Get.put(BottomNavigationController());

    return WillPopScope(
      onWillPop: () => bottomController.onWillPop(),
      child: Scaffold(
        appBar: _buildAppbar(),
        body: RefreshIndicator(
          onRefresh: controller.onRefresh,
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
                      controller.allSurveys.isEmpty) {
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

                  if (controller.filteredSurveys.isEmpty) {
                    return const Center(child: Text('No surveys found'));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
                    itemCount: controller.filteredSurveys.length +
                        (controller.isLoadingMore.value
                            ? 1
                            : (!controller.hasMoreData.value &&
                                    controller.hasPaginated.value
                                ? 1
                                : 0)),
                    itemBuilder: (ctx, i) {
                      if (i == controller.filteredSurveys.length) {
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
                        }
                        if (!controller.hasMoreData.value &&
                            controller.hasPaginated.value) {
                          return Padding(
                            padding:
                                EdgeInsets.all(ResponsiveHelper.spacing(16)),
                            child: Text(
                              'No more surveys to load',
                              style: AppStyle.bodySmallPoppinsGrey.responsive
                                  .copyWith(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(12),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                      }

                      final survey = controller.filteredSurveys[i];
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

  Widget _buildSearchField(SuperAdminReportController controller) {
    return Obx(
      () => TextFormField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        inputFormatters: [SecureTextInputFormatter.deny()],
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
      dynamic survey, SuperAdminReportController controller) {
    return GestureDetector(
      onTap: () => controller.onSurveyTap(survey),
      child: Card(
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
                    survey.surveyTitle ?? 'N/A',
                    style: AppStyle.reportCardTitle.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(5)),
                  Text(
                    survey.districtName ?? 'N/A',
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
                        survey.surveyId ?? 'N/A',
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
                        survey.response?.toString() ?? '0',
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
}
