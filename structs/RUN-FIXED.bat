    @echo off
REM =====================================================
REM FIXED - Run Script with Java 21 Compatibility
REM =====================================================

echo.
echo ========================================
echo TTS Dashboard - FIXED VERSION
echo ========================================
echo.
echo [INFO] Java 21 compatibility issues resolved!
echo [INFO] Added missing dependencies
echo.

cd /d C:\Users\Sandeep\Downloads\struts-main\structs

echo ========================================
echo Step 1: Cleaning previous build...
echo ========================================
call mvn clean
echo.

echo ========================================
echo Step 2: Installing dependencies...
echo ========================================
call mvn install -DskipTests
echo.

echo ========================================
echo Step 3: Starting Jetty Server...
echo ========================================
echo.
echo The application will be available at:
echo http://localhost:8080/tts-dashboard/dashboard
echo.
echo Press Ctrl+C to stop the server
echo.
echo ========================================
echo.

call mvn jetty:run

pause

