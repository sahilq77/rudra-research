import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/app_logger.dart';
import '../utils/responsive_utils.dart';
import 'app_style.dart';

class ProfileImageViewer extends StatefulWidget {
  final String imageUrl;
  final String userName;

  const ProfileImageViewer({
    super.key,
    required this.imageUrl,
    required this.userName,
  });

  @override
  State<ProfileImageViewer> createState() => _ProfileImageViewerState();
}

class _ProfileImageViewerState extends State<ProfileImageViewer>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    AppLogger.d('ProfileImageViewer initialized', tag: 'ProfileImageViewer');
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.ease,
    ));
    _animation!.addListener(() {
      _transformationController.value = _animation!.value;
    });
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            try {
              Get.closeAllSnackbars();
              Navigator.of(context).pop();
            } catch (e) {
              AppLogger.e('Error closing image viewer: $e',
                  tag: 'ProfileImageViewer');
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          widget.userName,
          style: AppStyle.heading1PoppinsWhite.responsive,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetZoom,
            tooltip: 'Reset Zoom',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: Center(
          child: widget.imageUrl.isNotEmpty
              ? GestureDetector(
                  onDoubleTap: _resetZoom,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        width: ResponsiveHelper.spacing(200),
                        height: ResponsiveHelper.spacing(200),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.spacing(12),
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: ResponsiveHelper.spacing(200),
                        height: ResponsiveHelper.spacing(200),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.spacing(12),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              size: ResponsiveHelper.spacing(80),
                              color: AppColors.grey,
                            ),
                            SizedBox(height: ResponsiveHelper.spacing(16)),
                            Text(
                              'Image not available',
                              style: AppStyle.bodySmallPoppinsGrey.responsive,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
              : Container(
                  width: ResponsiveHelper.spacing(200),
                  height: ResponsiveHelper.spacing(200),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.spacing(12),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: ResponsiveHelper.spacing(80),
                        color: AppColors.grey,
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(16)),
                      Text(
                        'No profile image',
                        style: AppStyle.bodySmallPoppinsGrey.responsive,
                      ),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.zoom_in,
                color: Colors.white70,
                size: ResponsiveHelper.spacing(16),
              ),
              SizedBox(width: ResponsiveHelper.spacing(8)),
              Text(
                'Pinch to zoom • Double tap to reset',
                textAlign: TextAlign.center,
                style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
