import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appName.
  ///
  /// In ja, this message translates to:
  /// **'ビジネスキッズ'**
  String get appName;

  /// No description provided for @playAsChild.
  ///
  /// In ja, this message translates to:
  /// **'子どもでプレイ'**
  String get playAsChild;

  /// No description provided for @parentLogin.
  ///
  /// In ja, this message translates to:
  /// **'親ログイン'**
  String get parentLogin;

  /// No description provided for @level1.
  ///
  /// In ja, this message translates to:
  /// **'レベル1'**
  String get level1;

  /// No description provided for @level2.
  ///
  /// In ja, this message translates to:
  /// **'レベル2'**
  String get level2;

  /// No description provided for @level3.
  ///
  /// In ja, this message translates to:
  /// **'レベル3'**
  String get level3;

  /// No description provided for @level1Desc.
  ///
  /// In ja, this message translates to:
  /// **'小1〜3年向け やさしい'**
  String get level1Desc;

  /// No description provided for @level2Desc.
  ///
  /// In ja, this message translates to:
  /// **'小3〜5年向け ふつう'**
  String get level2Desc;

  /// No description provided for @level3Desc.
  ///
  /// In ja, this message translates to:
  /// **'小5〜6年向け むずかしい'**
  String get level3Desc;

  /// No description provided for @tabGame.
  ///
  /// In ja, this message translates to:
  /// **'ゲーム'**
  String get tabGame;

  /// No description provided for @tabLedger.
  ///
  /// In ja, this message translates to:
  /// **'帳簿'**
  String get tabLedger;

  /// No description provided for @tabProfile.
  ///
  /// In ja, this message translates to:
  /// **'プロフィール'**
  String get tabProfile;

  /// No description provided for @todaySales.
  ///
  /// In ja, this message translates to:
  /// **'今日の売上'**
  String get todaySales;

  /// No description provided for @totalProfit.
  ///
  /// In ja, this message translates to:
  /// **'合計利益'**
  String get totalProfit;

  /// No description provided for @stockUp.
  ///
  /// In ja, this message translates to:
  /// **'仕入れる'**
  String get stockUp;

  /// No description provided for @sell.
  ///
  /// In ja, this message translates to:
  /// **'売る'**
  String get sell;

  /// No description provided for @setPrice.
  ///
  /// In ja, this message translates to:
  /// **'値段を決める'**
  String get setPrice;

  /// No description provided for @buyOrNot.
  ///
  /// In ja, this message translates to:
  /// **'買う'**
  String get buyOrNot;

  /// No description provided for @tooExpensive.
  ///
  /// In ja, this message translates to:
  /// **'高い…'**
  String get tooExpensive;

  /// No description provided for @goodDeal.
  ///
  /// In ja, this message translates to:
  /// **'お得！'**
  String get goodDeal;

  /// No description provided for @costPrice.
  ///
  /// In ja, this message translates to:
  /// **'仕入れ値'**
  String get costPrice;

  /// No description provided for @sellingPrice.
  ///
  /// In ja, this message translates to:
  /// **'売値'**
  String get sellingPrice;

  /// No description provided for @profit.
  ///
  /// In ja, this message translates to:
  /// **'利益'**
  String get profit;

  /// No description provided for @revenue.
  ///
  /// In ja, this message translates to:
  /// **'売上'**
  String get revenue;

  /// No description provided for @profitMargin.
  ///
  /// In ja, this message translates to:
  /// **'利益率'**
  String get profitMargin;

  /// No description provided for @daily.
  ///
  /// In ja, this message translates to:
  /// **'日次'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In ja, this message translates to:
  /// **'週次'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In ja, this message translates to:
  /// **'月次'**
  String get monthly;

  /// No description provided for @badge.
  ///
  /// In ja, this message translates to:
  /// **'バッジ'**
  String get badge;

  /// No description provided for @ranking.
  ///
  /// In ja, this message translates to:
  /// **'ランキング'**
  String get ranking;

  /// No description provided for @aiCoach.
  ///
  /// In ja, this message translates to:
  /// **'AIコーチ'**
  String get aiCoach;

  /// No description provided for @seasonEvent.
  ///
  /// In ja, this message translates to:
  /// **'今月のイベント'**
  String get seasonEvent;

  /// No description provided for @weeklyChallenge.
  ///
  /// In ja, this message translates to:
  /// **'週次チャレンジ'**
  String get weeklyChallenge;

  /// No description provided for @realMission.
  ///
  /// In ja, this message translates to:
  /// **'リアルミッション'**
  String get realMission;

  /// No description provided for @upgradeToSubscription.
  ///
  /// In ja, this message translates to:
  /// **'月¥100で復活する'**
  String get upgradeToSubscription;

  /// No description provided for @upgradeToLifetime.
  ///
  /// In ja, this message translates to:
  /// **'¥1,000で最強のお店にする'**
  String get upgradeToLifetime;

  /// No description provided for @continueWithAds.
  ///
  /// In ja, this message translates to:
  /// **'レベル1だけ続ける（広告あり）'**
  String get continueWithAds;

  /// No description provided for @bankruptcyTitle.
  ///
  /// In ja, this message translates to:
  /// **'お店が閉店しました…'**
  String get bankruptcyTitle;

  /// No description provided for @bankruptcyMessage.
  ///
  /// In ja, this message translates to:
  /// **'でも大丈夫！\n経営のプロになる方法があるよ！'**
  String get bankruptcyMessage;

  /// No description provided for @trialDaysLeft.
  ///
  /// In ja, this message translates to:
  /// **'{days}日間の無料体験'**
  String trialDaysLeft(int days);

  /// No description provided for @parentDashboard.
  ///
  /// In ja, this message translates to:
  /// **'親ダッシュボード'**
  String get parentDashboard;

  /// No description provided for @learningProgress.
  ///
  /// In ja, this message translates to:
  /// **'学習進捗'**
  String get learningProgress;

  /// No description provided for @conceptMastery.
  ///
  /// In ja, this message translates to:
  /// **'マスターした概念'**
  String get conceptMastery;

  /// No description provided for @aiCoachAdvice.
  ///
  /// In ja, this message translates to:
  /// **'経営コーチのアドバイス'**
  String get aiCoachAdvice;

  /// No description provided for @thankYou.
  ///
  /// In ja, this message translates to:
  /// **'ありがとう！'**
  String get thankYou;

  /// No description provided for @askMore.
  ///
  /// In ja, this message translates to:
  /// **'もっと聞く'**
  String get askMore;

  /// No description provided for @goalAchieved.
  ///
  /// In ja, this message translates to:
  /// **'目標達成！'**
  String get goalAchieved;

  /// No description provided for @emailLabel.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレス'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ja, this message translates to:
  /// **'パスワード'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In ja, this message translates to:
  /// **'ログイン'**
  String get loginButton;

  /// No description provided for @signupButton.
  ///
  /// In ja, this message translates to:
  /// **'新規登録'**
  String get signupButton;

  /// No description provided for @logout.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト'**
  String get logout;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// No description provided for @next.
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get next;

  /// No description provided for @back.
  ///
  /// In ja, this message translates to:
  /// **'もどる'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In ja, this message translates to:
  /// **'確認'**
  String get confirm;

  /// No description provided for @errorOccurred.
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In ja, this message translates to:
  /// **'ネットワークエラー'**
  String get networkError;

  /// No description provided for @loading.
  ///
  /// In ja, this message translates to:
  /// **'読み込み中…'**
  String get loading;

  /// No description provided for @goodMorning.
  ///
  /// In ja, this message translates to:
  /// **'おはよう！今日もがんばろう！'**
  String get goodMorning;

  /// No description provided for @dayResult.
  ///
  /// In ja, this message translates to:
  /// **'今日の結果'**
  String get dayResult;

  /// No description provided for @shopName.
  ///
  /// In ja, this message translates to:
  /// **'{name}のお店'**
  String shopName(String name);

  /// No description provided for @customers.
  ///
  /// In ja, this message translates to:
  /// **'お客さん'**
  String get customers;

  /// No description provided for @inventory.
  ///
  /// In ja, this message translates to:
  /// **'在庫'**
  String get inventory;

  /// No description provided for @stockAmount.
  ///
  /// In ja, this message translates to:
  /// **'{amount}個仕入れる'**
  String stockAmount(int amount);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
