.PHONY: up down down-v build logs ps backend-shell frontend-shell migrate makemigration test seed

# Copyright (c) 2026 Bibas Gautam

up:
	docker compose up -d

down:
	docker compose down

down-v:
	docker compose down -v

build:
	docker compose build --no-cache

logs:
	docker compose logs -f

ps:
	docker compose ps

backend-shell:
	docker compose exec backend /bin/bash

frontend-shell:
	docker compose exec frontend /bin/sh

migrate:
	docker compose exec backend alembic upgrade head

makemigration:
	docker compose exec backend alembic revision --autogenerate -m "$(m)"

test:
	docker compose exec backend pytest -v

seed:
	docker compose exec backend python -m app.core.seed
