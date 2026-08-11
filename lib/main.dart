import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shipgo/app_router.dart';
import 'package:shipgo/core/resources/app_assets.dart';
import 'package:shipgo/core/resources/app_strings.dart';
import 'package:shipgo/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('vi', 'VN')],
      fallbackLocale: const Locale('vi', 'VN'),
      path: AppAssets.translations,
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: AppStrings.appTitle.tr(),
      routerConfig: appRouter,
    );
  }
}
