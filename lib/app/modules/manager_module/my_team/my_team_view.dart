import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_style.dart';
import 'my_team_controller.dart';
import '../../../routes/app_routes.dart';

class MyTeamView extends StatelessWidget {
  const MyTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final MyTeamController controller = Get.put(MyTeamController());
    ResponsiveHelper.init(context);

    return Scaffold(
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Obx(
          () => controller.isLoading.value
              ? _buildShimmerEffect()
              : controller.filteredReportList.isEmpty
              ? const Center(child: Text('No reports found'))
              : ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.filteredReportList.length,
                  itemBuilder: (context, index) {
                    final report = controller.filteredReportList[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed(
                        AppRoutes.myteamdetail,
                        // arguments: {'report': report},
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                report.title,
                                style: AppStyle.myTeamCardTitle.responsive
                                    .copyWith(
                                      fontSize:
                                          ResponsiveHelper.getResponsiveFontSize(
                                            14,
                                          ),
                                    ),
                              ),
                            ),
                            Container(
                              height: ResponsiveHelper.screenHeight * 0.08,
                              width: ResponsiveHelper.screenWidth * 0.15,
                              decoration: BoxDecoration(
                                color: AppColors.defaultBlack,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "04",
                                  style: AppStyle.myTeamRowCount.responsive
                                      .copyWith(
                                        fontSize:
                                            ResponsiveHelper.getResponsiveFontSize(
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
                ),
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
