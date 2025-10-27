import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/notification/get_notification_response.dart';
import 'package:rudra/app/modules/manager_module/notification/notification_controller.dart';

import '../../../data/models/notification/notification_model.dart';

class NotificationDetailBottomSheet extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailBottomSheet({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Time
                Text(
                  controller.formatDateTime(notification.dateTime.toString()) ??
                      '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF373C3B),
                  ),
                ),
                const SizedBox(height: 16),
                // Details Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Detail', notification.message ?? ''),
                      // const Divider(
                      //   height: 24,
                      //   thickness: 1,
                      //   color: Color(0xFFE0E0E0),
                      // ),
                      // _buildDetailRow(
                      //   'Executive Name',
                      //   notification.details?.executiveName ?? '',
                      // ),
                      const Divider(
                        height: 24,
                        thickness: 1,
                        color: Color(0xFFE0E0E0),
                      ),
                      _buildDetailRow(
                        'Date & Time',
                        controller.formatDateTime(
                              notification.dateTime.toString(),
                            ) ??
                            '',
                      ),
                      // const Divider(
                      //   height: 24,
                      //   thickness: 1,
                      //   color: Color(0xFFE0E0E0),
                      // ),
                      // _buildDetailRow(
                      //   'Target',
                      //   notification.details?.target ?? '',
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8C8C8C),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF373C3B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
