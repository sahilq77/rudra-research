import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/custominputformatters/securetext_input_formatter.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import '../../../widgets/custom_shimmer_card.dart';
import 'super_admin_survey_team_members_controller.dart';

class SuperAdminSurveyTeamMembersView extends StatefulWidget {
  const SuperAdminSurveyTeamMembersView({super.key});

  @override
  State<SuperAdminSurveyTeamMembersView> createState() =>
      _SuperAdminSurveyTeamMembersViewState();
}

class _SuperAdminSurveyTeamMembersViewState
    extends State<SuperAdminSurveyTeamMembersView> {
  final SuperAdminSurveyTeamMembersController controller = Get.find();
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
        controller.fetchAssignSurveyTarget(
          context: context,
          isPagination: true,
          surveyId: controller.surveyId,
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
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          controller.refreshData();
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          return _buildBody();
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.defaultBlack),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Survey Users Detail',
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
          _buildSummaryCards(),
          SizedBox(height: ResponsiveHelper.spacing(20)),
          _buildExecutorList(),
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
          onChanged: controller.searchExecutors,
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

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: ResponsiveHelper.paddingSymmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    '${controller.surveyTarget.value}',
                    style: AppStyle.heading2PoppinsBlack.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(25),
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                Text(
                  'Survey Target',
                  style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(12),
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(12)),
        Expanded(
          child: Container(
            padding: ResponsiveHelper.paddingSymmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    '${controller.surveyCompleted.value}',
                    style: AppStyle.heading2PoppinsBlack.responsive.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(25),
                      fontWeight: FontWeight.w700,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                Text(
                  'Survey Completed',
                  style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(12),
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExecutorList() {
    return Obx(() {
      if (controller.isSearching.value) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (_, __) => const CustomShimmerCard(),
        );
      }

      if (controller.filteredExecutorList.isEmpty) {
        return Center(
          child: Padding(
            padding: ResponsiveHelper.padding(40),
            child: Text(
              'No executors found',
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
            itemCount: controller.filteredExecutorList.length,
            itemBuilder: (context, index) {
              return _buildExecutorCard(index);
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
              controller.filteredExecutorList.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.spacing(16)),
              child: Text(
                'No more executors to load',
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

  Widget _buildExecutorCard(int index) {
    final executor = controller.filteredExecutorList[index];

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.mySurveyResponse,
          arguments: {'surveyId': controller.surveyId, 'userId': executor.id},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(12)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
          border: Border.all(
            color: AppColors.lightGrey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: ResponsiveHelper.paddingSymmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Row(
                children: [
                  executor.executorImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: executor.executorImage,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            radius: ResponsiveHelper.spacing(20),
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => CircleAvatar(
                            radius: ResponsiveHelper.spacing(20),
                            backgroundColor:
                                AppColors.lightGrey.withOpacity(0.3),
                            child: const CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            radius: ResponsiveHelper.spacing(20),
                            backgroundColor:
                                AppColors.lightGrey.withOpacity(0.3),
                            child: Text(
                              executor.executorName.isNotEmpty
                                  ? executor.executorName[0].toUpperCase()
                                  : 'E',
                              style: AppStyle.bodyBoldPoppinsBlack.responsive
                                  .copyWith(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(16),
                              ),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: ResponsiveHelper.spacing(20),
                          backgroundColor: AppColors.lightGrey.withOpacity(0.3),
                          child: Text(
                            executor.executorName.isNotEmpty
                                ? executor.executorName[0].toUpperCase()
                                : 'E',
                            style: AppStyle.bodyBoldPoppinsBlack.responsive
                                .copyWith(
                              fontSize:
                                  ResponsiveHelper.getResponsiveFontSize(16),
                            ),
                          ),
                        ),
                  SizedBox(width: ResponsiveHelper.spacing(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          executor.executorName,
                          style:
                              AppStyle.bodyBoldPoppinsBlack.responsive.copyWith(
                            fontSize:
                                ResponsiveHelper.getResponsiveFontSize(15),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: ResponsiveHelper.spacing(30),
                    height: ResponsiveHelper.spacing(30),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.defaultBlack,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.phone,
                        color: AppColors.white,
                        size: ResponsiveHelper.spacing(20),
                      ),
                      onPressed: () => controller.makeCall(executor.id),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: ResponsiveHelper.paddingSymmetric(
                horizontal: 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  _buildTargetInfo(
                    'Today Completed Target',
                    executor.todayCompletedTarget,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(5)),
                  _buildTargetInfo(
                    'Total Assigned Target',
                    executor.totalAssignedTarget,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(5)),
                  _buildTargetInfo(
                    'Total Completed Target',
                    executor.totalCompletedTarget,
                  ),
                  SizedBox(
                    height: ResponsiveHelper.spacing(
                      5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetInfo(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(12),
            color: AppColors.grey,
          ),
        ),
        Text(
          value.toString().padLeft(2, '0'),
          style: AppStyle.bodySmallPoppinsBlack.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(12),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
