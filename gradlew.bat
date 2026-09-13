@echo off
where gradle >nul 2>nul
if %ERRORLEVEL% EQU 0 ( gradle %* ) else ( echo Gradle is not installed in PATH. Open this project in Android Studio and let Gradle Sync download Gradle 8.9. & exit /b 1 )
