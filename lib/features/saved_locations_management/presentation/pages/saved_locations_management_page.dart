import 'package:flutter/material.dart';
import 'package:shipgo/core/widgets/app_layout.dart';
import 'package:shipgo/core/widgets/app_navigation_bar.dart';

class SavedLocationsManagementPage extends StatelessWidget {
  const SavedLocationsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Text("Đây là trang định vị"),
      navigationBar: AppNavigationBar(currentIndex: 1, onTap: (int value) {}),
    );
  }
}
