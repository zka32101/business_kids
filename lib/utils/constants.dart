class AppConstants {
  AppConstants._();

  // Firebase Collections
  static const String colUsers = 'users';
  static const String colChildren = 'children';
  static const String colGameSessions = 'gameSessions';
  static const String colConvenienceStores = 'convenienceStores';
  static const String colConceptMasteries = 'conceptMasteries';
  static const String colSeasonEvents = 'seasonEvents';
  static const String colWeeklyChallenges = 'weeklyChallenges';
  static const String colRankings = 'rankings';
  static const String colRealMissions = 'realMissions';
  static const String colChildMissions = 'childMissions';
  static const String colAllowanceLinks = 'allowanceLinks';

  // RevenueCat
  static const String rcSubscriptionId = 'JP_100_1M_SUBSCRIPTION';
  static const String rcLifetimeId = 'JP_1000_LIFETIME';

  // Trial
  static const int trialDays = 7;
  static const int bankruptcyDay = 7;

  // Game levels
  static const int level1 = 1;
  static const int level2 = 2;
  static const int level3 = 3;

  // Store tiers
  static const String storeSmall = 'small';
  static const String storeMedium = 'medium';
  static const String storeFull = 'full';

  // Level 1 game params
  static const int level1MaxProducts = 3;
  static const int level1CustomersPerDay = 20;

  // Level 2 game params
  static const int level2MaxProducts = 10;
  static const int level2MinCustomers = 30;
  static const int level2MaxCustomers = 100;

  // Level 3 game params
  static const int level3MaxProducts = 15;
  static const int level3MinCustomers = 30;
  static const int level3MaxCustomers = 100;
  static const double level3TaxRate = 0.05;

  // AI Coach
  static const int aiCoachCallsPerDay = 1;
  static const String claudeModel = 'claude-haiku-4-5-20251001';
  static const int claudeMaxTokens = 200;

  // UI
  static const double borderRadius = 16.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 24.0;
  static const double padding = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingLarge = 24.0;
}

class ConceptKeys {
  ConceptKeys._();

  static const String costPrice = 'cost_price';
  static const String profit = 'profit';
  static const String revenue = 'revenue';
  static const String priceSet = 'price_setting';
  static const String inventory = 'inventory';
  static const String tax = 'tax';
  static const String profitMargin = 'profit_margin';
  static const String competition = 'competition';
  static const String trust = 'trust';  // ★ 新規：信用
}
