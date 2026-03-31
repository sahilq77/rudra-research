import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_controller.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_view.dart';

import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import '../../../widgets/custom_shimmer_card.dart';
import 'my_team_controller.dart';

class MyTeamView extends StatefulWidget {
  const MyTeamView({super.key});

  @override
  State<MyTeamView> createState() => _MyTeamViewState();
}

class _MyTeamViewState extends State<MyTeamView> {
  final MyTeamController controller = Get.put(MyTeamController());
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
        controller.fetchMyTeam(context: context, isPagination: true);
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
        body: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSearchField(),
              ),
              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoading.value &&
                        controller.teamList.isEmpty) {
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

                    if (controller.teamList.isEmpty) {
                      return const Center(child: Text('No data found'));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: controller.teamList.length +
                          (controller.isLoadingMore.value
                              ? 1
                              : (!controller.hasMoreData.value &&
                                      controller.hasPaginated.value
                                  ? 1
                                  : 0)),
                      itemBuilder: (context, index) {
                        if (index == controller.teamList.length) {
                          if (controller.isLoadingMore.value) {
                            return Padding(
                              padding: EdgeInsets.all(
                                ResponsiveHelper.spacing(16),
                              ),
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
                              padding: EdgeInsets.all(
                                ResponsiveHelper.spacing(16),
                              ),
                              child: Text(
                                'No more teams to load',
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
                        final team = controller.teamList[index];
                        return GestureDetector(
                          onTap: () => Get.toNamed(
                            AppRoutes.myteamdetail,
                            arguments: {'team': team},
                          ),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    team.teamName ?? 'Unnamed Team',
                                    style: AppStyle.myTeamCardTitle.responsive
                                        .copyWith(
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(
                                        14,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: ResponsiveHelper.screenHeight * 0.08,
                                  width: ResponsiveHelper.screenWidth * 0.15,
                                  decoration: const BoxDecoration(
                                    color: AppColors.defaultBlack,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      team.teamMembersCount.toString() ?? '0',
                                      style: AppStyle.myTeamRowCount.responsive
                                          .copyWith(
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(
                                          15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }

  Widget _buildSearchField() {
    return Obx(
      () => TextFormField(
        controller: controller.searchController,
        onChanged: controller.searchTeams,
        decoration: InputDecoration(
          hintText: 'Search.....',
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
