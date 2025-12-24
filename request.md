# SpatialSync - 位置ベースチャンネル分離オーディオシステム

## 1. プロジェクト概要

### 1.1 コンセプト

複数のスマートフォンを使用して、チャンネル分離オーディオシステムを実現する。
各スマートフォンがサラウンドシステムの1チャンネルとして機能する。

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SpatialSync コンセプト                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                        ┌─────────────┐                                      │
│                        │   ホスト    │                                      │
│                        │  スマホ     │                                      │
│                        │ (音源+制御) │                                      │
│                        └──────┬──────┘                                      │
│                               │ Wi-Fi                                       │
│              ┌────────────────┼────────────────┐                            │
│              │                │                │                            │
│              ▼                ▼                ▼                            │
│     ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                    │
│     │  スマホ L   │   │  スマホ C   │   │  スマホ R   │                    │
│     │ (Left Ch)   │   │ (Center Ch) │   │ (Right Ch)  │                    │
│     └─────────────┘   └─────────────┘   └─────────────┘                    │
│                                                                             │
│     ★ 手動 or UWB位置検出でデバイスにチャンネル割り当て                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Phase 1 開始時の方針

> **重要**: UWBは対応デバイスが限定的（iPhone 11以降、一部Android）なので、
> 最初はUWBなしで手動チャンネル割り当てからスタートする。
> UWB対応は Phase 2 以降で検討。

**Phase 1 の目標:**
- iOS デバイス間での同期再生を実現
- 手動 L/R チャンネル割り当て
- 100ms バッファで安定動作
- Snapcast方式のタイムスタンプ同期

---

## 2. Snapcast スタイル同期の仕組み

### 2.1 基本原理

Snapcastは **タイムスタンプベース同期** を採用し、0.2ms以下の同期偏差を実現している。

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Snapcast方式 タイムスタンプ同期                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  【原理】                                                                   │
│  1. ホストがオーディオチャンクにタイムスタンプを付与                         │
│  2. 各クライアントがNTP風プロトコルでホストと時刻同期                        │
│  3. クライアントは「指定時刻」にオーディオを再生                             │
│  4. サンプル単位（48kHz = 0.02ms）の補正で高精度同期                        │
│                                                                             │
│  【ポイント】                                                               │
│  ・各デバイスが独立して「この音は T=X に再生する」と判断                     │
│  ・ネットワーク遅延の変動は関係ない（十分なバッファがあれば）                │
│  ・クロックドリフトはPLL方式で継続補正                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 オーディオチャンクフォーマット

```
┌────────────────────────────────────────────────────────────────────┐
│                    Audio Chunk Format                              │
├────────┬────────┬────────┬────────┬────────┬───────────────────────┤
│ Magic  │ Version│ SeqNum │PlayTime│ Ch Mask│ Opus/PCM Payload      │
│ 4B     │ 1B     │ 4B     │ 8B     │ 1B     │ Variable              │
└────────┴────────┴────────┴────────┴────────┴───────────────────────┘

Magic: "SSYN" (SpatialSync)
SeqNum: シーケンス番号（パケットロス検出）
PlayTime: 再生すべき時刻（ホスト時刻基準、μs単位）
Ch Mask: チャンネルマスク (bit0=L, bit1=R, bit2=C, ...)
```

### 2.3 時刻同期プロトコル（NTP風）

```
  Client                              Host
     │                                  │
     │──── T1: Request (T1) ──────────►│
     │                                  │
     │◄─── T2,T3: Response (T1,T2,T3) ──│
     │                                  │
     │  T4: Response received           │

  RTT = (T4 - T1) - (T3 - T2)
  Offset = ((T2 - T1) + (T3 - T4)) / 2

  ・5秒ごとに再同期
  ・クロックドリフト補正（PLL方式）
  ・精度目標: ±1ms (95%tile)
```

---

## 3. チャンネル分離

### 3.1 ステレオ (2.0ch) モード

```
入力: ステレオPCM [L, R]
  │
  ├─── デバイスA (Left割り当て)  → [L, L] または [L, 0]
  └─── デバイスB (Right割り当て) → [R, R] または [0, R]
```

### 3.2 サラウンド (5.1ch) モード

