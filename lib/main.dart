import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smgo/app_router.dart';
import 'package:smgo/core/localization/domain/entities/locale_entity.dart';
import 'package:smgo/core/localization/domain/repository/localization_repository.dart';
import 'package:smgo/core/resources/app_assets.dart';
import 'package:smgo/core/resources/app_theme.dart';
import 'package:smgo/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  await EasyLocalization.ensureInitialized();
  final currLocale = (await di<LocalizationRepository>().getLocale()).data!;
  await di<LocalizationRepository>().setLocale(locale: currLocale);
  runApp(
    EasyLocalization(
      supportedLocales: supportedLocales,
      fallbackLocale: fallbackLocale,
      startLocale: currLocale,
      path: AppAssets.translations,
      useOnlyLangCode: false,
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: appRouter,
      ),
    );
  }
}
