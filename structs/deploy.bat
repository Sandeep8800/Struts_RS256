@echo off
REM Deploy script for TTS Dashboard

echo.
echo ===================================
echo TTS Dashboard - Deploy Script
echo ===================================
echo.

set WAR_FILE=target\tts-dashboard.war

REM Check if WAR file exists
if not exist "%WAR_FILE%" (
    echo ERROR: WAR file not found at %WAR_FILE%
    echo Please run build.bat first
    pause
    exit /b 1
)

REM Prompt for Tomcat path
set /p TOMCAT_PATH="Enter your Tomcat webapps path (e.g., C:\apache-tomcat\webapps): "

if not exist "%TOMCAT_PATH%" (
    echo ERROR: Path does not exist: %TOMCAT_PATH%
    pause
    exit /b 1
)

echo.
echo Copying WAR file to Tomcat...
copy "%WAR_FILE%" "%TOMCAT_PATH%\"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================
    echo Deployment completed successfully!
    echo ===================================
    echo.
    echo WAR deployed to: %TOMCAT_PATH%\tts-dashboard.war
    echo.
    echo Next steps:
    echo 1. Start/restart Tomcat
    echo 2. Wait for deployment to complete
    echo 3. Access: http://localhost:8080/tts-dashboard/dashboard
    echo.
) else (
    echo ERROR: Failed to copy WAR file
)

pause

