import 'package:flutter/material.dart';

class PermissionModel {
  final IconData icon;
  final String title;
  final String description;

  const PermissionModel({
    required this.icon,
    required this.title,
    required this.description,
  });

  static List<PermissionModel> getRequiredPermissions() {
    return [
      const PermissionModel(
        icon: Icons.camera_alt,
        title: 'Camera',
        description: 'To capture photos for survey documentation',
      ),
      const PermissionModel(
        icon: Icons.folder,
        title: 'Storage & Media',
        description: 'To save and access survey files, images, and audio',
      ),
      const PermissionModel(
        icon: Icons.mic,
        title: 'Microphone',
        description: 'To record audio notes during surveys',
      ),
      const PermissionModel(
        icon: Icons.notifications,
        title: 'Notifications',
        description: 'To receive important survey updates and alerts',
      ),
      const PermissionModel(
        icon: Icons.location_on,
        title: 'Location',
        description: 'To track survey locations and validate responses',
      ),
      const PermissionModel(
        icon: Icons.battery_saver,
        title: 'Battery Optimization',
        description: 'To run background tasks and sync data properly',
      ),
    ];
  }
}
