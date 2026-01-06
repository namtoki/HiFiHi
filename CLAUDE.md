# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**HiFi Audio Platform** - オーディオ機器データベース＆価格比較プラットフォーム

HiFi オーディオ機器のデータベース、互換性チェック、価格比較を提供するWebプラットフォーム。
トリバゴ的なアプローチで、複数ショップの最安価格を一括表示する。

### Current Phase: Phase 1 MVP

- 機器データベース（スピーカー、アンプ、DAC等）
- 組み合わせ互換性チェック
- 基本検索機能
- Next.js + Ruby on Rails + AWS アーキテクチャ

## Tech Stack

### Frontend
- **Next.js 14** (App Router) + TypeScript
- **Tailwind CSS** for styling
- **TanStack Query** for state management
- **CloudFront + S3** for hosting

### Backend
- **Ruby on Rails 8.0** (API mode)
- **Ruby 3.3**
- **PostgreSQL** (Aurora Serverless v2)
- **ECS Fargate** for container hosting
- **OpenSearch** for search (Phase 2+)
- **Cognito** for authentication (Phase 3+)

### Infrastructure
- **Terraform** for IaC
- **Docker** for containerization
- **ECR** for container registry
- **ALB** for load balancing
- **GitHub Actions** for CI/CD

## Development Environment

### Prerequisites

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

# Docker (required for backend development)
brew install --cask docker
# or using Colima
brew install colima
colima start
```

### Local Development

```bash
# Start all services (PostgreSQL, Redis, Backend)
docker-compose up -d

# Frontend only
cd frontend
pnpm install
pnpm dev

# Backend only (with Docker)
docker-compose up -d postgres
docker-compose up backend

# Run Rails console
docker-compose exec backend bundle exec rails console
```

## Common Commands

```bash
# Frontend (run from frontend/ directory)
pnpm dev              # Start dev server (http://localhost:3000)
pnpm build            # Production build
pnpm lint             # Run ESLint
pnpm test             # Run tests

# Backend (via Docker)
docker-compose up -d                          # Start all services
docker-compose exec backend rails db:migrate  # Run migrations
docker-compose exec backend rails db:seed     # Seed data
docker-compose exec backend rails console     # Rails console
docker-compose exec backend rspec             # Run tests
docker-compose logs -f backend                # View logs

# Terraform (run from infrastructure/terraform/)
terraform init        # Initialize
terraform plan        # Preview changes
terraform apply       # Deploy infrastructure

# Database
docker-compose up -d postgres   # Start local DB only
```

## Architecture

### Project Structure

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
├── backend/                     # Ruby on Rails API
│   ├── app/
│   │   ├── controllers/api/     # API controllers
│   │   ├── models/              # ActiveRecord models
│   │   └── serializers/         # JSON serializers
│   ├── config/
│   │   ├── routes.rb            # API routes
│   │   └── database.yml         # DB configuration
│   ├── db/
│   │   ├── migrate/             # Database migrations
│   │   └── seeds.rb             # Seed data
│   ├── Dockerfile               # Production container
│   └── Gemfile                  # Ruby dependencies
│
├── infrastructure/              # Terraform
│   └── terraform/
│       ├── main.tf
│       ├── rds.tf               # Aurora PostgreSQL
│       ├── ecs.tf               # ECS Fargate
│       ├── ecr.tf               # Container Registry
│       ├── alb.tf               # Load Balancer
│       ├── cloudfront.tf        # CDN
│       └── ...
│
└── docker-compose.yml           # Local development
```

### Database Schema (PostgreSQL via Rails Migrations)

Main tables:
- `categories` - Equipment categories (speaker, amplifier, dac, etc.)
- `brands` - Audio brands
- `equipment` - Equipment master with specs (JSONB)
- `compatibilities` - Equipment compatibility scores

Future tables (Phase 2+):
- `shops` - Online/physical shops
- `prices` - Price history
- `user_profiles` - User accounts
- `user_systems` - User equipment setups
- `reviews` - User reviews

### API Endpoints

```
# Categories
GET    /api/categories              # List all categories

# Brands
GET    /api/brands                  # List all brands
GET    /api/brands/:slug            # Brand detail

# Equipment
GET    /api/equipment               # List with filters
GET    /api/equipment/:slug         # Detail
GET    /api/equipment/:slug/compatibility  # Compatibility info

# Search
GET    /api/search                  # Full-text search
```

## Development Phases

| Phase | Goal | Status |
|-------|------|--------|
| **Phase 1** | MVP: Equipment DB, compatibility, basic search | In Progress |
| Phase 2 | Price comparison, crawlers, caching | Planned |
| Phase 3 | User accounts, reviews, my systems | Planned |
| Phase 4 | Shop/demo info, maps integration | Planned |
| Phase 5 | Articles/CMS, editorial workflow | Planned |

## Key Technical Details

### Equipment Specs (JSONB)

```ruby
# Speaker
{
  type: "floorstanding",
  impedanceOhm: 6,
  sensitivityDb: 88,
  frequencyHz: [39, 26000],
  powerWMin: 30,
  powerWMax: 150
}

# Amplifier
{
  type: "integrated",
  outputW8ohm: 60,
  outputW4ohm: 80,
  thdPercent: 0.02,
  inputTypes: ["RCA", "Optical"]
}
```

### Compatibility Calculation

Score 1-5 based on:
- Power matching (amp output vs speaker requirements)
- Impedance matching
- Source compatibility

### Rails API Conventions

- API-only mode (no views/assets)
- Kaminari for pagination
- CORS enabled for frontend
- JSON responses

## Reference Documentation

The `request.md` file contains detailed specifications:
- System architecture diagrams
- Complete database schema
- API design and response examples
- Terraform configurations
- Cost estimates per phase
- Evaluation metrics

## Cost Estimates (Monthly)

| Phase | Cost |
|-------|------|
| Phase 1 MVP | ~$80-130 |
| Phase 2-3 | ~$200 |
| Production | ~$450-600 |
