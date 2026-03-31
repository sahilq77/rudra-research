import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../bottom_navigation/bottom_navigation_controller.dart';
import '../../../../bottom_navigation/bottom_navigation_view.dart';
import '../../../common/custominputformatters/securetext_input_formatter.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_button_style.dart';
import '../../../widgets/app_style.dart';
import '../../../widgets/custom_shimmer_card.dart';
import 'super_admin_all_surveys_controller.dart';

class SuperAdminAllSurveysView extends StatefulWidget {
  const SuperAdminAllSurveysView({super.key});

  @override
  State<SuperAdminAllSurveysView> createState() =>
      _SuperAdminAllSurveysViewState();
}

class _SuperAdminAllSurveysViewState extends State<SuperAdminAllSurveysView> {
  final SuperAdminAllSurveysController controller = Get.find();
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
        controller.fetchAllSurveys(
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
        backgroundColor: AppColors.white,
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return _buildBody();
          }),
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'All Surveys',
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

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          _buildSearchField(),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          _buildSurveysList(),
          SizedBox(height: ResponsiveHelper.spacing(20)),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Obx(
        () => TextFormField(
          controller: controller.searchController,
          onChanged: controller.searchSurveys,
          inputFormatters: [SecureTextInputFormatter.deny()],
          decoration: InputDecoration(
            hintText: 'Search.....',
            hintStyle: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(14),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.grey,
              size: ResponsiveHelper.spacing(20),
            ),
            suffixIcon: controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: AppColors.grey,
                      size: ResponsiveHelper.spacing(20),
                    ),
                    onPressed: controller.clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: ResponsiveHelper.paddingSymmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(14),
          ),
        ),
      ),
    );
  }

  Widget _buildSurveysList() {
    return Obx(() {
      if (controller.isSearching.value) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (_, __) => const CustomShimmerCard(),
        );
      }

      if (controller.allSurveysList.isEmpty) {
        return Center(
          child: Padding(
            padding: ResponsiveHelper.padding(40),
            child: Text(
              'No surveys found',
              style: AppStyle.bodyRegularPoppinsGrey.responsive.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(14),
              ),
            ),
          ),
        );
      }

      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.allSurveysList.length,
            itemBuilder: (context, index) {
              return _buildSurveyCard(controller.allSurveysList[index]);
            },
          ),
          if (controller.isLoadingMore.value)
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.spacing(16)),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
          if (!controller.hasMoreData.value &&
              controller.hasPaginated.value &&
              controller.allSurveysList.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.spacing(16)),
              child: Text(
                'No more surveys to load',
                style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(12),
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      );
    });
  }

  Widget _buildSurveyCard(survey) {
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
                    SizedBox(height: ResponsiveHelper.spacing(4)),
                    ResponsiveHelper.safeText(
                      'Teams: ${survey.teamNames}',
                      style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(11),
                        color: AppColors.grey,
                      ),
                      maxLines: 2,
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
                          fontSize: ResponsiveHelper.getResponsiveFontSize(11),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.onViewDetailsTap(survey),
              style: AppButtonStyles.elevatedLargeBlack(),
              child: Text(
                'View Details',
                style: AppStyle.buttonTextSmallPoppinsWhite.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
