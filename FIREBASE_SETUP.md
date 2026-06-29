# Firebase セットアップ手順

## 1. Firebase プロジェクト作成

1. https://console.firebase.google.com/ を開く
2. 「プロジェクトを追加」をクリック
3. プロジェクト名: `business-kids`（任意）
4. Google Analytics: 有効（推奨）

## 2. Android アプリを追加

1. Firebase Console → プロジェクト → 「アプリを追加」→ Android
2. パッケージ名: `com.example.business_kids`
   ※ android/app/build.gradle.kts の applicationId を確認
3. `google-services.json` をダウンロード
4. 配置: `android/app/google-services.json`

## 3. iOS アプリを追加（iOS ビルドする場合）

1. Firebase Console → 「アプリを追加」→ Apple
2. Bundle ID: `com.example.businessKids`
   ※ ios/Runner.xcodeproj を Xcode で開いて Bundle ID を確認
3. `GoogleService-Info.plist` をダウンロード
4. 配置: `ios/Runner/GoogleService-Info.plist`

## 4. Firebase サービスを有効化

### Authentication
- Firebase Console → Authentication → 「始める」
- ログイン方法 → メール/パスワード → 有効化

### Firestore Database
- Firebase Console → Firestore Database → 「データベースを作成」
- 本番環境モード（セキュリティルールはこのリポジトリの firestore.rules を使用）
- ロケーション: `asia-northeast1`（東京）推奨

### セキュリティルールのデプロイ
```bash
# Firebase CLI をインストール（未インストールの場合）
npm install -g firebase-tools

# ログイン
firebase login

# プロジェクトIDを .firebaserc に設定
# "YOUR_FIREBASE_PROJECT_ID" を実際のプロジェクトIDに変更

# ルールをデプロイ
firebase deploy --only firestore:rules,firestore:indexes
```

### Cloud Functions のデプロイ
> **注意**: このプロジェクトは Google Drive (G:\) 上にあるため、
> `functions/node_modules` の書き込みが失敗します。
> 以下の手順でローカルドライブを経由してください。

```powershell
# 1. ローカルに functions をコピー
robocopy "G:\マイドライブ\apps\business_kids\functions" "C:\Users\Administrator\bk-functions" /E /XD node_modules lib

# 2. ローカルで npm install & ビルド
cd C:\Users\Administrator\bk-functions
npm install
npm run build

# 3. コンパイル済み lib/ をプロジェクトにコピー
Copy-Item -Recurse "C:\Users\Administrator\bk-functions\lib" "G:\マイドライブ\apps\business_kids\functions\lib" -Force

# 4. プロジェクトルートから Firebase デプロイ
cd "G:\マイドライブ\apps\business_kids"
firebase deploy --only functions
```

## 5. RevenueCat 設定

1. https://app.revenuecat.com/ でアカウント作成
2. 新規プロジェクト → Android/iOS アプリを追加
3. API Key を取得（Public SDK Key）
4. Entitlement を作成:
   - `premium` → 月額サブスクリプション
   - `lifetime` → 買い切り
5. Offerings を設定:
   - monthly: ¥100/月
   - lifetime: ¥1,000

## 6. ビルド実行

```bash
# Android デバッグ
flutter build apk --debug

# Android リリース
flutter build apk --release

# iOS（Mac 環境で）
flutter build ios --release
```

## 7. 環境変数

RevenueCat API キーはビルド時に渡す:
```bash
flutter build apk --dart-define=REVENUECAT_API_KEY=your_key_here
```

---

**重要**: `google-services.json` と `GoogleService-Info.plist` は
**絶対に Git にコミットしないこと**。
.gitignore に追加済み（確認してください）。
