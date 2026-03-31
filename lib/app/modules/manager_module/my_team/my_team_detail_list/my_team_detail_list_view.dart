import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/my_team/my_team_detail_list/my_team_detail_list_controller.dart';

import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/responsive_utils.dart';
import '../../../../widgets/app_style.dart';
import '../../../../widgets/custom_shimmer_card.dart';

class MyTeamDetailListView extends StatefulWidget {
  const MyTeamDetailListView({super.key});

  @override
  State<MyTeamDetailListView> createState() => _MyTeamDetailListViewState();
}

class _MyTeamDetailListViewState extends State<MyTeamDetailListView> {
  final MyTeamDetailListController controller = Get.put(
    MyTeamDetailListController(),
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
        final team = Get.arguments?['team'];
        final String teamId = team?.teamId?.toString() ?? '0';
        controller.fetchMyTeamMember(
          context: context,
          teamId: teamId,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSearchField(controller),
              SizedBox(height: ResponsiveHelper.spacing(16)),
              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoading.value &&
                        controller.teamMemberList.isEmpty) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: 5,
                        itemBuilder: (_, __) => const CustomShimmerCard(),
                      );
                    }

                    if (controller.isSearching.value) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: 3,
                        itemBuilder: (_, __) => const CustomShimmerCard(),
                      );
                    }

                    if (controller.filteredTeamMemberList.isEmpty) {
                      return const Center(child: Text('No team members found'));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.filteredTeamMemberList.length +
                          (controller.isLoadingMore.value
                              ? 1
                              : (!controller.hasMoreData.value &&
                                      controller.hasPaginated.value
                                  ? 1
                                  : 0)),
                      itemBuilder: (context, index) {
                        if (index == controller.filteredTeamMemberList.length) {
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
                                'No more team members to load',
                                style: AppStyle.bodySmallPoppinsGrey.responsive
                                    .copyWith(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          12),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                        }
                        final member = controller.filteredTeamMemberList[index];
                        return GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.teamMemberDetail,
                              arguments: member,
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: member.file.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: member.file,
                                      imageBuilder: (context, imageProvider) =>
                                          CircleAvatar(
                                        backgroundColor: AppColors.lightGrey,
                                        backgroundImage: imageProvider,
                                      ),
                                      placeholder: (context, url) =>
                                          const CircleAvatar(
                                        backgroundColor: AppColors.lightGrey,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const CircleAvatar(
                                        backgroundColor: AppColors.lightGrey,
                                        child: Icon(
                                          Icons.person,
                                          color: AppColors.darkBackground,
                                        ),
                                      ),
                                    )
                                  : const CircleAvatar(
                                      backgroundColor: AppColors.lightGrey,
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.darkBackground,
                                      ),
                                    ),
                              title: Text(
                                '${member.memberFirstName} ${member.memberLastName}',
                                style: AppStyle.myTeamCardTitle.responsive
                                    .copyWith(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                    14,
                                  ),
                                ),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  controller.makePhoneCall(
                                    member.memberMobileNo ?? '',
                                  );
                                },
                                child: const CircleAvatar(
                                  backgroundColor: AppColors.defaultBlack,
                                  child: Icon(
                                    Icons.phone,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              subtitle: Padding(
                                padding: ResponsiveHelper.paddingSymmetric(
                                  vertical: 3.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Phone Number: ${member.memberMobileNo}',
                                      style: AppStyle
                                          .myteamCardRowTitle.responsive
                                          .copyWith(
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(
                                          12,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Designation: ${member.role}',
                                      style: AppStyle
                                          .myteamCardRowTitle.responsive
                                          .copyWith(
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(
                                          12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(MyTeamDetailListController controller) {
    return Obx(
      () => TextFormField(
        controller: controller.searchController,
        onChanged: controller.searchMembers,
        decoration: InputDecoration(
          hintText: 'Search team members...',
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
        'My Team',
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
