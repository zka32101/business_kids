# ビジネスキッズ — コンセプト & 機能一覧

> バージョン: 1.0.0+1 / 作成日: 2026-06-10

---

## アプリ概要

| 項目 | 内容 |
|------|------|
| アプリ名 | ビジネスキッズ（Business Kids） |
| ジャンル | コンビニ経営シミュレーション × 金銭教育 |
| 対象年齢 | 小学2年生〜6年生（7〜12歳） |
| プラットフォーム | iOS 14+ / Android 8+ |
| 言語 | 日本語（日本語 / 英語対応） |
| 価格モデル | フリーミアム（7日間無料体験 → 課金 or 広告） |

---

## コンセプト

> **「楽しく遊びながら、お金の仕組みを体で覚える」**

小学生がコンビニの店長となり、商品の仕入れ・値付け・販売・利益計算を体験する。
抽象的な金融知識を「ゲームの結果」として直感的に理解させることで、
算数・家庭科の補完教育としても機能する。

### 教育コンセプト 3 本柱

1. **体験学習** — 実際に値段を決めて売り、利益が出るか失敗するかを体感
2. **段階的習熟** — レベル 1〜3 の難易度で概念を少しずつ積み上げ
3. **親子連携** — 親ダッシュボードで学習進捗を可視化、家庭での会話を促す

---

## 学習コンセプト（8 概念）

| キー | 概念名 | 習得タイミング |
|------|--------|---------------|
| `cost_price` | 仕入れ値（原価） | レベル 1 から |
| `profit` | 利益 | レベル 1 から |
| `revenue` | 売上 | レベル 1 から |
| `price_setting` | 値段設定 | レベル 2 から |
| `inventory` | 在庫管理 | レベル 2 から |
| `profit_margin` | 利益率 | レベル 2 から |
| `competition` | 競合・市場 | レベル 3 から |
| `tax` | 消費税（5%） | レベル 3 から |

---

## ゲームレベル設計

### レベル 1 — はじめてのお店（小2〜3 相当）
- 商品: レモネード 1 種のみ
- 客数: 毎日 20 人（固定）
- 値段: 固定（自分で決めない）
- 習得概念: 仕入れ値・売上・利益の基礎
- 店舗: 小さなお店（`StoreLevel.small`）

### レベル 2 — お店をひろげよう（小4〜5 相当）
- 商品: 3〜10 種（レモネード・おにぎり・コーヒー など）
- 客数: 30〜100 人/日（ランダム）
- 値段: 3 択から選ぶ（仕入れ値の 1.2倍 / 1.5倍 / 1.8倍）
- 習得概念: 値段設定・在庫・利益率
- 店舗: 中くらいのお店（`StoreLevel.medium`）

### レベル 3 — プロの店長（小6 相当）
- 商品: 最大 15 種（お弁当・アイス 等を追加）
- 客数: 30〜100 人/日（ランダム）
- 値段: 自由入力（上限なし）
- 消費税: 5% が自動計上
- 習得概念: 競合・市場価格・税金
- 店舗: 大きなお店（`StoreLevel.full`）

---

## 商品一覧

| 商品 ID | 名前 | 絵文字 | 仕入れ値 | 定価 | 解放レベル |
|---------|------|--------|---------|------|-----------|
| lemonade | レモネード | 🍋 | ¥50 | ¥100 | 1 |
| onigiri | おにぎり | 🍙 | ¥80 | ¥150 | 2 |
| coffee | コーヒー | ☕ | ¥60 | ¥130 | 2 |
| bento | お弁当 | 🍱 | ¥300 | ¥550 | 3 |
| ice | アイス | 🍦 | ¥100 | ¥200 | 3 |

---

## 機能一覧

### ゲーム機能

| 機能 | 説明 |
|------|------|
| 1 日ゲームサイクル | 朝〜夕方を 1 セッションでシミュレーション |
| 接客シミュレーション | NPC 客が値段に応じて購入 / 見送りを判断 |
| 値段設定 | レベルに応じた価格選択 UI |
| 日報カード | 1 日の売上・利益・利益率・ベスト商品を表示 |
| 連続プレイ日数 | 継続ログインでカウント |
| AI コーチ | Claude Haiku が 1 日 1 回フィードバックコメントを生成 |
| シーズンイベント | 月ごとの売上倍率イベント（バレンタイン、夏祭り 等） |
| ウィークリーチャレンジ | 週次目標ミッション |
| ランキング | 週次・全国利益ランキング |
| 破産画面 | トライアル終了時に表示、課金への導線 |

### 学習機能

