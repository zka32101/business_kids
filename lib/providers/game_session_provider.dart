import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_session.dart';
import '../models/npc.dart';
import '../models/product.dart';
import '../models/child.dart';
import '../models/session_npc_state.dart';
import '../models/concept_mastery.dart';
import '../services/firestore_service.dart';
import '../services/game_logic_service.dart';
import '../services/npc_state_service.dart';
import '../services/claude_api_service.dart';
import '../services/challenge_service.dart';
import '../services/badge_service.dart';
import '../services/streak_service.dart';
import '../utils/constants.dart';
import 'child_provider.dart';
import 'ai_coach_provider.dart';

final gameLogicServiceProvider =
    Provider<GameLogicService>((ref) => GameLogicService());

final npcStateServiceProvider = Provider<NpcStateService>(
  (ref) => NpcStateService(ref.read(firestoreServiceProvider).db),
);

final recentSessionsProvider =
    StreamProvider.family<List<GameSessionModel>, String>((ref, childUid) {
  return ref.watch(firestoreServiceProvider).watchRecentSessions(childUid);
});

class GameSessionState {
  final GameSessionModel? session;
  final NpcModel? todayManager;
  final NpcModel? currentCustomer;

  /// 現在の顧客に対応する NPC 状態（好感度・履歴）
  final SessionNpcState? currentNpcState;

  /// 全 NPC の状態マップ（セッション中に更新される）
  final Map<String, SessionNpcState> npcStates;

  final int customersRemaining;
  final bool isDayComplete;
  final bool isLoading;
  final String? error;

  const GameSessionState({
    this.session,
    this.todayManager,
    this.currentCustomer,
    this.currentNpcState,
    this.npcStates = const {},
    this.customersRemaining = 0,
    this.isDayComplete = false,
    this.isLoading = false,
    this.error,
  });

  GameSessionState copyWith({
    GameSessionModel? session,
    NpcModel? todayManager,
    NpcModel? currentCustomer,
    SessionNpcState? currentNpcState,
    Map<String, SessionNpcState>? npcStates,
    int? customersRemaining,
    bool? isDayComplete,
    bool? isLoading,
    String? error,
    bool clearCurrentCustomer = false,
  }) =>
      GameSessionState(
        session: session ?? this.session,
        todayManager: todayManager ?? this.todayManager,
        currentCustomer:
            clearCurrentCustomer ? null : (currentCustomer ?? this.currentCustomer),
        currentNpcState:
            clearCurrentCustomer ? null : (currentNpcState ?? this.currentNpcState),
        npcStates: npcStates ?? this.npcStates,
        customersRemaining: customersRemaining ?? this.customersRemaining,
        isDayComplete: isDayComplete ?? this.isDayComplete,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );

  /// 今日の常連さんの数
  int get newRegularsToday =>
      session?.sales.where((s) => s.npcBecameRegular).length ?? 0;

  /// 今日の常連さんが友達を連れてくる可能性があるか
  bool get hasFriendBonus =>
      npcStates.values.any((s) => s.isBringingFriend);
}

class GameSessionNotifier extends StateNotifier<GameSessionState> {
  final FirestoreService _firestore;
  final GameLogicService _logic;
  final NpcStateService _npcService;
  final Ref _ref;
  final Random _rng = Random();

  GameSessionNotifier(this._firestore, this._logic, this._npcService, this._ref)
      : super(const GameSessionState());

  Future<void> startDay(ChildModel child) async {
    final manager =
        DefaultNpcs.managers[_rng.nextInt(DefaultNpcs.managers.length)];
    final customerCount = _logic.customersForDay(child.currentLevel);

    // Firestore から前日までの NPC 状態をロード
    final npcStates = await _npcService.loadNpcStates(
      child.uid,
      DefaultNpcs.customers,
    );

    // 常連さんが友達を連れてくるか判定
    final updatedStates = {
      for (final entry in npcStates.entries)
        entry.key: entry.value.copyWith(
          isBringingFriend: _logic.shouldBringFriend(
            entry.value.favoriteScore,
            child.currentLevel,
          ),
        ),
    };

    state = GameSessionState(
      session: GameSessionModel(
        childUid: child.uid,
        level: child.currentLevel,
        date: DateTime.now(),
        sales: [],
      ),
      todayManager: manager,
      npcStates: updatedStates,
      customersRemaining: customerCount,
      isDayComplete: false,
    );
  }

  void spawnCustomer() {
    // 常連さん優先で来店（isRegular なら 30% の確率で先に来る）
    final regulars = DefaultNpcs.customers
        .where((c) =>
            state.npcStates[c.npcId]?.isRegular == true &&
            _rng.nextDouble() < 0.3)
        .toList();

    final customer = regulars.isNotEmpty
        ? regulars[_rng.nextInt(regulars.length)]
        : DefaultNpcs.customers[_rng.nextInt(DefaultNpcs.customers.length)];

    final npcState = state.npcStates[customer.npcId] ??
        SessionNpcState.initial(customer.npcId, customer.name, customer.emoji);

    state = state.copyWith(
      currentCustomer: customer,
      currentNpcState: npcState,
    );
  }

