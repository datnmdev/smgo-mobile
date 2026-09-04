import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/features/main/presentation/widgets/app_navigation_bar.dart';
import 'package:smgo/shared/presentation/bloc/get_current_plan/get_current_plan_cubit.dart';
import 'package:smgo/shared/presentation/bloc/subscription_purchase/subscription_purchase_cubit.dart';

class MainPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SubscriptionPurchaseCubit>(
          create: (_) => di<SubscriptionPurchaseCubit>()..initialize(),
        ),
        BlocProvider<GetCurrentPlanCubit>(
          create: (_) => di<GetCurrentPlanCubit>()..call(),
        ),
      ],
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: AppNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}
