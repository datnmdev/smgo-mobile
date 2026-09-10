import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/config/env.dart';
import 'package:smgo/core/exceptions/app_exception.dart';
import 'package:smgo/core/localization/presentation/bloc/set_locale/set_locale_cubit.dart';
import 'package:smgo/core/localization/presentation/bloc/set_locale/set_locale_state.dart';
import 'package:smgo/core/network/external_links.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:smgo/features/auth/presentation/bloc/sign_in/sign_in_event.dart';
import 'package:smgo/features/auth/presentation/bloc/sign_in/sign_in_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smgo/shared/presentation/bloc/get_profile/get_profile_cubit.dart';
import 'package:smgo/shared/presentation/bloc/subscription_purchase/subscription_purchase_cubit.dart';
import 'package:smgo/shared/presentation/widgets/language_bottom_sheet.dart';
import 'package:smgo/shared/presentation/widgets/language_selector_button.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';
import 'package:smgo/shared/utils/app_url_utils.dart';

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
          providers: [BlocProvider(create: (context) => di<SignInBloc>())],
          child: Stack(
            alignment: Alignment.center,
            children: [
              _MainContent(),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 16,
                right: 16,
                child: LanguageSelectorButton(
                  languageCode: context.locale.languageCode.toUpperCase(),
                  onTap: () {
                    _showLanguageBottomSheet(context: context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tiện ích để gọi BottomSheet ở bất kỳ đâu
  void _showLanguageBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return MultiBlocProvider(
          providers: [BlocProvider(create: (context) => di<SetLocaleCubit>())],
          child: BlocConsumer<SetLocaleCubit, SetLocaleState>(
            listener: (context, state) async {
              if (state is SetLocaleDone) {
                if (!context.mounted) {
                  return;
                }
                context.pop();
                await Restart.restartApp();
              } else if (state is SetLocaleFailed) {
                AppDialogUtils.showError(
                  context: context,
                  title: AppStrings.pPChangeLanguageFailedTitle.tr(),
                  subtitle: AppStrings.pPChangeLanguageFailedSubtitle.tr(),
                );
              }
            },

            builder: (context, state) => LanguageBottomSheet(
              isSubmitting: state is SetLocaleLoading,
              selectedCode: context.locale.languageCode,
              onSelected: (language) {
                context.read<SetLocaleCubit>().call(
                  locale: Locale(language.code, language.countryCode),
                );
              },
            ),
          ),
        );
      },
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
        SizedBox(height: 8),
        Image.asset(AppAssets.logoText, width: 128),
        SizedBox(height: 8),
        Text(
          AppStrings.slogan.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            letterSpacing: 0.3,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 0),
                blurRadius: 1.0,
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
        BlocListener<SignInBloc, SignInState>(
          listener: (context, state) async {
            if (state is SignInDone) {
              final getProfileCubit = di<GetProfileCubit>();

              await getProfileCubit.call();

              final String? userId = getProfileCubit.state.profile?.id;

              if (userId != null && userId.isNotEmpty) {
                di<SubscriptionPurchaseCubit>().initialize(userId: userId);
              }

              if (!context.mounted) {
                return;
              }

              context.goNamed(AppRouteNames.home);
            } else if (state is SignInError) {
              String message = '';

              if (state.error is DioException) {
                message = (state.error as DioException).message ?? '';
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
    final signInState = context.watch<SignInBloc>().state;

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
              color: AppColors.primary,
              fontSize: 14,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 0),
                  blurRadius: 2.0,
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
        const SizedBox(height: 16),
        const _TermsAndPrivacySection(),
      ],
    );
  }
}

class _TermsAndPrivacySection extends StatelessWidget {
  const _TermsAndPrivacySection();

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 12,
      color: Color(0xFF64748B),
      height: 1.5,
    );

    const linkStyle = TextStyle(
      fontSize: 12,
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
      height: 1.5,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(AppStrings.signInAgreementPrefix.tr(), style: textStyle),
          InkWell(
            onTap: () {
              AppUrlUtils.launchLink(ExternalLinks.termsOfService);
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: Text(AppStrings.termsOfService.tr(), style: linkStyle),
            ),
          ),
          Text(AppStrings.signInAgreementAnd.tr(), style: textStyle),
          InkWell(
            onTap: () {
              AppUrlUtils.launchLink(ExternalLinks.privacyPolicy);
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: Text(AppStrings.privacyPolicy.tr(), style: linkStyle),
            ),
          ),
        ],
      ),
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