```
入力: 5.1ch PCM [FL, FR, C, LFE, SL, SR]
  │
  ├─── デバイスA → [FL]      (Front Left)
  ├─── デバイスB → [FR]      (Front Right)
  ├─── デバイスC → [C + LFE] (Center + Subwoofer mix)
  ├─── デバイスD → [SL]      (Surround Left)
  └─── デバイスE → [SR]      (Surround Right)
```

### 3.3 5.1ch スピーカー配置

```
                    ┌─────┐
                    │  C  │  Center
                    └──┬──┘
                       │
         ┌─────┐       │       ┌─────┐
         │ FL  │───────┼───────│ FR  │  Front L/R
         └─────┘       │       └─────┘
                       │
                  ┌────┴────┐
                  │ Listener │
                  └────┬────┘
                       │
         ┌─────┐       │       ┌─────┐
         │ SL  │───────┴───────│ SR  │  Surround L/R
         └─────┘               └─────┘

  角度目安:
  - FL/FR: 正面から ±22.5° 〜 ±30°
  - SL/SR: 正面から ±90° 〜 ±110°
  - C: 正面 0°
```

---

## 4. 遅延分析

### 4.1 遅延コンポーネント内訳

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     エンドツーエンド遅延分析                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  │ コンポーネント      │ 典型値       │ 最適化後     │                      │
│  ├─────────────────────┼──────────────┼──────────────┤                      │
│  │ 音源キャプチャ      │ 5-20ms       │ 1-5ms        │                      │
│  │ エンコード (Opus)   │ 2-10ms       │ 2-5ms        │                      │
│  │ ネットワーク転送    │ 1-5ms        │ 1-3ms        │                      │
│  │ デコード            │ 1-5ms        │ 1-3ms        │                      │
│  │ バッファリング      │ 20-100ms     │ 20-40ms      │                      │
│  │ オーディオ出力      │ 10-40ms      │ 5-15ms       │                      │
│  │ Bluetooth送信       │ 40-200ms     │ 40-80ms(aptX)│                      │
│  ├─────────────────────┼──────────────┼──────────────┤                      │
│  │ 合計 (BT経由)       │ 79-380ms     │ 70-150ms     │                      │
│  │ 合計 (内蔵スピーカー)│ 39-180ms     │ 30-70ms      │                      │
│  └─────────────────────┴──────────────┴──────────────┘                      │
│                                                                             │
│  ★ 同期において重要なのは「全デバイス間で遅延が揃う」こと                    │
│  ★ 絶対遅延が大きくても、全員同じなら問題なし                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 遅延対策

| 対策 | 効果 |
|------|------|
| 内蔵スピーカー使用 | Bluetooth遅延を回避 (40-200ms削減) |
| aptX LL対応機器 | Bluetooth遅延を40ms程度に抑制 |
| デバイス別遅延補正 | 機種ごとの遅延プロファイル適用 |
| 適応バッファ | ネットワーク状況に応じてバッファ調整 |

---

## 5. 参考技術・アプリ

