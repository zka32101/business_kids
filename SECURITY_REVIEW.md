# セキュリティ調査レポート（business_kids）

調査日: 2026-08-07
対象: Firestore セキュリティルール / クライアント（Flutter）/ Cloud Functions

## 🔴 Critical: `children.hasPremium` / `planType` の課金バイパス（修正済み）

**該当ファイル**: `firestore.rules`

### 問題

`children` ドキュメントの `update` ルールが、`onlyFields([...])` の許可リストに
`planType` と `hasPremium` を含めていた。

```
allow update: if isAuthenticated()
              && request.auth.uid == resource.data.parentUid
              && onlyFields([..., 'planType', 'hasPremium', 'updatedAt']);
```

この2フィールドは以下の箇所でプレミアム判定に使われている（サーバー側の課金検証を経ない、
クライアント発の値がそのまま信頼される）:

- `lib/services/game_logic_service.dart` の `shouldTriggerBankruptcy()`:
  `if (child.hasPremium) return false;` → 無料トライアル終了後の「倒産（課金誘導）」画面を
  スキップできる。
- `lib/models/child.dart` の `isTrialExpired` / `shouldShowBankruptcy`。

一方、RevenueCat の実際の購入状態は `iap_provider.dart` の `iapState`（アプリ内メモリ）で
管理されており、`children.hasPremium/planType` を書き換える正規のコードパスはアプリ内に
存在しない（作成時に `false` / `'free'` を書き込むのみ）。

つまりこのフィールドは **アプリの正規フローからは使われないのに、Firestore ルール上は
誰でも直接書き換え可能** という状態だった。認証済みユーザー（自分の子どもドキュメントの
親ロールを持つだけ）であれば、Firestore クライアント SDK / REST API を直接叩いて

```
children/{自分の子のchildId} を update({ hasPremium: true, planType: 'lifetime' })
```

とするだけで、ストアの決済を一切通さずプレミアム機能・無料トライアル制限の恒久解除が
できてしまう（決済バイパスの権限昇格）。

### 修正内容

`planType` / `hasPremium` を `update` の許可フィールドから除外し、さらに
書き換え不可（immutable）であることを明示的に強制した:

```
allow update: if isAuthenticated()
              && request.auth.uid == resource.data.parentUid
              && onlyFields([...])  // planType, hasPremium を含まない
              && request.resource.data.planType == resource.data.planType
              && request.resource.data.hasPremium == resource.data.hasPremium;
```

これにより、`children` 作成時に強制される `planType == 'free'` / `hasPremium == false`
（既存の `create` ルール）以降、これらのフィールドはクライアントから **一切変更不可** になる。
プレミアム化を実データに反映する場合は、ストアのレシート/Webhookを検証した
Cloud Functions（Admin SDK、ルールをバイパス）からのみ書き込む設計にする必要がある。

## 🔴 High: `children.create` にフィールド制限・初期値検証が無い（修正済み）

**該当ファイル**: `firestore.rules`

自己レビュー（`/code-review`）で指摘。`children` の `create` ルールは `planType == 'free'` /
`hasPremium == false` のみをチェックしており、`onlyFields()` によるフィールド制限も
値の範囲チェックも無かった。そのため、認証済みユーザーは自分の子ドキュメント作成時に

```
children.add({
  parentUid: myUid, planType: 'free', hasPremium: false,
  totalProfit: 999999999, totalRevenue: 999999999,
  currentLevel: 99, storeLevel: 'mega', consecutiveDays: 365, ...
})
```

のように任意の初期値を仕込め、一切プレイせず最大進捗・最大売上を偽装できた。
`update` ルールで `planType`/`hasPremium` を締めても、`create` 時点で好きな値を
埋め込めては同じ「クライアントが不正に進捗・収益を自己申告できる」問題が残ってしまう。

### 修正内容

`create` ルールに `onlyFields()`（許可フィールドの固定）と、初期値の強制
（`totalProfit == 0`、`totalRevenue == 0`、`consecutiveDays == 0`、
`currentLevel in [1, 2, 3]`、`storeLevel == 'small'`）を追加した。

## 🟢 Fixed（同一PR内で発見・修正）: `onlyFields` の判定方法が原因で `children.update` が実質使用不能だった

**該当ファイル**: `firestore.rules`

