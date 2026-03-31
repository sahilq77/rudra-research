import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_utils.dart';

class CustomShimmerCard extends StatelessWidget {
  const CustomShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(12)),
        padding:
            ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 16),
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
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.white,
            ),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            Container(
              width: 150,
              height: 14,
              color: Colors.white,
            ),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            Container(
              width: 200,
              height: 12,
              color: Colors.white,
            ),
            SizedBox(height: ResponsiveHelper.spacing(16)),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
