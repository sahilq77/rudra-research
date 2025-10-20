import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rudra/app/modules/manager_module/my_team/my_team_detail_list/my_team_detail_list_controller.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../data/models/my_team/get_my_team_member_response.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/responsive_utils.dart';
import '../../../../widgets/app_style.dart';

class MyTeamDetailListView extends StatelessWidget {
  const MyTeamDetailListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final MyTeamDetailListController controller = Get.put(
      MyTeamDetailListController(),
    );
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
                  () => controller.isLoading.value
                      ? _buildShimmerEffect()
                      : controller.filteredTeamMemberList.isEmpty
                      ? const Center(child: Text('No team members found'))
                      : ListView.builder(
                          controller: controller.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount:
                              controller.filteredTeamMemberList.length +
                              (controller.isLoadingMore.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index ==
                                controller.filteredTeamMemberList.length) {
                              return _buildLoadingMoreIndicator();
                            }
                            final member =
                                controller.filteredTeamMemberList[index];
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
                                  leading: CircleAvatar(
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
                                  trailing: CircleAvatar(
                                    backgroundColor: AppColors.defaultBlack,
                                    child: Icon(
                                      Icons.phone,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: ResponsiveHelper.paddingSymmetric(
                                      vertical: 3.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Phone Number: ${member.memberMobileNo}',
                                          style: AppStyle
                                              .myteamCardRowTitle
                                              .responsive
                                              .copyWith(
                                                fontSize:
                                                    ResponsiveHelper.getResponsiveFontSize(
                                                      12,
                                                    ),
                                              ),
                                        ),
                                        Text(
                                          'Designation: ${member.role}',
                                          style: AppStyle
                                              .myteamCardRowTitle
                                              .responsive
                                              .copyWith(
                                                fontSize:
                                                    ResponsiveHelper.getResponsiveFontSize(
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
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildSearchField(MyTeamDetailListController controller) {
    return TextFormField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search team members...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 3,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: ResponsiveHelper.screenWidth * 0.6,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: ResponsiveHelper.screenWidth * 0.4,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              height: ResponsiveHelper.screenHeight * 0.08,
              width: ResponsiveHelper.screenWidth * 0.15,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
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
