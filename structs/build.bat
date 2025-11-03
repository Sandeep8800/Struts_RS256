@echo off
REM Build script for TTS Dashboard

echo.
echo ===================================
echo TTS Dashboard - Build Script
echo ===================================
echo.

REM Check if Maven is installed
where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Maven is not installed or not in PATH
    echo Please install Maven and try again
    pause
    exit /b 1
)

echo [1/3] Cleaning previous build...
call mvn clean

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Clean failed
    pause
    exit /b 1
)

echo.
echo [2/3] Compiling sources...
call mvn compile

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Compilation failed
    pause
    exit /b 1
)

echo.
echo [3/3] Packaging WAR file...
call mvn package

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Packaging failed
    pause
    exit /b 1
)

echo.
echo ===================================
echo Build completed successfully!
echo ===================================
echo.
echo WAR file location: target\tts-dashboard.war
echo.
echo To deploy:
echo 1. Copy target\tts-dashboard.war to your Tomcat webapps folder
echo 2. Start/restart Tomcat
echo 3. Access: http://localhost:8080/tts-dashboard/dashboard
echo.
pause