### 5.1 Snapcast

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Snapcast                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  GitHub: https://github.com/badaix/snapcast                                 │
│  ライセンス: GPL-3.0                                                        │
│                                                                             │
│  【特徴】                                                                   │
│  ・0.2ms以下の同期偏差を達成                                                │
│  ・サンプル単位の補正（48kHz = 0.02ms精度）                                 │
│  ・48台以上のApple TVへの同時配信実績あり                                   │
│  ・C++実装、iOS/Androidクライアント有り                                     │
│                                                                             │
│  【我々が参考にすべき点】                                                   │
│  ・タイムスタンプ同期アルゴリズム                                           │
│  ・クロックドリフト補正方式                                                 │
│  ・パケットフォーマット設計                                                 │
│                                                                             │
│  【我々の独自機能】                                                         │
│  ・チャンネル分離（Snapcastは全デバイス同一音声）                           │
│  ・UWB位置検出による自動ルーティング                                        │
│  ・スマホネイティブ最適化                                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 SoundSeeder

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SoundSeeder                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  URL: https://soundseeder.com/                                              │
│  プラットフォーム: Android (ホスト/クライアント), Windows, Linux            │
│                                                                             │
│  【特徴】                                                                   │
│  ・デバイスごとに L/R/モノラル/ステレオを手動設定可能                       │
│  ・Wi-Fi経由でPCMストリーミング                                            │
│  ・最大16台同期                                                            │
│  ・遅延調整 ±400ms（10msステップ）                                         │
│                                                                             │
│  【我々との違い】                                                           │
│  ・Android限定（iOSクライアントなし）                                       │
│  ・位置検出機能なし（完全手動）                                             │
│  ・サラウンド対応は限定的                                                   │
│                                                                             │
│  【参考ポイント】                                                           │
│  ・チャンネル分離UIデザイン                                                 │
│  ・遅延キャリブレーション方法                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 AmpMe

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             AmpMe                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  プラットフォーム: iOS, Android                                             │
│                                                                             │
│  【概要】                                                                   │
│  複数のスマホやBluetoothスピーカーを同期させて同じ音楽を再生するアプリ。     │
│  Spotify, YouTube, SoundCloud, Apple Music などと連携可能。                 │
│                                                                             │
│  【同期技術（独自開発）】                                                   │
│  1. 音響フィンガープリント: 再生中の音を分析して同期ポイント検出            │
│  2. 超音波同期: 可聴域外の超音波を使用                                      │
│  3. ML予測: 機種別遅延を機械学習で予測                                      │
│                                                                             │
│  【実績】                                                                   │
│  ・22,000台以上の同時同期（ギネス記録挑戦）                                 │
│  ・600万ダウンロード以上                                                    │
│                                                                             │
│  【限界】                                                                   │
│  ・チャンネル分離非対応（全デバイス同一音声のみ）                           │
│  ・独立ストリーミング方式（各デバイスが個別に音源取得）                     │
│  ・ローカルネットワーク最適化なし                                           │
│                                                                             │
│  【我々との差別化ポイント】                                                 │
│  ・L/Rチャンネル分離 → AmpMeにはない機能                                   │
│  ・ローカルWi-Fi最適化 → 低遅延・安定性向上                                │
│  ・UWB位置検出 → 自動チャンネルルーティング                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. 技術スタック

### 6.1 音源キャプチャ

| プラットフォーム | 方式 | 制限 |
|------------------|------|------|
| **Android** | AudioPlaybackCapture API | Android 10+, MediaProjection必要 |
| **iOS** | アプリ内再生のみ | 他アプリ音声のキャプチャ不可 |

```kotlin
// Android: AudioPlaybackCapture
val config = AudioPlaybackCaptureConfiguration.Builder(mediaProjection)
    .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
    .build()

val audioRecord = AudioRecord.Builder()
    .setAudioPlaybackCaptureConfig(config)
    .setAudioFormat(AudioFormat.Builder()
        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
        .setSampleRate(48000)
        .setChannelMask(AudioFormat.CHANNEL_IN_STEREO)
        .build())
    .build()
```

### 6.2 低遅延オーディオ出力

**iOS: AVAudioEngine**
```swift
let session = AVAudioSession.sharedInstance()
try session.setPreferredIOBufferDuration(0.002) // 2ms = 96 samples
try session.setCategory(.playback, mode: .default)
// 実測遅延: 5-10ms (出力のみ)
```

**Android: AAudio**
```kotlin
AAudioStreamBuilder_setPerformanceMode(builder, AAUDIO_PERFORMANCE_MODE_LOW_LATENCY)
AAudioStreamBuilder_setSharingMode(builder, AAUDIO_SHARING_MODE_EXCLUSIVE)
// 対応デバイス (Pixel等): 10ms round-trip
// 非対応デバイス: 50-100ms以上
```

### 6.3 位置検出（Phase 2以降）

| 技術 | 精度 | スマホ間測距 | 対応率 |
|------|------|--------------|--------|
| **UWB** | 10-30cm | 可能 | 25-30% |
| Bluetooth RSSI | 2-5m | 不可 | 100% |
| 音響測位 | 1-2cm | 可能 | 100% |
| **手動割り当て** | 完璧 | - | 100% |

---

## 7. AWSバックエンド

