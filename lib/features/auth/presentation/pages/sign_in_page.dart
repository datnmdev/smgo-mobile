import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shipgo/core/config/app_route_names.dart';
import 'package:shipgo/core/exception/app_exception.dart';
import 'package:shipgo/core/widgets/loading_overlay.dart';
import 'package:shipgo/dependency_injection.dart';
import 'package:shipgo/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:shipgo/features/auth/presentation/bloc/sign_in/sign_in_event.dart';
import 'package:shipgo/features/auth/presentation/bloc/sign_in/sign_in_state.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.green,
          image: DecorationImage(
            image: AssetImage('assets/images/login-bg.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocProvider(
          create: (context) => di<SignInBloc>(),
          child: BlocConsumer<SignInBloc, SignInState>(
            listener: (context, state) {
              if (state is SignInDone) {
                context.goNamed(AppRouteNames.explore);
              } else if (state is SignInError) {
                String message = "";
                if (state.error is DioException) {
                  message = state.error.message;
                } else if (state.error is AppException) {
                  message = state.error.message;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            builder: (context, state) => Stack(
              children: [
                _MainContent(),
                BlurLoadingOverlay(isLoading: state is SignInLoading),
              ],
            ),
          ),
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
        Image.asset(
          'assets/logo/logo.png',
          width: 128,
          height: 128,
          fit: BoxFit.cover,
        ),
        Text(
          "Shipgo",
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
        const Text(
          'Tối ưu lộ trình & tiết kiệm chi phí',
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
    return Column(
      children: [
        _SocialButton(
          iconPath: 'assets/icons/google.png',
          label: 'Đăng nhập bằng Google',
          onPressed: () {
            context.read<SignInBloc>().add(SignInWithGoogle());
          },
        ),
        const SizedBox(height: 8),
        _SocialButton(
          iconPath: 'assets/icons/facebook.png',
          label: 'Đăng nhập bằng Facebook',
          onPressed: () {},
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
