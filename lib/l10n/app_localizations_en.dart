// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Business Kids';

  @override
  String get playAsChild => 'Play as Child';

  @override
  String get parentLogin => 'Parent Login';

  @override
  String get level1 => 'Level 1';

  @override
  String get level2 => 'Level 2';

  @override
  String get level3 => 'Level 3';

  @override
  String get level1Desc => 'Grades 1-3 · Easy';

  @override
  String get level2Desc => 'Grades 3-5 · Normal';

  @override
  String get level3Desc => 'Grades 5-6 · Hard';

  @override
  String get tabGame => 'Game';

  @override
  String get tabLedger => 'Ledger';

  @override
  String get tabProfile => 'Profile';

  @override
  String get todaySales => 'Today\'s Sales';

  @override
  String get totalProfit => 'Total Profit';

  @override
  String get stockUp => 'Stock Up';

  @override
  String get sell => 'Sell';

  @override
  String get setPrice => 'Set Price';

  @override
  String get buyOrNot => 'Buy';

  @override
  String get tooExpensive => 'Too expensive…';

  @override
  String get goodDeal => 'Great deal!';

  @override
  String get costPrice => 'Cost Price';

  @override
  String get sellingPrice => 'Selling Price';

  @override
  String get profit => 'Profit';

  @override
  String get revenue => 'Revenue';

  @override
  String get profitMargin => 'Profit Margin';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get badge => 'Badge';

  @override
  String get ranking => 'Ranking';

  @override
  String get aiCoach => 'AI Coach';

  @override
  String get seasonEvent => 'Monthly Event';

  @override
  String get weeklyChallenge => 'Weekly Challenge';

  @override
  String get realMission => 'Real Mission';

  @override
  String get upgradeToSubscription => 'Revive for ¥100/month';

  @override
  String get upgradeToLifetime => 'Get the Ultimate Shop for ¥1,000';

  @override
  String get continueWithAds => 'Continue Level 1 (with ads)';

  @override
  String get bankruptcyTitle => 'Your shop closed…';

  @override
  String get bankruptcyMessage =>
      'But don\'t worry!\nYou can become a business pro!';

  @override
  String trialDaysLeft(int days) {
    return '$days days free trial';
  }

  @override
  String get parentDashboard => 'Parent Dashboard';

  @override
  String get learningProgress => 'Learning Progress';

  @override
  String get conceptMastery => 'Mastered Concepts';

  @override
  String get aiCoachAdvice => 'Coach\'s Advice';

  @override
  String get thankYou => 'Thank you!';

  @override
  String get askMore => 'Ask More';

  @override
  String get goalAchieved => 'Goal Achieved!';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get signupButton => 'Sign Up';

  @override
  String get logout => 'Logout';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get confirm => 'Confirm';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get networkError => 'Network error';

  @override
  String get loading => 'Loading…';

  @override
  String get goodMorning => 'Good morning! Let\'s do our best today!';

  @override
  String get dayResult => 'Today\'s Result';

  @override
  String shopName(String name) {
    return '$name\'s Shop';
  }

  @override
  String get customers => 'Customers';

  @override
  String get inventory => 'Inventory';

  @override
  String stockAmount(int amount) {
    return 'Stock $amount items';
  }
}
