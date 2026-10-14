@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Extract-Version-Zips.ps1"
if errorlevel 1 (
    echo.
    echo The extraction script failed. Check the message above.
    pause
    exit /b 1
)
exit /b 0
