import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/utils/app_colors.dart';



class NoDataScreen extends StatelessWidget {
  const NoDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.primary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace with no data icon
              const Icon(Icons.inbox, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'No Data Available',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