### 7.1 アーキテクチャ概要

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       AWS バックエンドアーキテクチャ                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐                                                           │
│  │   Flutter   │                                                           │
│  │    App      │                                                           │
│  └──────┬──────┘                                                           │
│         │                                                                   │
│         │ HTTPS                                                            │
│         ▼                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Amazon API Gateway                            │   │
│  │                         (REST API)                                   │   │
│  └──────────────────────────────┬──────────────────────────────────────┘   │
│                                 │                                           │
│         ┌───────────────────────┼───────────────────────┐                  │
│         │                       │                       │                  │
│         ▼                       ▼                       ▼                  │
│  ┌─────────────┐         ┌─────────────┐         ┌─────────────┐          │
│  │   Lambda    │         │   Lambda    │         │   Lambda    │          │
│  │  Settings   │         │    ML       │         │  Analytics  │          │
│  │   CRUD      │         │ Inference   │         │  Collector  │          │
│  └──────┬──────┘         └──────┬──────┘         └──────┬──────┘          │
│         │                       │                       │                  │
│         ▼                       ▼                       ▼                  │
│  ┌─────────────┐         ┌─────────────┐         ┌─────────────┐          │
│  │  DynamoDB   │         │  SageMaker  │         │ CloudWatch  │          │
│  │  Settings   │         │  Endpoint   │         │    Logs     │          │
│  └─────────────┘         └─────────────┘         └─────────────┘          │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      Amazon Cognito                                  │   │
│  │            User Pool + Identity Pool (実装済み)                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 既存実装（Cognito認証）

現在、以下が Terraform で実装済み:

```
infrastructure/terraform/
├── cognito.tf          # User Pool, Identity Pool, IAM Roles
├── provider.tf         # AWS Provider (ap-northeast-1)
├── variables.tf        # 設定変数
└── outputs.tf          # 出力値
```

**Cognito 機能:**
- Email/Password 認証
- Google/Facebook/Apple ソーシャルログイン
- MFA (TOTP)
- パスワードリセット

### 7.3 ユーザー設定ストレージ (DynamoDB)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      DynamoDB テーブル設計                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  【UserSettings テーブル】                                                   │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ PK: userId (String)                                                  │  │
│  │ SK: settingType (String)                                            │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │ Attributes:                                                          │  │
│  │   - data: Map (設定内容)                                             │  │
│  │   - updatedAt: Number (Unix timestamp)                               │  │
│  │   - version: Number (楽観的ロック用)                                 │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  【settingType の種類】                                                     │
│  ├─ "profile"       : ユーザープロフィール                                 │
│  ├─ "audio"         : オーディオ設定（バッファサイズ、コーデック等）        │
│  ├─ "channel"       : チャンネル割り当て設定                               │
│  ├─ "devices"       : 登録デバイス一覧                                     │
│  └─ "preferences"   : UI設定、通知設定等                                   │
│                                                                             │
│  【DeviceProfiles テーブル】（ML用）                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ PK: deviceModel (String) - 例: "iPhone 15 Pro"                       │  │
│  │ SK: osVersion (String) - 例: "17.2"                                  │  │
│  ├──────────────────────────────────────────────────────────────────────┤  │
│  │ Attributes:                                                          │  │
│  │   - avgLatency: Number (平均遅延 ms)                                 │  │
│  │   - latencyStdDev: Number (標準偏差)                                 │  │
│  │   - sampleCount: Number (測定サンプル数)                             │  │
│  │   - btLatencyProfile: Map (Bluetoothコーデック別遅延)                │  │
│  │   - recommendedBuffer: Number (推奨バッファサイズ)                   │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.4 機械学習機能

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ML 機能設計                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  【1. デバイス遅延予測モデル】                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ 入力:                                                                │  │
│  │   - デバイスモデル (iPhone 15 Pro, Pixel 8, etc.)                   │  │
│  │   - OSバージョン                                                     │  │
│  │   - Bluetoothコーデック (aptX, AAC, SBC, etc.)                      │  │
│  │   - Wi-Fi信号強度                                                    │  │
│  │                                                                      │  │
│  │ 出力:                                                                │  │
│  │   - 予測遅延 (ms)                                                    │  │
│  │   - 推奨バッファサイズ (ms)                                          │  │
│  │   - 信頼度スコア (0-1)                                               │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  【2. 遅延キャリブレーション自動化】                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ - ユーザーの実測データを収集                                         │  │
│  │ - デバイスモデル別に集計                                             │  │
│  │ - 新規ユーザーに最適な初期値を提供                                   │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  【3. UWB位置補正（Phase 2以降）】                                          │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ - カルマンフィルタのパラメータ最適化                                 │  │
│  │ - 環境ごとの位置誤差補正                                             │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  【実装方式】                                                               │
│  ├─ Phase 1-2: Lambda + 統計的手法（平均、分散）                          │
│  └─ Phase 3以降: SageMaker エンドポイント（本格MLモデル）                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.5 API設計

