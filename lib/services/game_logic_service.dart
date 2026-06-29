import 'dart:math';
import '../models/game_session.dart';
import '../models/product.dart';
import '../models/npc.dart';
import '../models/child.dart';
import '../models/session_npc_state.dart';
import '../utils/constants.dart';

class GameLogicService {
  final Random _rng = Random();

  int customersForDay(int level) {
    switch (level) {
      case AppConstants.level1:
        return AppConstants.level1CustomersPerDay;
      case AppConstants.level2:
        return AppConstants.level2MinCustomers +
            _rng.nextInt(AppConstants.level2MaxCustomers - AppConstants.level2MinCustomers);
      case AppConstants.level3:
        return AppConstants.level3MinCustomers +
            _rng.nextInt(AppConstants.level3MaxCustomers - AppConstants.level3MinCustomers);
      default:
        return AppConstants.level1CustomersPerDay;
    }
  }

  bool willCustomerBuy(NpcModel customer, int sellingPrice, int costPrice, int level) {
    if (sellingPrice <= 0) return false;
    final maxAcceptable = customer.preferredMaxPrice ?? (costPrice * 2.5).toInt();
    if (sellingPrice > maxAcceptable) {
      return _rng.nextDouble() < 0.2;
    }
    if (sellingPrice <= costPrice * 1.2) {
      return true;
    }
    return _rng.nextDouble() < 0.85;
  }

  int calculateProfit(int sellingPrice, int costPrice, int quantity, int level) {
    final base = (sellingPrice - costPrice) * quantity;
    if (level == AppConstants.level3) {
      return (base * (1 - AppConstants.level3TaxRate)).round();
    }
    return base;
  }

  List<int> priceOptions(ProductModel product) => [
    (product.costPrice * 1.2).round(),
    (product.costPrice * 1.5).round(),
    (product.costPrice * 1.8).round(),
  ];

  bool shouldTriggerBankruptcy(ChildModel child) {
    if (child.hasPremium) return false;
    return child.trialDaysElapsed >= AppConstants.bankruptcyDay;
  }

  String? topSellingProduct(List<SaleRecord> sales) {
    final counts = <String, int>{};
    for (final s in sales.where((s) => s.customerBought)) {
      counts[s.productName] = (counts[s.productName] ?? 0) + s.quantity;
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String? topProfitProduct(List<SaleRecord> sales) {
    final profits = <String, int>{};
    for (final s in sales.where((s) => s.customerBought)) {
      profits[s.productName] = (profits[s.productName] ?? 0) + s.profit;
    }
    if (profits.isEmpty) return null;
    return profits.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int suggestedStockAmount(int level) {
    switch (level) {
      case AppConstants.level1:
        return 20;
      case AppConstants.level2:
        return _rng.nextInt(30) + 20;
      case AppConstants.level3:
        return _rng.nextInt(50) + 30;
      default:
        return 20;
    }
  }

  double eventMultiplier(NpcModel? eventNpc) {
    if (eventNpc == null) return 1.0;
    switch (eventNpc.npcId) {
      case 'event_reporter':
        return 2.0;
      case 'event_rival':
        return 0.5;
      case 'event_investor':
        return 1.0;
      default:
        return 1.0;
    }
  }

  /// ★ NPC好感度変化を計算（セッション内購入履歴を考慮した複雑ロジック）
  ///
  /// 価格帯の定義:
  ///   格安    : sellingPrice <= costPrice * 1.2  (感謝される)
  ///   適正    : costPrice * 1.2 < price <= costPrice * 1.5  (ちょうど良い)
  ///   やや高め : costPrice * 1.5 < price <= costPrice * 2.0  (高いと感じる)
  ///   ぼったくり: costPrice * 2.0 < price              (怒る)
  ///
  /// 返値: favoriteScore の変化量 (-15 〜 +10)
  int calculateNpcFavoriteDelta(
    int sellingPrice,
    int costPrice,
    bool willBuy,
    SessionNpcState npcState,
  ) {
    if (costPrice <= 0) return 0;

    final ratio = sellingPrice / costPrice;
    final hadConsecutiveOverprice = npcState.hadConsecutiveOverprice;
    final isRegular = npcState.isRegular;

    // ── 購入した場合 ──────────────────────────────────────────
    if (willBuy) {
      if (ratio <= 1.2) {
        // 格安：大変喜ばれる。常連ならさらにお得感が増す
        return isRegular ? 10 : 8;
      } else if (ratio <= 1.5) {
        // 適正：普通に嬉しい
        return isRegular ? 7 : 5;
      } else if (ratio <= 2.0) {
        // やや高め：「まあいいか」という感じ
        return isRegular ? 2 : 0;
      } else {
        // ぼったくり価格で買わされた：連続ぼったくりなら特に怒る
        return hadConsecutiveOverprice ? -15 : -5;
      }
    }

    // ── 見送った（買わなかった）場合 ────────────────────────────
    if (ratio > 2.0) {
      // ぼったくり価格で見送り：連続なら「もう来ない」
      return hadConsecutiveOverprice ? -12 : -3;
    } else if (ratio > 1.5) {
      // やや高めで見送り：少し残念
      return -2;
    } else {
      // 適正・格安なのに買わなかった（在庫切れなど）：変化なし
      return 0;
    }
  }

  /// ★ NPC状態を購入結果で更新して返す
  SessionNpcState applyPurchaseToNpcState(
    SessionNpcState state,
    PurchaseRecord record,
  ) {
    final delta = calculateNpcFavoriteDelta(
      record.sellingPrice,
      record.costPrice,
      record.bought,
      state,
    );

    final newScore = (state.favoriteScore + delta).clamp(0, 100);

    return state.copyWith(
      favoriteScore: newScore,
      isRegular: newScore >= 70,
      dailyHistory: [...state.dailyHistory, record],
    );
  }

  /// ★ 新規：常連さんが友達を連れてくるか判定
  bool shouldBringFriend(int currentFavoriteScore, int level) {
    if (currentFavoriteScore < 70) return false;  // 常連以上必須

    final chance = switch (level) {
      1 => 0.0,
      2 => 0.15,
      3 => 0.25,
      _ => 0.0,
    };
    return _rng.nextDouble() < chance;
  }

  /// ★ 常連データを考慮した購入判定
  /// [npcState] が null の場合は従来の willCustomerBuy にフォールバック
  bool willCustomerBuyWithFavorite(
    NpcModel customer,
    int sellingPrice,
    int costPrice,
    SessionNpcState? npcState,
    int level,
  ) {
    if (sellingPrice <= 0) return false;

    var prob = _calculateBaseProbability(sellingPrice, costPrice);

    // NPC 個別の最大許容価格チェック
    final maxAcceptable =
        customer.preferredMaxPrice ?? (costPrice * 2.5).toInt();
    if (sellingPrice > maxAcceptable) {
      prob = prob * 0.25; // 許容超えはさらに低確率
    }

    if (npcState != null) {
      final fs = npcState.favoriteScore;
      if (fs >= 70) {
        // 常連：高めの値段も少し許容
        prob = (prob + 0.12).clamp(0.0, 1.0);
      } else if (fs < 30) {
        // 嫌われた客：購入意欲が大幅低下
        prob = prob * 0.4;
      }
    }

    return _rng.nextDouble() < prob;
  }

  /// ★ ヘルパー：基本購入確率を計算
  double _calculateBaseProbability(int sellingPrice, int costPrice) {
    if (sellingPrice <= costPrice * 1.2) return 1.0;
    if (sellingPrice <= costPrice * 1.5) return 0.85;
    return 0.2;
  }
}
