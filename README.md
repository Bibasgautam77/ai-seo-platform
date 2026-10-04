# AI Content Quality & Semantic SEO Platform

Content intelligence system for topic/entity coverage, search intent, content
gaps, internal linking, structured-data (schema.org) suggestions, and content
decay monitoring — with an editorial workflow for human review.

**Copyright (c) 2026 Bibas Gautam.** Licensed under the MIT License (see `LICENSE`).

## Core Features

| Feature | Description | Endpoint |
|---|---|---|
| Topic & Entity Extraction | Pulls named entities and topical clusters out of content using an LLM + vector similarity | `POST /api/v1/topics/extract` |
| Search Intent Classification | Classifies a page/query as informational, navigational, transactional, or commercial | `POST /api/v1/intent/classify` |
| Content Gap Detection | Compares your topic/entity coverage against a competitor set or SERP corpus | `POST /api/v1/gaps/analyze` |
| Internal Link Suggestions | Suggests contextual internal links using embedding similarity across your indexed content | `POST /api/v1/links/suggest` |
| Schema.org Suggestions | Recommends structured-data markup (Article, FAQ, HowTo, Product, etc.) per page | `POST /api/v1/schema/suggest` |
| Content Decay Monitoring | Tracks ranking/traffic drift over time and flags pages needing a refresh | `GET /api/v1/decay/report` |
| Editorial Workflow | Draft → In Review → Approved → Published states with assignment and comments | `/api/v1/review/*` |

## Architecture

```
┌─────────────┐      ┌──────────────┐      ┌──────────────────┐
│  Next.js UI │◄────►│   FastAPI    │◄────►│  PostgreSQL       │
│  (frontend) │      │   (backend)  │      │  (structured data)│
└─────────────┘      └──────┬───────┘      └──────────────────┘
                             │
              ┌──────────────┼───────────────┬────────────────┐
              ▼              ▼               ▼                ▼
        ┌───────────┐  ┌───────────┐  ┌─────────────┐  ┌────────────┐
        │Elasticsearch│ │ Vector DB │  │  Redis       │  │  LLM API   │
        │(full-text/  │ │ (Qdrant)  │  │ (cache/queue │  │ (Anthropic/│
        │ SERP index) │ │ embeddings│  │  + Celery)   │  │  OpenAI)   │
        └───────────┘  └───────────┘  └─────────────┘  └────────────┘
```

## Tech Stack

- **Frontend:** Next.js (App Router, TypeScript, Tailwind)
- **Backend:** FastAPI (Python 3.11), Celery workers
- **Database:** PostgreSQL (content, users, workflow state)
- **Search:** Elasticsearch (full-text + SERP/competitor corpus)
- **Vector DB:** Qdrant (topic/entity/content embeddings)
- **Cache/Queue:** Redis (Celery broker + result cache)
- **LLM:** Pluggable — Anthropic or OpenAI via `LLM_PROVIDER` env var
- **Infra:** Docker Compose

## Quick Start

Requirements: Docker Desktop (with Docker Compose).

### Windows

Double-click **`run.bat`** (or run it from a terminal). It will:
1. Verify Docker is running
2. Create `.env` from `.env.example` if missing
3. Build the images and start the full stack
4. Wait for the backend to become healthy
5. Open the frontend and API docs in your browser

To stop everything, double-click **`stop.bat`**.

### macOS / Linux

Requirements: Docker + Docker Compose, and `make`.

```bash
cp .env.example .env        # then fill in your LLM_API_KEY
make build                  # build all images
make up                     # start the full stack
```

Once running:

- Frontend: http://localhost:3000
- Backend API docs (Swagger): http://localhost:8000/docs
- Elasticsearch: http://localhost:9200
- Qdrant: http://localhost:6333/dashboard

Stop everything with `make down`, or `make down-v` to also wipe volumes.

## Common Make targets

```bash
make up            # docker compose up -d
make down           # docker compose down
make down-v         # docker compose down -v (wipes DB/ES/vector data)
make build          # rebuild images
make logs           # tail all service logs
make backend-shell  # shell into the backend container
make migrate        # run alembic migrations
make test           # run backend test suite
```

## Repository Layout

```
ai-seo-platform/
├── LICENSE
├── README.md
├── Makefile
├── docker-compose.yml
├── .env.example
├── backend/            # FastAPI service
│   ├── app/
│   │   ├── api/        # route handlers per feature
│   │   ├── core/       # config, db session, celery app
│   │   ├── models/     # pydantic + ORM schemas
│   │   └── services/   # business logic (extraction, intent, gaps, links, schema, decay)
│   └── requirements.txt
└── frontend/           # Next.js dashboard
    └── app/
```

## Notes

- The `services/` layer contains working reference implementations (keyword/entity
  extraction, cosine-similarity link suggestion, decay scoring) that call out to
  the LLM API for the parts that need language understanding, so you can run the
  whole pipeline end-to-end and then swap in your own models/prompts.
- Set `LLM_PROVIDER=anthropic` or `LLM_PROVIDER=openai` in `.env`, along with the
  matching API key, to enable the LLM-backed endpoints.
- `make migrate` / `make makemigration` assume Alembic is initialized in
  `backend/`. This scaffold ships without ORM tables yet (the editorial
  workflow uses an in-memory store as a placeholder), so run
  `docker compose exec backend alembic init migrations` the first time you
  add real SQLAlchemy models, before those targets will have anything to do.
