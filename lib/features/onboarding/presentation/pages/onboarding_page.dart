import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/localization/domain/entities/locale_entity.dart';
import 'package:smgo/core/localization/presentation/bloc/set_locale/set_locale_cubit.dart';
import 'package:smgo/core/localization/presentation/bloc/set_locale/set_locale_state.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_colors.dart';
import 'package:smgo/core/resources/app_strings.dart';
import 'package:smgo/dependency_injection.dart';
import 'package:smgo/shared/presentation/widgets/language_bottom_sheet.dart';
import 'package:smgo/shared/presentation/widgets/language_selector_button.dart';
import 'package:smgo/shared/presentation/widgets/smgo_onboarding_carousel.dart';
import 'package:smgo/shared/utils/app_dialog_utils.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final easyLoc = EasyLocalization.of(context);
    final currentLocale = easyLoc?.currentLocale ?? fallbackLocale;
    return Stack(
      children: [
        SmGoOnboardingCarousel(
          imageUrls: [
            AppAssets.getSmartSortingCarousel(lang: currentLocale.languageCode),
            AppAssets.getOptimizedRouteCarousel(
              lang: currentLocale.languageCode,
            ),
            AppAssets.getSaveLocationSmartCarousel(
              lang: currentLocale.languageCode,
            ),
            AppAssets.getRequireShareLocationCarousel(
              lang: currentLocale.languageCode,
            ),
            AppAssets.getImportOrderInfoFastCarousel(
              lang: currentLocale.languageCode,
            ),
          ],
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () {
                  context.replaceNamed(AppRouteNames.signIn);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.oPStartNowBtnLabel.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),

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
          providers: [
            BlocProvider<SetLocaleCubit>(
              create: (context) => di<SetLocaleCubit>(),
            ),
          ],
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
