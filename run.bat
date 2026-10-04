@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo  AI Content Quality ^& Semantic SEO Platform - Launcher
echo  Copyright (c) 2026 Bibas Gautam
echo ============================================================
echo.

REM --- Check Docker is installed and running ---
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker does not appear to be running.
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

REM --- Ensure .env exists ---
if not exist ".env" (
    if exist ".env.example" (
        echo [SETUP] No .env found - creating one from .env.example
        copy /Y ".env.example" ".env" >nul
        echo [SETUP] Edit .env and add your LLM_API_KEY before using LLM-backed endpoints.
        echo.
    ) else (
        echo [ERROR] .env.example not found. Run this script from the project root.
        pause
        exit /b 1
    )
)

REM --- Build images ---
echo [BUILD] Building Docker images - this can take a few minutes the first time...
docker compose build
if errorlevel 1 (
    echo [ERROR] Docker build failed. See output above.
    pause
    exit /b 1
)

REM --- Start the stack ---
echo [START] Starting all services in the background...
docker compose up -d
if errorlevel 1 (
    echo [ERROR] "docker compose up" failed. See output above.
    pause
    exit /b 1
)

REM --- Wait for backend health endpoint ---
echo [WAIT] Waiting for the backend API to become healthy...
set RETRIES=0

:waitloop
curl -s -o nul -w "%%{http_code}" http://localhost:8000/health > "%TEMP%\seo_health.txt" 2>nul
set /p HEALTHCODE=<"%TEMP%\seo_health.txt"
if "%HEALTHCODE%"=="200" goto healthy

set /a RETRIES+=1
if %RETRIES% GEQ 30 (
    echo [WARN] Backend did not report healthy within the timeout.
    echo        Check logs with: docker compose logs -f backend
    goto openbrowser
)
timeout /t 2 >nul
goto waitloop

:healthy
echo [OK] Backend is healthy.

:openbrowser
echo [OPEN] Opening the app in your browser...
start "" "http://localhost:3000"
start "" "http://localhost:8000/docs"

echo.
echo ============================================================
echo  Stack is running:
echo    Frontend:        http://localhost:3000
echo    Backend API:     http://localhost:8000/docs
echo    Elasticsearch:   http://localhost:9200
echo    Qdrant:          http://localhost:6333/dashboard
echo.
echo  Run stop.bat to shut everything down.
echo  Run "docker compose logs -f" in this folder to tail logs.
echo ============================================================
echo.
pause
endlocal