自己レビューで、既存の `onlyFields(fields)` ヘルパーが
`request.resource.data.keys().hasOnly(fields)` （＝更新後のドキュメント全体のキー集合）
をチェックしていたことが判明。`children` ドキュメントには `parentUid` / `createdAt` が
常に存在するが、これらは `update` の許可リストに含まれていなかったため、
`FirestoreService.updateChild()`（`ChildNotifier.updateLevel()` からレベルアップ時に
呼ばれる唯一の呼び出し元）による更新は **常に `permission-denied` で拒否され、
レベルアップが Firestore に保存されていなかった**（本PRの変更前から存在した不具合）。

同じ許可リストを本PRで書き換える箇所だったため、合わせて修正した。
「今回の書き込みで実際に変化したフィールド」だけを見る `onlyChangedFields()`
（`request.resource.data.diff(resource.data).affectedKeys().hasOnly(fields)`）を追加し、
`users.update` / `children.update` をこちらに切り替えた。未変更フィールドの存在に
左右されず、`planType`/`hasPremium` を書き換えようとした場合はこれまで通り拒否される。

## 🟡 Medium: `totalRevenue` / `totalProfit` / `gameSessions` の値検証不足（未修正・要検討）

- `children.update` は `totalProfit` / `totalRevenue` を任意の値に直接上書き可能
  （`FieldValue.increment` を強制する手段がルール上ない）。
- `gameSessions` の `create` ルールは所有者チェックのみで、`totalRevenue` /
  `totalProfit` / `sales` の内容が実際のゲームロジック（`GameLogicService` の価格・
  利益計算）と整合しているかを検証していない。捏造した `gameSessions` ドキュメントを
  直接作成すると、`onGameSessionCompleted` / `updateRanking` Cloud Functions が
  それを正として `children.totalProfit` の加算やランキング・コンセプトマスタリーを
  更新してしまう。

対子ども向けの経営ゲームであり金銭的実害は小さいが、ランキング・バッジ・週次レポートの
公平性に影響する。恒久対応にはゲームロジックの再計算をサーバー側（Cloud Functions /
Callable Function）に寄せ、クライアントは「今日プレイした」というイベントのみを送る設計への
見直しを推奨する。今回はスコープを課金バイパスの修正に絞り、本項目は今後の改修候補として
記録するに留めた。

## 🟡 Medium: Claude(Anthropic) API キーをエンドユーザーが直接クライアントに保存・利用

**該当ファイル**: `lib/screens/game/profile_tab.dart`, `lib/services/claude_api_service.dart`

「AIコーチの設定」画面から利用者（保護者想定だが子ども向け端末からもアクセス可能）が
自分の Anthropic API キー (`sk-ant-...`) を入力し、`flutter_secure_storage` に保存した上で、
モバイルクライアントから直接 `https://api.anthropic.com/v1/messages` を呼び出す実装になっている。

- 保存先はデバイスのセキュアストレージであり即座に漏洩するものではないが、
  サービス側の API キーではなく「利用者が持ち込んだ個人の課金キー」を子ども向けアプリの
  クライアントで直接使う設計は、以下のリスクがある。
  - 家庭で共有する端末・脱獄/root端末ではキーが取得され得る。
  - サーバー側の利用量制御・レート制限・不適切な入力のフィルタリングが一切ない
    （子ども向けアプリから未検閲のプロンプトが直接 LLM API に送られる）。
- 推奨改修: Cloud Functions（Callable）経由でリクエストをプロキシし、APIキーは
  サーバー側のシークレットとして管理する。子ども向けサービスとしてコンテンツ
  モデレーションやレート制御をサーバー側に集約することも容易になる。

コード変更を伴う大きめの改修（バックエンド追加）となるため、本PRでは対応せず
推奨事項として記録した。

## その他確認事項（問題なし）

- `google-services.json` / `GoogleService-Info.plist` / `firebase_options.dart` /
  `key.properties` / `.env` 等の秘匿情報は `.gitignore` により未コミットであることを確認。
- Android `AndroidManifest.xml` に不要な `exported` コンポーネントや平文通信許可は無し。
- Firestore の他コレクション（`gameSessions` 以外の更新系）はおおむね
  「自分の子どものドキュメントのみ」「Cloud Functions 経由のみ」の原則を守っている。
