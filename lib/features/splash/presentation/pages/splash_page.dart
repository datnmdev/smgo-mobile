import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/core/utils/app_update_util.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/features/splash/presentation/bloc/check_session/check_session_cubit.dart';
import 'package:smgo/features/splash/presentation/bloc/check_session/check_session_state.dart';
import 'package:smgo/features/splash/presentation/bloc/check_app_version/check_app_version_bloc.dart';
import 'package:smgo/features/splash/presentation/bloc/check_app_version/check_app_version_event.dart';
import 'package:smgo/features/splash/presentation/bloc/check_app_version/check_app_version_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              di<CheckAppVersionBloc>()..add(CheckAppVersion()),
        ),
        BlocProvider<CheckSessionCubit>(
          create: (context) => di<CheckSessionCubit>(),
        ),
      ],
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.green,
            image: DecorationImage(
              image: AssetImage(AppAssets.bgSplash),
              fit: BoxFit.cover,
            ),
          ),
          child: _MainContent(),
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckSessionCubit, CheckSessionState>(
      listener: (context, state) {
        if (state is CheckSessionDone) {
          if (state is Authenticated) {
            context.replaceNamed(AppRouteNames.home);
          } else {
            context.replaceNamed(AppRouteNames.onboarding);
          }
        }
      },
      child: BlocListener<CheckAppVersionBloc, CheckAppVersionState>(
        listener: (context, state) {
          final checkSessionCubit = context.read<CheckSessionCubit>();
          if (state is CheckAppVersionMaintenance) {
            showDialog(
              context: context,
              useRootNavigator: true,
              barrierDismissible: false,
              barrierColor: Colors.black.withAlpha(70),
              builder: (context) => _MaintenanceDialog(
                description: state.messageMap?['message'],
                estimatedTime: state.messageMap?['estimated_time'],
              ),
            );
          } else if (state is CheckAppVersionUpdateRequired) {
            late OverlayEntry overlayEntry;
            overlayEntry = OverlayEntry(
              builder: (dialogContext) => BlocProvider.value(
                value: context.read<CheckAppVersionBloc>(),
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      ModalBarrier(
                        color: Colors.black.withAlpha(70),
                        dismissible: false,
                      ),
                      Center(
                        child: _UpdateAppDialog(
                          storeAppId: state.storeAppId ?? "",
                          onDismiss: () {
                            overlayEntry.remove();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            Overlay.of(context, rootOverlay: true).insert(overlayEntry);
            if (!state.isForceUpdate) {
              checkSessionCubit.call();
            }
          } else if (state is CheckAppVersionUpToDate) {
            checkSessionCubit.call();
          }
        },
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _HeaderSection(),
                    SizedBox(height: 24),
                    _ProgressStateView(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateAppDialog extends StatelessWidget {
  final String storeAppId;
  final VoidCallback? onDismiss;

  const _UpdateAppDialog({required this.storeAppId, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Tiêu đề
              Text(
                AppStrings.appUpdateTitle.tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Nội dung mô tả
              Text(
                AppStrings.appUpdateDesc.tr(),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Các tùy chọn dạng Card/Button
              _BuildOptionCard(
                primaryColor: AppColors.primary,
                title: AppStrings.appUpdateButtonTitle.tr(),
                subtitle: AppStrings.appUpdateButtonDesc.tr(),
                icon: Icons.download_rounded,
                isPrimary: true,
                onTap: () {
                  AppUpdateUtil.openAppStore(storeAppId: storeAppId);
                },
              ),
              BlocBuilder<CheckAppVersionBloc, CheckAppVersionState>(
                builder: (context, state) {
                  if (state is CheckAppVersionUpdateRequired &&
                      state.isForceUpdate) {
                    return SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      _BuildOptionCard(
                        primaryColor: AppColors.primary,
                        title: AppStrings.appUpdateButtonLaterTitle.tr(),
                        subtitle: AppStrings.appUpdateButtonLaterDesc.tr(),
                        icon: Icons.history_rounded,
                        isPrimary: false,
                        onTap: onDismiss,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final Color primaryColor;
  final VoidCallback? onTap;

  const _BuildOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.primaryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? primaryColor : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: isPrimary
            ? Colors.white.withAlpha(20)
            : primaryColor.withAlpha(15),
        highlightColor: isPrimary
            ? Colors.white.withAlpha(10)
            : primaryColor.withAlpha(5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: isPrimary ? Colors.white : Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPrimary ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isPrimary
                            ? Colors.white70
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isPrimary ? Colors.white : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaintenanceDialog extends StatelessWidget {
  final String title;
  final String description;
  final String? estimatedTime;

  _MaintenanceDialog({String? title, String? description, this.estimatedTime})
    : title = title ?? AppStrings.maintenanceAppTitle.tr(),
      description = description ?? AppStrings.maintenanceAppMessage.tr();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        elevation: 16,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.construction_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),

              // Tiêu đề
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Nội dung
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              // Hiển thị khung thời gian nếu có truyền vào
              if (estimatedTime != null) ...[
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        estimatedTime!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Progress Bar
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppAssets.logo, width: 128, height: 128, fit: BoxFit.cover),
        SizedBox(height: 8),
        Image.asset(AppAssets.logoText, width: 128),
      ],
    );
  }
}

class _ProgressStateView extends StatelessWidget {
  const _ProgressStateView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 20),
        BlocBuilder<CheckAppVersionBloc, CheckAppVersionState>(
          builder: (context, state) {
            final checkSessionCubit = context.watch<CheckSessionCubit>();

            String message = '';
            if (state is CheckAppVersionLoading) {
              message = AppStrings.checkAppVersionLoading.tr();
            } else if (state is CheckAppVersionFailed) {
              message = AppStrings.checkAppVersionFailed.tr();
            } else if (checkSessionCubit.state is CheckSessionLoading) {
              message = AppStrings.checkAuthenticationLoading.tr();
            } else {
              return SizedBox.shrink();
            }

            return Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(0, 0),
                    blurRadius: 1.0,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
