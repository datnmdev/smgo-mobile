import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/core/exceptions/app_exception.dart';
import 'package:shipgo/core/resources/app_assets.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/auth/presentation/bloc/session/session_bloc.dart';
import 'package:shipgo/features/auth/presentation/bloc/session/session_event.dart';
import 'package:shipgo/features/auth/presentation/bloc/session/session_state.dart';
import 'package:shipgo/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:shipgo/features/auth/presentation/bloc/sign_in/sign_in_event.dart';
import 'package:shipgo/features/auth/presentation/bloc/sign_in/sign_in_state.dart';
import 'package:easy_localization/easy_localization.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          image: DecorationImage(
            image: AssetImage(AppAssets.bgSplash),
            fit: BoxFit.cover,
          ),
        ),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => di<SignInBloc>()),
            BlocProvider(
              create: (context) => di<SessionBloc>()..add(const CheckSession()),
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _HeaderSection(),
          SizedBox(height: 32),
          _SocialLoginSection(),
        ],
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
        Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 3.0,
            shadows: [
              Shadow(color: Colors.white.withAlpha(200), blurRadius: 10.0),
              const Shadow(color: Color(0xFFC8FFEC), blurRadius: 15.0),
            ],
          ),
        ),
        Text(
          AppStrings.slogan.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFEEFBF5),
            letterSpacing: 0.3,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1.5),
                blurRadius: 3.0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialLoginSection extends StatelessWidget {
  const _SocialLoginSection();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SessionBloc, SessionState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.goNamed(AppRouteNames.explore);
            }
          },
        ),
        BlocListener<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state is SignInDone) {
              context.goNamed(AppRouteNames.explore);
            } else if (state is SignInError) {
              String message = "";
              if (state.error is DioException) {
                message = (state.error as DioException).message ?? "";
              } else if (state.error is AppException) {
                message = (state.error as AppException).message;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
      ],
      child: const _SocialLoginBody(),
    );
  }
}

class _SocialLoginBody extends StatelessWidget {
  const _SocialLoginBody();

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<SessionBloc>().state;
    final signInState = context.watch<SignInBloc>().state;

    if (sessionState is CheckSessionLoading) {
      return _ProgressSection(
        message: AppStrings.checkAuthenticationLoading.tr(),
      );
    }

    if (signInState is SignInLoading) {
      return _ProgressSection(message: AppStrings.signInLoading.tr());
    }

    return const _SocialLoginContentSection();
  }
}

class _ProgressSection extends StatelessWidget {
  final String? message;

  const _ProgressSection({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 20),
        if (message != null && message!.isNotEmpty)
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 0),
                  blurRadius: 10.0,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SocialLoginContentSection extends StatelessWidget {
  const _SocialLoginContentSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialButton(
          iconPath: AppAssets.icGoogle,
          label: AppStrings.signInWithGoogle.tr(),
          onPressed: () {
            context.read<SignInBloc>().add(SignInWithGoogle());
          },
        ),
        const SizedBox(height: 8),
        _SocialButton(
          iconPath: AppAssets.icFacebook,
          label: AppStrings.signInWithFacebook.tr(),
          onPressed: () {
            context.read<SignInBloc>().add(SignInWithFacebook());
          },
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.iconPath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 24, height: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3C4043),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
