# HiFi Audio Platform

Audio equipment database & price comparison platform. Check compatibility of HiFi audio equipment and display the lowest prices from multiple shops at a glance.

```
┌─────────────────────────────────────────────────────────────┐
│                    HiFi Audio Platform                      │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌──────────┐  │
│  │ Equipment │  │ Compati-  │  │   Price   │  │  Review  │  │
│  │ Database  │  │  bility   │  │Comparison │  │  Posts   │  │
│  └───────────┘  └───────────┘  └───────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
           ┌────────────────┼────────────────┐
           ▼                ▼                ▼
     ┌──────────┐     ┌──────────┐     ┌──────────┐
     │  Amazon  │     │ Rakuten  │     │  Sound   │
     │          │     │          │     │  House   │
     └──────────┘     └──────────┘     └──────────┘
```

## Features

- **Equipment Database**: Search specs for speakers, amplifiers, DACs, etc.
- **Compatibility Check**: Compatibility diagnosis based on impedance and output matching
- **Price Comparison**: Automatically collect and display lowest prices from multiple shops
- **Reviews**: User equipment reviews and my-system sharing
- **Shop Info**: Audition-available equipment at physical stores with map integration

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
- **Ruby on Rails 8.0** (API mode)
- **Ruby 3.3**
- **PostgreSQL** (Aurora Serverless v2)
- **ECS Fargate** for container hosting

### Infrastructure
- **CloudFront + S3** for frontend hosting
- **ALB** for API load balancing
- **ECR** for container registry
- **Cognito** for authentication (Phase 3+)
- **OpenSearch** for full-text search (Phase 2+)
- **Terraform** for IaC

## AWS Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                      AWS Cloud                                      │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │                              Route 53 (DNS)                                 │    │
│  └────────────────────────────────────┬────────────────────────────────────────┘    │
│                                       │                                             │
│                                       ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │                        CloudFront (CDN)                                     │    │
│  │                    ┌───────────────┴───────────────┐                        │    │
│  │                    │                               │                        │    │
│  └────────────────────┼───────────────────────────────┼────────────────────────┘    │
│                       │                               │                             │
│                       ▼                               ▼                             │
│  ┌────────────────────────────┐      ┌────────────────────────────────────────┐     │
│  │         S3 Bucket          │      │              VPC                       │     │
│  │  ┌──────────────────────┐  │      │  ┌──────────────────────────────────┐  │     │
│  │  │  Frontend (Next.js)  │  │      │  │         Public Subnets           │  │     │
│  │  │  - Static Assets     │  │      │  │  ┌────────────────────────────┐  │  │     │
│  │  │  - SSG Pages         │  │      │  │  │    ALB (Load Balancer)     │  │  │     │
│  │  └──────────────────────┘  │      │  │  │    - HTTPS Termination     │  │  │     │
│  └────────────────────────────┘      │  │  │    - Health Checks         │  │  │     │
│                                      │  │  └────────────┬───────────────┘  │  │     │
│                                      │  └───────────────┼──────────────────┘  │     │
│                                      │                  │                     │     │
│                                      │  ┌───────────────┼──────────────────┐  │     │
│                                      │  │         Private Subnets          │  │     │
│                                      │  │               │                  │  │     │
│                                      │  │               ▼                  │  │     │
│                                      │  │  ┌────────────────────────────┐  │  │     │
│                                      │  │  │     ECS Fargate Cluster    │  │  │     │
│                                      │  │  │  ┌──────────────────────┐  │  │  │     │
│                                      │  │  │  │  Backend (Rails API) │  │  │  │     │
│                                      │  │  │  │  - Ruby 3.3          │  │  │  │     │
│                                      │  │  │  │  - Rails 8.0         │  │  │  │     │
│                                      │  │  │  │  - Puma              │  │  │  │     │
│                                      │  │  │  └──────────────────────┘  │  │  │     │
│                                      │  │  └─────────────┬──────────────┘  │  │     │
│                                      │  │                │                 │  │     │
│                                      │  │                ▼                 │  │     │
│                                      │  │  ┌────────────────────────────┐  │  │     │
│                                      │  │  │  Aurora PostgreSQL         │  │  │     │
│                                      │  │  │  Serverless v2             │  │  │     │
│                                      │  │  │  - 機器データ              │  │  │     │
│                                      │  │  │  - 価格履歴                │  │  │     │
│                                      │  │  │  - ユーザー情報            │  │  │     │
│                                      │  │  └────────────────────────────┘  │  │     │
│                                      │  └──────────────────────────────────┘  │     │
│                                      └────────────────────────────────────────┘     │
│                                                                                     │
│  ┌──────────────────────────────────────────────────────────────────────────────┐   │
│  │                          Supporting Services                                 │   │
│  │                                                                              │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │   │
│  │  │     ECR     │  │   Cognito   │  │ OpenSearch  │  │    ElastiCache      │  │   │
│  │  │  Container  │  │    User     │  │   Search    │  │      (Redis)        │  │   │
│  │  │  Registry   │  │    Pool     │  │   Engine    │  │   Price Cache       │  │   │
│  │  │             │  │  (Phase 3+) │  │  (Phase 2+) │  │    (Phase 2+)       │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────────┘  │   │
│  │                                                                              │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │   │
│  │  │ EventBridge │  │     SQS     │  │   Lambda    │  │    CloudWatch       │  │   │
│  │  │  Scheduler  │  │   Queue     │  │  Crawlers   │  │   Logs/Metrics      │  │   │
│  │  │  (Phase 2+) │  │  (Phase 2+) │  │  (Phase 2+) │  │                     │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘

                                       │
                                       │ Price Data
                                       ▼
                    ┌──────────────────────────────────────┐
                    │          External APIs               │
                    │  ┌────────┐ ┌────────┐ ┌──────────┐  │
                    │  │ Amazon │ │ 楽天   │ │サウンド  │  │
                    │  │  API   │ │  API   │ │ハウス等  │  │
                    │  └────────┘ └────────┘ └──────────┘  │
                    └──────────────────────────────────────┘
