import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  final Widget navigationBar;

  const AppLayout({
    super.key,
    required this.body,
    required this.navigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: body, bottomNavigationBar: navigationBar);
  }
}
