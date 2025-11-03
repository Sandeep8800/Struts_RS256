@echo off
REM Complete Setup Script for TTS Dashboard

echo.
echo ========================================
echo TTS Dashboard - Complete Setup Wizard
echo ========================================
echo.

REM Step 1: Check prerequisites
echo [Step 1/6] Checking prerequisites...
echo.

where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Maven is not installed or not in PATH
    echo Please install Maven from https://maven.apache.org/
    pause
    exit /b 1
)
echo   [OK] Maven found

where openssl >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] OpenSSL not found. You'll need to generate keys manually.
    set SKIP_KEYS=1
) else (
    echo   [OK] OpenSSL found
    set SKIP_KEYS=0
)

echo.
echo [Step 2/6] Generating RSA Key Pair...
echo.

if %SKIP_KEYS%==1 (
    echo [SKIPPED] OpenSSL not available
    echo Please generate keys manually:
    echo   openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
    echo   openssl rsa -pubout -in private_key.pem -out public_key.pem
    echo.
    set /p MANUAL_KEYS="Have you already generated the keys? (y/n): "
    if /i not "%MANUAL_KEYS%"=="y" (
        echo Setup cannot continue without keys.
        pause
        exit /b 1
    )
) else (
    if exist "private_key.pem" (
        echo   [SKIP] private_key.pem already exists
    ) else (
        echo Generating private key...
        openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
        if %ERRORLEVEL% NEQ 0 (
            echo [ERROR] Failed to generate private key
            pause
            exit /b 1
        )
        echo   [OK] Private key generated
    )

    if exist "public_key.pem" (
        echo   [SKIP] public_key.pem already exists
    ) else (
        echo Generating public key...
        openssl rsa -pubout -in private_key.pem -out public_key.pem
        if %ERRORLEVEL% NEQ 0 (
            echo [ERROR] Failed to generate public key
            pause
            exit /b 1
        )
        echo   [OK] Public key generated
    )
)

echo.
echo [Step 3/6] Copying private key to resources...
echo.

if not exist "src\main\resources\" (
    mkdir src\main\resources
)

copy /Y private_key.pem src\main\resources\private_key.pem >nul
if %ERRORLEVEL% EQU 0 (
    echo   [OK] Private key copied to resources
) else (
    echo [ERROR] Failed to copy private key
    pause
    exit /b 1
)

echo.
echo [Step 4/6] Configuration...
echo.

echo Please configure the following in src\main\resources\superset.properties:
echo   - superset.base.url (your Superset URL)
echo   - superset.dashboard.id (your dashboard UUID)
echo   - jwt.issuer (your application name)
echo.

set /p EDIT_CONFIG="Open superset.properties for editing? (y/n): "
if /i "%EDIT_CONFIG%"=="y" (
    notepad src\main\resources\superset.properties
)

echo.
echo [Step 5/6] Building project...
echo.

call mvn clean package
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed
    pause
    exit /b 1
)

echo.
echo [Step 6/6] Setup Summary
echo.

echo ========================================
echo Setup completed successfully!
echo ========================================
echo.
echo NEXT STEPS:
echo.
echo 1. Configure Superset with the public key:
echo    - Open: public_key.pem
echo    - Copy the content to your superset_config.py
echo    - Set GUEST_TOKEN_JWT_SECRET with the public key
echo    - Enable EMBEDDED_SUPERSET feature flag
echo.
echo 2. Deploy the application:
echo    - WAR file: target\tts-dashboard.war
echo    - Copy to Tomcat webapps folder
echo    - Or run: deploy.bat
echo.
echo 3. Access the application:
echo    - URL: http://localhost:8080/tts-dashboard/dashboard
echo.
echo ========================================
echo.

if exist "public_key.pem" (
    set /p SHOW_KEY="Show public key now? (y/n): "
    if /i "%SHOW_KEY%"=="y" (
        echo.
        echo PUBLIC KEY (copy this to Superset):
        echo ========================================
        type public_key.pem
        echo ========================================
    )
)

echo.
pause