```

### Component Summary

| Layer | Component | AWS Service | Phase |
|-------|-----------|-------------|-------|
| **CDN** | 静的配信・キャッシュ | CloudFront | 1 |
| **DNS** | ドメイン管理 | Route 53 | 1 |
| **Frontend** | Next.js アプリ | S3 | 1 |
| **Load Balancer** | API ルーティング | ALB | 1 |
| **Backend** | Rails API | ECS Fargate | 1 |
| **Container Registry** | Docker イメージ | ECR | 1 |
| **Database** | メインDB | Aurora PostgreSQL Serverless v2 | 1 |
| **Search** | 全文検索 | OpenSearch | 2 |
| **Cache** | 価格キャッシュ | ElastiCache (Redis) | 2 |
| **Scheduler** | 定期実行 | EventBridge | 2 |
| **Queue** | ジョブ管理 | SQS | 2 |
| **Crawler** | 価格収集 | Lambda | 2 |
| **Auth** | ユーザー認証 | Cognito | 3 |
| **Monitoring** | ログ・メトリクス | CloudWatch | 1 |

## Requirements

- Node.js 20+
- pnpm
- Docker (Colima or Docker Desktop)
- AWS CLI (configured)
- Terraform 1.5+

## Quick Start

### 1. 開発環境のセットアップ

```bash
# devbox shell で必要なツールが全て揃います
# (Node.js 20, pnpm, Terraform, AWS CLI, Colima, Docker Compose)
devbox shell

# AWS認証情報の設定（初回のみ）
aws configure
```

### 2. ローカル開発

```bash
# Backend
docker-compose up -d

# Frontend
cd frontend
pnpm install
pnpm dev
```

### 3. データベースセットアップ

```bash
# マイグレーション実行
docker-compose exec backend rails db:migrate

# シードデータ投入
docker-compose exec backend rails db:seed
```

### 4. AWSインフラのデプロイ

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

## Database Schema

主要テーブル (Phase 1):

| テーブル | 説明 |
|----------|------|
| `categories` | 機器カテゴリ（speaker, amplifier, dac等） |
| `brands` | オーディオブランド |
| `equipment` | 機器マスタ（スペックはJSONB） |
| `compatibilities` | 機器間の互換性スコア |

将来追加 (Phase 2+):

| テーブル | 説明 |
|----------|------|
| `shops` | オンライン/実店舗 |
| `prices` | 価格履歴 |
| `user_profiles` | ユーザーアカウント |
| `user_systems` | マイシステム |
| `reviews` | レビュー |

## API Endpoints

```
# Categories
GET    /api/categories              # カテゴリ一覧

# Brands
GET    /api/brands                  # ブランド一覧
GET    /api/brands/:slug            # ブランド詳細

# Equipment
GET    /api/equipment               # 機器一覧（フィルタ・ページネーション）
GET    /api/equipment/:slug         # 機器詳細
GET    /api/equipment/:slug/compatibility  # 互換性情報

# Search
GET    /api/search                  # 統合検索
```

## Commands

```bash
# Frontend (frontend/ ディレクトリで実行)
pnpm dev              # 開発サーバー起動 (localhost:3000)
pnpm build            # 本番ビルド
pnpm lint             # ESLint
pnpm test             # テスト

# Backend (Docker経由)
docker-compose up -d                          # 全サービス起動
docker-compose exec backend rails db:migrate  # マイグレーション
docker-compose exec backend rails db:seed     # シードデータ
docker-compose exec backend rails console     # Railsコンソール
docker-compose exec backend rspec             # テスト
docker-compose logs -f backend                # ログ確認

# Terraform (infrastructure/terraform/ ディレクトリで実行)
terraform init        # 初期化
terraform plan        # プレビュー
terraform apply       # デプロイ
```

## Cost Estimates (Monthly)

| Phase | コスト |
|-------|--------|
| Phase 1 MVP | ~$80-130 |
| Phase 2-3 | ~$200 |
| Production | ~$450-600 |

## Documentation

- **CLAUDE.md** - Claude Code向けの開発ガイド
- **request.md** - 詳細技術仕様（DB設計、API設計、Terraform設定）

## License

MIT License