  void processSale(ProductModel product, int sellingPrice, int quantity) {
    final customer = state.currentCustomer;
    final npcState = state.currentNpcState;
    if (customer == null || state.session == null) return;

    // 好感度を考慮した購入判定
    final bought = _logic.willCustomerBuyWithFavorite(
      customer,
      sellingPrice,
      product.costPrice,
      npcState,
      state.session!.level,
    );

    // 購入記録を作成
    final record = PurchaseRecord(
      productId: product.productId,
      productName: product.name,
      sellingPrice: sellingPrice,
      costPrice: product.costPrice,
      bought: bought,
      timestamp: DateTime.now(),
    );

    // NPC 状態を更新（好感度変化・常連化チェック）
    final updatedNpcState = npcState != null
        ? _logic.applyPurchaseToNpcState(npcState, record)
        : SessionNpcState.initial(customer.npcId, customer.name, customer.emoji);

    final becameRegular = updatedNpcState.justBecameRegular;

    // 好感度変化量を計算（UI 表示・Firestore 保存用）
    final scoreDelta = npcState != null
        ? updatedNpcState.favoriteScore - npcState.favoriteScore
        : 0;

    final sale = SaleRecord(
      productId: product.productId,
      productName: product.name,
      costPrice: product.costPrice,
      sellingPrice: sellingPrice,
      quantity: quantity,
      customerBought: bought,
      timestamp: DateTime.now(),
      customerNpcId: customer.npcId,
      npcFavoriteScoreDelta: scoreDelta,
      npcBecameRegular: becameRegular,
    );

    // NPC 状態マップを更新
    final updatedNpcStates = Map<String, SessionNpcState>.from(state.npcStates)
      ..[customer.npcId] = updatedNpcState.copyWith(
        isRegular: updatedNpcState.favoriteScore >= 70,
      );

    final updatedSession = state.session!.addSale(sale);
    final remaining = state.customersRemaining - 1;

    state = state.copyWith(
      session: updatedSession,
      npcStates: updatedNpcStates,
      customersRemaining: remaining,
      isDayComplete: remaining <= 0,
      clearCurrentCustomer: true,
    );
  }

  Future<void> completeDay(ChildModel child) async {
    final session = state.session;
    if (session == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final sales = session.sales;
      final topSelling = _logic.topSellingProduct(sales);
      final topProfit = _logic.topProfitProduct(sales);

      // AIコーチコメント生成（オプション）
      String? coachCommentReasoning;
      try {
        final service = await _getClaudeApiService();
        if (service != null) {
          final mastery = await _firestore.db
              .collection(AppConstants.colConceptMasteries)
              .doc(child.uid)
              .get();
          final masteryModel = mastery.exists
              ? ConceptMasteryModel.fromFirestore(mastery)
              : null;

          coachCommentReasoning =
              await service.generateCoachCommentWithCausality(
            GameSessionModel(
              childUid: session.childUid,
              level: session.level,
              date: session.date,
              sales: sales,
              isCompleted: true,
              topSellingProduct: topSelling,
              topProfitProduct: topProfit,
              totalRegularCount: session.totalRegularCount,
            ),
            child,
            masteryModel,
          );
        }
      } catch (_) {
        // AIコメント取得失敗時は無視（必須ではない）
      }

      final finalSession = GameSessionModel(
        childUid: session.childUid,
        level: session.level,
        date: session.date,
        sales: sales,
        isCompleted: true,
        topSellingProduct: topSelling,
        topProfitProduct: topProfit,
        totalRegularCount: session.totalRegularCount,
        coachCommentReasoning: coachCommentReasoning,
      );

      // ゲームセッションと NPC 状態を同時に保存
      await Future.wait([
        _firestore.saveGameSession(finalSession),
        _npcService.saveNpcStates(child.uid, state.npcStates),
      ]);

      final summary = finalSession.dailySummary;

      // TODO: Phase 1 - ゲーム性強化（チャレンジ・ストリーク・バッジ）
      // // チャレンジ進捗更新
      // final challengeService = ChallengeService(_firestore.db);
      // final today = DateTime.now();
      // try {
      //   await challengeService.updateDailyChallengeProgress(
      //     child.uid,
      //     today,
      //     'sales',
      //     summary.totalRevenue,
      //   );
      //   // ... 省略
      // } catch (_) {}

      // // ストリーク更新
      // final streakService = StreakService(_firestore.db);
      // try {
      //   await streakService.updateStreakOnGamePlay(child.uid);
      // } catch (_) {}

      // // バッジ自動付与チェック
      // final badgeService = BadgeService(_firestore.db);
      // // ... 省略

      await _firestore.updateChildProfit(
          child.uid, summary.totalProfit, summary.totalRevenue);

      state = state.copyWith(
        session: finalSession,
        isDayComplete: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<ClaudeApiService?> _getClaudeApiService() async {
    return await _ref.read(claudeApiServiceProvider.future);
  }

  List<ProductModel> productsForLevel(int level) {
    switch (level) {
      case AppConstants.level1:
        return DefaultProducts.level1;
      case AppConstants.level2:
        return DefaultProducts.level2;
      case AppConstants.level3:
        return DefaultProducts.level3;
      default:
        return DefaultProducts.level1;
    }
  }

  List<int> priceOptionsFor(ProductModel product) =>
      _logic.priceOptions(product);
}

final gameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, GameSessionState>((ref) {
  return GameSessionNotifier(
    ref.read(firestoreServiceProvider),
    ref.read(gameLogicServiceProvider),
    ref.read(npcStateServiceProvider),
    ref,
  );
});