```yaml
# API Gateway エンドポイント

# ユーザー設定
GET    /settings                    # 全設定取得
GET    /settings/{type}             # 特定タイプの設定取得
PUT    /settings/{type}             # 設定更新
DELETE /settings/{type}             # 設定削除

# デバイスプロファイル
GET    /devices/profile             # 現在のデバイスの推奨設定取得
POST   /devices/calibration         # キャリブレーション結果送信

# ML推論
POST   /ml/predict-latency          # 遅延予測
POST   /ml/optimize-buffer          # バッファサイズ最適化

# セッション管理
POST   /sessions                    # セッション作成
GET    /sessions/{id}               # セッション情報取得
PUT    /sessions/{id}               # セッション更新
DELETE /sessions/{id}               # セッション終了

# 分析・テレメトリ
POST   /analytics/event             # イベント送信（バッチ対応）
```

### 7.6 Terraform 追加リソース

```hcl
# infrastructure/terraform/dynamodb.tf

resource "aws_dynamodb_table" "user_settings" {
  name           = "${var.app_name}-${var.environment}-user-settings"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "userId"
  range_key      = "settingType"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "settingType"
    type = "S"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = var.environment == "prod"
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-user-settings"
  }
}

resource "aws_dynamodb_table" "device_profiles" {
  name           = "${var.app_name}-${var.environment}-device-profiles"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "deviceModel"
  range_key      = "osVersion"

  attribute {
    name = "deviceModel"
    type = "S"
  }

  attribute {
    name = "osVersion"
    type = "S"
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-device-profiles"
  }
}
```

```hcl
# infrastructure/terraform/api_gateway.tf

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.app_name}-${var.environment}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 86400
  }
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.mobile_client.id]
    issuer   = "https://${aws_cognito_user_pool.main.endpoint}"
  }
}
```

```hcl
# infrastructure/terraform/lambda.tf

resource "aws_lambda_function" "settings_handler" {
  filename         = data.archive_file.lambda_settings.output_path
  function_name    = "${var.app_name}-${var.environment}-settings"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.lambda_settings.output_base64sha256
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      SETTINGS_TABLE = aws_dynamodb_table.user_settings.name
      DEVICES_TABLE  = aws_dynamodb_table.device_profiles.name
    }
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-settings"
  }
}

resource "aws_lambda_function" "ml_inference" {
  filename         = data.archive_file.lambda_ml.output_path
  function_name    = "${var.app_name}-${var.environment}-ml-inference"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_ml.output_base64sha256
  timeout          = 60
  memory_size      = 512

  environment {
    variables = {
      DEVICES_TABLE = aws_dynamodb_table.device_profiles.name
      # SAGEMAKER_ENDPOINT = aws_sagemaker_endpoint.latency_predictor.name  # Phase 3以降
    }
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-ml-inference"
  }
}
```

### 7.7 Flutter API クライアント

```dart
// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify_flutter.dart';

class ApiService {
  static const String baseUrl = 'https://api.spatialsync.example.com';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String> _getAccessToken() async {
    final session = await Amplify.Auth.fetchAuthSession()
        as CognitoAuthSession;
    return session.userPoolTokensResult.value.accessToken.toJson();
  }

  /// ユーザー設定を取得
  Future<Map<String, dynamic>> getSettings() async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/settings'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  /// 設定を更新
  Future<void> updateSettings(String type, Map<String, dynamic> data) async {
    final token = await _getAccessToken();
    await http.put(
      Uri.parse('$baseUrl/settings/$type'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
  }

  /// デバイス遅延予測
  Future<LatencyPrediction> predictLatency({
    required String deviceModel,
    required String osVersion,
    String? bluetoothCodec,
  }) async {
    final token = await _getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/ml/predict-latency'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'deviceModel': deviceModel,
        'osVersion': osVersion,
        'bluetoothCodec': bluetoothCodec,
      }),
    );
    return LatencyPrediction.fromJson(jsonDecode(response.body));
  }

  /// キャリブレーション結果を送信
  Future<void> submitCalibration({
    required String deviceModel,
    required String osVersion,
    required double measuredLatency,
    String? bluetoothCodec,
  }) async {
    final token = await _getAccessToken();
    await http.post(
      Uri.parse('$baseUrl/devices/calibration'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'deviceModel': deviceModel,
        'osVersion': osVersion,
        'measuredLatency': measuredLatency,
        'bluetoothCodec': bluetoothCodec,
      }),
    );
  }
}

class LatencyPrediction {
  final double predictedLatency;
  final int recommendedBuffer;
  final double confidence;

  LatencyPrediction({
    required this.predictedLatency,
    required this.recommendedBuffer,
    required this.confidence,
  });

  factory LatencyPrediction.fromJson(Map<String, dynamic> json) {
    return LatencyPrediction(
      predictedLatency: json['predictedLatency'].toDouble(),
      recommendedBuffer: json['recommendedBuffer'],
      confidence: json['confidence'].toDouble(),
    );
  }
}
```

