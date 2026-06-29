// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'ビジネスキッズ';

  @override
  String get playAsChild => '子どもでプレイ';

  @override
  String get parentLogin => '親ログイン';

  @override
  String get level1 => 'レベル1';

  @override
  String get level2 => 'レベル2';

  @override
  String get level3 => 'レベル3';

  @override
  String get level1Desc => '小1〜3年向け やさしい';

  @override
  String get level2Desc => '小3〜5年向け ふつう';

  @override
  String get level3Desc => '小5〜6年向け むずかしい';

  @override
  String get tabGame => 'ゲーム';

  @override
  String get tabLedger => '帳簿';

  @override
  String get tabProfile => 'プロフィール';

  @override
  String get todaySales => '今日の売上';

  @override
  String get totalProfit => '合計利益';

  @override
  String get stockUp => '仕入れる';

  @override
  String get sell => '売る';

  @override
  String get setPrice => '値段を決める';

  @override
  String get buyOrNot => '買う';

  @override
  String get tooExpensive => '高い…';

  @override
  String get goodDeal => 'お得！';

  @override
  String get costPrice => '仕入れ値';

  @override
  String get sellingPrice => '売値';

  @override
  String get profit => '利益';

  @override
  String get revenue => '売上';

  @override
  String get profitMargin => '利益率';

  @override
  String get daily => '日次';

  @override
  String get weekly => '週次';

  @override
  String get monthly => '月次';

  @override
  String get badge => 'バッジ';

  @override
  String get ranking => 'ランキング';

  @override
  String get aiCoach => 'AIコーチ';

  @override
  String get seasonEvent => '今月のイベント';

  @override
  String get weeklyChallenge => '週次チャレンジ';

  @override
  String get realMission => 'リアルミッション';

  @override
  String get upgradeToSubscription => '月¥100で復活する';

  @override
  String get upgradeToLifetime => '¥1,000で最強のお店にする';

  @override
  String get continueWithAds => 'レベル1だけ続ける（広告あり）';

  @override
  String get bankruptcyTitle => 'お店が閉店しました…';

  @override
  String get bankruptcyMessage => 'でも大丈夫！\n経営のプロになる方法があるよ！';

  @override
  String trialDaysLeft(int days) {
    return '$days日間の無料体験';
  }

  @override
  String get parentDashboard => '親ダッシュボード';

  @override
  String get learningProgress => '学習進捗';

  @override
  String get conceptMastery => 'マスターした概念';

  @override
  String get aiCoachAdvice => '経営コーチのアドバイス';

  @override
  String get thankYou => 'ありがとう！';

  @override
  String get askMore => 'もっと聞く';

  @override
  String get goalAchieved => '目標達成！';

  @override
  String get emailLabel => 'メールアドレス';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get loginButton => 'ログイン';

  @override
  String get signupButton => '新規登録';

  @override
  String get logout => 'ログアウト';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get close => '閉じる';

  @override
  String get next => '次へ';

  @override
  String get back => 'もどる';

  @override
  String get confirm => '確認';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get networkError => 'ネットワークエラー';

  @override
  String get loading => '読み込み中…';

  @override
  String get goodMorning => 'おはよう！今日もがんばろう！';

  @override
  String get dayResult => '今日の結果';

  @override
  String shopName(String name) {
    return '$nameのお店';
  }

  @override
  String get customers => 'お客さん';

  @override
  String get inventory => '在庫';

  @override
  String stockAmount(int amount) {
    return '$amount個仕入れる';
  }
}
