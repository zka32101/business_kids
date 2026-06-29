import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const db = admin.firestore();

// ─── 型定義 ──────────────────────────────────────────────────────────────────

interface SaleRecord {
  productId: string;
  productName: string;
  costPrice: number;
  sellingPrice: number;
  quantity: number;
  customerBought: boolean;
}

interface GameSessionData {
  childUid: string;
  level: number;
  date: admin.firestore.Timestamp;
  sales: SaleRecord[];
  isCompleted: boolean;
  totalRevenue: number;
  totalProfit: number;
  totalRegularCount?: number;
}

interface ConceptScores {
  [key: string]: number;
}

// ─── ゲームセッション記録 ─────────────────────────────────────────────────────

/**
 * ゲームセッション完了時：
 * 1. 子どもの累計売上・利益を更新
 * 2. コンセプトマスタリーを更新
 */
export const onGameSessionCompleted = functions
  .region("asia-northeast1")
  .firestore
  .document("gameSessions/{sessionId}")
  .onCreate(async (snap) => {
    const session = snap.data() as GameSessionData;
    if (!session.isCompleted) return;

    const childRef = db.collection("children").doc(session.childUid);

    await db.runTransaction(async (tx) => {
      const childSnap = await tx.get(childRef);
      if (!childSnap.exists) return;

      // 累計更新
      tx.update(childRef, {
        totalRevenue: admin.firestore.FieldValue.increment(session.totalRevenue),
        totalProfit: admin.firestore.FieldValue.increment(session.totalProfit),
        consecutiveDays: admin.firestore.FieldValue.increment(1),
        lastPlayedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    // コンセプトマスタリー更新
    await updateConceptMastery(session);

    functions.logger.info(
      `Session recorded: child=${session.childUid} revenue=${session.totalRevenue} profit=${session.totalProfit}`
    );
  });

// ─── コンセプトマスタリー更新ロジック ────────────────────────────────────────

async function updateConceptMastery(session: GameSessionData): Promise<void> {
  const masteryRef = db.collection("conceptMasteries").doc(session.childUid);

  const snap = await masteryRef.get();
  const current: ConceptScores = snap.exists
    ? (snap.data()?.masteryScores ?? {})
    : {};

  const deltas = calcConceptDeltas(session);
  const updated: ConceptScores = { ...current };

  for (const [key, delta] of Object.entries(deltas)) {
    updated[key] = Math.min(100, Math.max(0, (updated[key] ?? 0) + delta));
  }

  await masteryRef.set(
    {
      childUid: session.childUid,
      masteryScores: updated,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
}

function calcConceptDeltas(session: GameSessionData): ConceptScores {
  const deltas: ConceptScores = {};
  const sales = session.sales.filter((s) => s.customerBought);

  if (sales.length === 0) return deltas;

  // cost_price: 仕入れ値を認識して販売したか
  const avgMargin =
    sales.reduce((acc, s) => acc + (s.sellingPrice - s.costPrice), 0) /
    sales.length;
  deltas["cost_price"] = avgMargin > 0 ? 5 : 2;

  // profit: 利益が出ているか
  const totalProfit = sales.reduce(
    (acc, s) => acc + (s.sellingPrice - s.costPrice) * s.quantity,
    0
  );
  deltas["profit"] = totalProfit > 0 ? 5 : 0;

  // revenue: 売上があったか
  const totalRevenue = sales.reduce(
    (acc, s) => acc + s.sellingPrice * s.quantity,
    0
  );
  deltas["revenue"] = totalRevenue > 0 ? 3 : 0;

  // price_setting: レベル2以上で複数の価格を試したか
  if (session.level >= 2) {
    const uniquePrices = new Set(sales.map((s) => s.sellingPrice)).size;
    deltas["price_setting"] = uniquePrices >= 2 ? 6 : 3;
  }

  // profit_margin: 利益率 20%以上で高評価
  if (totalRevenue > 0) {
    const margin = totalProfit / totalRevenue;
    deltas["profit_margin"] = margin >= 0.2 ? 7 : margin > 0 ? 3 : 0;
  }

  // tax: レベル3のみ
  if (session.level >= 3) {
    deltas["tax"] = 8;
  }

  // trust: 常連さんを新たに獲得した場合（+5/人、最大+15）
  const newRegularsCount = session.totalRegularCount ?? 0;
  if (newRegularsCount > 0) {
    deltas["trust"] = Math.min(15, newRegularsCount * 5);
  }

  return deltas;
}

// ─── 無料期限切れクリーンアップ ──────────────────────────────────────────────

/**
 * 毎日 AM3:00 (JST) に実行：
 * 無料トライアル期限切れの子どものデータをアーカイブ
 */
export const cleanupExpiredTrials = functions
  .region("asia-northeast1")
  .pubsub.schedule("0 18 * * *") // UTC 18:00 = JST 03:00
  .timeZone("UTC")
  .onRun(async () => {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const expired = await db
      .collection("children")
      .where("planType", "==", "free")
      .where("createdAt", "<", admin.firestore.Timestamp.fromDate(sevenDaysAgo))
      .get();

    const batch = db.batch();
    expired.docs.forEach((doc) => {
      // ゲームを継続できないようフラグを立てる（削除はしない）
      batch.update(doc.ref, { trialExpired: true });
    });

    await batch.commit();

    functions.logger.info(`Marked ${expired.size} expired trials`);
  });

// ─── お小遣いリマインド通知 ───────────────────────────────────────────────────

/**
 * 毎週土曜 AM9:00 (JST) に実行：
 * 子どもの週間成績を親に通知
 */
export const sendWeeklyReport = functions
  .region("asia-northeast1")
  .pubsub.schedule("0 0 * * 6") // UTC 00:00 土曜 = JST 09:00 土曜
  .timeZone("UTC")
  .onRun(async () => {
    // 先週の期間
    const now = new Date();
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    // アクティブな子どもを取得（上限100件/実行）
    const children = await db
      .collection("children")
      .where("lastPlayedAt", ">=", admin.firestore.Timestamp.fromDate(weekAgo))
      .limit(100)
      .get();

    functions.logger.info(`Sending weekly reports for ${children.size} children`);

    for (const childDoc of children.docs) {
      const child = childDoc.data();

      // 先週のセッションを取得
      const sessions = await db
        .collection("gameSessions")
        .where("childUid", "==", childDoc.id)
        .where("date", ">=", admin.firestore.Timestamp.fromDate(weekAgo))
        .get();

      const totalRevenue = sessions.docs.reduce(
        (acc, s) => acc + (s.data().totalRevenue ?? 0),
        0
      );
      const totalProfit = sessions.docs.reduce(
        (acc, s) => acc + (s.data().totalProfit ?? 0),
        0
      );

      functions.logger.info(
        `Child ${child.name}: ${sessions.size} sessions, ¥${totalRevenue} revenue, ¥${totalProfit} profit`
      );

      // FCM 通知（親の FCM トークンがあれば送信）
      // 実装は親ユーザーの FCM トークン管理後に追加
    }
  });

// ─── シーズンイベント配信 ─────────────────────────────────────────────────────

/**
 * 毎月1日 AM6:00 (JST) に実行：
 * 月ごとのシーズンイベントを作成
 */
export const deliverSeasonEvent = functions
  .region("asia-northeast1")
  .pubsub.schedule("0 21 1 * *") // UTC 21:00 1日 = JST 06:00 2日（近似）
  .timeZone("UTC")
  .onRun(async () => {
    const now = new Date();
    const month = now.getMonth() + 1;

    const seasonEvents: Record<number, { title: string; description: string; multiplier: number }> = {
      1:  { title: "お正月セール",     description: "新年！売上2倍のチャンス！",       multiplier: 2.0 },
      2:  { title: "バレンタイン",     description: "チョコが売れる！",               multiplier: 1.5 },
      3:  { title: "卒業シーズン",     description: "お菓子の需要が高まる！",          multiplier: 1.3 },
      4:  { title: "お花見",          description: "飲み物が飛ぶように売れる！",       multiplier: 1.5 },
      5:  { title: "ゴールデンウィーク", description: "観光客が大勢やってくる！",       multiplier: 2.0 },
      6:  { title: "梅雨入り",        description: "室内で食べるものが売れる！",       multiplier: 1.2 },
      7:  { title: "夏まつり",        description: "アイスと飲み物が大人気！",        multiplier: 1.8 },
      8:  { title: "夏休み",          description: "子どもたちがたくさん来る！",       multiplier: 1.5 },
      9:  { title: "運動会シーズン",   description: "お弁当需要が急上昇！",           multiplier: 1.4 },
      10: { title: "ハロウィン",       description: "お菓子が爆発的に売れる！",        multiplier: 1.8 },
      11: { title: "秋の収穫祭",      description: "季節の食べ物が人気！",           multiplier: 1.3 },
      12: { title: "クリスマス",       description: "年末！最大の稼ぎどき！",         multiplier: 2.5 },
    };

    const event = seasonEvents[month];
    if (!event) return;

    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

    await db.collection("seasonEvents").add({
      ...event,
      month,
      startAt: admin.firestore.Timestamp.fromDate(startOfMonth),
      endAt:   admin.firestore.Timestamp.fromDate(endOfMonth),
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info(`Season event created: ${event.title} (x${event.multiplier})`);
  });

// ─── ランキング更新 ───────────────────────────────────────────────────────────

/**
 * ゲームセッション作成時にランキングを更新
 */
export const updateRanking = functions
  .region("asia-northeast1")
  .firestore
  .document("gameSessions/{sessionId}")
  .onCreate(async (snap) => {
    const session = snap.data() as GameSessionData;
    if (!session.isCompleted || session.totalProfit <= 0) return;

    const weekStart = getWeekStart();

    const rankRef = db
      .collection("rankings")
      .doc(`week_${weekStart.getFullYear()}_${getWeekNumber(weekStart)}_level${session.level}`);

    await rankRef.set(
      {
        weekStart: admin.firestore.Timestamp.fromDate(weekStart),
        level: session.level,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // 子どものスコアを更新
    await rankRef
      .collection("scores")
      .doc(session.childUid)
      .set(
        {
          childUid: session.childUid,
          totalProfit: admin.firestore.FieldValue.increment(session.totalProfit),
          sessionCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
  });

// ─── ユーティリティ ───────────────────────────────────────────────────────────

function getWeekStart(): Date {
  const now = new Date();
  const day = now.getDay();
  const diff = now.getDate() - day + (day === 0 ? -6 : 1);
  const monday = new Date(now);
  monday.setDate(diff);
  monday.setHours(0, 0, 0, 0);
  return monday;
}

function getWeekNumber(date: Date): number {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  return Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
}