### 7.8 AWS サービス一覧

| サービス | 用途 | フェーズ |
|----------|------|----------|
| **Cognito** | ユーザー認証 | 実装済み |
| **API Gateway** | REST API | Phase 1 |
| **Lambda** | ビジネスロジック | Phase 1 |
| **DynamoDB** | ユーザー設定、デバイスプロファイル | Phase 1 |
| **CloudWatch** | ログ、メトリクス | Phase 1 |
| **S3** | オーディオファイル保存（オプション） | Phase 2 |
| **SageMaker** | 本格MLモデル | Phase 3 |
| **CloudFront** | CDN（オプション） | Phase 4 |

---

## 8. 開発フェーズ

### Phase 1: MVP（iOS限定、手動割り当て）

```
【目標】4-6週間
├─ iOS デバイス間での同期再生実証
├─ 手動 L/R チャンネル割り当て
├─ 100ms バッファで安定動作
├─ 同期精度 ±5ms
└─ AWSバックエンド基盤構築

【技術】
├─ Flutter (iOS only)
├─ AVAudioEngine
├─ WebSocket + UDP
├─ Opus コーデック
└─ AWS (API Gateway + Lambda + DynamoDB)

【成果物】
├─ ホストアプリ: ローカル音楽再生 + ストリーミング
├─ クライアントアプリ: 受信 + 同期再生
├─ 手動チャンネル割り当てUI
├─ ユーザー設定保存/復元機能
└─ デバイスプロファイル収集開始
```

### Phase 2: UWB位置検出

```
【目標】3-4週間
├─ UWB による自動位置検出 (iPhone 11以降)
├─ 位置に基づく L/R/C 自動割り当て
├─ リスナー移動時の動的チャンネル切り替え
└─ 非UWBデバイスは手動フォールバック

【技術】
├─ iOS Nearby Interaction Framework
└─ カルマンフィルタによる位置安定化
```

### Phase 3: Android対応

```
【目標】4-6週間
├─ Android クライアント対応
├─ Android ホスト: AudioPlaybackCapture
├─ AAudio による低遅延再生
└─ iOS/Android 混在環境

【技術】
├─ Android AudioPlaybackCapture API
├─ AAudio (MMAP Exclusive)
└─ androidx.core.uwb
```

### Phase 4: 最適化・5.1ch対応

```
【目標】4-6週間
├─ 50ms以下遅延達成（対応デバイス）
├─ 10台以上の同時接続
├─ 5.1ch サラウンド分離
└─ Bluetooth aptX LL 対応

【技術】
├─ デバイス別遅延プロファイル
├─ マルチキャスト配信
└─ 5.1ch→2.0ch ダウンミックス
```

---

