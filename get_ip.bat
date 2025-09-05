@echo off
echo Finding your PC's IP address...
echo.
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    set ip=%%i
    setlocal enabledelayedexpansion
    set ip=!ip: =!
    echo Found IP: !ip!
    endlocal
)
echo.
echo Use one of these IP addresses in your Flutter app configuration
pause
