import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'config/router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _initRevenueCat();
  runApp(const ProviderScope(child: BusinessKidsApp()));
}

Future<void> _initRevenueCat() async {
  const rcKey = String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');
  if (rcKey.isNotEmpty) {
    await Purchases.configure(PurchasesConfiguration(rcKey));
  }
}

class BusinessKidsApp extends ConsumerWidget {
  const BusinessKidsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ビジネスキッズ',
      theme: AppTheme.theme,
      routerConfig: router,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja'),
        Locale('en'),
      ],
      locale: const Locale('ja'),
      debugShowCheckedModeBanner: false,
    );
  }
}