| 機能 | 説明 |
|------|------|
| コンセプト習熟度 | 8 つの金融概念を 0〜100 スコアで管理 |
| 台帳タブ | 過去 7 日の売上グラフ（棒グラフ）+ 概念習熟度タイル |
| 週次レポート | 親へのプッシュ通知 + ダッシュボード集計 |

### 認証 & ユーザー管理

| 機能 | 説明 |
|------|------|
| 親アカウント | メール/パスワード認証（Firebase Auth） |
| こどもプロフィール | 1 親アカウントに複数こどもを登録可能 |
| こど名・アバター設定 | 初回セットアップ画面 |
| セキュア保存 | JWT トークン / RevenueCat キーは flutter_secure_storage |

### 親ダッシュボード

| 機能 | 説明 |
|------|------|
| こど別切り替え | 複数のこどもを選択して表示 |
| 週次売上グラフ | fl_chart 棒グラフ |
| 概念習熟度マップ | 8 概念のスコアを一覧表示 |
| プラン管理 | 現在のプラン（無料 / サブスク / 買い切り）を表示 |

### 課金 & マネタイズ

| 機能 | 説明 |
|------|------|
| 7 日間無料体験 | 新規登録から 7 日間は全機能利用可 |
| 月額サブスク | `JP_100_1M_SUBSCRIPTION` ¥100/月（RevenueCat） |
| 買い切り | `JP_1000_LIFETIME` ¥1,000（RevenueCat） |
| 広告（無料プラン） | Google Mobile Ads（AdMob）バナー / インタースティシャル |
| 破産ゲートウェイ | トライアル期限後、ゲーム継続には課金が必要 |

---

## 技術スタック

### フロントエンド（Flutter）

| カテゴリ | パッケージ | 用途 |
|---------|-----------|------|
| 状態管理 | flutter_riverpod 2.x | Provider / StateNotifier |
| コード生成 | freezed + json_serializable | モデル定型コード |
| ナビゲーション | go_router | 認証ガード付きルーティング |
| グラフ | fl_chart | 棒グラフ（台帳・ダッシュボード） |
| フォント | NotoSansJP（可変フォント） | 全画面統一フォント |
| アニメーション | lottie | 演出アニメーション |
| 国際化 | flutter_localizations + intl | 日本語 / 英語 |

### バックエンド（Firebase）

| サービス | 用途 |
|---------|------|
| Firebase Auth | 親アカウント認証 |
| Cloud Firestore | ゲームデータ・概念習熟度・ランキング保存 |
| Cloud Functions | セッション完了トリガー / 日次・週次・月次バッチ |
| Firebase Messaging | 週次レポート Push 通知 |
| Firebase Analytics | ユーザー行動分析 |

### Cloud Functions（4 本）

| 関数名 | トリガー | 処理 |
|--------|---------|------|
| `onGameSessionCompleted` | Firestore `gameSessions` 作成 | 概念習熟度スコア更新・ランキング集計 |
| `cleanupExpiredTrials` | Cron 毎日 0:00 | トライアル期限切れユーザーにフラグ |
| `sendWeeklyReport` | Cron 土曜 8:00 | 週次レポート Push + Firestore 集計 |
| `deliverSeasonEvent` | Cron 毎月 1 日 | 月次シーズンイベントドキュメント生成 |

### Firestore セキュリティルール 設計方針

- `users/{userId}`: 本人のみ読み書き
- `children/{childId}`: 親 UID が一致する場合のみ読み書き（子は書き込み不可）
- `gameSessions/{sessionId}`: 親のみ読み取り / 作成
- `conceptMasteries/{childUid}`: 親のみ読み取り / Cloud Functions のみ書き込み
- `seasonEvents`, `rankings`: 認証ユーザー全員に読み取り公開

---

## ユーザーフロー

```
起動
 └─ 初回 → ログイン選択画面
 │         ├─ 親ログイン → 親ダッシュボード
 │         └─ こどもプレイ → こどもプロフィール選択
 │                           └─ レベル選択 → ゲームホーム
 └─ 2回目以降 → 自動ログイン → 直前の画面へ

ゲームホーム（3 タブ）
 ├─ [ゲーム] — 接客・販売・値段設定
 ├─ [台帳]  — 週次グラフ・概念習熟度
 └─ [プロフ] — こど情報・プラン・バッジ

トライアル期限 → 破産画面 → 課金 or 広告でリトライ
```

---

## Firestore データ構造

