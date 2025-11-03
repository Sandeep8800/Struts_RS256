@echo off
REM =====================================================
REM TTS Dashboard - Quick Run with Jetty
REM This script runs the application using Maven Jetty plugin
REM =====================================================

echo.
echo ========================================
echo TTS Dashboard - Quick Run (Jetty)
echo ========================================
echo.

REM Check if Maven is installed
where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Maven is not installed or not in PATH
    echo Please install Maven from https://maven.apache.org/download.cgi
    pause
    exit /b 1
)

echo [INFO] Starting application with Jetty...
echo.
echo This will:
echo   1. Compile the project
echo   2. Start Jetty server on port 8080
echo   3. Deploy the application
echo.
echo Press Ctrl+C to stop the server
echo.
echo ========================================
echo.

REM Run with Jetty plugin
call mvn jetty:run

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Failed to start Jetty
    echo.
    echo If jetty plugin is not configured, use run.bat instead
    echo and deploy to Tomcat manually.
    pause
    exit /b 1
)

