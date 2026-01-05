# HiFi Audio Platform

オーディオ機器データベース＆価格比較プラットフォーム。HiFi オーディオ機器の互換性チェックと複数ショップの最安価格を一括表示します。

```
┌─────────────────────────────────────────────────────────────┐
│                    HiFi Audio Platform                       │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌──────────┐ │
│  │ 機器DB    │  │ 互換性    │  │ 価格比較  │  │ レビュー │ │
│  │ 検索      │  │ チェック  │  │ 最安表示  │  │ 投稿     │ │
│  └───────────┘  └───────────┘  └───────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
           ┌────────────────┼────────────────┐
           ▼                ▼                ▼
     ┌──────────┐     ┌──────────┐     ┌──────────┐
     │  Amazon  │     │  楽天    │     │サウンド  │
     │          │     │          │     │ハウス    │
     └──────────┘     └──────────┘     └──────────┘
```

## Features

- **機器データベース**: スピーカー、アンプ、DAC等のスペック検索
- **互換性チェック**: インピーダンス・出力マッチングによる相性診断
- **価格比較**: 複数ショップの最安値を自動収集・表示
- **レビュー**: ユーザーによる機器レビュー・マイシステム公開
- **店舗情報**: 実店舗での視聴可能機器・地図連携

## Development Phases

| Phase | 内容 | 状態 |
|-------|------|------|
| **Phase 1** | MVP: 機器DB、互換性チェック、基本検索 | In Progress |
| Phase 2 | 価格比較、クローラー、キャッシュ | Planned |
| Phase 3 | ユーザー機能、レビュー、マイシステム | Planned |
| Phase 4 | 店舗・視聴情報、地図連携 | Planned |
| Phase 5 | 記事CMS、編集ワークフロー | Planned |

## Tech Stack

### Frontend
- **Next.js 14** (App Router) + TypeScript
- **Tailwind CSS** for styling
- **TanStack Query** for data fetching

### Backend
- **AWS Lambda** (Node.js)
- **API Gateway** (REST API)
- **Aurora PostgreSQL Serverless v2**

### Infrastructure
- **CloudFront + S3** for hosting
- **Cognito** for authentication
- **OpenSearch** for full-text search
- **Terraform** for IaC

## Requirements

- Node.js 20+
- pnpm
- AWS CLI (configured)
- Terraform 1.5+
- Docker (for local development)

## Quick Start

### 1. 開発環境のセットアップ

```bash
# Node.js (v20+)
nvm install 20
nvm use 20

# pnpm
npm install -g pnpm

# AWS CLI
brew install awscli
aws configure

# Terraform
brew install terraform

# Docker
brew install --cask docker
```

### 2. ローカル開発

```bash
# リポジトリクローン
git clone https://github.com/xxx/hifi-audio-platform
cd hifi-audio-platform

# フロントエンド
cd frontend
pnpm install
pnpm dev

# バックエンド（別ターミナル）
cd backend
pnpm install
pnpm dev

# ローカルDB
docker-compose up -d postgres
```

### 3. AWSインフラのデプロイ

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

## Project Structure

```
/hifi-audio-platform
├── frontend/                    # Next.js application
│   ├── src/
│   │   ├── app/                 # App Router pages
│   │   ├── components/          # React components
│   │   ├── hooks/               # Custom hooks
│   │   ├── lib/                 # Utilities
│   │   ├── services/            # API clients
│   │   └── types/               # TypeScript types
│   └── package.json
│
├── backend/                     # Lambda functions
│   ├── functions/
│   │   ├── equipment/           # Equipment CRUD
│   │   ├── price/               # Price crawler & API
│   │   ├── user/                # User management
│   │   └── shared/              # Common utilities
│   └── serverless.yml
│
├── infrastructure/              # Terraform
│   └── terraform/
│       ├── main.tf
│       ├── rds.tf
│       ├── lambda.tf
│       ├── cloudfront.tf
│       └── ...
│
├── scripts/                     # Utility scripts
└── docs/                        # Documentation
```

## Database Schema

主要テーブル:

| テーブル | 説明 |
|----------|------|
| `categories` | 機器カテゴリ（speaker, amplifier, dac等） |
| `brands` | オーディオブランド |
| `equipment` | 機器マスタ（スペックはJSONB） |
| `compatibility` | 機器間の互換性スコア |
| `shops` | オンライン/実店舗 |
| `prices` | 価格履歴（パーティション分割） |
| `user_profiles` | ユーザーアカウント |
| `user_systems` | マイシステム |
| `reviews` | レビュー |

## API Endpoints

```
# Equipment
GET    /api/equipment                 # 機器一覧（フィルタ・ページネーション）
GET    /api/equipment/:slug           # 機器詳細
GET    /api/equipment/:slug/prices    # 価格一覧
GET    /api/equipment/:slug/compatibility  # 互換性情報

# Search
GET    /api/search                    # 統合検索
POST   /api/search/compatibility      # 互換性検索

# Prices
GET    /api/prices/lowest/:id         # 最安値
GET    /api/prices/history/:id        # 価格履歴

# Users (authenticated)
GET    /api/users/me                  # プロファイル
GET    /api/systems                   # マイシステム一覧
POST   /api/reviews                   # レビュー投稿
```

## Commands

```bash
# Frontend
cd frontend
pnpm dev              # 開発サーバー起動
pnpm build            # 本番ビルド
pnpm lint             # ESLint
pnpm test             # テスト

# Backend
cd backend
pnpm dev              # Serverless offline
pnpm deploy           # AWS デプロイ
pnpm test             # テスト

# Terraform
cd infrastructure/terraform
terraform init        # 初期化
terraform plan        # プレビュー
terraform apply       # デプロイ

# Database
docker-compose up -d postgres   # ローカルDB起動
pnpm db:migrate                 # マイグレーション
pnpm db:seed                    # シードデータ
```

## Cost Estimates (Monthly)

| Phase | コスト |
|-------|--------|
| Phase 1 MVP | ~$60-110 |
| Phase 2-3 | ~$185 |
| Production | ~$400-550 |

## Documentation

- **CLAUDE.md** - Claude Code向けの開発ガイド
- **request.md** - 詳細技術仕様（DB設計、API設計、Terraform設定）

## License

MIT License
