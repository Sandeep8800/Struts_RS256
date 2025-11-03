@echo off
REM =====================================================
REM TTS Dashboard - Run Script
REM This script rebuilds and prepares the application
REM =====================================================

echo.
echo ========================================
echo TTS Dashboard - Run Script
echo ========================================
echo.

REM Check if Maven is installed
where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Maven is not installed or not in PATH
    echo Please install Maven from https://maven.apache.org/download.cgi
    echo.
    pause
    exit /b 1
)

echo [INFO] Maven found!
echo.

REM Step 1: Clean previous build
echo ========================================
echo Step 1: Cleaning previous build...
echo ========================================
call mvn clean
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Clean failed
    pause
    exit /b 1
)
echo [SUCCESS] Clean completed
echo.

REM Step 2: Compile sources
echo ========================================
echo Step 2: Compiling sources...
echo ========================================
call mvn compile
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed
    pause
    exit /b 1
)
echo [SUCCESS] Compilation completed
echo.

REM Step 3: Package WAR file
echo ========================================
echo Step 3: Packaging WAR file...
echo ========================================
call mvn package
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Packaging failed
    pause
    exit /b 1
)
echo [SUCCESS] WAR file created at target\tts-dashboard.war
echo.

REM Display next steps
echo ========================================
echo BUILD COMPLETED SUCCESSFULLY!
echo ========================================
echo.
echo WAR file location: target\tts-dashboard.war
echo.
echo ========================================
echo NEXT STEPS TO RUN THE APPLICATION:
echo ========================================
echo.
echo Option 1: Deploy to Tomcat
echo   1. Run: deploy.bat
echo   2. Start Tomcat
echo   3. Access: http://localhost:8080/tts-dashboard/dashboard
echo.
echo Option 2: Use Maven Tomcat Plugin (if configured)
echo   Run: mvn tomcat7:run
echo.
echo Option 3: Manual Deployment
echo   1. Copy target\tts-dashboard.war to your Tomcat webapps folder
echo   2. Start/restart Tomcat
echo   3. Access: http://localhost:8080/tts-dashboard/dashboard
echo.
echo ========================================
echo IMPORTANT CONFIGURATION CHECKS:
echo ========================================
echo.
echo Before running, ensure:
echo   [✓] private_key.pem exists in src\main\resources\
echo   [✓] superset.properties is configured with:
echo       - superset.base.url (your Superset instance URL)
echo       - superset.dashboard.id (your dashboard UUID)
echo       - jwt.issuer and jwt.audience
echo   [✓] Superset is configured with the public key
echo   [✓] Superset has EMBEDDED_SUPERSET feature enabled
echo   [✓] CORS is enabled in Superset for your domain
echo.
echo ========================================
echo.
pause

