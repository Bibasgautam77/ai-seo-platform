@echo off
echo ============================================================
echo  Stopping AI Content Quality ^& Semantic SEO Platform
echo  Copyright (c) 2026 Bibas Gautam
echo ============================================================
echo.

docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker does not appear to be running.
    pause
    exit /b 1
)

echo [STOP] Stopping all containers...
docker compose down

echo.
echo Done. Data volumes were preserved.
echo To also wipe Postgres/Elasticsearch/Qdrant data, run:
echo    docker compose down -v
echo.
pause