## 9. プロジェクト構造

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── audio/
│   │   ├── audio_engine.dart          # オーディオ処理エンジン
│   │   ├── channel_splitter.dart      # チャンネル分離
│   │   ├── opus_codec.dart            # Opusエンコード/デコード
│   │   └── low_latency_player.dart    # 低遅延再生
│   │
│   ├── network/
│   │   ├── sync_protocol.dart         # 同期プロトコル
│   │   ├── audio_streamer.dart        # オーディオストリーミング
│   │   ├── time_sync.dart             # 時刻同期
│   │   └── discovery_service.dart     # デバイス発見
│   │
│   └── positioning/
│       ├── uwb_manager.dart           # UWB位置検出 (Phase 2)
│       └── channel_router.dart        # チャンネルルーティング
│
├── services/
│   ├── auth_service.dart              # Cognito認証 (実装済み)
│   ├── api_service.dart               # AWS API クライアント
│   └── settings_service.dart          # ユーザー設定管理
│
├── features/
│   ├── auth/                          # 認証画面 (実装済み)
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── ...
│   │
│   ├── host/
│   │   ├── host_screen.dart           # ホスト画面
│   │   ├── source_selector.dart       # 音源選択
│   │   └── device_manager.dart        # 接続デバイス管理
│   │
│   ├── client/
│   │   ├── client_screen.dart         # クライアント画面
│   │   └── speaker_output.dart        # スピーカー出力
│   │
│   └── setup/
│       ├── manual_assign_screen.dart  # 手動チャンネル割り当て
│       └── calibration_screen.dart    # 遅延キャリブレーション
│
└── models/
    ├── session.dart                   # セッションモデル
    ├── device_info.dart               # デバイス情報
    ├── channel_assignment.dart        # チャンネル割り当て
    └── user_settings.dart             # ユーザー設定モデル
```

---

## 10. 技術的リスクと対策

| リスク | 影響度 | 対策 |
|--------|--------|------|
| UWB対応デバイス限定 | 高 | 手動割り当てフォールバック (Phase 1で先行実装) |
| Android遅延ばらつき | 高 | デバイスホワイトリスト + 適応バッファ |
| iOS音源キャプチャ不可 | 中 | Android限定ホスト or アプリ内再生 |
| Wi-Fi品質による同期乱れ | 中 | 適応バッファ + エラー訂正 |
| Bluetooth遅延 | 中 | 内蔵スピーカー推奨 + aptX LL対応 |

---

## 11. 評価指標

### Phase 1 MVP
- [ ] 3台のiOSデバイスで安定した同期再生
- [ ] 手動L/R割り当てが正常動作
- [ ] 同期精度 ±5ms以内
- [ ] 1時間連続再生でドリフトなし
- [ ] AWS API Gateway + Lambda + DynamoDB デプロイ完了
- [ ] ユーザー設定の保存/復元が動作
- [ ] デバイスプロファイル収集が動作

### Phase 2 UWB
- [ ] UWBで位置検出・自動チャンネル割り当て動作
- [ ] リスナー移動時の滑らかなチャンネル切り替え
- [ ] 位置検出精度 50cm以内

### Phase 3 Android
- [ ] Android→iOS ストリーミング動作
- [ ] YouTube音声キャプチャ・配信成功
- [ ] Pixel デバイスで50ms以下遅延達成
- [ ] SageMaker エンドポイントでML推論動作
- [ ] 遅延予測精度 ±10ms以内

### Phase 4 最適化
- [ ] 10台同時接続で安定動作
- [ ] 5.1chソース分離再生
- [ ] 対応デバイスで30ms以下遅延達成

---

## 12. 参考リソース

| リソース | URL |
|----------|-----|
| Snapcast GitHub | https://github.com/badaix/snapcast |
| SoundSeeder | https://soundseeder.com/ |
| iOS Nearby Interaction | https://developer.apple.com/nearby-interaction/ |
| Android UWB Jetpack | https://developer.android.com/develop/connectivity/uwb |
| Android AudioPlaybackCapture | https://developer.android.com/media/platform/av-capture |
| iOS AVAudioEngine | https://developer.apple.com/documentation/avfaudio/avaudioengine |
| Opus Codec | https://opus-codec.org/ |
| AWS Cognito | https://docs.aws.amazon.com/cognito/ |
| AWS API Gateway | https://docs.aws.amazon.com/apigateway/ |
| AWS Lambda | https://docs.aws.amazon.com/lambda/ |
| AWS DynamoDB | https://docs.aws.amazon.com/dynamodb/ |
| AWS SageMaker | https://docs.aws.amazon.com/sagemaker/ |
| Terraform AWS Provider | https://registry.terraform.io/providers/hashicorp/aws/ |
| Amplify Flutter | https://docs.amplify.aws/flutter/ |

---

*Last Updated: 2024-12-24*
*Project: SpatialSync - Position-based Channel Separation Audio System*