```
users/{parentUid}
  ├── email, displayName, createdAt

children/{childUid}
  ├── parentUid, name, avatarId
  ├── currentLevel, storeLevel
  ├── totalProfit, totalRevenue, consecutiveDays
  ├── hasPremium, planType ('free'|'subscription'|'lifetime')
  └── createdAt, lastPlayedAt

gameSessions/{sessionId}
  ├── childUid, date, level
  ├── totalRevenue, totalProfit, totalSalesCount
  ├── averageProfitMargin, sales[]
  └── createdAt

conceptMasteries/{childUid}
  └── scores: { cost_price, profit, revenue, price_setting,
                inventory, profit_margin, competition, tax }

seasonEvents/{eventId}
  ├── month, title, multiplier, emoji
  └── startDate, endDate

rankings/{weekKey}/scores/{childUid}
  └── childName, weeklyProfit, rank
```

---

## ファイル構成

```
business_kids/
 ├── lib/
 │   ├── main.dart                    # エントリポイント + Firebase 初期化
 │   ├── config/router.dart           # GoRouter ルーティング
 │   ├── theme/app_theme.dart         # テーマ・カラー定義
 │   ├── utils/
 │   │   ├── constants.dart           # AppConstants / ConceptKeys
 │   │   ├── app_colors.dart          # カラーパレット
 │   │   └── formatters.dart          # 数値・日付フォーマット
 │   ├── models/
 │   │   ├── user.dart                # UserModel
 │   │   ├── child.dart               # ChildModel / StoreLevel
 │   │   ├── product.dart             # ProductModel / DefaultProducts
 │   │   ├── game_session.dart        # GameSessionModel / SaleRecord / DailySummary
 │   │   ├── npc.dart                 # NpcModel
 │   │   └── concept_mastery.dart     # ConceptMasteryModel
 │   ├── providers/
 │   │   ├── auth_provider.dart       # 認証状態
 │   │   ├── child_provider.dart      # こどもリスト
 │   │   ├── game_session_provider.dart # ゲームセッション管理
 │   │   ├── iap_provider.dart        # RevenueCat 課金状態
 │   │   └── ai_coach_provider.dart   # Claude API コーチ
 │   ├── services/
 │   │   ├── auth_service.dart        # Firebase Auth ラッパー
 │   │   ├── firestore_service.dart   # Firestore CRUD
 │   │   ├── game_logic_service.dart  # ゲームロジック（確率・利益計算）
 │   │   └── claude_api_service.dart  # Claude API 呼び出し
 │   ├── screens/
 │   │   ├── auth/
 │   │   │   ├── login_select_screen.dart
 │   │   │   ├── parent_login_screen.dart
 │   │   │   ├── level_select_screen.dart
 │   │   │   └── child_setup_screen.dart
 │   │   ├── game/
 │   │   │   ├── home_screen.dart         # BottomNav ホスト
 │   │   │   ├── game_tab.dart            # 接客・販売画面
 │   │   │   ├── ledger_tab.dart          # 台帳（グラフ・習熟度）
 │   │   │   ├── profile_tab.dart         # プロフィール・バッジ
 │   │   │   ├── bankruptcy_screen.dart   # 破産・課金誘導
 │   │   │   └── widgets/
 │   │   │       ├── store_display.dart   # 店舗ビジュアル
 │   │   │       ├── customer_card.dart   # NPC 接客カード
 │   │   │       ├── price_selector.dart  # 値段選択 UI
 │   │   │       └── day_result_card.dart # 日報モーダル
 │   │   └── parent/
 │   │       └── parent_dashboard_screen.dart
 │   └── l10n/                        # 国際化リソース
 ├── functions/                       # Cloud Functions (TypeScript)
 │   ├── src/index.ts
 │   └── lib/index.js                 # コンパイル済み
 ├── assets/
 │   ├── fonts/NotoSansJP-*.ttf
 │   ├── images/store/               # 店舗ビジュアル 3 種
 │   ├── images/products/            # 商品バッジ 5 種
 │   ├── images/npcs/                # NPC キャラクター 5 種
 │   ├── images/badges/              # 実績バッジ 3 種
 │   └── images/icons/               # UI アイコン 5 種
 ├── firestore.rules                 # セキュリティルール
 ├── firestore.indexes.json          # 複合インデックス
 ├── firebase.json                   # Firebase CLI 設定
 ├── FIREBASE_SETUP.md               # セットアップ手順
 └── CONCEPT_AND_FEATURES.md        # このファイル
```

---

## ロードマップ（v1.0 以降）

| バージョン | 機能 |
|----------|------|
| v1.1 | お小遣い連携（リアルミッション → QR コード → 保護者が承認） |
| v1.2 | 複数店舗経営（フランチャイズ拡大モード） |
| v1.3 | 友達と対戦（マルチプレイヤーランキング強化） |
| v2.0 | 株式投資入門モード（利益を仮想株式市場に投資） |
